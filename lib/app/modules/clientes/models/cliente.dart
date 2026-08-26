// lib/app/modules/clientes/models/cliente.dart

class Cliente {
  final int id;
  final String nome;
  final String? email;
  final String? cpf;
  final String? telefone;
  final String? whatsapp;
  final String? dataNascimento;
  final String status;
  final String? statusLabel;
  final String tipo;
  final String? avatar;
  final int totalPedidos;
  final double totalGasto;
  final int pontos;
  final int nivel;
  final String? primeiroPedidoEm;
  final String? ultimoPedidoEm;
  final String? criadoEm;
  final String? atualizadoEm;
  final String? ultimoLoginEm;
  final String? ultimoLoginProvider;
  final bool prefNotificacoesEmail;
  final bool prefNotificacoesPush;
  final bool prefNotificacoesSms;
  final String prefTema;
  final bool emailVerificado;
  final bool telefoneVerificado;
  final bool termosAceitos;
  final int loginCount;

  Cliente({
    required this.id,
    required this.nome,
    this.email,
    this.cpf,
    this.telefone,
    this.whatsapp,
    this.dataNascimento,
    required this.status,
    this.statusLabel,
    required this.tipo,
    this.avatar,
    this.totalPedidos = 0,
    this.totalGasto = 0.0,
    this.pontos = 0,
    this.nivel = 1,
    this.primeiroPedidoEm,
    this.ultimoPedidoEm,
    this.criadoEm,
    this.atualizadoEm,
    this.ultimoLoginEm,
    this.ultimoLoginProvider,
    this.prefNotificacoesEmail = true,
    this.prefNotificacoesPush = true,
    this.prefNotificacoesSms = true,
    this.prefTema = 'auto',
    this.emailVerificado = false,
    this.telefoneVerificado = false,
    this.termosAceitos = false,
    this.loginCount = 0,
  });

  factory Cliente.fromJson(Map<String, dynamic> json) {
    return Cliente(
      id: json['id'] ?? 0,
      nome: json['nome'] ?? '',
      email: json['email'],
      cpf: json['cpf'],
      telefone: json['telefone'],
      whatsapp: json['whatsapp'],
      dataNascimento: json['data_nascimento'],
      status: json['status'] ?? 'pendente',
      statusLabel: json['status_label'] ?? json['status'],
      tipo: json['tipo'] ?? 'cliente',
      avatar: json['avatar'],
      totalPedidos: json['total_pedidos'] ?? 0,
      totalGasto: (json['total_gasto'] ?? 0.0).toDouble(),
      pontos: json['pontos'] ?? 0,
      nivel: json['nivel'] ?? 1,
      primeiroPedidoEm: json['primeiro_pedido_em'],
      ultimoPedidoEm: json['ultimo_pedido_em'],
      criadoEm: json['criado_em'],
      atualizadoEm: json['atualizado_em'],
      ultimoLoginEm: json['ultimo_login_em'],
      ultimoLoginProvider: json['ultimo_login_provider'],
      prefNotificacoesEmail: json['pref_notificacoes_email'] ?? true,
      prefNotificacoesPush: json['pref_notificacoes_push'] ?? true,
      prefNotificacoesSms: json['pref_notificacoes_sms'] ?? true,
      prefTema: json['pref_tema'] ?? 'auto',
      emailVerificado: json['email_verificado'] ?? false,
      telefoneVerificado: json['telefone_verificado'] ?? false,
      termosAceitos: json['termos_aceitos'] ?? false,
      loginCount: json['login_count'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'nome': nome,
      'email': email,
      'cpf': cpf,
      'telefone': telefone,
      'whatsapp': whatsapp,
      'data_nascimento': dataNascimento,
      'status': status,
      'tipo': tipo,
      'avatar': avatar,
      'pref_notificacoes_email': prefNotificacoesEmail ? 1 : 0,
      'pref_notificacoes_push': prefNotificacoesPush ? 1 : 0,
      'pref_notificacoes_sms': prefNotificacoesSms ? 1 : 0,
      'pref_tema': prefTema,
      'pontos': pontos,
      'nivel': nivel,
    };
  }
}
