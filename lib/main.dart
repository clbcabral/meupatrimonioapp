import 'package:flutter/material.dart';
import 'package:meupatrimonio/vals/strings.dart';
import 'package:meupatrimonio/pages/home/patrimonio.dart';

void main() {
  runApp(MeuPatrimonioApp());
}

class MeuPatrimonioApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: Strings.meuPatrimonio,
      theme: ThemeData(
        primarySwatch: Colors.green,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: PatrimonioWidget(),
    );
  }
}
