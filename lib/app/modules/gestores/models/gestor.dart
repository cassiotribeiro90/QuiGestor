import 'package:equatable/equatable.dart';

class Gestor extends Equatable {
  final int id;
  final String nome;
  final String email;
  final String? cpf;
  final String? telefone;
  final String nivel;
  final int status;
  final String? statusLabel;
  final DateTime? criadoEm;

  const Gestor({
    required this.id,
    required this.nome,
    required this.email,
    this.cpf,
    this.telefone,
    required this.nivel,
    required this.status,
    this.statusLabel,
    this.criadoEm,
  });

  factory Gestor.fromJson(Map<String, dynamic> json) {
    return Gestor(
      id: json['id'] as int,
      nome: json['nome'] as String,
      email: json['email'] as String,
      cpf: json['cpf'] as String?,
      telefone: json['telefone'] as String?,
      nivel: json['nivel'] as String? ?? 'comercial',
      status: json['status'] as int? ?? 1,
      statusLabel: json['status_label'] as String?,
      criadoEm: json['criado_em'] != null 
          ? DateTime.tryParse(json['criado_em']) 
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nome': nome,
      'email': email,
      'cpf': cpf,
      'telefone': telefone,
      'nivel': nivel,
      'status': status,
    };
  }

  Gestor copyWith({
    int? id,
    String? nome,
    String? email,
    String? cpf,
    String? telefone,
    String? nivel,
    int? status,
    String? statusLabel,
    DateTime? criadoEm,
  }) {
    return Gestor(
      id: id ?? this.id,
      nome: nome ?? this.nome,
      email: email ?? this.email,
      cpf: cpf ?? this.cpf,
      telefone: telefone ?? this.telefone,
      nivel: nivel ?? this.nivel,
      status: status ?? this.status,
      statusLabel: statusLabel ?? this.statusLabel,
      criadoEm: criadoEm ?? this.criadoEm,
    );
  }

  @override
  List<Object?> get props => [id, nome, email, cpf, telefone, nivel, status, statusLabel, criadoEm];
}
