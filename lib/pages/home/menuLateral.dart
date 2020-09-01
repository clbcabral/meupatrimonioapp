import 'package:flutter/material.dart';
import 'package:meupatrimonio/vals/strings.dart';

class MenuLateral extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        children: <Widget>[
          UserAccountsDrawerHeader(
            // accountName: Text(userInfo != null ? userInfo.fullname : ''),
            // accountEmail: Text(userInfo != null ? userInfo.email : ''),
            // currentAccountPicture: CircleAvatar(
            //   backgroundColor: Colors.white,
            //   child: Text(
            //     userInfo != null ? userInfo.fullname[0] : '',
            //     style: TextStyle(
            //       fontSize: 40.0,
            //       color: Theme.of(context).primaryColor,
            //     ),
            //   ),
            // ),
            accountName: Text('Fulano'),
            accountEmail: Text('fulano@email.com'),
            currentAccountPicture: CircleAvatar(
              backgroundColor: Colors.white,
              child: Icon(Icons.account_circle),
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
            leading: Icon(Icons.money_off),
            title: Text(Strings.dividas),
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
            onTap: () {
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }
}
