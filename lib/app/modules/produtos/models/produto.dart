class Produto {
  final int id;
  final int lojaId;
  final String nome;
  final String? descricao;
  final double preco;
  final double? precoPromocional;
  final String? imagem;
  final String? categoria;
  final String? subcategoria;
  final bool disponivel;
  final int? tempoPreparo;
  final Map<String, dynamic>? variacoes;
  final Map<String, dynamic>? opcoes;

  Produto({
    required this.id,
    required this.lojaId,
    required this.nome,
    this.descricao,
    required this.preco,
    this.precoPromocional,
    this.imagem,
    this.categoria,
    this.subcategoria,
    required this.disponivel,
    this.tempoPreparo,
    this.variacoes,
    this.opcoes,
  });

  factory Produto.fromJson(Map<String, dynamic> json) {
    return Produto(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id'].toString()) ?? 0,
      lojaId: json['loja_id'] is int ? json['loja_id'] : int.tryParse(json['loja_id'].toString()) ?? 0,
      nome: json['nome'] ?? '',
      descricao: json['descricao'],
      preco: (json['preco'] as num?)?.toDouble() ?? 0,
      precoPromocional: (json['preco_promocional'] as num?)?.toDouble(),
      imagem: json['imagem'],
      categoria: json['categoria'],
      subcategoria: json['subcategoria'],
      disponivel: json['disponivel'] == 1 || json['disponivel'] == true,
      tempoPreparo: json['tempo_preparo_min'],
      variacoes: json['variacoes'],
      opcoes: json['opcoes'],
    );
  }

  bool get emPromocao => precoPromocional != null && precoPromocional! < preco;
}
