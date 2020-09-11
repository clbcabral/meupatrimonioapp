import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:meupatrimonio/models/reserva.dart';
import 'package:meupatrimonio/pages/reserva/formReserva.dart';
import 'package:meupatrimonio/pages/reserva/itemReserva.dart';
import 'package:meupatrimonio/services/bdRemoto.dart';
import 'package:meupatrimonio/shared/componentes.dart';
import 'package:meupatrimonio/vals/strings.dart';

class ReservasWidget extends StatefulWidget {
  final String titulo;
  final String tipo;
  final FirebaseUser usuario;
  ReservasWidget({Key key, this.titulo, this.tipo, this.usuario})
      : super(key: key);
  @override
  ReservasState createState() => ReservasState();
}

class ReservasState extends State<ReservasWidget> {
  final _formatador = NumberFormat.simpleCurrency(locale: 'pt_br');
  List<Reserva> _reservas = [];
  bool _carregando = false;

  @override
  void initState() {
    super.initState();
    buscarDados();
  }

  void buscarDados() async {
    _carregando = true;
    List<Reserva> reservas = await ServicoBancoRemoto(widget.usuario.uid)
        .listarReservas(widget.tipo);
    setState(() {
      _reservas = reservas;
      _carregando = false;
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
    return _carregando
        ? Loader()
        : Scaffold(
            appBar: AppBar(
                title: Text(
              widget.titulo,
              style: TextStyle(fontSize: 16),
            )),
            floatingActionButton: FloatingActionButton(
              child: Icon(Icons.add),
              onPressed: () => {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) {
                      Reserva reserva = Reserva.exemplo();
                      reserva.tipo = widget.tipo;
                      reserva.uid = widget.usuario.uid;
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
