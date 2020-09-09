import 'package:flutter/material.dart';
import 'package:meupatrimonio/pages/autenticacao/formAutenticacao.dart';
import 'package:meupatrimonio/vals/constantes.dart';

class AutenticacaoWidget extends StatefulWidget {
  @override
  _AutenticacaoWidgetState createState() => _AutenticacaoWidgetState();
}

class _AutenticacaoWidgetState extends State<AutenticacaoWidget> {
  MetodoAutenticacao metodo = MetodoAutenticacao.Login;

  void trocaView() {
    setState(() {
      metodo = (metodo == MetodoAutenticacao.Login)
          ? MetodoAutenticacao.Registro
          : MetodoAutenticacao.Login;
    });
  }

  @override
  Widget build(BuildContext context) {
    return AutenticacaoForm(callback: trocaView, metodo: metodo);
  }
}
