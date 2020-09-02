import 'package:charts_flutter/flutter.dart' as charts;
import 'package:dots_indicator/dots_indicator.dart';
import 'package:flutter/material.dart';
import 'package:meupatrimonio/pages/home/menuLateral.dart';
import 'package:meupatrimonio/vals/strings.dart';

class Loader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Center(
        child: SizedBox(
          child: CircularProgressIndicator(),
          width: 60,
          height: 60,
        ),
      ),
    );
  }
}

class Alerta extends StatelessWidget {
  final String aviso;
  Alerta(this.aviso);
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(Strings.atencao),
      content: Text(aviso),
      actions: <Widget>[
        FlatButton(
          child: Text(Strings.cancelar),
          onPressed: () {
            Navigator.pop(context, false);
          },
        ),
        FlatButton(
          child: Text(Strings.confirmar),
          onPressed: () {
            Navigator.pop(context, true);
          },
        ),
      ],
    );
  }
}

class Graficos extends StatefulWidget {
  final charts.Series seriesAtual;
  final charts.Series seriesIdeal;

  Graficos({this.seriesAtual, this.seriesIdeal});

  @override
  GraficosState createState() => GraficosState();
}

class GraficosState extends State<Graficos> {
  int _paginaAtual = 0;

  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: PageView(
            onPageChanged: (value) {
              setState(() {
                _paginaAtual = value;
              });
            },
            children: [
              corpoGraficos(context, 'Posição atual', widget.seriesAtual),
              corpoGraficos(context, 'Posição ideal', widget.seriesIdeal),
            ],
          ),
        ),
        DotsIndicator(dotsCount: 2, position: _paginaAtual.roundToDouble()),
        SizedBox(
          height: 15,
        ),
      ],
    );
  }

  Widget corpoGraficos(context, String titulo, charts.Series series) {
    bool possuiValor = false;
    series.data.asMap().forEach((key, value) {
      if (series.measureFn.call(key) > 0) {
        possuiValor = true;
      }
    });
    if (!possuiValor) {
      return Center(
        child: Text('Ainda sem dados.'),
      );
    }
    return Column(children: [
      SizedBox(
        height: 15,
      ),
      Text(
        titulo,
        style: TextStyle(fontSize: 18),
      ),
      SizedBox(
        height: 15,
      ),
      Expanded(
        child: charts.PieChart(
          [series],
          animate: false,
          defaultRenderer: charts.ArcRendererConfig(
              arcRendererDecorators: [charts.ArcLabelDecorator()]),
          behaviors: [
            charts.DatumLegend(
              position:
                  MediaQuery.of(context).orientation == Orientation.portrait
                      ? charts.BehaviorPosition.bottom
                      : charts.BehaviorPosition.end,
              horizontalFirst: false,
              cellPadding: EdgeInsets.all(4),
              showMeasures: false,
              entryTextStyle: charts.TextStyleSpec(fontSize: 12),
              outsideJustification: charts.OutsideJustification.middleDrawArea,
              legendDefaultMeasure: charts.LegendDefaultMeasure.firstValue,
              desiredMaxRows: 4,
              measureFormatter: (num value) {
                return value == null ? '-' : '$value%';
              },
            ),
          ],
        ),
      ),
      SizedBox(
        height: 15,
      ),
    ]);
  }
}

class PaginaComTabsWidget extends StatefulWidget {
  final String titulo;
  final List<Widget> acoes;
  final Widget corpo;
  final Graficos graficos;
  final bool exibeDrawer;
  final bool carregando;
  final FloatingActionButton botaoAdicionar;

  PaginaComTabsWidget(
      {this.titulo,
      this.acoes,
      this.corpo,
      this.graficos,
      this.botaoAdicionar,
      this.exibeDrawer,
      this.carregando});

  PaginaComTabsState createState() => PaginaComTabsState();
}

class PaginaComTabsState extends State<PaginaComTabsWidget>
    with SingleTickerProviderStateMixin {
  TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this, initialIndex: 0);
    _tabController.addListener(_handleTabIndex);
  }

  @override
  void dispose() {
    _tabController.removeListener(_handleTabIndex);
    _tabController.dispose();
    super.dispose();
  }

  void _handleTabIndex() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return (widget.carregando == true)
        ? Container(
            padding: EdgeInsets.all(25),
            child: Center(
              child: CircularProgressIndicator(),
            ),
          )
        : Scaffold(
            drawer: widget.exibeDrawer ? MenuLateral() : null,
            appBar: AppBar(
              title: Text(
                widget.titulo,
                style: TextStyle(fontSize: 16),
              ),
              actions: widget.acoes,
              bottom: TabBar(
                controller: _tabController,
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
            floatingActionButton:
                _tabController.index == 0 ? widget.botaoAdicionar : null,
            body: TabBarView(
              controller: _tabController,
              children: [
                Tab(
                  child: widget.corpo,
                ),
                Tab(
                  child: widget.graficos,
                ),
                Tab(
                  icon: Icon(Icons.account_balance),
                ),
              ],
            ),
          );
  }
}
