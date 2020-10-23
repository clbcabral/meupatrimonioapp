import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:meupatrimonio/models/ativo.dart';
import 'package:meupatrimonio/services/bdRemoto.dart';
import 'package:meupatrimonio/services/yahooFinance.dart';
import 'package:meupatrimonio/shared/componentes.dart';
import 'package:meupatrimonio/vals/constantes.dart';
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
  final _chaveScaffold = GlobalKey<ScaffoldState>();
  final _chaveForm = GlobalKey<FormState>();
  final _tickerController = TextEditingController();
  final _nomeController = TextEditingController();
  final _valorController = TextEditingController();
  final _quantidadeController = TextEditingController();
  String _nome;
  String _ticker;
  String _quantidade;
  String _valor;
  double _peso;
  String _tipo;
  bool _carregando = false;

  @override
  void initState() {
    super.initState();
    _nome = widget.ativo.nome;
    _ticker = widget.ativo.ticker;
    _quantidade = widget.ativo.quantidade.toString();
    _valor = widget.ativo.cotacao.toString();
    _peso = widget.ativo.peso;
    _tipo = widget.ativo.tipo;
    _tickerController.text = widget.ativo.ticker;
    _nomeController.text = widget.ativo.nome;
    _valorController.text = widget.ativo.cotacao.toString();
    _quantidadeController.text = widget.ativo.quantidade.toString();
  }

  @override
  Widget build(BuildContext context) {
    bool ehEdicao = widget.ativo.id.isNotEmpty;
    return Scaffold(
        key: _chaveScaffold,
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
                        await ServicoBancoRemoto(widget.ativo.uid)
                            .removerAtivo(widget.ativo);
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
            key: _chaveForm,
            autovalidate: true,
            child: ListView(
                padding: EdgeInsets.symmetric(
                  vertical: 20.0,
                  horizontal: 30.0,
                ),
                children: ATIVO_RF == widget.ativo.tipo
                    ? corpoAtivoRF(ehEdicao)
                    : corpoAtivoRV(ehEdicao)));
  }

  List<Widget> corpoAtivoRV(bool ehEdicao) {
    return [
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
          labelText: Strings.ticker,
          hintText: getTickerHint(),
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
          labelText: Strings.quantidade,
        ),
        keyboardType: TextInputType.numberWithOptions(decimal: false),
        inputFormatters: [
          FilteringTextInputFormatter.deny(new RegExp('[\\-|\\ |\\,]'))
        ],
        onChanged: (val) {
          setState(() => _quantidade = val);
        },
      ),
      SizedBox(height: 10.0),
      Align(
          alignment: Alignment.centerLeft,
          child: Text(
            Strings.peso,
            style: TextStyle(fontSize: 16, color: Colors.grey),
          )),
      Slider(
        value: _peso,
        min: 0,
        max: 10,
        divisions: 10,
        label: _peso.round().toString(),
        onChanged: (double value) {
          setState(() {
            _peso = value;
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
        onPressed: () => salvarAtivoRV(ehEdicao),
      ),
    ];
  }

  List<Widget> corpoAtivoRF(bool ehEdicao) {
    return [
      SizedBox(height: 10.0),
      TextFormField(
        controller: _nomeController,
        validator: (val) {
          if (val.isEmpty) {
            return Strings.validacaoNome;
          }
          return null;
        },
        decoration: InputDecoration(
          labelText: Strings.descricao,
          hintText: Strings.dicaTesouro,
        ),
        textCapitalization: TextCapitalization.sentences,
        onChanged: (val) {
          setState(() => _nome = val);
        },
      ),
      SizedBox(height: 10.0),
      TextFormField(
        controller: _quantidadeController,
        validator: (val) {
          if (val.isEmpty) {
            return Strings.validacaoValor;
          }
          if (val.indexOf('.') != val.lastIndexOf('.')) {
            return Strings.validacaoPontos;
          }
          return null;
        },
        decoration: InputDecoration(
          labelText: Strings.quantidade,
        ),
        keyboardType: TextInputType.numberWithOptions(decimal: false),
        inputFormatters: [
          FilteringTextInputFormatter.deny(new RegExp('[\\-|\\ |\\,]'))
        ],
        onChanged: (val) {
          setState(() => _quantidade = val);
        },
      ),
      SizedBox(height: 10.0),
      TextFormField(
        controller: _valorController,
        validator: (val) {
          if (val.isEmpty) {
            return Strings.validacaoValor;
          }
          if (val.indexOf('.') != val.lastIndexOf('.')) {
            return Strings.validacaoPontos;
          }
          return null;
        },
        decoration: InputDecoration(
          labelText: Strings.valor,
        ),
        keyboardType: TextInputType.numberWithOptions(decimal: true),
        inputFormatters: [
          FilteringTextInputFormatter.deny(new RegExp('[\\-|\\ |\\,]'))
        ],
        onChanged: (val) {
          setState(() => _valor = val);
        },
      ),
      SizedBox(height: 10.0),
      Align(
          alignment: Alignment.centerLeft,
          child: Text(
            Strings.peso,
            style: TextStyle(fontSize: 16, color: Colors.grey),
          )),
      Slider(
        value: _peso,
        min: 0,
        max: 10,
        divisions: 10,
        label: _peso.round().toString(),
        onChanged: (double value) {
          setState(() {
            _peso = value;
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
        onPressed: () => salvarAtivoRF(ehEdicao),
      ),
    ];
  }

  String getTickerHint() {
    String hint = '';
    switch (_tipo) {
      case ATIVO_ACAO:
        hint = 'ex: ITUB3.SA';
        break;
      case ATIVO_FII:
        hint = 'ex: HGBS11.SA';
        break;
      case ATIVO_STOCK:
        hint = 'ex: AAPL';
        break;
      case ATIVO_REIT:
        hint = 'ex: AMT';
        break;
    }
    return hint;
  }

  void salvarAtivoRV(bool ehEdicao) async {
    if (!_chaveForm.currentState.validate()) {
      return;
    }
    setState(() {
      _carregando = true;
    });
    var tickers =
        widget.ativo.ehAtivoDolarizado() ? [_ticker, DOLAR_TICKER] : [_ticker];
    var response = await ServicoYahooFinance().getTickersInfo(tickers);
    var resultado = response['quoteResponse']['result'];
    if (resultado == null ||
        resultado.isEmpty ||
        resultado[0]['quoteType'] != 'EQUITY') {
      SnackBar snack = SnackBar(
        content: Text(Strings.tickerInvalido),
      );
      _chaveScaffold.currentState.showSnackBar(snack);
    } else {
      Map dados = resultado[0];
      double dolar = widget.ativo.ehAtivoDolarizado()
          ? resultado[1]['regularMarketPrice']
          : 1;
      Ativo ativo = Ativo(
          id: widget.ativo.id.isNotEmpty ? widget.ativo.id : Uuid().v1(),
          nome: dados['longName'],
          cotacao: dados['regularMarketPrice'] * dolar,
          quantidade: double.parse(_quantidade),
          ticker: _ticker,
          peso: _peso,
          uid: widget.ativo.uid,
          tipo: _tipo);
      ehEdicao
          ? await ServicoBancoRemoto(widget.ativo.uid).atualizarAtivo(ativo)
          : await ServicoBancoRemoto(widget.ativo.uid).adicionarAtivo(ativo);
      Navigator.pop(context);
      widget.callback();
    }
    setState(() {
      _carregando = false;
    });
  }

  void salvarAtivoRF(bool ehEdicao) async {
    if (!_chaveForm.currentState.validate()) {
      return;
    }
    setState(() {
      _carregando = true;
    });
    Ativo ativo = Ativo(
        id: widget.ativo.id.isNotEmpty ? widget.ativo.id : Uuid().v1(),
        nome: _nome,
        cotacao: double.parse(_valor),
        quantidade: double.parse(_quantidade),
        ticker: null,
        peso: _peso,
        uid: widget.ativo.uid,
        tipo: _tipo);
    ehEdicao
        ? await ServicoBancoRemoto(widget.ativo.uid).atualizarAtivo(ativo)
        : await ServicoBancoRemoto(widget.ativo.uid).adicionarAtivo(ativo);
    Navigator.pop(context);
    widget.callback();
    setState(() {
      _carregando = false;
    });
  }
}
