// lib/app/modules/clientes/views/clientes_list_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../apparte/widgets/app_text.dart';
import '../../../../apparte/widgets/loading_skeleton.dart';
import '../../../models/filter_option.dart';
import '../../../widgets/generic_filter_widget.dart';
import '../../../widgets/conditional_selection_area.dart';
import '../../../routes/app_router.dart';
import '../bloc/clientes_cubit.dart';
import '../bloc/clientes_state.dart';
import '../widgets/cliente_card.dart';

class ClientesListScreen extends StatefulWidget {
  const ClientesListScreen({super.key});

  @override
  State<ClientesListScreen> createState() => _ClientesListScreenState();
}

class _ClientesListScreenState extends State<ClientesListScreen> {
  final ScrollController _scrollController = ScrollController();
  late final ClientesCubit _cubit;

  @override
  void initState() {
    super.initState();
    _cubit = context.read<ClientesCubit>();
    _cubit.fetchClientes();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      _cubit.loadMore();
    }
  }

  Future<void> _onRefresh() async {
    await _cubit.refresh();
  }

  void _navegarParaForm(BuildContext context, {int? clienteId}) {
    if (clienteId != null) {
      context.go(Routes.clienteEditar(clienteId));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocConsumer<ClientesCubit, ClientesState>(
        listener: (context, state) {
          if (state is ClientesError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: TextBody2(state.message, color: Colors.white),
                backgroundColor: Colors.red,
              ),
            );
          } else if (state is ClienteOperationSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: TextBody2(state.message, color: Colors.white),
                backgroundColor: Colors.green,
              ),
            );
            _cubit.refresh();
          }
        },
        builder: (context, state) {
          final filterOptions = _cubit.filterOptions;
          final total = state is ClientesLoaded ? state.total : 0;

          return ConditionalSelectionArea(
            child: RefreshIndicator(
              onRefresh: _onRefresh,
              child: CustomScrollView(
                controller: _scrollController,
                physics: const AlwaysScrollableScrollPhysics(),
                slivers: [
                  if (filterOptions != null)
                    SliverToBoxAdapter(
                      child: GenericFilterWidget(
                        groups: (filterOptions).entries
                            .map((entry) => FilterGroup.fromJson(entry.key, entry.value))
                            .whereType<FilterGroup>()
                            .toList(),
                        onApply: (params) => _cubit.fetchClientes(filters: params),
                        totalItems: total,
                      ),
                    ),
                  _buildListContentSliver(state),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildListContentSliver(ClientesState state) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (state is ClientesLoading && state is! ClientesLoaded) {
      return SliverPadding(
        padding: const EdgeInsets.all(16),
        sliver: SliverList(
          delegate: SliverChildBuilderDelegate(
            (_, __) => const Padding(
              padding: EdgeInsets.only(bottom: 12),
              child: LojaCardSkeleton(),
            ),
            childCount: 5,
          ),
        ),
      );
    }

    if (state is ClientesLoaded) {
      final clientes = state.clientes;

      if (clientes.isEmpty) {
        return SliverFillRemaining(
          hasScrollBody: false,
          child: Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 40),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.people_outline,
                    size: 80,
                    color: isDark ? Colors.grey[600] : Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  TextH3(
                    'Nenhum cliente encontrado',
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                  const SizedBox(height: 8),
                  TextBody2(
                    'Ajuste os filtros de busca',
                    color: isDark ? Colors.grey[400] : Colors.grey[600],
                  ),
                ],
              ),
            ),
          ),
        );
      }

      return SliverPadding(
        padding: const EdgeInsets.all(16),
        sliver: SliverList(
          delegate: SliverChildBuilderDelegate(
            (context, index) {
              if (index == clientes.length) {
                if (state.hasMore) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: CircularProgressIndicator(),
                    ),
                  );
                }
                return const SizedBox.shrink();
              }

              final cliente = clientes[index];
              return RepaintBoundary(
                child: ClienteCard(
                  cliente: cliente,
                  onTap: () => _navegarParaForm(context, clienteId: cliente.id),
                ),
              );
            },
            childCount: clientes.length + (state.hasMore ? 1 : 0),
          ),
        ),
      );
    }

    return const SliverToBoxAdapter(child: SizedBox.shrink());
  }
}
