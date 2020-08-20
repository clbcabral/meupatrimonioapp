class Reserva {
  String id;
  String nome;
  double valor;
  String tipo;

  Reserva({
    this.id,
    this.nome,
    this.valor,
    this.tipo,
  });

  Reserva.vazio() {
    id = null;
    nome = null;
    valor = null;
    tipo = null;
  }

  Reserva.exemplo() {
    id = '';
    nome = '';
    valor = 0.0;
    tipo = '';
  }

  Reserva.fromMap(Map<String, dynamic> map) {
    this.id = map['id'];
    this.nome = map['nome'];
    this.valor = map['valor'];
    this.tipo = map['tipo'];
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nome': nome,
      'valor': valor,
      'tipo': tipo,
    };
  }

  bool equalTo(Reserva reserva) {
    return this.id == reserva.id &&
        this.nome == reserva.nome &&
        this.valor == reserva.valor &&
        this.tipo == reserva.tipo;
  }

  Reserva clone() {
    return Reserva(
      id: this.id,
      nome: this.nome,
      valor: this.valor,
      tipo: this.tipo,
    );
  }
}
