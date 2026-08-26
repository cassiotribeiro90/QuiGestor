// lib/app/modules/pedidos/models/pedido_model.dart

class Pedido {
  final int id;
  final String codigo;
  final int? usuarioId;
  final int lojaId;
  final String lojaNome;
  final String? lojaImagem;
  final String clienteNome;
  final String? clienteTelefone;
  final String status;
  final String statusLabel;
  final double total;
  final double subtotal;
  final double taxaEntrega;
  final double desconto;
  final String? formaPagamento;
  final String? pagamentoStatus;
  final double? trocoPara;
  final String? enderecoEntrega;
  final String? observacoes;
  final DateTime criadoEm;
  final DateTime? atualizadoEm;
  final int? tempoEsperaMin;
  final List<PedidoItem>? itens;

  Pedido({
    required this.id,
    required this.codigo,
    this.usuarioId,
    required this.lojaId,
    required this.lojaNome,
    this.lojaImagem,
    required this.clienteNome,
    this.clienteTelefone,
    required this.status,
    required this.statusLabel,
    required this.total,
    required this.subtotal,
    required this.taxaEntrega,
    required this.desconto,
    this.formaPagamento,
    this.pagamentoStatus,
    this.trocoPara,
    this.enderecoEntrega,
    this.observacoes,
    required this.criadoEm,
    this.atualizadoEm,
    this.tempoEsperaMin,
    this.itens,
  });

  factory Pedido.fromJson(Map<String, dynamic> json) {
    return Pedido(
      id: json['id'] as int,
      codigo: json['codigo'] ?? '',
      usuarioId: json['usuario_id'] as int?,
      lojaId: json['loja_id'] as int,
      lojaNome: json['loja_nome'] ?? '',
      lojaImagem: json['loja_imagem'] as String?,
      clienteNome: json['cliente_nome'] ?? '',
      clienteTelefone: json['cliente_telefone']?.toString(),
      status: json['status'] ?? '',
      statusLabel: json['status_label'] ?? json['status'] ?? '',
      total: (json['total'] ?? 0).toDouble(),
      subtotal: (json['subtotal'] ?? 0).toDouble(),
      taxaEntrega: (json['taxa_entrega'] ?? 0).toDouble(),
      desconto: (json['desconto'] ?? 0).toDouble(),
      formaPagamento: json['forma_pagamento'] as String?,
      pagamentoStatus: json['pagamento_status'] as String?,
      trocoPara: json['troco_para']?.toDouble(),
      enderecoEntrega: json['endereco_entrega'] as String?,
      observacoes: json['observacoes'] as String?,
      criadoEm: DateTime.parse(json['criado_em'] ?? DateTime.now().toIso8601String()),
      atualizadoEm: json['atualizado_em'] != null
          ? DateTime.parse(json['atualizado_em'])
          : null,
      tempoEsperaMin: json['tempo_espera_min'] as int?,
      itens: json['itens'] != null
          ? (json['itens'] as List)
          .map((item) => PedidoItem.fromJson(item))
          .toList()
          : null,
    );
  }
}

class PedidoItem {
  final int? id;
  final int? produtoId;
  final String nome;
  final int quantidade;
  final double precoUnitario;
  final double total;
  final String? observacao;
  final String? imagem;

  PedidoItem({
    this.id,
    this.produtoId,
    required this.nome,
    required this.quantidade,
    required this.precoUnitario,
    required this.total,
    this.observacao,
    this.imagem,
  });

  factory PedidoItem.fromJson(Map<String, dynamic> json) {
    return PedidoItem(
      id: json['id'] as int?,
      produtoId: json['produto_id'] as int?,
      nome: json['produto_nome'] ?? '',
      quantidade: json['quantidade'] ?? 1,
      precoUnitario: double.tryParse(json['preco_unitario']?.toString() ?? '0') ?? 0.0,
      total: double.tryParse(json['preco_total']?.toString() ?? '0') ?? 0.0,
      observacao: json['observacao'] ?? json['observacoes'] as String?,
      imagem: json['produto_imagem'] as String?,
    );
  }
}