class Receita {
  int? id;
  int usuarioId;
  int? categoriaId;
  String descricao;
  double valor;
  DateTime data;
  DateTime dataCriacao;
//Construtor da classe Receita
  Receita({
    this.id,
    required this.usuarioId,
    this.categoriaId,
    required this.descricao,
    required this.valor,
    required this.data,
    DateTime? dataCriacao,
  }) : dataCriacao = dataCriacao ?? DateTime.now();

  // Converte Receita para Map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'usuarioId': usuarioId,
      'categoriaId': categoriaId,
      'descricao': descricao,
      'valor': valor,
      'data': data.toIso8601String(),
      'dataCriacao': dataCriacao.toIso8601String(),
    };
  }

  // Cria Receita a partir do Map
  factory Receita.fromMap(Map<String, dynamic> map) {
    return Receita(
      id: map['id'],
      usuarioId: map['usuarioId'],
      categoriaId: map['categoriaId'],
      descricao: map['descricao'],
      valor: map['valor'],
      data: DateTime.parse(map['data']),
      dataCriacao: DateTime.parse(map['dataCriacao']),
    );
  }

  @override
  String toString() {
    return 'Receita{id: $id, descricao: $descricao, valor: $valor, data: $data}';
  }
}
