import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:meupatrimonio/models/reserva.dart';
import 'package:meupatrimonio/pages/reserva/formReserva.dart';

class ItemReserva extends StatelessWidget {
  final Reserva reserva;
  final Function callback;
  final NumberFormat _formatador = NumberFormat.simpleCurrency(locale: 'pt_br');

  ItemReserva({this.reserva, this.callback});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(5.0),
      child: Card(
        margin: EdgeInsets.fromLTRB(5.0, 0.0, 5.0, 0.0),
        child: ListTile(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) {
                  return ReservaForm(
                    reserva: reserva,
                    callback: callback,
                  );
                },
              ),
            );
          },
          contentPadding: EdgeInsets.all(7),
          dense: true,
          leading: CircleAvatar(
            radius: 25.0,
            backgroundColor: Theme.of(context).backgroundColor,
            child: Icon(Icons.account_balance),
          ),
          title: Text(
            this.reserva.nome,
            style: const TextStyle(),
          ),
          trailing: Text(
            _formatador.format(this.reserva.valor),
            style: TextStyle(
              color: this.reserva.valor > 0.0 ? Colors.green : Colors.black,
              fontSize: 14,
            ),
          ),
        ),
      ),
    );
  }
}
