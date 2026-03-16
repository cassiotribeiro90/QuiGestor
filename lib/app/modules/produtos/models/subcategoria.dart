class Subcategoria {
  final int id;
  final int categoriaId;
  final String nome;
  final String? icone;

  Subcategoria({
    required this.id,
    required this.categoriaId,
    required this.nome,
    this.icone,
  });

  factory Subcategoria.fromJson(Map<String, dynamic> json) {
    return Subcategoria(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id'].toString()) ?? 0,
      categoriaId: json['categoria_id'] is int ? json['categoria_id'] : int.tryParse(json['categoria_id'].toString()) ?? 0,
      nome: json['nome'] ?? '',
      icone: json['icone'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'categoria_id': categoriaId,
      'nome': nome,
      'icone': icone,
    };
  }
}
