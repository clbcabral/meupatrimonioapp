import 'package:charts_flutter/flutter.dart' as charts;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:meupatrimonio/models/ativo.dart';
import 'package:meupatrimonio/models/objetivo.dart';
import 'package:meupatrimonio/models/percentual.dart';
import 'package:meupatrimonio/pages/home/formObjetivos.dart';
import 'package:meupatrimonio/pages/home/itemPatrimonio.dart';
import 'package:meupatrimonio/pages/home/menuLateral.dart';
import 'package:meupatrimonio/services/bdRemoto.dart';
import 'package:meupatrimonio/services/yahooFinance.dart';
import 'package:meupatrimonio/shared/componentes.dart';
import 'package:meupatrimonio/vals/strings.dart';
import 'package:intl/intl.dart';

class PatrimonioWidget extends StatefulWidget {
  final FirebaseUser usuario;
  PatrimonioWidget({Key key, this.usuario}) : super(key: key);
  @override
  PatrimonioState createState() => PatrimonioState();
}

class PatrimonioState extends State<PatrimonioWidget> {
  bool _carregando = false;
  final _fmtPct = NumberFormat.decimalPercentPattern(decimalDigits: 1);
  List<Objetivo> _objetivos;
  final NumberFormat _formatador = NumberFormat.simpleCurrency(locale: 'pt_br');

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration(seconds: 3), () => buscarDados());
    buscarDados();
  }

  void buscarDados() async {
    setState(() {
      _carregando = true;
    });
    List<Objetivo> objetivos =
        await ServicoBancoRemoto(widget.usuario.uid).listarObjetivos();
    setState(() {
      _carregando = false;
      _objetivos = objetivos;
    });
  }

  void atualizarCotacoes() async {
    setState(() {
      _carregando = true;
    });
    List<Ativo> ativos = await ServicoBancoRemoto(widget.usuario.uid)
        .listarAtivosRendaVariavel();
    await ServicoYahooFinance().atualizarCotacoes(widget.usuario.uid, ativos);
    buscarDados();
  }

  double calcularTotal() {
    if (_objetivos == null) {
      return 0.0;
    }
    return _objetivos.fold(0.0, (val, objetivo) => val + (objetivo.valor));
  }

  @override
  Widget build(BuildContext context) {
    List<Percentual> ondeAportar = _objetivos != null
        ? List.generate(
            _objetivos.length,
            (index) => Percentual(
                descricao: _objetivos[index].nome,
                falta: _objetivos[index].falta))
        : [];
    ondeAportar.sort((a, b) => b.falta.compareTo(a.falta));
    return PaginaComTabsWidget(
      carregando: _carregando,
      drawer: MenuLateral(
        usuario: widget.usuario,
      ),
      titulo: Strings.meuPatrimonio,
      corpo: corpoPatrimonio(),
      botaoAdicionar: null,
      graficos: GraficosWidget(
        seriesAtual: charts.Series<Objetivo, String>(
          id: 'atual',
          domainFn: (Objetivo obj, _) => obj.nome,
          measureFn: (Objetivo obj, _) => obj.atual,
          labelAccessorFn: (Objetivo obj, _) => '${_fmtPct.format(obj.atual)}',
          data: _objetivos,
        ),
        seriesIdeal: charts.Series<Objetivo, String>(
          id: 'ideal',
          domainFn: (Objetivo obj, _) => obj.nome,
          measureFn: (Objetivo obj, _) => obj.ideal,
          labelAccessorFn: (Objetivo obj, _) => '${_fmtPct.format(obj.ideal)}',
          data: _objetivos,
        ),
      ),
      ondeAportar: OndeAportarWidget(
        dados: ondeAportar,
      ),
      acoes: <Widget>[
        IconButton(
          icon: Icon(Icons.settings),
          onPressed: () => {
            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => ObjetivosForm(
                        objetivos: _objetivos,
                        usuario: widget.usuario,
                      )),
            ).then((value) => buscarDados())
          },
        ),
      ],
    );
  }

  Widget corpoPatrimonio() {
    if (_objetivos == null) {
      return Container();
    }
    return Column(children: <Widget>[
      cabecalhoResumoPatrimonio(),
      Expanded(
          child: RefreshIndicator(
              onRefresh: () async {
                atualizarCotacoes();
              },
              child: ListView.builder(
                itemCount: _objetivos.length,
                itemBuilder: (context, index) {
                  return ItemPatrimonio(
                    objetivo: _objetivos[index],
                    callback: buscarDados,
                    usuario: widget.usuario,
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
}
