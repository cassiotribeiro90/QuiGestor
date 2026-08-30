import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../bloc/lojistas_cubit.dart';
import '../bloc/lojistas_state.dart';
import '../widgets/lojista_card.dart';
import '../widgets/carregar_mais_button.dart';
import '../../../core/constants/icon_constants.dart';
import '../../../models/filter_option.dart';
import '../../../widgets/generic_filter_widget.dart';
import '../../../widgets/conditional_selection_area.dart';
import '../../../routes/app_router.dart';

class LojistasListPage extends StatefulWidget {
  const LojistasListPage({super.key});

  @override
  State<LojistasListPage> createState() => _LojistasListPageState();
}

class _LojistasListPageState extends State<LojistasListPage> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<LojistasCubit>().carregar();
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _navegarParaForm(BuildContext context, [int? id]) {
    if (id != null) {
      context.go(Routes.lojistaEditar(id));
    } else {
      context.go(Routes.lojistaNovo);
    }
  }

  @override
  Widget build(BuildContext context) {
    final lojistasCubit = context.read<LojistasCubit>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () => _navegarParaForm(context),
        backgroundColor: Theme.of(context).colorScheme.primary,
        child: const Icon(AppIcons.add, color: Colors.white),
      ),
      body: BlocConsumer<LojistasCubit, LojistasState>(
        listener: (context, state) {
          if (state.error != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  state.error!,
                  style: TextStyle(color: isDark ? Colors.white : Colors.black87),
                ),
                backgroundColor: Colors.red,
              ),
            );
          } else if (state.successMessage != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  state.successMessage!,
                  style: TextStyle(color: isDark ? Colors.white : Colors.black87),
                ),
                backgroundColor: Colors.green,
              ),
            );
          }
        },
        builder: (context, state) {
          // ⭐ SKELETON: só mostra se isLoading = true E for o primeiro carregamento
          if (state.isLoading && state.isFirstLoad) {
            return const Center(child: CircularProgressIndicator());
          }

          final filterOptions = state.filterOptions;
          final total = state.total;

          return ConditionalSelectionArea(
            child: RefreshIndicator(
              onRefresh: () async => lojistasCubit.carregar(showLoading: true),
              child: CustomScrollView(
                controller: _scrollController,
                physics: const AlwaysScrollableScrollPhysics(),
                slivers: [
                  if (filterOptions != null)
                    SliverToBoxAdapter(
                      child: GenericFilterWidget(
                        key: ValueKey(filterOptions),
                        groups: (filterOptions).entries
                            .map((entry) => FilterGroup.fromJson(entry.key, entry.value))
                            .toList(),
                        onApply: (params) => lojistasCubit.carregar(filters: params, showLoading: false),
                        totalItems: total,
                        initialFilters: lojistasCubit.activeFilters,
                      ),
                    ),
                  if (filterOptions == null && !state.isLoading)
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        child: Row(
                          children: [
                            const Spacer(),
                            IconButton(
                              icon: const Icon(AppIcons.refresh),
                              onPressed: () => lojistasCubit.reset(),
                              tooltip: 'Atualizar',
                            ),
                          ],
                        ),
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

  Widget _buildListContentSliver(LojistasState state) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (state.lojistas.isEmpty && !state.isLoading) {
      return SliverFillRemaining(
        hasScrollBody: false,
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(60.0),
            child: Text(
              'Nenhum lojista encontrado',
              style: TextStyle(
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
          ),
        ),
      );
    }
    
    return SliverList(
      delegate: SliverChildBuilderDelegate(
            (context, index) {
          if (index == state.lojistas.length) {
            return CarregarMaisButton(
              hasMore: context.read<LojistasCubit>().hasMore,
              onTap: () {
                context.read<LojistasCubit>().carregar(
                  carregarMais: true,
                );
              },
            );
          }
          final lojista = state.lojistas[index];
          return RepaintBoundary(
            child: LojistaCard(
              lojista: lojista,
              onTap: () => _navegarParaForm(context, lojista.id),
              onDelete: () => _confirmarExclusao(context, lojista.id),
            ),
          );
        },
        childCount: state.lojistas.length + 1,
      ),
    );
  }

  void _confirmarExclusao(BuildContext context, int id) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Confirmar exclusão'),
        content: const Text('Tem certeza que deseja excluir este lojista?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              context.read<LojistasCubit>().deletar(id);
            },
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
            child: const Text('Excluir'),
          ),
        ],
      ),
    );
  }
}
