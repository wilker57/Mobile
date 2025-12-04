class Categoria {
  int? id;
  String nome;
  String tipo;
  int usuarioId;
//Construtor da classe Categoria
  Categoria({
    this.id,
    required this.nome,
    required this.tipo,
    required this.usuarioId,
  });
//Convertendo objeto Categoria para Map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nome': nome,
      'tipo': tipo,
      'usuarioId': usuarioId,
    };
  }

//Convertendo Map para objeto Categoria
  factory Categoria.fromMap(Map<String, dynamic> map) {
    return Categoria(
      id: map['id'],
      nome: map['nome'],
      tipo: map['tipo'],
      usuarioId: map['usuarioId'],
    );
  }
//apresenta string formatado do objeto Categoria
  @override
  String toString() {
    return 'Categoria{id: $id, nome: $nome, tipo: $tipo, usuarioId: $usuarioId}';
  }
}
