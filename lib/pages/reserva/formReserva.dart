import 'package:flutter/material.dart';
import 'package:meupatrimonio/models/reserva.dart';
import 'package:meupatrimonio/vals/strings.dart';

class ReservaForm extends StatefulWidget {
  final Reserva reserva;
  ReservaForm({this.reserva});

  @override
  ReservaFormState createState() => ReservaFormState();
}

class ReservaFormState extends State<ReservaForm> {
  final _chave = GlobalKey<ReservaFormState>();
  final _nomeController = TextEditingController();
  String _nome;
  double _valor;

  @override
  void initState() {
    super.initState();
    _nome = widget.reserva.nome ?? '';
    _valor = widget.reserva.valor;
    _nomeController.text = widget.reserva.nome;
  }

  @override
  Widget build(BuildContext context) {
    bool ehEdicao = !Reserva.vazio().equalTo(widget.reserva);
    return Scaffold(
        appBar: AppBar(
          title: Text(ehEdicao ? Strings.editarItem : Strings.adicionarItem),
          actions: ehEdicao
              ? <Widget>[
                  IconButton(
                    icon: Icon(Icons.delete),
                    onPressed: () => {},
                  ),
                ]
              : null, // add reset category here for defaults
        ),
        body: Form(
          key: _chave,
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
                  if (val.isEmpty) {
                    return 'Informe o nome.';
                  }
                  return null;
                },
                textCapitalization: TextCapitalization.words,
                onChanged: (val) {
                  setState(() => _nome = val);
                },
              ),
              SizedBox(height: 10.0),
            ],
          ),
        ));
  }
}
