import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../bloc/avaliacoes_cubit.dart';
import '../bloc/avaliacoes_state.dart';
import '../widgets/avaliacao_card.dart';
import '../widgets/carregar_mais_button.dart';
import '../../../core/constants/icon_constants.dart';
import '../../../models/filter_option.dart';
import '../../../widgets/generic_filter_widget.dart';
import '../../../widgets/conditional_selection_area.dart';
import '../../../routes/app_router.dart';

class AvaliacoesListScreen extends StatefulWidget {
  const AvaliacoesListScreen({super.key});

  @override
  State<AvaliacoesListScreen> createState() => _AvaliacoesListScreenState();
}

class _AvaliacoesListScreenState extends State<AvaliacoesListScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<AvaliacoesCubit>().carregar();
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _navegarParaDetalhe(BuildContext context, int id) {
    context.go(Routes.avaliacaoDetalhe(id));
  }

  @override
  Widget build(BuildContext context) {
    final avaliacoesCubit = context.read<AvaliacoesCubit>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: BlocConsumer<AvaliacoesCubit, AvaliacoesState>(
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
          if (state.isLoading && state.isFirstLoad) {
            return const Center(child: CircularProgressIndicator());
          }

          final filterOptions = state.filterOptions;
          final total = state.total;

          return ConditionalSelectionArea(
            child: RefreshIndicator(
              onRefresh: () async => avaliacoesCubit.carregar(showLoading: true),
              child: CustomScrollView(
                controller: _scrollController,
                physics: const AlwaysScrollableScrollPhysics(),
                slivers: [
                  if (filterOptions != null)
                    SliverToBoxAdapter(
                      child: GenericFilterWidget(
                        key: ValueKey(filterOptions),
                        groups: filterOptions.entries
                            .map((entry) => FilterGroup.fromJson(entry.key, entry.value))
                            .toList(),
                        onApply: (params) => avaliacoesCubit.carregar(filters: params, showLoading: false),
                        totalItems: total,
                        initialFilters: avaliacoesCubit.activeFilters,
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
                              onPressed: () => avaliacoesCubit.reset(),
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

  Widget _buildListContentSliver(AvaliacoesState state) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (state.avaliacoes.isEmpty && !state.isLoading) {
      return SliverFillRemaining(
        hasScrollBody: false,
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(60.0),
            child: Text(
              'Nenhuma avaliação encontrada',
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
          if (index == state.avaliacoes.length) {
            return CarregarMaisButton(
              hasMore: context.read<AvaliacoesCubit>().hasMore,
              onTap: () {
                context.read<AvaliacoesCubit>().carregar(
                  carregarMais: true,
                );
              },
            );
          }
          final avaliacao = state.avaliacoes[index];
          return RepaintBoundary(
            child: AvaliacaoCard(
              avaliacao: avaliacao,
              onTap: () => _navegarParaDetalhe(context, avaliacao.id),
              onDelete: () => _confirmarExclusao(context, avaliacao.id),
            ),
          );
        },
        childCount: state.avaliacoes.length + 1,
      ),
    );
  }

  void _confirmarExclusao(BuildContext context, int id) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Confirmar exclusão'),
        content: const Text('Tem certeza que deseja excluir esta avaliação?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              context.read<AvaliacoesCubit>().deletar(id);
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
