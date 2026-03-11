import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../apparte/widgets/loading_skeleton.dart';
import '../../../../apparte/widgets/quigestor_card.dart';
import '../bloc/lojas_cubit.dart';
import '../bloc/lojas_state.dart';
import '../models/loja.dart';
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
  bool _showFiltros = false;
  String? _filtroStatus;
  String? _filtroCategoria;
  bool? _filtroDestaque;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    context.read<LojasCubit>().fetchLojas(perPage: 10);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      if (context.read<LojasCubit>().hasMorePages && !_isLoadingMore) {
        _loadMore();
      }
    }
  }

  Future<void> _loadMore() async {
    setState(() => _isLoadingMore = true);

    final currentPage = context.read<LojasCubit>().currentPage;
    await context.read<LojasCubit>().fetchLojas(
      page: currentPage + 1,
      perPage: 10,
      isLoadMore: true,
    );

    setState(() => _isLoadingMore = false);
  }

  void _aplicarFiltros() {
    final search = _searchController.text;

    if (search.isNotEmpty) {
      context.read<LojasCubit>().filtrarLojas(search);
    } else {
      context.read<LojasCubit>().fetchLojas(
        status: _filtroStatus,
        destaque: _filtroDestaque,
        perPage: 10,
      );
    }
  }

  String _formatarTempoEntrega(Loja loja) {
    if (loja.tempoEntregaMin == loja.tempoEntregaMax) {
      return '${loja.tempoEntregaMin} min';
    }
    return '${loja.tempoEntregaMin}-${loja.tempoEntregaMax} min';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Todas as Lojas'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(120),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Buscar lojas por nome, cidade...',
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
                            context.read<LojasCubit>().limparFiltros();
                          },
                        ),
                      ],
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onChanged: (value) {
                    if (value.isEmpty) {
                      context.read<LojasCubit>().limparFiltros();
                    } else {
                      context.read<LojasCubit>().filtrarLojas(value);
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
                        label: const Text('Ativo'),
                        selected: _filtroStatus == 'ativo',
                        onSelected: (selected) {
                          setState(() {
                            _filtroStatus = selected ? 'ativo' : null;
                          });
                          _aplicarFiltros();
                        },
                      ),
                      const SizedBox(width: 8),
                      FilterChip(
                        label: const Text('Em revisão'),
                        selected: _filtroStatus == 'revisao',
                        onSelected: (selected) {
                          setState(() {
                            _filtroStatus = selected ? 'revisao' : null;
                          });
                          _aplicarFiltros();
                        },
                      ),
                      const SizedBox(width: 8),
                      FilterChip(
                        label: const Text('Destaque'),
                        selected: _filtroDestaque == true,
                        onSelected: (selected) {
                          setState(() {
                            _filtroDestaque = selected ? true : null;
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
                    Text(
                      'Nenhuma loja encontrada',
                      style: theme.textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      state.lojas.isEmpty
                          ? 'Comece criando uma loja'
                          : 'Tente outros filtros de busca',
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                    if (state.lojas.isEmpty) ...[
                      const SizedBox(height: 24),
                      ElevatedButton.icon(
                        onPressed: () => _abrirFormLoja(context),
                        icon: const Icon(Icons.add),
                        label: const Text('Criar Loja'),
                      ),
                    ],
                  ],
                ),
              );
            }

            return RefreshIndicator(
              onRefresh: () => context.read<LojasCubit>().refreshList(),
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

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: QuiGestorCard(
                      onTap: () => _abrirFormLoja(context, loja: loja),
                      child: Row(
                        children: [
                          Container(
                            width: 56,
                            height: 56,
                            decoration: BoxDecoration(
                              color: theme.colorScheme.primary.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Center(
                              child: loja.logo != null
                                  ? ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.network(
                                  loja.logo!,
                                  width: 40,
                                  height: 40,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) => Icon(
                                    Icons.store,
                                    color: theme.colorScheme.primary,
                                  ),
                                ),
                              )
                                  : Text(
                                loja.nome[0].toUpperCase(),
                                style: TextStyle(
                                  color: theme.colorScheme.primary,
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
                                        loja.nome,
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    if (loja.destaque)
                                      Container(
                                        margin: const EdgeInsets.only(right: 8),
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 4,
                                        ),
                                        decoration: BoxDecoration(
                                          color: Colors.amber.withOpacity(0.1),
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        child: const Text(
                                          '⭐',
                                          style: TextStyle(fontSize: 12),
                                        ),
                                      ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 4,
                                      ),
                                      decoration: BoxDecoration(
                                        color: loja.statusColor.withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Text(
                                        loja.statusLabel,
                                        style: TextStyle(
                                          color: loja.statusColor,
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
                                    Icon(
                                      Icons.category_outlined,
                                      size: 14,
                                      color: Colors.grey[600],
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      loja.categoria,
                                      style: TextStyle(
                                        color: Colors.grey[600],
                                        fontSize: 13,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Icon(
                                      Icons.location_on_outlined,
                                      size: 14,
                                      color: Colors.grey[600],
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      '${loja.cidade}/${loja.uf}',
                                      style: TextStyle(
                                        color: Colors.grey[600],
                                        fontSize: 13,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 2),
                                Row(
                                  children: [
                                    Icon(
                                      Icons.access_time_outlined,
                                      size: 14,
                                      color: Colors.grey[600],
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      _formatarTempoEntrega(loja),
                                      style: TextStyle(
                                        color: Colors.grey[600],
                                        fontSize: 13,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Icon(
                                      Icons.attach_money_outlined,
                                      size: 14,
                                      color: Colors.grey[600],
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      'R\$ ${loja.pedidoMinimo.toStringAsFixed(2)}',
                                      style: TextStyle(
                                        color: Colors.grey[600],
                                        fontSize: 13,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          Icon(
                            Icons.chevron_right_rounded,
                            color: Colors.grey[400],
                          ),
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
        onPressed: () => _abrirFormLoja(context),
        label: const Text('Nova Loja'),
        icon: const Icon(Icons.add),
      ),
    );
  }

  void _abrirFormLoja(BuildContext context, {Loja? loja}) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => LojaFormScreen(loja: loja),
      ),
    ).then((atualizou) {
      if (atualizou == true) {
        context.read<LojasCubit>().refreshList();
      }
    });
  }
}