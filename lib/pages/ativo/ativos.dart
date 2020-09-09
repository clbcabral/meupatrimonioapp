import 'package:charts_flutter/flutter.dart' as charts;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:meupatrimonio/models/percentual.dart';
import 'package:meupatrimonio/models/ativo.dart';
import 'package:meupatrimonio/pages/ativo/formAtivo.dart';
import 'package:meupatrimonio/pages/ativo/itemAtivo.dart';
import 'package:meupatrimonio/services/bdLocal.dart';
import 'package:meupatrimonio/services/yahooFinance.dart';
import 'package:meupatrimonio/shared/componentes.dart';
import 'package:meupatrimonio/vals/constantes.dart';
import 'package:meupatrimonio/vals/strings.dart';

class AtivosWidget extends StatefulWidget {
  final String titulo;
  final String tipo;
  final FirebaseUser usuario;
  AtivosWidget({
    this.titulo,
    this.tipo,
    this.usuario,
  });
  @override
  AtivosState createState() => AtivosState();
}

class AtivosState extends State<AtivosWidget> {
  bool _carregando = false;
  final _fmtValor = NumberFormat.simpleCurrency(locale: 'pt_br');
  final _fmtPct = NumberFormat.decimalPercentPattern(decimalDigits: 1);
  List<Ativo> _ativos = [];
  List<Percentual> _percentuais = [];

  @override
  void initState() {
    super.initState();
    buscarDados();
  }

  void buscarDados() async {
    List<Future> operacoes = [
      ServicoBancoLocal().listarAtivos(widget.usuario.uid, widget.tipo),
      ServicoBancoLocal().listarPercentuais(widget.usuario.uid, widget.tipo),
    ];
    List<dynamic> data = await Future.wait(operacoes);
    setState(() {
      _ativos = data[0];
      _percentuais = data[1];
    });
  }

  void atualizarCotacoes() async {
    if (widget.tipo != ATIVO_RF) {
      await ServicoYahooFinance().atualizarCotacoes(_ativos);
    }
    buscarDados();
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
    double totalAtivos = calcularTotal();
    double totalPesos = calcularPesos();
    return PaginaComTabsWidget(
      carregando: _carregando,
      drawer: null,
      titulo: widget.titulo,
      corpo: corpo(context, totalAtivos, totalPesos),
      graficos: GraficosWidget(
        seriesAtual: charts.Series<Percentual, String>(
          id: 'atual',
          domainFn: (Percentual p, _) => p.descricao,
          measureFn: (Percentual p, _) => p.atual,
          labelAccessorFn: (Percentual p, _) => '${_fmtPct.format(p.atual)}',
          data: _percentuais,
        ),
        seriesIdeal: charts.Series<Percentual, String>(
          id: 'ideal',
          domainFn: (Percentual p, _) => p.descricao,
          measureFn: (Percentual p, _) => p.ideal,
          labelAccessorFn: (Percentual p, _) => '${_fmtPct.format(p.ideal)}',
          data: _percentuais,
        ),
      ),
      ondeAportar: OndeAportarWidget(
        dados: _percentuais,
      ),
      botaoAdicionar: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () => {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) {
                Ativo ativo = Ativo.exemplo();
                ativo.tipo = widget.tipo;
                ativo.uid = widget.usuario.uid;
                return AtivoForm(
                  ativo: ativo,
                  callback: buscarDados,
                );
              },
            ),
          )
        },
      ),
      acoes: <Widget>[
        IconButton(
          icon: Icon(Icons.help),
          onPressed: () => {},
        ),
      ],
    );
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
            _fmtValor.format(calcularTotal()),
            style: const TextStyle(color: Colors.white, fontSize: 16),
          ),
        ],
      ),
    );
  }

  Widget corpo(BuildContext context, double totalAtivos, double totalPesos) {
    if (_ativos == null || _ativos.isEmpty) {
      return Container(
        child: Center(
          child: Text(Strings.dicaAdicionar),
        ),
      );
    }
    return Column(
      children: [
        cabecalho(),
        Expanded(
            child: RefreshIndicator(
          onRefresh: () async {
            atualizarCotacoes();
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
