import 'package:flutter/material.dart';
import 'package:meupatrimonio/vals/strings.dart';
import 'package:meupatrimonio/widgets/menu-lateral.dart';

class PatrimonioWidget extends StatefulWidget {
  final String title;
  PatrimonioWidget({Key key, this.title}) : super(key: key);
  @override
  PatrimonioState createState() => PatrimonioState();
}

class PatrimonioState extends State<PatrimonioWidget> {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        drawer: MenuLateral(),
        appBar: AppBar(
          title: Text(Strings.meuPatrimonio),
          bottom: TabBar(
            tabs: [
              Tab(
                text: Strings.consolidado,
              ),
              Tab(
                text: Strings.graficos,
              ),
              Tab(
                text: Strings.ondeAportar,
              ),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            Tab(
              child: ListView.builder(
                itemCount: 5,
                itemBuilder: (context, index) {
                  return Container(
                    padding: EdgeInsets.fromLTRB(5, 5, 5, 0),
                    height: 100,
                    width: double.maxFinite,
                    child: Card(
                      elevation: 5,
                    ),
                  );
                },
              ),
            ),
            Tab(
              icon: Icon(Icons.accessible),
            ),
            Tab(
              icon: Icon(Icons.account_balance),
            ),
          ],
        ),
      ),
    );
  }
}
