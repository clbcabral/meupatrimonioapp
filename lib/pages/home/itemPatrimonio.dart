import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:meupatrimonio/models/objetivo.dart';
import 'package:meupatrimonio/pages/ativo/ativos.dart';
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
    double atual =
        this.objetivo.sumValores / (this.subtotal > 0 ? this.subtotal : 1);
    double ideal = this.objetivo.percentual;
    return Padding(
      padding: EdgeInsets.only(top: 5.0),
      child: Card(
        margin: EdgeInsets.fromLTRB(5.0, 0.0, 5.0, 0.0),
        child: ListTile(
          onTap: () async {
            Widget widgetRota;
            if (this.objetivo.ehUmaReserva()) {
              widgetRota = ReservasWidget(
                titulo: this.objetivo.nome,
                tipo: this.objetivo.tipo,
              );
            } else if (this.objetivo.ehUmAtivo()) {
              widgetRota = AtivosWidget(
                titulo: this.objetivo.nome,
                tipo: this.objetivo.tipo,
              );
            }
            if (widgetRota != null) {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => widgetRota),
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
          dense: true,
          subtitle: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Ideal: ${formatador.format(ideal)}'),
              Text(
                'Atual: ${formatador.format(atual)}',
                style:
                    TextStyle(color: atual > ideal ? Colors.red : Colors.green),
              )
            ],
          ),
          trailing: Text(
            _formatador.format(this.objetivo.sumValores ?? 0),
            style: TextStyle(
              color:
                  this.objetivo.sumValores > 0.0 ? Colors.green : Colors.black,
              fontSize: 15,
            ),
          ),
        ),
      ),
    );
  }
}
