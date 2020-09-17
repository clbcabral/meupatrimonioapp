import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:meupatrimonio/pages/sobre/sobre.dart';
import 'package:meupatrimonio/services/autenticacao.dart';
import 'package:meupatrimonio/shared/componentes.dart';
import 'package:meupatrimonio/vals/strings.dart';

class MenuLateral extends StatefulWidget {
  final FirebaseUser usuario;

  MenuLateral({this.usuario});

  @override
  _MenuLateralState createState() => _MenuLateralState();
}

class _MenuLateralState extends State<MenuLateral> {
  final ServicoAutenticacao _servico = ServicoAutenticacao();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var usuario = widget.usuario;
    return Drawer(
      child: ListView(
        children: <Widget>[
          UserAccountsDrawerHeader(
            accountName: Text(usuario != null ? usuario.displayName ?? '' : ''),
            accountEmail: Text(usuario != null ? usuario.email : ''),
            currentAccountPicture: CircleAvatar(
              backgroundColor: Colors.white,
              child: Text(
                (usuario != null && usuario.displayName.isNotEmpty)
                    ? usuario.displayName[0]
                    : '',
                style: TextStyle(
                  fontSize: 40.0,
                  color: Theme.of(context).primaryColor,
                ),
              ),
            ),
          ),
          ListTile(
            leading: Icon(Icons.android),
            title: Text(Strings.sobre),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => SobreWidget()),
              );
            },
          ),
          ListTile(
            leading: Icon(Icons.exit_to_app),
            title: Text(Strings.sair),
            onTap: () async {
              bool confirmou = await showDialog(
                    context: context,
                    builder: (BuildContext context) =>
                        Alerta(Strings.desejaSair),
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
