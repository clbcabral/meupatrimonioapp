import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:meupatrimonio/models/ativo.dart';
import 'package:meupatrimonio/pages/ativo/formAtivo.dart';
import 'package:meupatrimonio/services/bancoLocal.dart';
import 'package:meupatrimonio/vals/strings.dart';
import 'package:sticky_headers/sticky_headers/widget.dart';

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(widget.titulo),
          actions: <Widget>[
            IconButton(
              icon: Icon(Icons.help),
              onPressed: () => {},
            ),
          ],
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
        body: corpo(context));
  }

  Widget corpo(BuildContext context) {
    if (_ativos == null || _ativos.isEmpty) {
      return Container(
        child: Center(
          child: Text(Strings.dicaAdicionar),
        ),
      );
    }
    return ListView.builder(
      itemCount: 1,
      itemBuilder: (context, index) {
        return StickyHeader(
          header: Container(
            height: 75.0,
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
          ),
          content: Column(
            children: _ativos.map<Widget>((item) {
              return Container(
                child: Text(item.nome),
                // child: ItemReserva(
                //   reserva: item,
                //   callback: buscarDados,
                // ),
              );
            }).toList(),
          ),
        );
      },
    );
  }
}
