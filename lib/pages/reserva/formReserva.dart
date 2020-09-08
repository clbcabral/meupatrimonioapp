import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:meupatrimonio/models/reserva.dart';
import 'package:meupatrimonio/services/bdLocal.dart';
import 'package:meupatrimonio/services/sicronizador.dart';
import 'package:meupatrimonio/shared/componentes.dart';
import 'package:meupatrimonio/vals/strings.dart';
import 'package:uuid/uuid.dart';

class ReservaForm extends StatefulWidget {
  final Reserva reserva;
  final Function callback;
  ReservaForm({Key key, this.reserva, this.callback}) : super(key: key);

  @override
  ReservaFormState createState() => ReservaFormState();
}

class ReservaFormState extends State<ReservaForm> {
  final _formKey = GlobalKey<FormState>();
  final _nomeController = TextEditingController();
  final _valorController = TextEditingController();
  String _nome;
  String _valor;
  String _tipo;

  @override
  void initState() {
    super.initState();
    _nome = widget.reserva.nome;
    _valor = widget.reserva.valor.toString();
    _tipo = widget.reserva.tipo;
    _nomeController.text = widget.reserva.nome;
    _valorController.text = widget.reserva.valor.toString();
  }

  @override
  void dispose() {
    ServicoSincronizador(widget.reserva.uid).sincronizarReservas();
    super.dispose();
  }

  Widget corpo(bool ehEdicao) {
    return Form(
      key: _formKey,
      autovalidate: true,
      child: ListView(
        padding: EdgeInsets.symmetric(
          vertical: 20.0,
          horizontal: 30.0,
        ),
        children: [
          SizedBox(height: 10.0),
          TextFormField(
            controller: _nomeController,
            validator: (val) {
              if (val.isEmpty || val.trim().isEmpty) {
                return Strings.validacaoNome;
              }
              return null;
            },
            decoration: InputDecoration(
              labelText: Strings.descricao,
            ),
            textCapitalization: TextCapitalization.words,
            onChanged: (val) {
              setState(() => _nome = val);
            },
          ),
          SizedBox(height: 10.0),
          TextFormField(
            controller: _valorController,
            validator: (val) {
              if (val.isEmpty) {
                return Strings.validacaoValor;
              }
              if (val.indexOf('.') > 0 && val.split('.')[1].length > 2) {
                return Strings.validacaoCasasDecimais;
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
          RaisedButton(
            color: Theme.of(context).primaryColor,
            child: Text(
              ehEdicao ? Strings.salvar : Strings.adicionar,
              style: TextStyle(color: Colors.white),
            ),
            onPressed: () async {
              if (_formKey.currentState.validate()) {
                Reserva reserva = Reserva(
                    id: widget.reserva.id.isNotEmpty
                        ? widget.reserva.id
                        : Uuid().v1(),
                    nome: _nome,
                    valor: double.parse(_valor),
                    uid: widget.reserva.uid,
                    tipo: _tipo);
                ehEdicao
                    ? await ServicoBancoLocal().atualizarReserva(reserva)
                    : await ServicoBancoLocal().adicionarReserva(reserva);
                ServicoSincronizador(widget.reserva.uid).sincronizarReservas();
                Navigator.pop(context);
                widget.callback();
              }
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    bool ehEdicao = widget.reserva.id.isNotEmpty;
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
                        ServicoBancoLocal().removerReserva(widget.reserva);
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
}
