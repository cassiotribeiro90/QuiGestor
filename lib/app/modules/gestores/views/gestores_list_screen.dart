import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../apparte/widgets/app_text.dart';
import '../../../../apparte/widgets/quigestor_card.dart';
import '../../../app_config.dart';
import '../../../routes/app_router.dart';
import '../bloc/gestores_cubit.dart';
import '../bloc/gestores_state.dart';
import '../models/gestor.dart';
import '../../../core/constants/icon_constants.dart';
import '../../../models/filter_option.dart';
import '../../../widgets/generic_filter_widget.dart';
import '../../../widgets/conditional_selection_area.dart';

class GestoresListScreen extends StatefulWidget {
  const GestoresListScreen({super.key});

  @override
  State<GestoresListScreen> createState() => _GestoresListScreenState();
}

class _GestoresListScreenState extends State<GestoresListScreen> {
  final ScrollController _scrollController = ScrollController();
  static const int _perPage = AppConfig.defaultPerPage;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<GestoresCubit>().fetchGestores();
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    final cubit = context.read<GestoresCubit>();
    if (!cubit.state.hasMorePages || cubit.state.isLoadingMore) return;

    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      cubit.fetchGestores(
        page: cubit.state.currentPage + 1,
        perPage: _perPage,
        isLoadMore: true,
      );
    }
  }

  Future<void> _onRefresh() async {
    await context.read<GestoresCubit>().fetchGestores(perPage: _perPage, showLoading: true);
  }

  @override
  Widget build(BuildContext context) {
    final gestoresCubit = context.read<GestoresCubit>();

    return Scaffold(
      body: BlocConsumer<GestoresCubit, GestoresState>(
        listener: (context, state) {
          if (state.error != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: TextBody2(state.error!),
                backgroundColor: Colors.red,
              ),
            );
          } else if (state.operationMessage != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: TextBody2(state.operationMessage!),
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
                        onApply: (params) => gestoresCubit.fetchGestores(filters: params, showLoading: false),
                        totalItems: total,
                        initialFilters: gestoresCubit.activeFilters,
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
        onPressed: () => _abrirFormGestor(context),
        label: const TextInverse('Novo Gestor', fontWeight: FontWeight.bold),
        icon: const Icon(AppIcons.add),
      ),
    );
  }

  Widget _buildListContentSliver(GestoresState state) {
    if (state.gestoresFiltrados.isEmpty && !state.isLoading) {
      return SliverFillRemaining(
        hasScrollBody: false,
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 60),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(AppIcons.people, size: 100, color: Colors.grey[400]),
                const SizedBox(height: 16),
                const TextH2('Nenhum gestor encontrado'),
                const SizedBox(height: 8),
                TextBody2(
                  state.gestores.isEmpty ? 'Comece criando um gestor' : 'Tente outros filtros de busca',
                  color: Colors.grey[600],
                ),
                if (state.gestores.isEmpty) ...[
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: () => _abrirFormGestor(context),
                    icon: const Icon(AppIcons.add),
                    label: const TextBody2('Criar Gestor', fontWeight: FontWeight.bold, color: Colors.white),
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
            if (index == state.gestoresFiltrados.length) {
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

            final gestor = state.gestoresFiltrados[index];

            return RepaintBoundary(
              child: QuiGestorCard(
                onTap: () => _abrirFormGestor(context, gestor: gestor),
                child: Row(
                  children: [
                    Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        color: _getStatusColor(gestor.status).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Center(
                        child: TextH1(
                          gestor.nome.isNotEmpty ? gestor.nome[0].toUpperCase() : '?',
                          color: _getStatusColor(gestor.status),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: TextBody1(
                                  gestor.nome,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: _getStatusColor(gestor.status).withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: TextBody3(
                                  _getStatusLabel(gestor.status),
                                  color: _getStatusColor(gestor.status),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Icon(AppIcons.email, size: 14, color: Colors.grey[600]),
                              const SizedBox(width: 4),
                              Expanded(
                                child: TextBody3(gestor.email, color: Colors.grey[600]),
                              ),
                            ],
                          ),
                          const SizedBox(height: 2),
                          Row(
                            children: [
                              Icon(AppIcons.admin, size: 14, color: Colors.grey[600]),
                              const SizedBox(width: 4),
                              TextBody3(gestor.nivel, color: Colors.grey[600]),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Icon(AppIcons.chevronRight, color: Colors.grey[400]),
                  ],
                ),
              ),
            );
          },
          childCount: state.gestoresFiltrados.length + 1,
        ),
      ),
    );
  }

  void _abrirFormGestor(BuildContext context, {Gestor? gestor}) {
    if (gestor != null) {
      context.go(Routes.gestorEditar(gestor.id));
    } else {
      context.go(Routes.gestorNovo);
    }
  }

  Color _getStatusColor(int status) {
    switch (status) {
      case 1: return Colors.green;
      case 0: return Colors.grey;
      case 2: return Colors.red;
      default: return Colors.grey;
    }
  }

  String _getStatusLabel(int status) {
    switch (status) {
      case 1: return 'Ativo';
      case 0: return 'Inativo';
      case 2: return 'Bloqueado';
      default: return 'Desconhecido';
    }
  }
}
