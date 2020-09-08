import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:meupatrimonio/models/usuario.dart';
import 'package:meupatrimonio/services/autenticacao.dart';
import 'package:meupatrimonio/services/bdLocal.dart';
import 'package:meupatrimonio/services/bdWrapper.dart';
import 'package:meupatrimonio/shared/componentes.dart';
import 'package:meupatrimonio/vals/strings.dart';

class MenuLateral extends StatefulWidget {
  final FirebaseUser usuarioFB;

  MenuLateral({this.usuarioFB});

  @override
  _MenuLateralState createState() => _MenuLateralState();
}

class _MenuLateralState extends State<MenuLateral> {
  final ServicoAutenticacao _servico = ServicoAutenticacao();
  Usuario usuario;

  @override
  void initState() {
    super.initState();
    ServicoBancoLocal().obterUsuario(widget.usuarioFB.uid).then((user) {
      setState(() => usuario = user);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        children: <Widget>[
          UserAccountsDrawerHeader(
            accountName: Text(usuario != null ? usuario.nome : ''),
            accountEmail: Text(usuario != null ? usuario.email : ''),
            currentAccountPicture: CircleAvatar(
              backgroundColor: Colors.white,
              child: Text(
                usuario != null ? usuario.nome[0] : '',
                style: TextStyle(
                  fontSize: 40.0,
                  color: Theme.of(context).primaryColor,
                ),
              ),
            ),
          ),
          ListTile(
            leading: Icon(Icons.home),
            title: Text(Strings.meuPatrimonio),
            onTap: () {
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: Icon(Icons.android),
            title: Text(Strings.sobre),
            onTap: () {
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: Icon(Icons.exit_to_app),
            title: Text(Strings.sair),
            onTap: () async {
              bool confirmou = await showDialog(
                    context: context,
                    builder: (BuildContext context) =>
                        Alerta('Deseja realmente sair?'),
                  ) ??
                  false;
              if (confirmou) {
                Navigator.popUntil(
                    context, ModalRoute.withName(Navigator.defaultRouteName));
                _servico.logout();
              }
            },
          ),
        ],
      ),
    );
  }
}
