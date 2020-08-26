import 'package:meupatrimonio/vals/constantes.dart';

class Ativo {
  String id;
  String nome;
  String ticker;
  double cotacao;
  double quantidade;
  double peso;
  String tipo;

  Ativo({
    this.id,
    this.nome,
    this.ticker,
    this.cotacao,
    this.quantidade,
    this.peso,
    this.tipo,
  });

  double valor() {
    if (this.cotacao == null || this.quantidade == null) {
      return 0.0;
    }
    return this.cotacao * this.quantidade;
  }

  bool ehAtivoDolarizado() {
    return [ATIVO_STOCK, ATIVO_REIT].contains(this.tipo);
  }

  Ativo.exemplo() {
    id = '';
    nome = '';
    ticker = '';
    cotacao = 0.0;
    quantidade = 0.0;
    peso = 0;
    tipo = '';
  }

  Ativo.fromMap(Map<String, dynamic> map) {
    this.id = map['id'];
    this.nome = map['nome'];
    this.ticker = map['ticker'];
    this.cotacao = map['cotacao'];
    this.quantidade = map['quantidade'];
    this.peso = map['peso'];
    this.tipo = map['tipo'];
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nome': nome,
      'ticker': ticker,
      'cotacao': cotacao,
      'quantidade': quantidade,
      'peso': peso,
      'tipo': tipo,
    };
  }

  bool equalTo(Ativo ativo) {
    return this.id == ativo.id &&
        this.nome == ativo.nome &&
        this.ticker == ativo.ticker &&
        this.cotacao == ativo.cotacao &&
        this.quantidade == ativo.quantidade &&
        this.peso == ativo.peso &&
        this.tipo == ativo.tipo;
  }

  Ativo clone() {
    return Ativo(
      id: this.id,
      nome: this.nome,
      ticker: this.ticker,
      cotacao: this.cotacao,
      quantidade: this.quantidade,
      peso: this.peso,
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
      'peso': peso,
      'tipo': tipo,
    }.toString();
  }
}
