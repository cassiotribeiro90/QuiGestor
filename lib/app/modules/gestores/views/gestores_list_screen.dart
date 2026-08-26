import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../apparte/widgets/app_text.dart';
import '../../../../apparte/widgets/loading_skeleton.dart';
import '../../../../apparte/widgets/quigestor_card.dart';
import '../../../app_config.dart';
import '../bloc/gestores_cubit.dart';
import '../bloc/gestores_state.dart';
import '../models/gestor.dart';
import 'gestor_form_screen.dart';
import '../../../core/constants/icon_constants.dart';
import '../../../models/filter_option.dart';
import '../../../widgets/generic_filter_widget.dart';

class GestoresListScreen extends StatefulWidget {
  const GestoresListScreen({super.key});

  @override
  State<GestoresListScreen> createState() => _GestoresListScreenState();
}

class _GestoresListScreenState extends State<GestoresListScreen> {
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

    await context.read<GestoresCubit>().fetchGestores(
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
    await context.read<GestoresCubit>().fetchGestores(perPage: _perPage);
  }

  @override
  Widget build(BuildContext context) {
    final gestoresCubit = context.read<GestoresCubit>();

    return Scaffold(
      body: BlocConsumer<GestoresCubit, GestoresState>(
        listener: (context, state) {
          if (state is GestoresError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: TextBody2(state.message),
                backgroundColor: Colors.red,
              ),
            );
          } else if (state is GestorOperationSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: TextBody2(state.message),
                backgroundColor: Colors.green,
              ),
            );
          } else if (state is GestoresLoaded) {
            _hasMorePages = state.hasMorePages;
          }
        },
        builder: (context, state) {
          final filterOptions = gestoresCubit.filterOptions;
          final total = state is GestoresLoaded ? state.total : 0;

          return SelectionArea(
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
                      onApply: (params) => gestoresCubit.fetchGestores(filters: params),
                      totalItems: total,
                    ),
                  ),
                _buildListContentSliver(state),
              ],
            ),
          ));
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
    if (state is GestoresLoading && !_isLoadingMore) {
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

    if (state is GestoresLoaded) {
      final gestores = state.gestoresFiltrados;

      if (gestores.isEmpty) {
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
              if (index == gestores.length) {
                return const Center(
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: CircularProgressIndicator(),
                  ),
                );
              }

              final gestor = gestores[index];

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
                            gestor.nome[0].toUpperCase(),
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
            childCount: gestores.length + (_isLoadingMore ? 1 : 0),
          ),
        ),
      );
    }
    return const SliverToBoxAdapter(child: SizedBox());
  }

  void _abrirFormGestor(BuildContext context, {Gestor? gestor}) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => BlocProvider.value(
          value: context.read<GestoresCubit>(),
          child: GestorFormScreen(gestor: gestor),
        ),
      ),
    );
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
