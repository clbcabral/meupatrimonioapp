import 'package:meupatrimonio/vals/constantes.dart';

class Objetivo {
  String id;
  String nome;
  String tipo;
  double valor;
  double ideal;
  double atual;
  double falta;
  int ordem;
  String uid;

  Objetivo({
    this.id,
    this.nome,
    this.tipo,
    this.valor,
    this.ideal,
    this.atual,
    this.falta,
    this.ordem,
    this.uid,
  });

  bool ehUmAtivo() {
    return [ATIVO_ACAO, ATIVO_FII, ATIVO_RF, ATIVO_STOCK, ATIVO_REIT]
        .contains(this.tipo);
  }

  bool ehUmaReserva() {
    return [REVERSA_EMERGENCIA, REVERSA_OPORTUNIDADE, REVERSA_VALOR]
        .contains(this.tipo);
  }

  bool ehReservaEmergencia() {
    return REVERSA_EMERGENCIA == this.tipo;
  }

  Objetivo.fromMap(Map<String, dynamic> map) {
    this.id = map['id'];
    this.nome = map['nome'];
    this.tipo = map['tipo'];
    this.valor = map['valor'];
    this.ideal = map['ideal'];
    this.atual = map['atual'];
    this.falta = map['falta'];
    this.ordem = map['ordem'];
    this.uid = map['uid'];
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nome': nome,
      'tipo': tipo,
      'valor': valor,
      'ideal': ideal,
      'atual': atual,
      'falta': falta,
      'ordem': ordem,
      'uid': uid,
    };
  }

  bool equalTo(Objetivo objetivo) {
    return this.id == objetivo.id && this.ideal == objetivo.ideal;
  }

  @override
  String toString() {
    return {
      'id': id,
      'nome': nome,
      'tipo': tipo,
      'valor': valor,
      'ideal': ideal,
      'atual': atual,
      'falta': falta,
      'ordem': ordem,
      'uid': uid,
    }.toString();
  }
}
