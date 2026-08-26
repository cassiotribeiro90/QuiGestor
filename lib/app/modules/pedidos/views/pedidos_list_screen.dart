import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:quigestor/apparte/widgets/loading_skeleton.dart';
import '../bloc/pedidos_cubit.dart';
import '../../../widgets/generic_filter_widget.dart';
import '../models/pedido_model.dart';

class PedidosListScreen extends StatefulWidget {
  const PedidosListScreen({super.key});

  @override
  State<PedidosListScreen> createState() => _PedidosListScreenState();
}

class _PedidosListScreenState extends State<PedidosListScreen> {
  late final PedidosCubit _cubit;

  @override
  void initState() {
    super.initState();
    _cubit = context.read<PedidosCubit>();
    _cubit.fetchPedidos();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PedidosCubit, PedidosState>(
      builder: (context, state) {
        // 🔥 PRIMEIRO CARREGAMENTO: mostra progress central
        if (!state.hasLoaded) {
          return const Center(child: CircularProgressIndicator());
        }

        // 🔥 ERRO NA PRIMEIRA CARGA
        if (state.error != null && state.items.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
                const SizedBox(height: 16),
                const Text('Erro ao carregar pedidos'),
                const SizedBox(height: 8),
                Text(state.error!),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => _cubit.fetchPedidos(),
                  child: const Text('Tentar novamente'),
                ),
              ],
            ),
          );
        }

        // 🔥 SCROLL NA TELA INTEIRA com NotificationListener
        return NotificationListener<ScrollNotification>(
          onNotification: (notification) {
            // Detecta quando chegou no final do scroll para carregar mais
            if (notification is ScrollEndNotification &&
                notification.metrics.pixels >=
                    notification.metrics.maxScrollExtent - 100) {
              _cubit.loadMore();
            }
            return false;
          },
          child: SingleChildScrollView(
            padding: const EdgeInsets.only(bottom: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 🔥 Filtro genérico
                GenericFilterWidget(
                  groups: state.filterGroups,
                  onApply: (params) {
                    _cubit.refreshWithFilters(params);
                  },
                  totalItems: state.total,
                  initialFilters: _cubit.currentFilters,
                ),
                const SizedBox(height: 8),

                // 📋 Lista de pedidos com shrinkWrap (scroll interno desabilitado)
                if (state.isLoading && state.items.isEmpty)
                  const CardSkeleton()
                else if (state.items.isEmpty)
                  const Center(
                    child: Text('Nenhum pedido encontrado'),
                  )
                else
                  Column(
                    children: [
                      ...state.items.map((pedido) => _PedidoCard(
                        pedido: pedido,
                        onTap: () {
                          context.push('/pedidos/${pedido.id}');
                        },
                      )),
                      // 🔥 Loading no final da lista (se houver mais páginas)
                      if (state.isLoadingMore && state.hasMore)
                        const Padding(
                          padding: EdgeInsets.all(16),
                          child: Center(
                            child: CircularProgressIndicator(),
                          ),
                        ),
                      if (state.hasMore && !state.isLoadingMore)
                        const Padding(
                          padding: EdgeInsets.all(8),
                          child: Center(
                            child: Text(
                              'Role para carregar mais...',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}

// ==================== WIDGET DO CARD ====================

class _PedidoCard extends StatelessWidget {
  final Pedido pedido;
  final VoidCallback onTap;

  const _PedidoCard({required this.pedido, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final statusColor = _getStatusColor(pedido.status);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: ListTile(
        onTap: onTap,
        leading: _buildLeadingImage(),
        title: Row(
          children: [
            Expanded(
              child: Text(
                pedido.codigo,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: statusColor.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                pedido.statusLabel,
                style: TextStyle(
                  fontSize: 12,
                  color: statusColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('${pedido.clienteNome} • ${pedido.lojaNome}'),
            Text(
              'R\$ ${pedido.total.toStringAsFixed(2)} • ${_formatDate(pedido.criadoEm)}',
              style: theme.textTheme.bodySmall,
            ),
          ],
        ),
        trailing: const Icon(Icons.chevron_right),
        isThreeLine: true,
      ),
    );
  }

  Widget _buildLeadingImage() {
    if (pedido.lojaImagem != null && pedido.lojaImagem!.isNotEmpty) {
      return CircleAvatar(
        radius: 24,
        backgroundImage: NetworkImage(pedido.lojaImagem!),
        onBackgroundImageError: (_, __) => _buildFallbackIcon(),
      );
    }
    return _buildFallbackIcon();
  }

  Widget _buildFallbackIcon() {
    final statusColor = _getStatusColor(pedido.status);
    return CircleAvatar(
      radius: 24,
      backgroundColor: statusColor.withOpacity(0.2),
      child: Icon(
        Icons.receipt_long,
        color: statusColor,
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'novo':
        return Colors.blue;
      case 'confirmado':
        return Colors.green;
      case 'preparando':
        return Colors.orange;
      case 'pronto':
        return Colors.purple;
      case 'saiu':
        return Colors.indigo;
      case 'entregue':
        return Colors.teal;
      case 'cancelado':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);
    if (diff.inHours < 24) {
      return '${diff.inHours}h atrás';
    }
    return '${date.day}/${date.month}/${date.year}';
  }
}