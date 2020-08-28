import 'package:flutter/material.dart';
import 'package:meupatrimonio/models/divida.dart';
import 'package:meupatrimonio/models/objetivo.dart';
import 'package:meupatrimonio/pages/home/formObjetivos.dart';
import 'package:meupatrimonio/pages/home/itemPatrimonio.dart';
import 'package:meupatrimonio/services/bancoLocal.dart';
import 'package:meupatrimonio/vals/strings.dart';
import 'package:meupatrimonio/pages/home/menuLateral.dart';
import 'package:intl/intl.dart';

class PatrimonioWidget extends StatefulWidget {
  PatrimonioWidget({Key key}) : super(key: key);
  @override
  PatrimonioState createState() => PatrimonioState();
}

class PatrimonioState extends State<PatrimonioWidget> {
  bool _carregando = false;
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
    return _objetivos.fold(
        0.0, (val, objetivo) => val + (objetivo.sumValores ?? 0));
  }

  double calcularTotal() {
    double dividas = calcularDividas();
    double subtotal = calcularSubTotal();
    return (subtotal - dividas).abs();
  }

  @override
  Widget build(BuildContext context) {
    return (_carregando == true)
        ? Container(
            padding: EdgeInsets.all(25),
            child: Center(
              child: CircularProgressIndicator(),
            ),
          )
        : DefaultTabController(
            length: 3,
            child: Scaffold(
              drawer: MenuLateral(),
              appBar: AppBar(
                title: Text(
                  Strings.meuPatrimonio,
                  style: TextStyle(fontSize: 18),
                ),
                actions: <Widget>[
                  IconButton(
                    icon: Icon(Icons.help),
                    onPressed: () => {},
                  ),
                  IconButton(
                    icon: Icon(Icons.settings),
                    onPressed: () => {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) =>
                                ObjetivosForm(objetivos: _objetivos)),
                      ).then((value) => buscarDados())
                    },
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
                    child: corpoGraficos(),
                  ),
                  Tab(
                    icon: Icon(Icons.account_balance),
                  ),
                ],
              ),
            ),
          );
  }

  Widget corpoGraficos() {
    return Container(
      child: Text('Foo'),
    );
  }

  Widget corpoPatrimonio() {
    if (_objetivos == null) {
      return Container();
    }
    double subtotal = calcularSubTotal();
    return Column(children: <Widget>[
      cabecalhoResumoPatrimonio(),
      Expanded(
          child: RefreshIndicator(
              onRefresh: () async {
                buscarDados();
              },
              child: ListView.builder(
                itemCount: _objetivos.length,
                itemBuilder: (context, index) {
                  return ItemPatrimonio(
                    subtotal: subtotal,
                    objetivo: _objetivos[index],
                    callback: buscarDados,
                  );
                },
              )))
    ]);
  }

  Widget cabecalhoResumoPatrimonio() {
    return Container(
      height: 65.0,
      color: Colors.black,
      padding: EdgeInsets.symmetric(horizontal: 15.0),
      alignment: Alignment.center,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
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
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
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
                style: const TextStyle(color: Colors.white, fontSize: 16),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
