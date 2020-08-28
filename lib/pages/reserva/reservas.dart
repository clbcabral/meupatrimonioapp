import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:meupatrimonio/models/reserva.dart';
import 'package:meupatrimonio/pages/reserva/formReserva.dart';
import 'package:meupatrimonio/pages/reserva/itemReserva.dart';
import 'package:meupatrimonio/services/bancoLocal.dart';
import 'package:meupatrimonio/vals/strings.dart';
import 'package:sticky_headers/sticky_headers/widget.dart';

class ReservasWidget extends StatefulWidget {
  final String titulo;
  final String tipo;
  ReservasWidget({Key key, this.titulo, this.tipo}) : super(key: key);
  @override
  ReservasState createState() => ReservasState();
}

class ReservasState extends State<ReservasWidget> {
  final _formatador = NumberFormat.simpleCurrency(locale: 'pt_br');
  List<Reserva> _reservas = [];

  @override
  void initState() {
    super.initState();
    buscarDados();
  }

  void buscarDados() async {
    List<Reserva> reservas =
        await ServicoBancoLocal().listarReservas(widget.tipo);
    setState(() {
      _reservas = reservas;
    });
  }

  double calcularTotal() {
    if (_reservas == null) {
      return 0.0;
    }
    return _reservas.fold(0.0, (val, reserva) => val + reserva.valor);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(
            widget.titulo,
            style: TextStyle(fontSize: 16),
          ),
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
                  Reserva reserva = Reserva.exemplo();
                  reserva.tipo = widget.tipo;
                  return ReservaForm(
                    reserva: reserva,
                    callback: buscarDados,
                  );
                },
              ),
            )
          },
        ),
        body: corpo(context));
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
    if (_reservas == null || _reservas.isEmpty) {
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
            buscarDados();
          },
          child: ListView.builder(
            itemCount: _reservas.length,
            itemBuilder: (context, index) {
              return Container(
                child: ItemReserva(
                  reserva: _reservas[index],
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
