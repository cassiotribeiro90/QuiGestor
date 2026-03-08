import 'package:equatable/equatable.dart';

class Loja extends Equatable {
  final String id;
  final String nome;
  final String? descricao;
  final String? endereco;
  final String? telefone;
  final String? categoria;

  const Loja({
    required this.id,
    required this.nome,
    this.descricao,
    this.endereco,
    this.telefone,
    this.categoria,
  });

  factory Loja.fromJson(Map<String, dynamic> json) {
    return Loja(
      id: json['id']?.toString() ?? '',
      nome: json['nome'] ?? '',
      descricao: json['descricao'],
      endereco: json['endereco'],
      telefone: json['telefone'],
      categoria: json['categoria'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nome': nome,
      'descricao': descricao,
      'endereco': endereco,
      'telefone': telefone,
      'categoria': categoria,
    };
  }

  @override
  List<Object?> get props => [id, nome, descricao, endereco, telefone, categoria];
}
