import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:meupatrimonio/checaUsuario.dart';
import 'package:meupatrimonio/services/autenticacao.dart';
import 'package:meupatrimonio/vals/strings.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(MeuPatrimonioApp());
}

class MeuPatrimonioApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamProvider<FirebaseUser>(
      create: (_) => ServicoAutenticacao().user,
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        home: ChecaUsuarioWidget(),
        title: Strings.meuPatrimonio,
        theme: ThemeData(
          primarySwatch: Colors.green,
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),
      ),
    );
  }
}
