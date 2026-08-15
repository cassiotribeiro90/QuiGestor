import 'package:equatable/equatable.dart';

class LojistaModel extends Equatable {
  final int id;
  final String nome;
  final String email;
  final String? telefone;
  final String? cpfCnpj;
  final String funcao; // proprietario, gerente, vendedor
  final int status; // 1=ativo, 0=inativo
  final String? ultimoLoginEm;
  final String? ultimoLoginIp;
  final String? criadoEm;
  final String? atualizadoEm;
  final List<int>? lojaIds;
  final List<LojaSimplificada>? lojas;

  const LojistaModel({
    required this.id,
    required this.nome,
    required this.email,
    this.telefone,
    this.cpfCnpj,
    required this.funcao,
    required this.status,
    this.ultimoLoginEm,
    this.ultimoLoginIp,
    this.criadoEm,
    this.atualizadoEm,
    this.lojaIds,
    this.lojas,
  });

  factory LojistaModel.fromJson(Map<String, dynamic> json) {
    return LojistaModel(
      id: json['id'] as int? ?? 0,
      nome: json['nome']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      telefone: json['telefone']?.toString(),
      cpfCnpj: json['cpf_cnpj']?.toString(),
      funcao: json['funcao']?.toString() ?? 'vendedor',
      status: json['status'] is int ? json['status'] as int : int.tryParse(json['status']?.toString() ?? '1') ?? 1,
      ultimoLoginEm: json['ultimo_login_em']?.toString(),
      ultimoLoginIp: json['ultimo_login_ip']?.toString(),
      criadoEm: json['criado_em']?.toString(),
      atualizadoEm: json['atualizado_em']?.toString(),
      lojaIds: (json['loja_ids'] as List?)?.map((e) => int.tryParse(e.toString()) ?? 0).where((e) => e != 0).toList(),
      lojas: (json['lojas'] as List?)
          ?.map((e) => LojaSimplificada.fromJson(e))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() => {
        'nome': nome,
        'email': email,
        'telefone': telefone,
        'cpf_cnpj': cpfCnpj,
        'funcao': funcao,
        'status': status,
        'loja_ids': lojaIds ?? [],
      };

  @override
  List<Object?> get props => [id, nome, email, funcao, status];
}

class LojaSimplificada extends Equatable {
  final int id;
  final String nome;

  const LojaSimplificada({required this.id, required this.nome});

  factory LojaSimplificada.fromJson(Map<String, dynamic> json) {
    return LojaSimplificada(
      id: json['id'] as int,
      nome: json['nome'] ?? '',
    );
  }

  @override
  List<Object?> get props => [id, nome];
}
