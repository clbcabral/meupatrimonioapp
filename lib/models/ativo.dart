class Ativo {
  String id;
  String nome;
  String ticker;
  double cotacao;
  double quantidade;
  String tipo;

  Ativo({
    this.id,
    this.nome,
    this.ticker,
    this.cotacao,
    this.quantidade,
    this.tipo,
  });

  double valor() {
    return this.cotacao * this.quantidade;
  }

  Ativo.vazio() {
    id = null;
    nome = null;
    ticker = null;
    cotacao = null;
    quantidade = null;
    tipo = null;
  }

  Ativo.exemplo() {
    id = '';
    nome = '';
    ticker = '';
    cotacao = 0.0;
    quantidade = 0.0;
    tipo = '';
  }

  Ativo.fromMap(Map<String, dynamic> map) {
    this.id = map['id'];
    this.nome = map['nome'];
    this.ticker = map['ticker'];
    this.cotacao = map['cotacao'];
    this.quantidade = map['quantidade'];
    this.tipo = map['tipo'];
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nome': nome,
      'ticker': ticker,
      'cotacao': cotacao,
      'quantidade': quantidade,
      'tipo': tipo,
    };
  }

  bool equalTo(Ativo ativo) {
    return this.id == ativo.id &&
        this.nome == ativo.nome &&
        this.ticker == ativo.ticker &&
        this.cotacao == ativo.cotacao &&
        this.quantidade == ativo.quantidade &&
        this.tipo == ativo.tipo;
  }

  Ativo clone() {
    return Ativo(
      id: this.id,
      nome: this.nome,
      ticker: this.ticker,
      cotacao: this.cotacao,
      quantidade: this.quantidade,
      tipo: this.tipo,
    );
  }

  @override
  String toString() {
    return {
      'id': id,
      'nome': nome,
      'ticker': ticker,
      'cotacao': cotacao,
      'quantidade': quantidade,
      'tipo': tipo,
    }.toString();
  }
}
