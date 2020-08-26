import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:meupatrimonio/models/ativo.dart';
import 'package:meupatrimonio/pages/ativo/formAtivo.dart';

class ItemAtivo extends StatelessWidget {
  final Ativo ativo;
  final Function callback;
  final double totalAtivos;
  final double totalPesos;
  final NumberFormat _fmtValor = NumberFormat.simpleCurrency(locale: 'pt_br');
  final NumberFormat _fmtPct = NumberFormat.percentPattern();

  ItemAtivo({this.ativo, this.totalAtivos, this.totalPesos, this.callback});

  @override
  Widget build(BuildContext context) {
    double ideal = this.ativo.peso / this.totalPesos;
    double atual = this.ativo.valor() / this.totalAtivos;
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
                  return AtivoForm(
                    ativo: ativo,
                    callback: callback,
                  );
                },
              ),
            );
          },
          contentPadding: EdgeInsets.all(7),
          leading: CircleAvatar(
            radius: 25.0,
            backgroundColor: Theme.of(context).backgroundColor,
            child: Icon(Icons.account_balance),
          ),
          dense: true,
          title: Text(
            this.ativo.ticker,
            style: const TextStyle(),
          ),
          subtitle: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Ideal: ${_fmtPct.format(ideal)}'),
              Text(
                'Atual: ${_fmtPct.format(atual)}',
                style:
                    TextStyle(color: atual > ideal ? Colors.red : Colors.green),
              )
            ],
          ),
          trailing: Text(
            _fmtValor.format(this.ativo.valor()),
            style: TextStyle(
              color: this.ativo.valor() > 0.0 ? Colors.green : Colors.black,
              fontSize: 15,
            ),
          ),
        ),
      ),
    );
  }
}
