import 'package:flutter/material.dart';
import 'package:meupatrimonio/models/ativo.dart';
import 'package:meupatrimonio/models/objetivo.dart';
import 'package:meupatrimonio/pages/home/itemPatrimonio.dart';
import 'package:meupatrimonio/services/bancoLocal.dart';
import 'package:meupatrimonio/vals/constantes.dart';
import 'package:meupatrimonio/vals/strings.dart';
import 'package:meupatrimonio/pages/home/menuLateral.dart';
import 'package:sticky_headers/sticky_headers.dart';

class PatrimonioWidget extends StatefulWidget {
  @override
  PatrimonioState createState() => PatrimonioState();
}

class PatrimonioState extends State<PatrimonioWidget> {
  List<Objetivo> _objetivos;

  @override
  void initState() {
    super.initState();
    buscarDados();
  }

  void buscarDados() async {
    List<dynamic> data = await ServicoBancoLocal().listarObjetivos();
    setState(() {
      _objetivos = data;
    });
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        drawer: MenuLateral(),
        appBar: AppBar(
          title: Text(Strings.meuPatrimonio),
          actions: <Widget>[
            IconButton(
              icon: Icon(Icons.refresh),
              onPressed: () => {},
            ),
          ],
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
              child: corpoPatrimonio(),
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

  Widget corpoPatrimonio() {
    if (_objetivos == null) {
      return Container();
    }
    return ListView.builder(
      itemCount: 1,
      itemBuilder: (context, index) {
        return StickyHeader(
          header: cabecalhoResumoPatrimonio(),
          content: Column(
            children: _objetivos.map<Widget>((objetivo) {
              return ItemPatrimonio(
                titulo: objetivo.nome,
                valor: objetivo.valor,
                icone: Icons.attach_money,
                tipo: objetivo.tipo,
              );
            }).toList(),
          ),
        );
      },
    );
  }

  Widget cabecalhoResumoPatrimonio() {
    return Container(
      height: 75.0,
      color: Colors.black,
      padding: EdgeInsets.symmetric(horizontal: 15.0),
      alignment: Alignment.center,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Dívidas',
                style: const TextStyle(
                  color: Colors.white38,
                  fontSize: 12,
                ),
              ),
              Text(
                'R\$ ${0.0}',
                style: const TextStyle(color: Colors.white, fontSize: 18),
              ),
            ],
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Total',
                style: const TextStyle(
                  color: Colors.white38,
                  fontSize: 12,
                ),
              ),
              Text(
                'R\$ ${0.0}',
                style: const TextStyle(color: Colors.white, fontSize: 26),
              ),
            ],
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Sub-total',
                style: const TextStyle(
                  color: Colors.white38,
                  fontSize: 12,
                ),
              ),
              Text(
                'R\$ ${0.0}',
                style: const TextStyle(color: Colors.white, fontSize: 18),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
