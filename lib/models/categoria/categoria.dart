class Categoria {
  int? id;
  String nome;
  String tipo; // 'receita' or 'despesa'
  int usuarioId;

  Categoria({
    this.id,
    required this.nome,
    required this.tipo,
    required this.usuarioId,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nome': nome,
      'tipo': tipo,
      'usuarioId': usuarioId,
    };
  }

  factory Categoria.fromMap(Map<String, dynamic> map) {
    return Categoria(
      id: map['id'],
      nome: map['nome'],
      tipo: map['tipo'],
      usuarioId: map['usuarioId'],
    );
  }

  @override
  String toString() {
    return 'Categoria{id: $id, nome: $nome, tipo: $tipo, usuarioId: $usuarioId}';
  }
}
