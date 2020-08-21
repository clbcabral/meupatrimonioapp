import 'package:flutter/material.dart';

class ItemPatrimonio extends StatelessWidget {
  final String titulo;
  final IconData icone;
  final String tipo;
  final double valor;

  ItemPatrimonio({
    this.titulo,
    this.valor,
    this.icone,
    this.tipo,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(top: 5.0),
      child: Card(
        margin: EdgeInsets.fromLTRB(5.0, 0.0, 5.0, 0.0),
        child: ListTile(
          onTap: () {
            print('clicou: ' + this.tipo);
          },
          leading: CircleAvatar(
            radius: 25.0,
            backgroundColor: Theme.of(context).backgroundColor,
            child: Icon(this.icone),
          ),
          title: Text(
            this.titulo,
            style: const TextStyle(),
          ),
          subtitle: null,
          trailing: Text(
            'R\$ ${this.valor}',
            style: TextStyle(
              color: Colors.green,
              fontSize: 18,
            ),
          ),
        ),
      ),
    );
  }
}
