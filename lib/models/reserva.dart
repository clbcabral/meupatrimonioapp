class Reserva {
  String id;
  String nome;
  double valor;
  String tipo;
  String uid;

  Reserva({
    this.id,
    this.nome,
    this.valor,
    this.tipo,
    this.uid,
  });

  Reserva.exemplo() {
    id = '';
    nome = '';
    valor = 0.0;
    tipo = '';
    uid = '';
  }

  Reserva.fromMap(Map<String, dynamic> map) {
    this.id = map['id'];
    this.nome = map['nome'];
    this.valor = map['valor'];
    this.tipo = map['tipo'];
    this.uid = map['uid'];
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nome': nome,
      'valor': valor,
      'tipo': tipo,
      'uid': uid,
    };
  }

  bool equalTo(Reserva reserva) {
    return this.id == reserva.id &&
        this.nome == reserva.nome &&
        this.valor == reserva.valor &&
        this.tipo == reserva.tipo &&
        this.uid == reserva.uid;
  }

  Reserva clone() {
    return Reserva(
      id: this.id,
      nome: this.nome,
      valor: this.valor,
      tipo: this.tipo,
      uid: this.uid,
    );
  }

  @override
  String toString() {
    return {
      'id': id,
      'nome': nome,
      'valor': valor,
      'tipo': tipo,
      'uid': uid,
    }.toString();
  }
}
