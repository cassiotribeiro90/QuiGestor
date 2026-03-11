import 'package:flutter/material.dart';

class Loja {
  final int id;
  final String nome;
  final String slug;
  final String categoria;
  final String? logo;
  final String? capa;
  final double notaMedia;
  final int totalAvaliacoes;
  final int tempoEntregaMin;
  final int tempoEntregaMax;
  final double taxaEntrega;
  final double pedidoMinimo;
  final String cidade;
  final String uf;
  final String status;
  final bool verificado;
  final bool destaque;
  final String? criadoEm;
  final String? descricao;
  final String? telefone;
  final String? whatsapp;
  final String? email;
  final String? instagram;
  
  // Novos campos de endereço
  final String? cep;
  final String? logradouro;
  final String? numero;
  final String? complemento;
  final String? bairro;

  Loja({
    required this.id,
    required this.nome,
    required this.slug,
    required this.categoria,
    this.logo,
    this.capa,
    required this.notaMedia,
    required this.totalAvaliacoes,
    required this.tempoEntregaMin,
    required this.tempoEntregaMax,
    required this.taxaEntrega,
    required this.pedidoMinimo,
    required this.cidade,
    required this.uf,
    required this.status,
    required this.verificado,
    required this.destaque,
    this.criadoEm,
    this.descricao,
    this.telefone,
    this.whatsapp,
    this.email,
    this.instagram,
    this.cep,
    this.logradouro,
    this.numero,
    this.complemento,
    this.bairro,
  });

  factory Loja.fromJson(Map<String, dynamic> json) {
    return Loja(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id'].toString()) ?? 0,
      nome: json['nome'] ?? '',
      slug: json['slug'] ?? '',
      categoria: json['categoria'] ?? '',
      logo: json['logo'],
      capa: json['capa'],
      notaMedia: (json['nota_media'] as num?)?.toDouble() ?? 0,
      totalAvaliacoes: json['total_avaliacoes'] ?? 0,
      tempoEntregaMin: json['tempo_entrega_min'] ?? 0,
      tempoEntregaMax: json['tempo_entrega_max'] ?? 0,
      taxaEntrega: (json['taxa_entrega'] as num?)?.toDouble() ?? 0,
      pedidoMinimo: (json['pedido_minimo'] as num?)?.toDouble() ?? 0,
      cidade: json['cidade'] ?? '',
      uf: json['uf'] ?? '',
      status: json['status'] ?? 'revisao',
      verificado: json['verificado'] ?? false,
      destaque: json['destaque'] ?? false,
      criadoEm: json['criado_em'],
      descricao: json['descricao'],
      telefone: json['telefone'],
      whatsapp: json['whatsapp'],
      email: json['email'],
      instagram: json['instagram'],
      cep: json['cep'],
      logradouro: json['logradouro'],
      numero: json['numero'],
      complemento: json['complemento'],
      bairro: json['bairro'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nome': nome,
      'slug': slug,
      'categoria': categoria,
      'logo': logo,
      'capa': capa,
      'nota_media': notaMedia,
      'total_avaliacoes': totalAvaliacoes,
      'tempo_entrega_min': tempoEntregaMin,
      'tempo_entrega_max': tempoEntregaMax,
      'taxa_entrega': taxaEntrega,
      'pedido_minimo': pedidoMinimo,
      'cidade': cidade,
      'uf': uf,
      'status': status,
      'verificado': verificado,
      'destaque': destaque,
      'criado_em': criadoEm,
      'descricao': descricao,
      'telefone': telefone,
      'whatsapp': whatsapp,
      'email': email,
      'instagram': instagram,
      'cep': cep,
      'logradouro': logradouro,
      'numero': numero,
      'complemento': complemento,
      'bairro': bairro,
    };
  }

  bool get isAtivo => status == 'ativo';
  bool get isFechado => status == 'fechado';
  bool get isRevisao => status == 'revisao';

  String get statusLabel {
    switch (status) {
      case 'ativo': return 'Ativo';
      case 'inativo': return 'Inativo';
      case 'fechado': return 'Fechado';
      case 'revisao': return 'Em revisão';
      default: return status;
    }
  }

  Color get statusColor {
    switch (status) {
      case 'ativo': return Colors.green;
      case 'inativo': return Colors.grey;
      case 'fechado': return Colors.red;
      case 'revisao': return Colors.orange;
      default: return Colors.grey;
    }
  }
}
