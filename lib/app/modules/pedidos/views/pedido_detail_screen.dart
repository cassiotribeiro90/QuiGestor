// lib/app/modules/pedidos/views/pedido_detail_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../core/widgets/back_button_mixin.dart';
import '../bloc/pedidos_cubit.dart';
import '../models/pedido_model.dart';
import '../../../../shared/utils/image_helper.dart';

class PedidoDetailScreen extends StatefulWidget {
  final int pedidoId;

  const PedidoDetailScreen({super.key, required this.pedidoId});

  @override
  State<PedidoDetailScreen> createState() => _PedidoDetailScreenState();
}

class _PedidoDetailScreenState extends State<PedidoDetailScreen> with BackButtonMixin {
  late final PedidosCubit _cubit;
  Pedido? _pedido;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _cubit = context.read<PedidosCubit>();
    _loadPedido();
  }

  Future<void> _loadPedido() async {
    setState(() => _loading = true);
    try {
      final pedido = await _cubit.fetchPedido(widget.pedidoId);
      setState(() {
        _pedido = pedido;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  Future<void> _updateStatus(String newStatus) async {
    final success = await _cubit.updatePedido(
      widget.pedidoId,
      {'status': newStatus},
    );
    if (success) {
      await _loadPedido();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Status atualizado com sucesso!')),
        );
      }
    }
  }

  Future<void> _cancelPedido() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cancelar pedido'),
        content: const Text('Tem certeza que deseja cancelar este pedido?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Não'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Sim, cancelar', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
    if (confirm == true) {
      final success = await _cubit.deletePedido(widget.pedidoId);
      if (success && mounted) {
        context.pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Pedido cancelado com sucesso!')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_error != null || _pedido == null) {
      return Scaffold(
        appBar: AppBar(
          leading: buildBackButton(context),
          title: const Text('Detalhes do Pedido'),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('Erro ao carregar pedido'),
              Text(_error ?? 'Pedido não encontrado'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _loadPedido,
                child: const Text('Tentar novamente'),
              ),
            ],
          ),
        ),
      );
    }

    final pedido = _pedido!;

    return Scaffold(
      appBar: AppBar(
        leading: buildBackButton(context),
        title: Text('Pedido ${pedido.codigo}'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadPedido,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Status e ações
            _buildStatusSection(pedido),
            const Divider(),
            // Informações do cliente
            _buildInfoSection('Cliente', [
              'Nome: ${pedido.clienteNome}',
              if (pedido.clienteTelefone != null) 'Telefone: ${pedido.clienteTelefone}',
            ]),
            // Informações da loja
            _buildInfoSection('Loja', [
              'Nome: ${pedido.lojaNome}',
              if (pedido.lojaImagem != null) 'Imagem: ${pedido.lojaImagem}',
            ]),
            // Valores
            _buildInfoSection('Valores', [
              'Subtotal: R\$ ${pedido.subtotal.toStringAsFixed(2)}',
              'Taxa de entrega: R\$ ${pedido.taxaEntrega.toStringAsFixed(2)}',
              'Desconto: R\$ ${pedido.desconto.toStringAsFixed(2)}',
              'Total: R\$ ${pedido.total.toStringAsFixed(2)}',
              if (pedido.formaPagamento != null) 'Pagamento: ${pedido.formaPagamento}',
              if (pedido.pagamentoStatus != null) 'Status pagamento: ${pedido.pagamentoStatus}',
            ]),
            // Itens
            if (pedido.itens != null && pedido.itens!.isNotEmpty) ...[
              const Divider(),
              const Text('Itens', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              ...pedido.itens!.map((item) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  children: [
                    if (item.imagem != null)
                      CircleAvatar(
                        radius: 16,
                        backgroundImage: NetworkImage(ImageHelper.getFullImageUrl(item.imagem)),
                        onBackgroundImageError: (_, __) => Container(),
                      ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text('${item.quantidade}x ${item.nome}'),
                    ),
                    Text('R\$ ${item.total.toStringAsFixed(2)}'),
                  ],
                ),
              )),
            ],
            // Observações
            if (pedido.observacoes != null && pedido.observacoes!.isNotEmpty) ...[
              const Divider(),
              const Text('Observações', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Text(pedido.observacoes!),
            ],
            // Botão cancelar
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: pedido.status == 'cancelado' || pedido.status == 'entregue'
                    ? null
                    : _cancelPedido,
                icon: const Icon(Icons.cancel),
                label: const Text('Cancelar Pedido'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusSection(Pedido pedido) {
    final availableStatus = [
      'novo',
      'confirmado',
      'preparando',
      'pronto',
      'saiu',
      'entregue',
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Status', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          children: availableStatus.map((status) {
            final isSelected = status == pedido.status;
            return ActionChip(
              label: Text(_getStatusLabel(status)),
              onPressed: () => _updateStatus(status),
              backgroundColor: isSelected ? Colors.blue.shade100 : Colors.grey.shade200,
              labelStyle: TextStyle(
                color: isSelected ? Colors.blue.shade700 : Colors.black87,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  String _getStatusLabel(String status) {
    const labels = {
      'novo': 'Novo',
      'confirmado': 'Confirmado',
      'preparando': 'Preparando',
      'pronto': 'Pronto',
      'saiu': 'Saiu',
      'entregue': 'Entregue',
    };
    return labels[status] ?? status;
  }

  Widget _buildInfoSection(String title, List<String> lines) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          ...lines.map((line) => Text(line)),
        ],
      ),
    );
  }
}