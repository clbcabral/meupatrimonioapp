import 'package:charts_flutter/flutter.dart' as charts;
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:meupatrimonio/models/ativo.dart';
import 'package:meupatrimonio/pages/ativo/formAtivo.dart';
import 'package:meupatrimonio/pages/ativo/itemAtivo.dart';
import 'package:meupatrimonio/services/bancoLocal.dart';
import 'package:meupatrimonio/shared/componentes.dart';
import 'package:meupatrimonio/vals/strings.dart';

class AtivosWidget extends StatefulWidget {
  final String titulo;
  final String tipo;
  AtivosWidget({
    this.titulo,
    this.tipo,
  });
  @override
  AtivosState createState() => AtivosState();
}

class AtivosState extends State<AtivosWidget> {
  bool _carregando = false;
  final _formatador = NumberFormat.simpleCurrency(locale: 'pt_br');
  List<Ativo> _ativos = [];

  @override
  void initState() {
    super.initState();
    buscarDados();
  }

  void buscarDados() async {
    List<Ativo> ativos = await ServicoBancoLocal().listarAtivos(widget.tipo);
    setState(() {
      _ativos = ativos;
    });
  }

  double calcularTotal() {
    if (_ativos == null) {
      return 0.0;
    }
    return _ativos.fold(0.0, (val, ativo) => val + ativo.valor());
  }

  double calcularPesos() {
    if (_ativos == null) {
      return 0.0;
    }
    return _ativos.fold(0.0, (val, ativo) => val + ativo.peso);
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
              appBar: AppBar(
                title: Text(
                  widget.titulo,
                  style: TextStyle(fontSize: 16),
                ),
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
              floatingActionButton: FloatingActionButton(
                child: Icon(Icons.add),
                onPressed: () => {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) {
                        Ativo ativo = Ativo.exemplo();
                        ativo.tipo = widget.tipo;
                        return AtivoForm(
                          ativo: ativo,
                          callback: buscarDados,
                        );
                      },
                    ),
                  )
                },
              ),
              body: TabBarView(
                children: [
                  Tab(
                    child: corpo(context),
                  ),
                  Tab(
                    child: Graficos(
                      seriesA: charts.Series<Ativo, String>(
                        id: 'atual',
                        domainFn: (Ativo obj, _) => obj.ticker,
                        measureFn: (Ativo obj, _) => obj.valor(),
                        labelAccessorFn: (Ativo obj, _) => '${obj.valor()}%',
                        data: _ativos,
                      ),
                      seriesB: charts.Series<Ativo, String>(
                        id: 'ideal',
                        domainFn: (Ativo obj, _) => obj.ticker,
                        measureFn: (Ativo obj, _) => obj.valor(),
                        labelAccessorFn: (Ativo obj, _) => '${obj.valor()}%',
                        data: _ativos,
                      ),
                    ),
                  ),
                  Tab(
                    icon: Icon(Icons.account_balance),
                  ),
                ],
              ),
            ));
  }

  Widget cabecalho() {
    return Container(
      height: 65.0,
      color: Colors.black,
      padding: EdgeInsets.symmetric(horizontal: 15.0),
      alignment: Alignment.center,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Text(
            Strings.total,
            style: const TextStyle(color: Colors.white, fontSize: 16),
          ),
          Text(
            _formatador.format(calcularTotal()),
            style: const TextStyle(color: Colors.white, fontSize: 16),
          ),
        ],
      ),
    );
  }

  Widget corpo(BuildContext context) {
    if (_ativos == null || _ativos.isEmpty) {
      return Container(
        child: Center(
          child: Text(Strings.dicaAdicionar),
        ),
      );
    }
    double totalAtivos = calcularTotal();
    double totalPesos = calcularPesos();
    return Column(
      children: [
        cabecalho(),
        Expanded(
            child: RefreshIndicator(
          onRefresh: () async {
            buscarDados();
          },
          child: ListView.builder(
            itemCount: _ativos.length,
            itemBuilder: (context, index) {
              return Container(
                child: ItemAtivo(
                  ativo: _ativos[index],
                  totalAtivos: totalAtivos,
                  totalPesos: totalPesos,
                  callback: buscarDados,
                ),
              );
            },
          ),
        ))
      ],
    );
  }
}
