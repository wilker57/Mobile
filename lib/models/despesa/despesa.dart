class Despesa {
  int? id;
  int usuarioId;
  int? categoriaId;
  String descricao;
  double valor;
  DateTime data;
  DateTime dataCriacao;
  String pagamentoTipo;
  int parcelasTotal;
  int? parcelaNumero;
//Construtor da classe Despesa
  Despesa({
    this.id,
    required this.usuarioId,
    this.categoriaId,
    required this.descricao,
    required this.valor,
    required this.data,
    DateTime? dataCriacao,
    this.pagamentoTipo = 'AVISTA',
    this.parcelasTotal = 1,
    this.parcelaNumero = 1,
  }) : dataCriacao = dataCriacao ?? DateTime.now();
//Convertendo objeto Despesa para Map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'usuarioId': usuarioId,
      'categoriaId': categoriaId,
      'descricao': descricao,
      'valor': valor,
      'data': data.toIso8601String(),
      'dataCriacao': dataCriacao.toIso8601String(),
      'pagamentoTipo': pagamentoTipo,
      'parcelasTotal': parcelasTotal,
      'parcelaNumero': parcelaNumero,
    };
  }

//Convertendo Map para objeto Despesa
  factory Despesa.fromMap(Map<String, dynamic> map) {
    return Despesa(
      id: map['id'],
      usuarioId: map['usuarioId'],
      categoriaId: map['categoriaId'],
      descricao: map['descricao'],
      valor: map['valor'],
      data: DateTime.parse(map['data']),
      dataCriacao: DateTime.parse(map['dataCriacao']),
      pagamentoTipo: map['pagamentoTipo'] ?? 'AVISTA',
      parcelasTotal: map['parcelasTotal'] ?? 1,
      parcelaNumero: map['parcelaNumero'] ?? 1,
    );
  }

//apresenta string formatado do objeto Despesa
  @override
  String toString() {
    return 'Despesa{id: $id, descricao: $descricao, valor: $valor, data: $data}';
  }
}
