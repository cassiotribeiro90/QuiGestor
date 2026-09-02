
import '../../../../shared/utils/image_helper.dart';

class Produto {
  final int id;
  final int lojaId;
  final String nome;
  final String? slug;
  final String? descricao;
  final double preco;
  final double? precoPromocional;
  final String? imagem;
  final List<String>? imagens;
  final int? categoriaId;
  final int? subcategoriaId;
  final String? subcategoria;
  final bool disponivel;
  final bool ativo;
  final bool destaque;
  final int? tempoPreparo;
  final int ordem;
  final String? ingredientesTexto;
  final List<dynamic>? ingredientes;
  final int? calorias;
  final double? pesoGramas;
  final bool contemGluten;
  final bool contemLactose;
  final bool vegano;
  final bool vegetariano;
  final bool apimentado;
  final int estoque;
  final Map<String, dynamic>? variacoes;
  final Map<String, dynamic>? opcoes;

  Produto({
    required this.id,
    required this.lojaId,
    required this.nome,
    this.slug,
    this.descricao,
    required this.preco,
    this.precoPromocional,
    this.imagem,
    this.imagens,
    this.categoriaId,
    this.subcategoriaId,
    this.subcategoria,
    required this.disponivel,
    this.ativo = true,
    this.destaque = false,
    this.tempoPreparo,
    this.ordem = 0,
    this.ingredientesTexto,
    this.ingredientes,
    this.calorias,
    this.pesoGramas,
    this.contemGluten = false,
    this.contemLactose = false,
    this.vegano = false,
    this.vegetariano = false,
    this.apimentado = false,
    this.estoque = 0,
    this.variacoes,
    this.opcoes,
  });

  factory Produto.fromJson(Map<String, dynamic> json) {
    return Produto(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id'].toString()) ?? 0,
      lojaId: json['loja_id'] is int ? json['loja_id'] : int.tryParse(json['loja_id'].toString()) ?? 0,
      nome: json['nome'] ?? '',
      slug: json['slug'],
      descricao: json['descricao'],
      preco: (json['preco'] as num?)?.toDouble() ?? 0,
      precoPromocional: (json['preco_promocional'] as num?)?.toDouble(),
      imagem: json['imagem'],
      imagens: json['imagens'] != null ? List<String>.from(json['imagens']) : null,
      categoriaId: json['categoria_id'] is int 
          ? json['categoria_id'] 
          : int.tryParse(json['categoria_id']?.toString() ?? ''),
      subcategoriaId: json['subcategoria_id'] is int 
          ? json['subcategoria_id'] 
          : int.tryParse(json['subcategoria_id']?.toString() ?? ''),
      subcategoria: json['subcategoria'] is String ? json['subcategoria'] : null,
      disponivel: json['disponivel'] == 1 || json['disponivel'] == true,
      ativo: json['ativo'] == 1 || json['ativo'] == true,
      destaque: json['destaque'] == 1 || json['destaque'] == true,
      tempoPreparo: json['tempo_preparo_min'] is int 
          ? json['tempo_preparo_min'] 
          : int.tryParse(json['tempo_preparo_min']?.toString() ?? ''),
      ordem: json['ordem'] is int ? json['ordem'] : int.tryParse(json['ordem']?.toString() ?? '0') ?? 0,
      ingredientesTexto: json['ingredientes_texto'],
      ingredientes: json['ingredientes'] is List ? json['ingredientes'] : null,
      calorias: json['calorias'] is int ? json['calorias'] : int.tryParse(json['calorias']?.toString() ?? ''),
      pesoGramas: (json['peso_gramas'] as num?)?.toDouble(),
      contemGluten: json['contem_gluten'] == 1 || json['contem_gluten'] == true,
      contemLactose: json['contem_lactose'] == 1 || json['contem_lactose'] == true,
      vegano: json['vegano'] == 1 || json['vegano'] == true,
      vegetariano: json['vegetariano'] == 1 || json['vegetariano'] == true,
      apimentado: json['apimentado'] == 1 || json['apimentado'] == true,
      estoque: json['estoque'] is int ? json['estoque'] : int.tryParse(json['estoque']?.toString() ?? '0') ?? 0,
      variacoes: json['variacoes'],
      opcoes: json['opcoes'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'loja_id': lojaId,
      'nome': nome,
      'slug': slug,
      'descricao': descricao,
      'preco': preco,
      'preco_promocional': precoPromocional,
      'imagem': imagem,
      'imagens': imagens,
      'categoria_id': categoriaId,
      'subcategoria_id': subcategoriaId,
      'disponivel': disponivel ? 1 : 0,
      'ativo': ativo ? 1 : 0,
      'destaque': destaque ? 1 : 0,
      'tempo_preparo_min': tempoPreparo,
      'ordem': ordem,
      'ingredientes_texto': ingredientesTexto,
      'ingredientes': ingredientes,
      'calorias': calorias,
      'peso_gramas': pesoGramas,
      'contem_gluten': contemGluten ? 1 : 0,
      'contem_lactose': contemLactose ? 1 : 0,
      'vegano': vegano ? 1 : 0,
      'vegetariano': vegetariano ? 1 : 0,
      'apimentado': apimentado ? 1 : 0,
      'estoque': estoque,
    };
  }

  bool get emPromocao => precoPromocional != null && precoPromocional! < preco;

  String get imagemUrl => ImageHelper.getFullImageUrl(imagem);
}
