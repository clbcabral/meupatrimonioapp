class Percentual {
  String descricao;
  double atual;
  double ideal;
  double falta;

  Percentual({
    this.descricao,
    this.atual,
    this.ideal,
    this.falta,
  });

  Percentual.fromMap(Map<String, dynamic> map) {
    this.descricao = map['descricao'];
    this.atual = map['atual'];
    this.ideal = map['ideal'];
    this.falta = map['falta'];
  }

  Map<String, dynamic> toMap() {
    return {
      'descricao': descricao,
      'atual': atual,
      'ideal': ideal,
      'falta': falta,
    };
  }

  @override
  String toString() {
    return {
      'descricao': descricao,
      'atual': atual,
      'ideal': ideal,
      'falta': falta,
    }.toString();
  }
}
