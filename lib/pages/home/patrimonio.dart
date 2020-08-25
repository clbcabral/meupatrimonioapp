import 'package:flutter/material.dart';
import 'package:meupatrimonio/models/divida.dart';
import 'package:meupatrimonio/models/objetivo.dart';
import 'package:meupatrimonio/pages/home/itemPatrimonio.dart';
import 'package:meupatrimonio/services/bancoLocal.dart';
import 'package:meupatrimonio/vals/strings.dart';
import 'package:meupatrimonio/pages/home/menuLateral.dart';
import 'package:sticky_headers/sticky_headers.dart';
import 'package:intl/intl.dart';

class PatrimonioWidget extends StatefulWidget {
  @override
  PatrimonioState createState() => PatrimonioState();
}

class PatrimonioState extends State<PatrimonioWidget> {
  List<Objetivo> _objetivos;
  List<Divida> _dividas;
  final NumberFormat _formatador = NumberFormat.simpleCurrency(locale: 'pt_br');

  @override
  void initState() {
    super.initState();
    buscarDados();
  }

  void buscarDados() async {
    List<Future> operacoes = [
      ServicoBancoLocal().listarObjetivos(),
      ServicoBancoLocal().listarDividas(),
    ];
    List<dynamic> data = await Future.wait(operacoes);
    setState(() {
      print(data);
      _objetivos = data[0];
      _dividas = data[1];
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
              icon: Icon(Icons.help),
              onPressed: () => {},
            ),
            IconButton(
              icon: Icon(Icons.refresh),
              onPressed: () => buscarDados(),
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

  double calcularDividas() {
    if (_dividas == null) {
      return 0.0;
    }
    return _dividas.fold(0.0, (val, divida) => val + divida.valor);
  }

  double calcularSubTotal() {
    if (_objetivos == null) {
      return 0.0;
    }
    return _objetivos.fold(0.0, (val, objetivo) => val + objetivo.valor);
  }

  double calcularTotal() {
    double dividas = calcularDividas();
    double subtotal = calcularSubTotal();
    return (subtotal - dividas).abs();
  }

  Widget corpoPatrimonio() {
    if (_objetivos == null) {
      return Container();
    }
    double subtotal = calcularSubTotal();
    return ListView.builder(
      itemCount: 1,
      itemBuilder: (context, index) {
        return StickyHeader(
          header: cabecalhoResumoPatrimonio(),
          content: Column(
            children: _objetivos.map<Widget>((objetivo) {
              return ItemPatrimonio(
                subtotal: subtotal,
                objetivo: objetivo,
                callback: buscarDados,
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
                Strings.dividas,
                style: TextStyle(
                  color: Colors.white38,
                  fontSize: 12,
                ),
              ),
              Text(
                _formatador.format(calcularDividas()),
                style: TextStyle(color: Colors.white, fontSize: 14),
              ),
            ],
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                Strings.total,
                style: const TextStyle(
                  color: Colors.white38,
                  fontSize: 12,
                ),
              ),
              Text(
                _formatador.format(calcularTotal()),
                style: const TextStyle(color: Colors.white, fontSize: 20),
              ),
            ],
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                Strings.subtotal,
                style: const TextStyle(
                  color: Colors.white38,
                  fontSize: 12,
                ),
              ),
              Text(
                _formatador.format(calcularSubTotal()),
                style: const TextStyle(color: Colors.white, fontSize: 14),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
