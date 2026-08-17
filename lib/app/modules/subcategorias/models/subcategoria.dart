class Subcategoria {
  final int id;
  final String nome;
  final int? categoriaId;
  final String? categoriaNome; // Adicionado para facilitar exibição na lista
  final String? descricao;
  final String? icone;
  final bool ativo;

  Subcategoria({
    required this.id,
    required this.nome,
    this.categoriaId,
    this.categoriaNome,
    this.descricao,
    this.icone,
    this.ativo = true,
  });

  factory Subcategoria.fromJson(Map<String, dynamic> json) => Subcategoria(
    id: json['id'] is int ? json['id'] : int.tryParse(json['id'].toString()) ?? 0,
    nome: json['nome'] ?? '',
    categoriaId: json['categoria_id'] is int ? json['categoria_id'] : int.tryParse(json['categoria_id']?.toString() ?? ''),
    categoriaNome: json['categoria_nome'] ?? json['categoria']?['nome'],
    descricao: json['descricao'],
    icone: json['icone'],
    ativo: json['status'] == 1 || json['ativo'] == 1,
  );

  Map<String, dynamic> toJson() => {
    'nome': nome,
    'categoria_id': categoriaId,
    'descricao': descricao,
    'status': ativo ? 1 : 0,
  };
}
