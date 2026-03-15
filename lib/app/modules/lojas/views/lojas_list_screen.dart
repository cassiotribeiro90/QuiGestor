import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../apparte/widgets/loading_skeleton.dart';
import '../../../app_config.dart';
import '../bloc/lojas_cubit.dart';
import '../bloc/lojas_state.dart';
import '../models/loja.dart';
import '../widgets/loja_filters.dart';
import '../widgets/loja_card_item.dart';
import 'loja_form_screen.dart';

class LojasListScreen extends StatefulWidget {
  const LojasListScreen({super.key});

  @override
  State<LojasListScreen> createState() => _LojasListScreenState();
}

class _LojasListScreenState extends State<LojasListScreen> {
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
    _searchController.clear();
    _resetPagination();
    await context.read<LojasCubit>().fetchLojas(perPage: _perPage);
  }

  void _showFilters(LojasCubit cubit) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => BlocProvider.value(
        value: cubit,
        child: const LojaFilters(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final lojasCubit = context.read<LojasCubit>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Todas as Lojas'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_alt_outlined),
            onPressed: () => _showFilters(lojasCubit),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(80),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Buscar lojas por nome, cidade...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          context.read<LojasCubit>().applySearch('');
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onChanged: (value) {
                _resetPagination();
                context.read<LojasCubit>().applySearch(value);
              },
            ),
          ),
        ),
      ),
      body: BlocConsumer<LojasCubit, LojasState>(
        listener: (context, state) {
          if (state is LojasError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          } else if (state is LojaOperationSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.green,
              ),
            );
          } else if (state is LojasLoaded) {
            _hasMorePages = state.hasMorePages;
          }
        },
        builder: (context, state) {
          if (state is LojasLoading && !_isLoadingMore) {
            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: 5,
              itemBuilder: (_, __) => const Padding(
                padding: EdgeInsets.only(bottom: 12),
                child: LojaCardSkeleton(),
              ),
            );
          }

          if (state is LojasLoaded) {
            final lojas = state.lojasFiltradas;

            if (lojas.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.storefront_outlined,
                      size: 100,
                      color: Colors.grey[400],
                    ),
                    const SizedBox(height: 16),
                    Text('Nenhuma loja encontrada',
                        style: theme.textTheme.titleMedium),
                    const SizedBox(height: 8),
                    Text(
                      state.lojas.isEmpty
                          ? 'Comece criando uma loja'
                          : 'Tente outros filtros de busca',
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                  ],
                ),
              );
            }

            return RefreshIndicator(
              onRefresh: _onRefresh,
              child: ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.all(16),
                itemCount: lojas.length + (_isLoadingMore ? 1 : 0),
                itemBuilder: (context, index) {
                  if (index == lojas.length) {
                    return const Center(
                      child: Padding(
                        padding: EdgeInsets.all(16),
                        child: CircularProgressIndicator(),
                      ),
                    );
                  }

                  final loja = lojas[index];
                  return LojaCardItem(
                    loja: loja,
                    onTap: () => _abrirFormLoja(context, loja: loja),
                  );
                },
              ),
            );
          }
          return const SizedBox();
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _abrirFormLoja(context),
        label: const Text('Nova Loja'),
        icon: const Icon(Icons.add),
      ),
    );
  }

  void _abrirFormLoja(BuildContext context, {Loja? loja}) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => BlocProvider.value(
          value: context.read<LojasCubit>(),
          child: LojaFormScreen(loja: loja),
        ),
      ),
    );
  }
}
