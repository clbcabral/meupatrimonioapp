import 'package:meupatrimonio/vals/constantes.dart';

class Objetivo {
  String id;
  String nome;
  String tipo;
  double percentual;
  double valor;
  int ordem;
  double sumValores;

  Objetivo({
    this.id,
    this.nome,
    this.tipo,
    this.percentual,
    this.valor,
    this.ordem,
  });

  bool ehUmAtivo() {
    return [ATIVO_ACAO, ATIVO_FII, ATIVO_RF, ATIVO_STOCK, ATIVO_REIT]
        .contains(this.tipo);
  }

  bool ehUmaReserva() {
    return [REVERSA_EMERGENCIA, REVERSA_OPORTUNIDADE, REVERSA_VALOR]
        .contains(this.tipo);
  }

  Objetivo.exemplo() {
    id = '';
    nome = '';
    tipo = '';
    percentual = 0.0;
    valor = 0.0;
    ordem = 0;
    sumValores = 0.0;
  }

  Objetivo.fromMap(Map<String, dynamic> map) {
    this.id = map['id'];
    this.nome = map['nome'];
    this.tipo = map['tipo'];
    this.percentual = map['percentual'];
    this.valor = map['valor'];
    this.ordem = map['ordem'];
    this.sumValores = map['sumValores'];
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nome': nome,
      'tipo': tipo,
      'percentual': percentual,
      'valor': valor,
      'ordem': ordem,
      'sumValores': sumValores,
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
      'sumValores': sumValores,
    }.toString();
  }
}
