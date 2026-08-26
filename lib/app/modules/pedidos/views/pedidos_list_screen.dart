import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:quigestor/apparte/widgets/loading_skeleton.dart';
import 'package:quigestor/apparte/widgets/app_text.dart';
import 'package:quigestor/apparte/widgets/quigestor_card.dart';
import '../bloc/pedidos_cubit.dart';
import '../../../widgets/generic_filter_widget.dart';
import '../models/pedido_model.dart';
import '../../../core/constants/icon_constants.dart';

class PedidosListScreen extends StatefulWidget {
  const PedidosListScreen({super.key});

  @override
  State<PedidosListScreen> createState() => _PedidosListScreenState();
}

class _PedidosListScreenState extends State<PedidosListScreen> {
  late final PedidosCubit _cubit;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _cubit = context.read<PedidosCubit>();
    _cubit.fetchPedidos();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 100) {
      _cubit.loadMore();
    }
  }

  Future<void> _onRefresh() async {
    await _cubit.refreshWithFilters(_cubit.currentFilters);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      body: BlocConsumer<PedidosCubit, PedidosState>(
        listener: (context, state) {
          if (state.error != null && state.items.isNotEmpty) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  state.error!,
                  style: TextStyle(
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
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
                  Icon(
                    Icons.error_outline,
                    size: 64,
                    color: isDark ? Colors.grey[400] : Colors.red[300],
                  ),
                  const SizedBox(height: 16),
                  TextH3(
                    'Erro ao carregar pedidos',
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                  const SizedBox(height: 8),
                  TextBody2(
                    state.error!,
                    color: isDark ? Colors.grey[400] : Colors.grey[600],
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: () => _cubit.fetchPedidos(),
                    icon: const Icon(AppIcons.refresh),
                    label: const Text('Tentar novamente'),
                  ),
                ],
              ),
            );
          }

          // 🔥 LISTA COM REFRESH INDICATOR
          return RefreshIndicator(
            onRefresh: _onRefresh,
            child: CustomScrollView(
              controller: _scrollController,
              physics: const AlwaysScrollableScrollPhysics(),
              slivers: [
                // Filtro
                SliverToBoxAdapter(
                  child: GenericFilterWidget(
                    groups: state.filterGroups,
                    onApply: (params) {
                      _cubit.refreshWithFilters(params);
                    },
                    totalItems: state.total,
                    initialFilters: _cubit.currentFilters,
                  ),
                ),
                const SliverToBoxAdapter(child: SizedBox(height: 8)),

                // Conteúdo da lista
                _buildListContentSliver(state),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildListContentSliver(PedidosState state) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // Loading inicial
    if (state.isLoading && state.items.isEmpty) {
      return SliverPadding(
        padding: const EdgeInsets.all(16),
        sliver: SliverList(
          delegate: SliverChildBuilderDelegate(
                (_, __) => const Padding(
              padding: EdgeInsets.only(bottom: 12),
              child: CardSkeleton(),
            ),
            childCount: 5,
          ),
        ),
      );
    }

    // Lista vazia
    if (state.items.isEmpty) {
      return SliverFillRemaining(
        hasScrollBody: false,
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 40),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.receipt_long_outlined,
                  size: 80,
                  color: isDark ? Colors.grey[600] : Colors.grey[400],
                ),
                const SizedBox(height: 16),
                TextH3(
                  'Nenhum pedido encontrado',
                  color: isDark ? Colors.white : Colors.black87,
                ),
                const SizedBox(height: 8),
                TextBody2(
                  'Ajuste os filtros ou aguarde novos pedidos',
                  color: isDark ? Colors.grey[400] : Colors.grey[600],
                ),
              ],
            ),
          ),
        ),
      );
    }

    // Lista com pedidos
    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate(
              (context, index) {
            if (index == state.items.length) {
              // Loading more
              if (state.isLoadingMore && state.hasMore) {
                return const Padding(
                  padding: EdgeInsets.all(16),
                  child: Center(
                    child: CircularProgressIndicator(),
                  ),
                );
              }
              // Mensagem de "carregar mais"
              if (state.hasMore && !state.isLoadingMore) {
                return Padding(
                  padding: const EdgeInsets.all(16),
                  child: Center(
                    child: Text(
                      'Role para carregar mais...',
                      style: TextStyle(
                        fontSize: 12,
                        color: isDark ? Colors.grey[500] : Colors.grey,
                      ),
                    ),
                  ),
                );
              }
              return const SizedBox.shrink();
            }

            final pedido = state.items[index];
            return RepaintBoundary(
              child: _PedidoCard(
                pedido: pedido,
                onTap: () {
                  context.go('/pedidos/${pedido.id}');
                },
              ),
            );
          },
          childCount: state.items.length + 1, // +1 para o loading/end
        ),
      ),
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
    final isDark = theme.brightness == Brightness.dark;
    final statusColor = _getStatusColor(pedido.status);

    // Cores adaptativas
    final textColor = isDark ? Colors.white : Colors.black87;
    final subtitleColor = isDark ? Colors.grey[400] : Colors.grey[600];
    final iconColor = isDark ? Colors.grey[400] : Colors.grey[600];

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: QuiGestorCard(
        onTap: onTap,
        padding: const EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Avatar com imagem ou ícone
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: statusColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: pedido.lojaImagem != null && pedido.lojaImagem!.isNotEmpty
                    ? Image.network(
                  pedido.lojaImagem!,
                  width: 48,
                  height: 48,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => _buildFallbackIcon(statusColor),
                )
                    : _buildFallbackIcon(statusColor),
              ),
            ),

            const SizedBox(width: 12),

            // Conteúdo principal
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Código e status
                  Row(
                    children: [
                      Expanded(
                        child: TextH3(
                          pedido.codigo,
                          maxLines: 1,
                          fontWeight: FontWeight.w600,
                          color: textColor,
                        ),
                      ),
                      // Chip de status
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: statusColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: TextBody3(
                          pedido.statusLabel,
                          color: statusColor,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),

                  // Cliente e loja
                  Row(
                    children: [
                      Icon(Icons.person_outline, size: 13, color: iconColor),
                      const SizedBox(width: 4),
                      Expanded(
                        child: TextBody3(
                          '${pedido.clienteNome} • ${pedido.lojaNome}',
                          color: subtitleColor,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),

                  // Total e data
                  Row(
                    children: [
                      Icon(Icons.attach_money_outlined, size: 13, color: iconColor),
                      const SizedBox(width: 4),
                      TextBody3(
                        'R\$ ${pedido.total.toStringAsFixed(2)}',
                        color: subtitleColor,
                        fontWeight: FontWeight.w500,
                      ),
                      const SizedBox(width: 12),
                      Icon(Icons.access_time_outlined, size: 13, color: iconColor),
                      const SizedBox(width: 4),
                      TextBody3(
                        _formatDate(pedido.criadoEm),
                        color: subtitleColor,
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Setinha
            Icon(
              Icons.chevron_right_rounded,
              color: isDark ? Colors.grey[500] : Colors.grey[400],
              size: 20,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFallbackIcon(Color statusColor) {
    return Center(
      child: Icon(
        Icons.receipt_long,
        color: statusColor,
        size: 24,
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