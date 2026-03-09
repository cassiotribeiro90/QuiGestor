import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/gestores_cubit.dart';
import '../models/gestor.dart';
import '../widgets/gestor_card.dart';
import '../widgets/gestor_filters.dart';
import 'gestor_form_screen.dart';
import 'gestor_detail_screen.dart';
import '../../../../apparte/widgets/app_text.dart';
import '../../../../core/widgets/responsive_layout.dart';

class GestoresListScreen extends StatefulWidget {
  const GestoresListScreen({super.key});

  @override
  State<GestoresListScreen> createState() => _GestoresListScreenState();
}

class _GestoresListScreenState extends State<GestoresListScreen> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    context.read<GestoresCubit>().fetchGestores();
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    _searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      context.read<GestoresCubit>().loadMore();
    }
  }

  void _onSearchChanged(String value) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      context.read<GestoresCubit>().setSearch(value);
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final gestoresCubit = context.read<GestoresCubit>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestores'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list_rounded),
            onPressed: () => _showFilters(context, gestoresCubit),
          ),
        ],
      ),
      body: Column(
        children: [
          // Barra de pesquisa
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Buscar por nome, email ou CPF',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          context.read<GestoresCubit>().setSearch('');
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onChanged: _onSearchChanged,
            ),
          ),

          // Lista de gestores
          Expanded(
            child: BlocConsumer<GestoresCubit, GestoresState>(
              listener: (context, state) {
                if (state is GestorOperationSuccess) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(state.message),
                      backgroundColor: Colors.green,
                    ),
                  );
                } else if (state is GestoresError) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(state.message),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
              builder: (context, state) {
                if (state is GestoresLoading && state is! GestoresLoadingMore) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (state is GestoresError) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.error_outline, size: 80, color: theme.colorScheme.error),
                        const SizedBox(height: 16),
                        TextBody1(state.message),
                        const SizedBox(height: 24),
                        ElevatedButton(
                          onPressed: () => context.read<GestoresCubit>().fetchGestores(),
                          child: const Text('Tentar novamente'),
                        ),
                      ],
                    ),
                  );
                }

                if (state is GestoresLoaded) {
                  if (state.filteredGestores.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.people_outline, size: 100, color: Colors.grey[400]),
                          const SizedBox(height: 16),
                          const TextH3('Nenhum gestor encontrado'),
                          const SizedBox(height: 8),
                          TextBody2(
                            _searchController.text.isNotEmpty
                                ? 'Tente outros termos de busca'
                                : 'Clique no botão + para adicionar',
                          ),
                        ],
                      ),
                    );
                  }

                  return RefreshIndicator(
                    onRefresh: () => context.read<GestoresCubit>().fetchGestores(),
                    child: ListView.builder(
                      controller: _scrollController,
                      padding: const EdgeInsets.all(16),
                      itemCount: state.filteredGestores.length + (state.hasMore ? 1 : 0),
                      itemBuilder: (context, index) {
                        if (index == state.filteredGestores.length) {
                          return const Padding(
                            padding: EdgeInsets.all(16),
                            child: Center(child: CircularProgressIndicator()),
                          );
                        }

                        final gestor = state.filteredGestores[index];
                        return GestorCard(
                          gestor: gestor,
                          onTap: () => _navigateToDetail(context, gestor),
                          onEdit: () => _navigateToEdit(context, gestoresCubit, gestor),
                          onDelete: () => _confirmDelete(context, gestor),
                        );
                      },
                    ),
                  );
                }

                return const SizedBox();
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _navigateToCreate(context, gestoresCubit),
        icon: const Icon(Icons.add),
        label: const Text('Novo Gestor'),
      ),
    );
  }

  void _showFilters(BuildContext context, GestoresCubit cubit) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => BlocProvider.value(
        value: cubit,
        child: const GestorFilters(),
      ),
    );
  }

  void _navigateToCreate(BuildContext context, GestoresCubit cubit) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => BlocProvider.value(
          value: cubit,
          child: const GestorFormScreen(),
        ),
      ),
    );
    if (result == true && context.mounted) {
      cubit.fetchGestores();
    }
  }

  void _navigateToEdit(BuildContext context, GestoresCubit cubit, Gestor gestor) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => BlocProvider.value(
          value: cubit,
          child: GestorFormScreen(gestor: gestor),
        ),
      ),
    );
    if (result == true && context.mounted) {
      cubit.fetchGestores();
    }
  }

  void _navigateToDetail(BuildContext context, Gestor gestor) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => GestorDetailScreen(gestor: gestor),
      ),
    );
  }

  Future<void> _confirmDelete(BuildContext context, Gestor gestor) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar exclusão'),
        content: Text('Deseja realmente excluir o gestor ${gestor.nome}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Excluir'),
          ),
        ],
      ),
    );

    if (confirm == true && context.mounted) {
      context.read<GestoresCubit>().deleteGestor(gestor.id);
    }
  }
}
