import 'package:flutter/material.dart';
import 'package:meupatrimonio/models/reserva.dart';
import 'package:meupatrimonio/pages/reserva/formReserva.dart';
import 'package:meupatrimonio/vals/strings.dart';
import 'package:sticky_headers/sticky_headers/widget.dart';

class ReservasWidget extends StatefulWidget {
  final String titulo;
  final String tipo;
  ReservasWidget({
    this.titulo,
    this.tipo,
  });
  @override
  ReservasState createState() => ReservasState();
}

class ReservasState extends State<ReservasWidget> {
  List<Reserva> _reservas = [];

  @override
  void initState() {
    super.initState();
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
                  builder: (context) => ReservaForm(
                        reserva: Reserva.vazio(),
                      )),
            )
          },
        ),
        body: corpo(context));
  }

  Widget corpo(BuildContext context) {
    if (_reservas == null || _reservas.isEmpty) {
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
            height: 50.0,
            color: Colors.black,
            padding: EdgeInsets.symmetric(horizontal: 16.0),
            alignment: Alignment.centerLeft,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Text(
                  'Total',
                  style: const TextStyle(color: Colors.white),
                ),
                Text(
                  '${0.0}',
                  style: const TextStyle(color: Colors.white),
                ),
              ],
            ),
          ),
          content: Column(
            children: [].map<Widget>((item) {
              return Container();
            }).toList(),
          ),
        );
      },
    );
  }
}
