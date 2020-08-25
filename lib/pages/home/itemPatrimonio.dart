import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:meupatrimonio/models/objetivo.dart';
import 'package:meupatrimonio/pages/reserva/reservas.dart';

class ItemPatrimonio extends StatelessWidget {
  final NumberFormat _formatador = NumberFormat.simpleCurrency(locale: 'pt_br');
  final double subtotal;
  final Objetivo objetivo;
  final Function callback;

  ItemPatrimonio({
    this.subtotal,
    this.objetivo,
    this.callback,
  });

  @override
  Widget build(BuildContext context) {
    NumberFormat formatador = NumberFormat.percentPattern();
    double cumprido =
        this.objetivo.valor / (this.subtotal > 0 ? this.subtotal : 1);
    return Padding(
      padding: EdgeInsets.only(top: 5.0),
      child: Card(
        margin: EdgeInsets.fromLTRB(5.0, 0.0, 5.0, 0.0),
        child: ListTile(
          onTap: () async {
            if (this.objetivo.ehUmaReserva()) {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => ReservasWidget(
                          titulo: this.objetivo.nome,
                          tipo: this.objetivo.tipo,
                        )),
              ).then((value) => callback());
            }
            print('clicou: ' + this.objetivo.tipo);
          },
          contentPadding: EdgeInsets.all(7),
          leading: CircleAvatar(
            radius: 25.0,
            backgroundColor: Theme.of(context).backgroundColor,
            child: Icon(Icons.attach_money),
          ),
          title: Text(
            this.objetivo.nome,
            style: const TextStyle(),
          ),
          subtitle: Text(
              '${formatador.format(cumprido)} de ${formatador.format(this.objetivo.percentual)}'),
          trailing: Text(
            _formatador.format(this.objetivo.valor),
            style: TextStyle(
              color: this.objetivo.valor > 0.0 ? Colors.green : Colors.black,
              fontSize: 15,
            ),
          ),
        ),
      ),
    );
  }
}
