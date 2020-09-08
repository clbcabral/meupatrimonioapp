class Usuario {
  String id;
  String email;
  String nome;

  Usuario({
    this.id,
    this.email,
    this.nome,
  });

  Usuario.fromMap(Map<String, dynamic> map) {
    this.id = map['id'];
    this.email = map['email'];
    this.nome = map['nome'];
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'email': email,
      'nome': nome,
    };
  }
}
