import 'package:charts_flutter/flutter.dart' as charts;
import 'package:dots_indicator/dots_indicator.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:meupatrimonio/models/percentual.dart';
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

class GraficosWidget extends StatefulWidget {
  final charts.Series seriesAtual;
  final charts.Series seriesIdeal;

  GraficosWidget({this.seriesAtual, this.seriesIdeal});

  @override
  GraficosWidgetState createState() => GraficosWidgetState();
}

class GraficosWidgetState extends State<GraficosWidget> {
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
              corpoGraficos(context, Strings.posicaoAtual, widget.seriesAtual),
              corpoGraficos(context, Strings.posicaoIdeal, widget.seriesIdeal),
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
        child: Text(Strings.semDados),
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
              showMeasures: false,
              entryTextStyle: charts.TextStyleSpec(fontSize: 12),
              outsideJustification: charts.OutsideJustification.middleDrawArea,
              legendDefaultMeasure: charts.LegendDefaultMeasure.firstValue,
              desiredMaxRows: 5,
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

class OndeAportarWidget extends StatefulWidget {
  final List<Percentual> dados;

  OndeAportarWidget({this.dados});

  OndeAportarState createState() => OndeAportarState();
}

class OndeAportarState extends State<OndeAportarWidget> {
  final _fmtPct = NumberFormat.decimalPercentPattern(decimalDigits: 1);
  @override
  Widget build(BuildContext context) {
    return Column(children: [
      Padding(
        padding: EdgeInsets.all(15),
        child: Text(
          Strings.dicaPercentual,
          style: const TextStyle(fontSize: 14),
        ),
      ),
      Expanded(
          child: ListView.builder(
        itemCount: widget.dados.length,
        itemBuilder: (context, index) => Padding(
          padding: EdgeInsets.all(5.0),
          child: Card(
            margin: EdgeInsets.fromLTRB(5.0, 0.0, 5.0, 0.0),
            child: ListTile(
              contentPadding: EdgeInsets.all(7),
              leading: CircleAvatar(
                radius: 25.0,
                backgroundColor: Theme.of(context).buttonColor,
                child: Text('${index + 1}'),
              ),
              dense: true,
              title: Text(
                widget.dados[index].descricao,
                style: const TextStyle(),
              ),
              trailing: Text(
                '${_fmtPct.format(widget.dados[index].falta)}',
                style: TextStyle(
                  color:
                      widget.dados[index].falta > 0 ? Colors.green : Colors.red,
                  fontSize: 15,
                ),
              ),
            ),
          ),
        ),
      ))
    ]);
  }
}

class PaginaComTabsWidget extends StatefulWidget {
  final String titulo;
  final List<Widget> acoes;
  final Widget corpo;
  final OndeAportarWidget ondeAportar;
  final GraficosWidget graficos;
  final Widget drawer;
  final bool carregando;
  final FloatingActionButton botaoAdicionar;

  PaginaComTabsWidget(
      {this.titulo,
      this.acoes,
      this.corpo,
      this.graficos,
      this.ondeAportar,
      this.botaoAdicionar,
      this.drawer,
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
    return Scaffold(
      drawer: widget.drawer,
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
            child: widget.ondeAportar,
          ),
        ],
      ),
    );
  }
}
