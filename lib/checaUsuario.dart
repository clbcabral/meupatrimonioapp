import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:meupatrimonio/pages/autenticacao/autenticacao.dart';
import 'package:meupatrimonio/pages/home/patrimonio.dart';
import 'package:provider/provider.dart';

class ChecaUsuarioWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    dynamic usuario = Provider.of<FirebaseUser>(context);
    if (usuario != null) {
      return PatrimonioWidget(
        usuario: usuario,
      );
    } else {
      return AutenticacaoWidget();
    }
  }
}
