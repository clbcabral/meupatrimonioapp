class Divida {
  String id;
  String nome;
  double valor;

  Divida({
    this.id,
    this.nome,
    this.valor,
  });

  Divida.vazio() {
    id = null;
    nome = null;
    valor = null;
  }

  Divida.exemplo() {
    id = '';
    nome = '';
    valor = 0.0;
  }

  Divida.fromMap(Map<String, dynamic> map) {
    this.id = map['id'];
    this.nome = map['nome'];
    this.valor = map['valor'];
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nome': nome,
      'valor': valor,
    };
  }

  bool equalTo(Divida divida) {
    return this.id == divida.id &&
        this.nome == divida.nome &&
        this.valor == divida.valor;
  }

  Divida clone() {
    return Divida(
      id: this.id,
      nome: this.nome,
      valor: this.valor,
    );
  }
}
