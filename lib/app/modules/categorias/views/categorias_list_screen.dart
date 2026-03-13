import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../apparte/widgets/loading_skeleton.dart';
import '../../../app_config.dart';
import '../bloc/categorias_cubit.dart';
import '../bloc/categorias_state.dart';
import '../models/categoria.dart';
import '../widgets/categoria_card.dart';
import '../widgets/categoria_filters.dart';
import 'categoria_form_screen.dart';

class CategoriasListScreen extends StatefulWidget {
  const CategoriasListScreen({super.key});

  @override
  State<CategoriasListScreen> createState() => _CategoriasListScreenState();
}

class _CategoriasListScreenState extends State<CategoriasListScreen> {
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
    _carregarCategorias();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _carregarCategorias() {
    _resetPagination();
    context.read<CategoriasCubit>().fetchCategorias(perPage: _perPage);
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

    await context.read<CategoriasCubit>().fetchCategorias(
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
    await context.read<CategoriasCubit>().fetchCategorias(perPage: _perPage);
  }

  void _showFilters() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const CategoriaFilters(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Categorias'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_alt_outlined),
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
                hintText: 'Buscar categorias...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          context.read<CategoriasCubit>().applySearch('');
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onChanged: (value) {
                _resetPagination();
                context.read<CategoriasCubit>().applySearch(value);
              },
            ),
          ),
        ),
      ),
      body: BlocConsumer<CategoriasCubit, CategoriasState>(
        listener: (context, state) {
          if (state is CategoriasError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message), backgroundColor: Colors.red),
            );
          } else if (state is CategoriaOperationSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message), backgroundColor: Colors.green),
            );
          } else if (state is CategoriasLoaded) {
            _hasMorePages = state.hasMorePages;
          }
        },
        builder: (context, state) {
          if (state is CategoriasLoading && !_isLoadingMore) {
            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: 5,
              itemBuilder: (_, __) => const CategoriaCardSkeleton(),
            );
          }

          if (state is CategoriasLoaded) {
            final categorias = state.categoriasFiltradas;

            if (categorias.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.category_outlined, size: 100, color: Colors.grey[400]),
                    const SizedBox(height: 16),
                    const Text('Nenhuma categoria encontrada'),
                  ],
                ),
              );
            }

            return RefreshIndicator(
              onRefresh: _onRefresh,
              child: ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.all(16),
                itemCount: categorias.length + (_isLoadingMore ? 1 : 0),
                itemBuilder: (context, index) {
                  if (index == categorias.length) {
                    return const Center(
                      child: Padding(
                        padding: EdgeInsets.all(16),
                        child: CircularProgressIndicator(),
                      ),
                    );
                  }

                  final categoria = categorias[index];
                  return CategoriaCard(
                    categoria: categoria,
                    onTap: () => _abrirFormCategoria(context, categoria: categoria),
                  );
                },
              ),
            );
          }
          return const SizedBox();
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _abrirFormCategoria(context),
        label: const Text('Nova Categoria'),
        icon: const Icon(Icons.add),
      ),
    );
  }

  void _abrirFormCategoria(BuildContext context, {Categoria? categoria}) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => CategoriaFormScreen(categoria: categoria)),
    ).then((atualizou) {
      if (atualizou == true) {
        _carregarCategorias();
      }
    });
  }
}
