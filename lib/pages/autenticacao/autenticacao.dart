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
    switch (metodo) {
      case MetodoAutenticacao.Login:
        return AutenticacaoForm(
            callback: trocaView, metodo: MetodoAutenticacao.Login);
        break;
      case MetodoAutenticacao.Registro:
        return AutenticacaoForm(
            callback: trocaView, metodo: MetodoAutenticacao.Registro);
        break;
      default:
        return Text('Erro na autenticação.');
        break;
    }
  }
}
