import 'package:flutter/material.dart';
import 'package:meupatrimonio/vals/strings.dart';

class Loader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Center(
        child: SizedBox(
          child: CircularProgressIndicator(),
          width: 60,
          height: 60,
        ),
      ),
    );
  }
}

class Alerta extends StatelessWidget {
  final String aviso;
  Alerta(this.aviso);
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(Strings.atencao),
      content: Text(aviso),
      actions: <Widget>[
        FlatButton(
          child: Text(Strings.cancelar),
          onPressed: () {
            Navigator.pop(context, false);
          },
        ),
        FlatButton(
          child: Text(Strings.confirmar),
          onPressed: () {
            Navigator.pop(context, true);
          },
        ),
      ],
    );
  }
}
