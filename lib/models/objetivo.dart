class Objetivo {
  String id;
  String nome;
  String tipo;
  double percentual;
  double valor;
  int ordem;

  Objetivo({
    this.id,
    this.nome,
    this.tipo,
    this.percentual,
    this.valor,
    this.ordem,
  });

  Objetivo.vazio() {
    id = null;
    nome = null;
    tipo = null;
    percentual = null;
    valor = null;
    ordem = null;
  }

  Objetivo.exemplo() {
    id = '';
    nome = '';
    tipo = '';
    percentual = 0.0;
    valor = 0.0;
    ordem = 0;
  }

  Objetivo.fromMap(Map<String, dynamic> map) {
    this.id = map['id'];
    this.nome = map['nome'];
    this.tipo = map['tipo'];
    this.percentual = map['percentual'];
    this.valor = map['valor'];
    this.ordem = map['ordem'];
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nome': nome,
      'tipo': tipo,
      'percentual': percentual,
      'valor': valor,
      'ordem': ordem,
    };
  }

  bool equalTo(Objetivo objetivo) {
    return this.id == objetivo.id &&
        this.nome == objetivo.nome &&
        this.tipo == objetivo.tipo &&
        this.percentual == objetivo.percentual &&
        this.valor == objetivo.valor &&
        this.ordem == objetivo.ordem;
  }

  Objetivo clone() {
    return Objetivo(
      id: this.id,
      nome: this.nome,
      tipo: this.tipo,
      percentual: this.percentual,
      valor: this.valor,
      ordem: this.ordem,
    );
  }

  @override
  String toString() {
    return {
      'id': id,
      'nome': nome,
      'tipo': tipo,
      'percentual': percentual,
      'valor': valor,
      'ordem': ordem,
    }.toString();
  }
}
