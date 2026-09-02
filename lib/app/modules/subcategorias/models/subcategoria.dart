import '../../../../shared/utils/image_helper.dart';

class Subcategoria {
  final int id;
  final String nome;
  final int? categoriaId;
  final String? categoriaNome; // Adicionado para facilitar exibição na lista
  final String? categoriaEmoji; // Emoji da categoria pai
  final String? descricao;
  final String? icone;
  final bool ativo;

  Subcategoria({
    required this.id,
    required this.nome,
    this.categoriaId,
    this.categoriaNome,
    this.categoriaEmoji,
    this.descricao,
    this.icone,
    this.ativo = true,
  });

  factory Subcategoria.fromJson(Map<String, dynamic> json) => Subcategoria(
    id: json['id'] is int ? json['id'] : int.tryParse(json['id'].toString()) ?? 0,
    nome: json['nome'] ?? '',
    categoriaId: json['categoria_id'] is int ? json['categoria_id'] : int.tryParse(json['categoria_id']?.toString() ?? ''),
    categoriaNome: json['categoria_nome'] ?? json['categoria']?['nome'],
    categoriaEmoji: json['categoria_icone'] as String? ?? json['categoria']?['icone'] as String?,
    descricao: json['descricao'],
    icone: json['icone'],
    ativo: json['status'] == 1 || json['ativo'] == 1 || json['ativo'] == true || json['ativo'] == '1',
  );

  Subcategoria copyWith({
    int? id,
    String? nome,
    int? categoriaId,
    String? categoriaNome,
    String? categoriaEmoji,
    String? descricao,
    String? icone,
    bool? ativo,
  }) {
    return Subcategoria(
      id: id ?? this.id,
      nome: nome ?? this.nome,
      categoriaId: categoriaId ?? this.categoriaId,
      categoriaNome: categoriaNome ?? this.categoriaNome,
      categoriaEmoji: categoriaEmoji ?? this.categoriaEmoji,
      descricao: descricao ?? this.descricao,
      icone: icone ?? this.icone,
      ativo: ativo ?? this.ativo,
    );
  }

  Map<String, dynamic> toJson() => {
    'nome': nome,
    'categoria_id': categoriaId,
    'categoria_icone': categoriaEmoji,
    'descricao': descricao,
    'status': ativo ? 1 : 0,
  };

  String get iconeUrl => ImageHelper.getFullImageUrl(icone);
}
