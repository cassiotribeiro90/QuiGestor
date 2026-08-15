import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../apparte/widgets/app_text.dart';
import '../../../../apparte/widgets/loading_skeleton.dart';
import '../../../../apparte/widgets/quigestor_card.dart';
import '../../../app_config.dart';
import '../bloc/gestores_cubit.dart';
import '../bloc/gestores_state.dart';
import '../models/gestor.dart';
import '../widgets/gestor_filters.dart';
import 'gestor_form_screen.dart';
import '../../../core/constants/icon_constants.dart';

class GestoresListScreen extends StatefulWidget {
  const GestoresListScreen({super.key});

  @override
  State<GestoresListScreen> createState() => _GestoresListScreenState();
}

class _GestoresListScreenState extends State<GestoresListScreen> {
  final _searchController = TextEditingController();
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
    _searchController.dispose();
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
    _searchController.clear();
    _resetPagination();
    await context.read<GestoresCubit>().fetchGestores(perPage: _perPage);
  }

  void _showFilters() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const GestorFilters(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const TextH2('Gestores'),
        actions: [
          IconButton(
            icon: const Icon(AppIcons.filter),
            onPressed: _showFilters,
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(80),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Buscar gestores por nome, email...',
                prefixIcon: const Icon(AppIcons.search),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(AppIcons.clear),
                        onPressed: () {
                          _searchController.clear();
                          context.read<GestoresCubit>().applySearch('');
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onChanged: (value) {
                _resetPagination();
                context.read<GestoresCubit>().applySearch(value);
              },
            ),
          ),
        ),
      ),
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
          if (state is GestoresLoading && !_isLoadingMore) {
            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: 5,
              itemBuilder: (_, __) => const Padding(
                padding: EdgeInsets.only(bottom: 12),
                child: LojaCardSkeleton(),
              ),
            );
          }

          if (state is GestoresLoaded) {
            final gestores = state.gestoresFiltrados;

            if (gestores.isEmpty) {
              return Center(
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
              );
            }

            return RefreshIndicator(
              onRefresh: _onRefresh,
              child: ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.all(16),
                itemCount: gestores.length + (_isLoadingMore ? 1 : 0),
                itemBuilder: (context, index) {
                  if (index == gestores.length) {
                    return const Center(
                      child: Padding(
                        padding: EdgeInsets.all(16),
                        child: CircularProgressIndicator(),
                      ),
                    );
                  }

                  final gestor = gestores[index];

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
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
                                    TextBody3(gestor.email, color: Colors.grey[600]),
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
              ),
            );
          }
          return const SizedBox();
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _abrirFormGestor(context),
        label: const TextInverse('Novo Gestor', fontWeight: FontWeight.bold),
        icon: const Icon(AppIcons.add),
      ),
    );
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
