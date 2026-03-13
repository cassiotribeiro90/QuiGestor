import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

class Categoria extends Equatable {
  final int id;
  final String nome;
  final String slug;
  final String? descricao;
  final String? icone;
  final String? imagem;
  final String cor;
  final int ordem;
  final bool ativo;
  final bool destaque;
  final DateTime? criadoEm;
  final DateTime? atualizadoEm;

  const Categoria({
    required this.id,
    required this.nome,
    required this.slug,
    this.descricao,
    this.icone,
    this.imagem,
    required this.cor,
    required this.ordem,
    required this.ativo,
    required this.destaque,
    this.criadoEm,
    this.atualizadoEm,
  });

  factory Categoria.fromJson(Map<String, dynamic> json) {
    return Categoria(
      id: json['id'] as int,
      nome: json['nome'] as String,
      slug: json['slug'] as String,
      descricao: json['descricao'] as String?,
      icone: json['icone'] as String?,
      imagem: json['imagem'] as String?,
      cor: json['cor'] as String? ?? '#FF6B6B',
      ordem: json['ordem'] as int? ?? 0,
      ativo: json['ativo'] == 1 || json['ativo'] == true,
      destaque: json['destaque'] == 1 || json['destaque'] == true,
      criadoEm: json['criado_em'] != null ? DateTime.tryParse(json['criado_em']) : null,
      atualizadoEm: json['atualizado_em'] != null ? DateTime.tryParse(json['atualizado_em']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nome': nome,
      'slug': slug,
      'descricao': descricao,
      'icone': icone,
      'imagem': imagem,
      'cor': cor,
      'ordem': ordem,
      'ativo': ativo,
      'destaque': destaque,
    };
  }

  Categoria copyWith({
    int? id,
    String? nome,
    String? slug,
    String? descricao,
    String? icone,
    String? imagem,
    String? cor,
    int? ordem,
    bool? ativo,
    bool? destaque,
    DateTime? criadoEm,
    DateTime? atualizadoEm,
  }) {
    return Categoria(
      id: id ?? this.id,
      nome: nome ?? this.nome,
      slug: slug ?? this.slug,
      descricao: descricao ?? this.descricao,
      icone: icone ?? this.icone,
      imagem: imagem ?? this.imagem,
      cor: cor ?? this.cor,
      ordem: ordem ?? this.ordem,
      ativo: ativo ?? this.ativo,
      destaque: destaque ?? this.destaque,
      criadoEm: criadoEm ?? this.criadoEm,
      atualizadoEm: atualizadoEm ?? this.atualizadoEm,
    );
  }

  Color get colorValue {
    try {
      return Color(int.parse(cor.replaceFirst('#', '0xFF')));
    } catch (e) {
      return const Color(0xFFFF6B6B);
    }
  }

  String get statusLabel => ativo ? 'Ativo' : 'Inativo';

  @override
  List<Object?> get props => [
        id,
        nome,
        slug,
        descricao,
        icone,
        imagem,
        cor,
        ordem,
        ativo,
        destaque,
        criadoEm,
        atualizadoEm,
      ];
}
