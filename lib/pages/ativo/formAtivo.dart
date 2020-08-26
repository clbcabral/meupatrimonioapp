import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:meupatrimonio/models/ativo.dart';
import 'package:meupatrimonio/models/reserva.dart';
import 'package:meupatrimonio/services/bancoLocal.dart';
import 'package:meupatrimonio/services/yahooFinance.dart';
import 'package:meupatrimonio/shared/componentes.dart';
import 'package:meupatrimonio/vals/strings.dart';
import 'package:uuid/uuid.dart';

class AtivoForm extends StatefulWidget {
  final Ativo ativo;
  final Function callback;
  AtivoForm({Key key, this.ativo, this.callback}) : super(key: key);

  @override
  AtivoFormState createState() => AtivoFormState();
}

class AtivoFormState extends State<AtivoForm> {
  final _chave = GlobalKey<FormState>();
  final _tickerController = TextEditingController();
  final _quantidadeController = TextEditingController();
  String _ticker;
  String _quantidade;
  double _nota;
  String _tipo;
  bool _carregando = false;

  @override
  void initState() {
    super.initState();
    _ticker = widget.ativo.ticker;
    _quantidade = widget.ativo.quantidade.toString();
    _nota = widget.ativo.quantidade;
    _tipo = widget.ativo.tipo;
  }

  @override
  Widget build(BuildContext context) {
    bool ehEdicao = widget.ativo.id.isNotEmpty;
    return Scaffold(
        appBar: AppBar(
          title: Text(ehEdicao ? Strings.editarItem : Strings.adicionarItem),
          actions: ehEdicao
              ? <Widget>[
                  IconButton(
                    icon: Icon(Icons.delete),
                    onPressed: () async {
                      bool confirmou = await showDialog(
                            context: context,
                            builder: (BuildContext context) =>
                                Alerta(Strings.avisoRemover),
                          ) ??
                          false;
                      if (confirmou) {
                        await ServicoBancoLocal().removerAtivo(widget.ativo);
                        widget.callback();
                        Navigator.pop(context);
                      }
                    },
                  ),
                ]
              : null,
        ),
        body: corpo(ehEdicao));
  }

  Widget corpo(bool ehEdicao) {
    return (_carregando == true)
        ? Container(
            padding: EdgeInsets.all(25),
            child: Center(
              child: CircularProgressIndicator(),
            ),
          )
        : Form(
            key: _chave,
            autovalidate: true,
            child: ListView(
              padding: EdgeInsets.symmetric(
                vertical: 20.0,
                horizontal: 30.0,
              ),
              children: [
                SizedBox(height: 10.0),
                TextFormField(
                  controller: _tickerController,
                  validator: (val) {
                    if (val.isEmpty) {
                      return Strings.validacaoNome;
                    }
                    return null;
                  },
                  decoration: InputDecoration(
                    labelText: 'Ticker',
                    hintText: 'ex: ITSA3.SA',
                  ),
                  textCapitalization: TextCapitalization.characters,
                  onChanged: (val) {
                    setState(() => _ticker = val);
                  },
                ),
                SizedBox(height: 10.0),
                TextFormField(
                  controller: _quantidadeController,
                  validator: (val) {
                    if (val.isEmpty) {
                      return Strings.validacaoValor;
                    }
                    return null;
                  },
                  decoration: InputDecoration(
                    labelText: 'Quantidade',
                  ),
                  keyboardType: TextInputType.numberWithOptions(decimal: false),
                  inputFormatters: [
                    FilteringTextInputFormatter.deny(
                        new RegExp('[\\-|\\ |\\,|\\.]'))
                  ],
                  onChanged: (val) {
                    setState(() => _quantidade = val);
                  },
                ),
                SizedBox(height: 10.0),
                Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Peso',
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                    )),
                Slider(
                  value: _nota,
                  min: 0,
                  max: 10,
                  divisions: 10,
                  label: _nota.round().toString(),
                  onChanged: (double value) {
                    setState(() {
                      _nota = value;
                    });
                  },
                ),
                SizedBox(height: 10.0),
                RaisedButton(
                  color: Theme.of(context).primaryColor,
                  child: Text(
                    ehEdicao ? Strings.salvar : Strings.adicionar,
                    style: TextStyle(color: Colors.white),
                  ),
                  onPressed: () async {
                    if (!_chave.currentState.validate()) {
                      return;
                    }
                    setState(() {
                      _carregando = true;
                    });
                    var response =
                        await ServicoYahooFinance().getTickersInfo([_ticker]);
                    List resultado = response['quoteResponse']['result'];
                    if (resultado != null && resultado.isNotEmpty) {
                      var dados = resultado[0];
                      Ativo ativo = Ativo(
                          id: widget.ativo.id.isNotEmpty
                              ? widget.ativo.id
                              : Uuid().v1(),
                          nome: dados['longName'],
                          cotacao: dados['bid'],
                          quantidade: double.parse(_quantidade),
                          nota: _nota,
                          tipo: _tipo);
                      ehEdicao
                          ? await ServicoBancoLocal().atualizarAtivo(ativo)
                          : await ServicoBancoLocal().adicionarAtivo(ativo);
                      Navigator.pop(context);
                      widget.callback();
                    } else {}
                    setState(() {
                      _carregando = false;
                    });
                  },
                ),
              ],
            ),
          );
  }
}
