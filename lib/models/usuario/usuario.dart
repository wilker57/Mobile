class Usuario {
  int? id;
  String nome;
  String email;
  String senha;
  DateTime dataCriacao;
//Construtor da classe Usuario
  Usuario({
    this.id,
    required this.nome,
    required this.email,
    required this.senha,
    DateTime? dataCriacao,
  }) : dataCriacao = dataCriacao ?? DateTime.now();

  // Converte Usuario para Map para inserir no banco
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nome': nome,
      'email': email,
      'senha': senha,
      'dataCriacao': dataCriacao.toIso8601String(),
    };
  }

  // Cria Usuario a partir do Map do banco
  factory Usuario.fromMap(Map<String, dynamic> map) {
    return Usuario(
      id: map['id'],
      nome: map['nome'],
      email: map['email'],
      senha: map['senha'],
      dataCriacao: DateTime.parse(map['dataCriacao']),
    );
  }

  @override
  String toString() {
    return 'Usuario{id: $id, nome: $nome, email: $email}';
  }
}
