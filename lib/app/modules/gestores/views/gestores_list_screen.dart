import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:quigestor/apparte/widgets/loading_skeleton.dart';
import 'package:quigestor/apparte/widgets/quigestor_card.dart';
import 'package:quigestor/core/config/app_config.dart';
import 'package:quigestor/app/modules/gestores/bloc/gestores_cubit.dart';
import 'package:quigestor/app/modules/gestores/bloc/gestores_state.dart';
import 'package:quigestor/app/modules/gestores/models/gestor.dart';
import 'package:quigestor/app/modules/gestores/views/gestor_form_screen.dart';

class GestoresListScreen extends StatefulWidget {
  const GestoresListScreen({super.key});

  @override
  State<GestoresListScreen> createState() => _GestoresListScreenState();
}

class _GestoresListScreenState extends State<GestoresListScreen> {
  final _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  bool _isLoadingMore = false;
  bool _showFiltros = false;
  String? _filtroNivel;
  int? _filtroStatus;

  bool _hasMorePages = true;
  int _currentPage = 1;
  static const int _perPage = AppConfig.defaultPerPage;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _carregarGestores();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _carregarGestores() {
    _resetPagination();
    context.read<GestoresCubit>().fetchGestores(perPage: _perPage);
  }

  void _resetPagination() {
    _currentPage = 1;
    _hasMorePages = true;
    _isLoadingMore = false;
  }

  void _onScroll() {
    if (!_hasMorePages || _isLoadingMore) return;

    if (_scrollController.position.maxScrollExtent < 100 && _hasMorePages) {
      _loadMore();
      return;
    }

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
    setState(() {
      _filtroNivel = null;
      _filtroStatus = null;
      _showFiltros = false;
      _resetPagination();
    });
    
    await context.read<GestoresCubit>().fetchGestores(perPage: _perPage);
  }

  void _aplicarFiltros() {
    _resetPagination();
    
    final search = _searchController.text;
    if (search.isNotEmpty) {
      context.read<GestoresCubit>().applySearch(search);
    } else {
      context.read<GestoresCubit>().fetchGestores(
        nivel: _filtroNivel,
        status: _filtroStatus,
        perPage: _perPage,
      );
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestores'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(120),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Buscar gestores por nome, email...',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: Icon(
                            _showFiltros ? Icons.filter_list_off : Icons.filter_list,
                          ),
                          onPressed: () {
                            setState(() => _showFiltros = !_showFiltros);
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            _searchController.clear();
                            context.read<GestoresCubit>().clearFilters();
                          },
                        ),
                      ],
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onChanged: (value) {
                    _resetPagination();
                    if (value.isEmpty) {
                      context.read<GestoresCubit>().clearFilters();
                    } else {
                      context.read<GestoresCubit>().applySearch(value);
                    }
                  },
                ),
              ),
              if (_showFiltros)
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  child: Row(
                    children: [
                      FilterChip(
                        label: const Text('Admin'),
                        selected: _filtroNivel == 'admin',
                        onSelected: (selected) {
                          setState(() {
                            _filtroNivel = selected ? 'admin' : null;
                          });
                          _aplicarFiltros();
                        },
                      ),
                      const SizedBox(width: 8),
                      FilterChip(
                        label: const Text('Comercial'),
                        selected: _filtroNivel == 'comercial',
                        onSelected: (selected) {
                          setState(() {
                            _filtroNivel = selected ? 'comercial' : null;
                          });
                          _aplicarFiltros();
                        },
                      ),
                      const SizedBox(width: 8),
                      FilterChip(
                        label: const Text('Ativo'),
                        selected: _filtroStatus == 1,
                        onSelected: (selected) {
                          setState(() {
                            _filtroStatus = selected ? 1 : null;
                          });
                          _aplicarFiltros();
                        },
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
      body: BlocConsumer<GestoresCubit, GestoresState>(
        listener: (context, state) {
          if (state is GestoresError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          } else if (state is GestorOperationSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
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
                    Icon(Icons.people_outline, size: 100, color: Colors.grey[400]),
                    const SizedBox(height: 16),
                    Text('Nenhum gestor encontrado', style: theme.textTheme.titleMedium),
                    const SizedBox(height: 8),
                    Text(
                      state.gestores.isEmpty ? 'Comece criando um gestor' : 'Tente outros filtros de busca',
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                    if (state.gestores.isEmpty) ...[
                      const SizedBox(height: 24),
                      ElevatedButton.icon(
                        onPressed: () => _abrirFormGestor(context),
                        icon: const Icon(Icons.add),
                        label: const Text('Criar Gestor'),
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
                              child: Text(
                                gestor.nome[0].toUpperCase(),
                                style: TextStyle(
                                  color: _getStatusColor(gestor.status),
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                ),
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
                                      child: Text(
                                        gestor.nome,
                                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: _getStatusColor(gestor.status).withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Text(
                                        _getStatusLabel(gestor.status),
                                        style: TextStyle(
                                          color: _getStatusColor(gestor.status),
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    Icon(Icons.email_outlined, size: 14, color: Colors.grey[600]),
                                    const SizedBox(width: 4),
                                    Text(gestor.email, style: TextStyle(color: Colors.grey[600], fontSize: 13)),
                                  ],
                                ),
                                const SizedBox(height: 2),
                                Row(
                                  children: [
                                    Icon(Icons.security_outlined, size: 14, color: Colors.grey[600]),
                                    const SizedBox(width: 4),
                                    Text(gestor.nivel, style: TextStyle(color: Colors.grey[600], fontSize: 13)),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          Icon(Icons.chevron_right_rounded, color: Colors.grey[400]),
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
        label: const Text('Novo Gestor'),
        icon: const Icon(Icons.add),
      ),
    );
  }

  void _abrirFormGestor(BuildContext context, {Gestor? gestor}) {
    final cubit = context.read<GestoresCubit>();
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => GestorFormScreen(gestor: gestor)),
    ).then((atualizou) {
      if (atualizou == true) {
        _resetPagination();
        cubit.refreshList();
      }
    });
  }
}
