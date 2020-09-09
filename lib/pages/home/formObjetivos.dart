import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:meupatrimonio/models/objetivo.dart';
import 'package:meupatrimonio/services/bdLocal.dart';
import 'package:meupatrimonio/services/sicronizador.dart';
import 'package:meupatrimonio/vals/strings.dart';

class ObjetivosForm extends StatefulWidget {
  final List<Objetivo> objetivos;
  final FirebaseUser usuario;
  ObjetivosForm({Key key, this.objetivos, this.usuario}) : super(key: key);

  @override
  ObjetivosFormState createState() => ObjetivosFormState();
}

class ObjetivosFormState extends State<ObjetivosForm> {
  GlobalKey<ScaffoldState> _chave = GlobalKey<ScaffoldState>();
  @override
  void initState() {
    super.initState();
  }

  double calcularTotal() {
    if (widget.objetivos == null) {
      return 0.0;
    }
    return widget.objetivos.fold(0.0, (val, objetivo) => val + objetivo.ideal) *
        100;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _chave,
      appBar: AppBar(title: Text(Strings.objetivos), actions: <Widget>[
        IconButton(
          icon: Icon(Icons.save),
          onPressed: () async {
            if (calcularTotal() != 100.0) {
              var snak = SnackBar(
                content: Text(Strings.validacaoSomaPercentual),
              );
              _chave.currentState.showSnackBar(snak);
            } else {
              await ServicoBancoLocal().atualizarObjetivos(widget.objetivos);
              ServicoSincronizador(widget.usuario.uid)
                  .sincronizarObjetivosParaRemoto();
              Navigator.pop(context);
            }
          },
        ),
      ]),
      body: Column(
        children: [
          Container(
            height: 65.0,
            color: Colors.black,
            padding: EdgeInsets.symmetric(horizontal: 15.0),
            alignment: Alignment.center,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Text(
                  Strings.total,
                  style: const TextStyle(color: Colors.white, fontSize: 16),
                ),
                Text(
                  '${calcularTotal().roundToDouble()}%',
                  style: const TextStyle(color: Colors.white, fontSize: 16),
                ),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.all(15),
            child: Text(
              Strings.dicaObjetivosPercentuais,
              style: const TextStyle(fontSize: 14),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: widget.objetivos.length,
              itemBuilder: (context, index) => Padding(
                padding: EdgeInsets.all(5.0),
                child: Card(
                  margin: EdgeInsets.fromLTRB(5.0, 0.0, 5.0, 0.0),
                  child: ListTile(
                    contentPadding: EdgeInsets.fromLTRB(15, 7, 15, 7),
                    dense: true,
                    title: Text(
                      widget.objetivos[index].nome,
                      style: const TextStyle(),
                    ),
                    subtitle: Slider(
                      value: widget.objetivos[index].ideal * 100,
                      min: 0,
                      max: 100,
                      onChanged: (double value) {
                        setState(() {
                          widget.objetivos[index].ideal =
                              value.roundToDouble() / 100;
                        });
                      },
                    ),
                    trailing: Text(
                      '${(widget.objetivos[index].ideal * 100).round()}%',
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 15,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}
