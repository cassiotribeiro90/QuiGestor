import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../apparte/widgets/app_text.dart';
import '../../../app_config.dart';
import '../bloc/lojas_cubit.dart';
import '../bloc/lojas_state.dart';
import '../models/loja.dart';
import '../../../models/filter_option.dart';
import '../../../widgets/generic_filter_widget.dart';
import '../../../widgets/conditional_selection_area.dart';
import '../widgets/loja_card_item.dart';
import '../../../core/constants/icon_constants.dart';
import '../../../routes/app_router.dart';

class LojasListScreen extends StatefulWidget {
  const LojasListScreen({super.key});

  @override
  State<LojasListScreen> createState() => _LojasListScreenState();
}

class _LojasListScreenState extends State<LojasListScreen> {
  final ScrollController _scrollController = ScrollController();
  static const int _perPage = AppConfig.defaultPerPage;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<LojasCubit>().fetchLojas();
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    final cubit = context.read<LojasCubit>();
    if (!cubit.state.hasMorePages || cubit.state.isLoadingMore) return;

    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      cubit.fetchLojas(
        page: cubit.state.currentPage + 1,
        perPage: _perPage,
        isLoadMore: true,
      );
    }
  }

  Future<void> _onRefresh() async {
    await context.read<LojasCubit>().fetchLojas(perPage: _perPage, showLoading: true);
  }

  void _abrirFormLoja(BuildContext context, {Loja? loja}) {
    if (loja != null) {
      context.go(Routes.lojaEditar(loja.id));
    } else {
      context.go(Routes.lojaNovo);
    }
  }

  @override
  Widget build(BuildContext context) {
    final lojasCubit = context.read<LojasCubit>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: BlocConsumer<LojasCubit, LojasState>(
        listener: (context, state) {
          if (state.error != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: TextBody2(state.error!, color: Colors.white),
                backgroundColor: Colors.red,
              ),
            );
          } else if (state.operationMessage != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: TextBody2(state.operationMessage!, color: Colors.white),
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
                        key: ValueKey(filterOptions),
                        groups: (filterOptions).entries
                            .map((entry) => FilterGroup.fromJson(entry.key, entry.value))
                            .toList(),
                        onApply: (params) => lojasCubit.fetchLojas(filters: params, showLoading: false),
                        totalItems: state.total,
                        initialFilters: lojasCubit.activeFilters,
                      ),
                    ),
                  _buildListContentSliver(state),
                ],
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _abrirFormLoja(context),
        label: const TextBody2(
          'Nova Loja',
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
        icon: const Icon(AppIcons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildListContentSliver(LojasState state) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (state.lojasFiltradas.isEmpty && !state.isLoading) {
      return SliverFillRemaining(
        hasScrollBody: false,
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 60),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  AppIcons.store,
                  size: 100,
                  color: isDark ? Colors.grey[600] : Colors.grey[400],
                ),
                const SizedBox(height: 16),
                TextH2(
                  'Nenhuma loja encontrada',
                  color: isDark ? Colors.white : Colors.black87,
                ),
                const SizedBox(height: 8),
                TextBody2(
                  state.lojas.isEmpty
                      ? 'Comece criando uma loja'
                      : 'Tente outros filtros de busca',
                  color: isDark ? Colors.grey[400] : Colors.grey[600],
                ),
                if (state.lojas.isEmpty) ...[
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: () => _abrirFormLoja(context),
                    icon: const Icon(AppIcons.add),
                    label: const TextBody1('Criar Loja'),
                  ),
                ],
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
            if (index == state.lojasFiltradas.length) {
              if (state.isLoadingMore) {
                return const Center(
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: CircularProgressIndicator(),
                  ),
                );
              }
              return const SizedBox.shrink();
            }

            final loja = state.lojasFiltradas[index];
            return RepaintBoundary(
              child: LojaCardItem(
                loja: loja,
                onTap: () => _abrirFormLoja(context, loja: loja),
              ),
            );
          },
          childCount: state.lojasFiltradas.length + 1,
        ),
      ),
    );
  }
}
