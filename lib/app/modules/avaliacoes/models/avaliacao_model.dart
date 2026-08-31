
class AvaliacaoModel {
  final int id;
  final int? pedidoId;
  final int? usuarioId;
  final int? lojaId;
  final int? produtoId;
  final String clienteNome;
  final String lojaNome;
  final String? produtoNome;
  final int nota;
  final String? comentario;
  final String? resposta;
  final String status;
  final DateTime criadoEm;
  final DateTime? atualizadoEm;
  final PedidoInfo? pedido;

  const AvaliacaoModel({
    required this.id,
    this.pedidoId,
    this.usuarioId,
    this.lojaId,
    this.produtoId,
    this.clienteNome = '',
    this.lojaNome = '',
    this.produtoNome,
    required this.nota,
    this.comentario,
    this.resposta,
    required this.status,
    required this.criadoEm,
    this.atualizadoEm,
    this.pedido,
  });

  // Helper para converter qualquer valor para int
  static int? _toInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is String) return int.tryParse(value);
    if (value is double) return value.toInt();
    return null;
  }

  // Helper para converter qualquer valor para String
  static String _toString(dynamic value) {
    if (value == null) return '';
    return value.toString();
  }

  factory AvaliacaoModel.fromJson(Map<String, dynamic> json) {
    return AvaliacaoModel(
      id: _toInt(json['id']) ?? 0,
      pedidoId: _toInt(json['pedido_id']),
      usuarioId: _toInt(json['usuario_id']),
      lojaId: _toInt(json['loja_id']),
      produtoId: _toInt(json['produto_id']),
      clienteNome: _toString(json['cliente_nome']),
      lojaNome: _toString(json['loja_nome']),
      produtoNome: json['produto_nome']?.toString(),
      nota: _toInt(json['nota']) ?? 0,
      comentario: json['comentario']?.toString(),
      resposta: json['resposta']?.toString(),
      status: _normalizarStatus(_toString(json['status'])),
      criadoEm: DateTime.tryParse(_toString(json['criado_em'])) ?? DateTime.now(),
      atualizadoEm: json['atualizado_em'] != null
          ? DateTime.tryParse(_toString(json['atualizado_em']))
          : null,
      pedido: json['pedido'] != null && json['pedido'] is Map
          ? PedidoInfo.fromJson(json['pedido'] as Map<String, dynamic>)
          : null,
    );
  }

  // ⚠️ NORMALIZA O STATUS - "aprovado" -> "aprovada", "rejeitado" -> "rejeitada"
  static String _normalizarStatus(String status) {
    switch (status.toLowerCase()) {
      case 'aprovado':
        return 'aprovada';
      case 'rejeitado':
        return 'rejeitada';
      case 'pendente':
        return 'pendente';
      default:
        return status.toLowerCase();
    }
  }

  String get statusLabel {
    switch (status) {
      case 'aprovada':
        return 'Aprovada';
      case 'rejeitada':
        return 'Rejeitada';
      default:
        return 'Pendente';
    }
  }

  bool get isPendente => status == 'pendente';
  bool get isAprovada => status == 'aprovada';
  bool get isRejeitada => status == 'rejeitada';
}

class PedidoInfo {
  final int id;
  final String numero;
  final double total;
  final String status;
  final DateTime criadoEm;
  final List<ProdutoInfo> produtos;

  const PedidoInfo({
    required this.id,
    required this.numero,
    required this.total,
    required this.status,
    required this.criadoEm,
    required this.produtos,
  });

  factory PedidoInfo.fromJson(Map<String, dynamic> json) {
    return PedidoInfo(
      id: AvaliacaoModel._toInt(json['id']) ?? 0,
      numero: AvaliacaoModel._toString(json['numero']),
      total: (json['total'] is num)
          ? (json['total'] as num).toDouble()
          : double.tryParse(AvaliacaoModel._toString(json['total'])) ?? 0,
      status: AvaliacaoModel._toString(json['status']),
      criadoEm: DateTime.tryParse(AvaliacaoModel._toString(json['criado_em'])) ?? DateTime.now(),
      produtos: (json['produtos'] as List? ?? [])
          .where((e) => e is Map)
          .map((e) => ProdutoInfo.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

class ProdutoInfo {
  final int id;
  final String nome;
  final int quantidade;
  final double preco;
  final double subtotal;
  final String? imagem;
  final String? observacao;

  const ProdutoInfo({
    required this.id,
    required this.nome,
    required this.quantidade,
    required this.preco,
    required this.subtotal,
    this.imagem,
    this.observacao,
  });

  factory ProdutoInfo.fromJson(Map<String, dynamic> json) {
    final preco = (json['preco'] is num)
        ? (json['preco'] as num).toDouble()
        : double.tryParse(AvaliacaoModel._toString(json['preco'])) ?? 0;

    final quantidade = AvaliacaoModel._toInt(json['quantidade']) ?? 0;

    final subtotal = (json['subtotal'] is num)
        ? (json['subtotal'] as num).toDouble()
        : double.tryParse(AvaliacaoModel._toString(json['subtotal'])) ?? (preco * quantidade);

    return ProdutoInfo(
      id: AvaliacaoModel._toInt(json['id']) ?? 0,
      nome: AvaliacaoModel._toString(json['nome']),
      quantidade: quantidade,
      preco: preco,
      subtotal: subtotal,
      imagem: json['imagem']?.toString(),
      observacao: json['observacao']?.toString(),
    );
  }
}