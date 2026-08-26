import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../apparte/widgets/app_text.dart';
import '../../../../apparte/widgets/loading_skeleton.dart';
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

  bool _isLoadingMore = false;
  bool _hasMorePages = true;
  int _currentPage = 1;
  static const int _perPage = AppConfig.defaultPerPage;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _resetPagination() {
    _currentPage = 1;
    _hasMorePages = true;
    _isLoadingMore = false;
  }

  void _onScroll() {
    if (!_hasMorePages || _isLoadingMore) return;

    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      _loadMore();
    }
  }

  Future<void> _loadMore() async {
    if (_isLoadingMore || !_hasMorePages) return;

    setState(() {
      _isLoadingMore = true;
      _currentPage++;
    });

    await context.read<LojasCubit>().fetchLojas(
      page: _currentPage,
      perPage: _perPage,
      isLoadMore: true,
    );

    if (mounted) {
      setState(() {
        _isLoadingMore = false;
      });
    }
  }

  Future<void> _onRefresh() async {
    _resetPagination();
    await context.read<LojasCubit>().fetchLojas(perPage: _perPage);
  }

  // 🔥 CORRIGIDO: Usando GoRouter
  void _abrirFormLoja(BuildContext context, {Loja? loja}) {
    if (loja != null) {
      context.push(Routes.lojaEditar(loja.id));
    } else {
      context.push(Routes.lojaNovo);
    }
  }

  @override
  Widget build(BuildContext context) {
    final lojasCubit = context.read<LojasCubit>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: BlocConsumer<LojasCubit, LojasState>(
        listener: (context, state) {
          if (state is LojasError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: TextBody2(state.message, color: Colors.white),
                backgroundColor: Colors.red,
              ),
            );
          } else if (state is LojaOperationSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: TextBody2(state.message, color: Colors.white),
                backgroundColor: Colors.green,
              ),
            );
          } else if (state is LojasLoaded) {
            _hasMorePages = state.hasMorePages;
          }
        },
        builder: (context, state) {
          final filterOptions = lojasCubit.filterOptions;
          final pagination = state is LojasLoaded ? state.pagination : null;

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
                        onApply: (params) => lojasCubit.fetchLojas(filters: params),
                        totalItems: pagination?['total'] ?? 0,
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
        label: TextBody2(
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

    if (state is LojasLoading && !_isLoadingMore) {
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

    if (state is LojasLoaded) {
      final lojas = state.lojasFiltradas;

      if (lojas.isEmpty) {
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
              if (index == lojas.length) {
                if (_isLoadingMore) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: CircularProgressIndicator(),
                    ),
                  );
                }
                return const SizedBox.shrink();
              }

              final loja = lojas[index];
              return RepaintBoundary(
                child: LojaCardItem(
                  loja: loja,
                  onTap: () => _abrirFormLoja(context, loja: loja),
                ),
              );
            },
            childCount: lojas.length,
          ),
        ),
      );
    }
    return const SliverToBoxAdapter(child: SizedBox());
  }
}