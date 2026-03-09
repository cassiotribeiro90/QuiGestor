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
import '../../../../apparte/widgets/pagination_widget.dart';

class GestoresListScreen extends StatefulWidget {
  const GestoresListScreen({super.key});

  @override
  State<GestoresListScreen> createState() => _GestoresListScreenState();
}

class _GestoresListScreenState extends State<GestoresListScreen> {
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  void _loadInitialData() {
    context.read<GestoresCubit>().fetchGestores(page: 1);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _onSearchChanged(String value) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      if (mounted) {
        context.read<GestoresCubit>().applyFilters(search: value);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestores'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list_rounded),
            onPressed: () => _showFilters(context),
          ),
        ],
      ),
      body: Column(
        children: [
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
                          context.read<GestoresCubit>().applyFilters(search: '');
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

          Expanded(
            child: BlocConsumer<GestoresCubit, GestoresState>(
              listener: (context, state) {
                if (state is GestorOperationSuccess) {
                  print('📋 [LIST] Operação bem-sucedida: ${state.message}');
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(state.message),
                      backgroundColor: Colors.green,
                      duration: const Duration(seconds: 2),
                    ),
                  );
                } else if (state is GestoresError) {
                  print('📋 [LIST] Erro no Cubit: ${state.message}');
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(state.message),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
              builder: (context, state) {
                print('📋 [LIST] Renderizando estado: $state');

                if (state is GestoresLoading && state is! GestoresLoaded) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (state is GestoresError && state is! GestoresLoaded) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.error_outline, size: 80, color: theme.colorScheme.error),
                        const SizedBox(height: 16),
                        TextBody1(state.message),
                        const SizedBox(height: 24),
                        ElevatedButton(
                          onPressed: _loadInitialData,
                          child: const Text('Tentar novamente'),
                        ),
                      ],
                    ),
                  );
                }

                if (state is GestoresLoaded) {
                  if (state.gestores.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.people_outline, size: 100, color: Colors.grey[400]),
                          const SizedBox(height: 16),
                          const TextH3('Nenhum gestor encontrado'),
                          const SizedBox(height: 8),
                          TextBody2('Tente outros termos de busca ou filtros'),
                        ],
                      ),
                    );
                  }

                  return Column(
                    children: [
                      Expanded(
                        child: RefreshIndicator(
                          onRefresh: () async => _loadInitialData(),
                          child: ListView.separated(
                            padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                            itemCount: state.gestores.length,
                            separatorBuilder: (_, __) => const SizedBox(height: 8),
                            itemBuilder: (context, index) {
                              final gestor = state.gestores[index];
                              return GestorCard(
                                gestor: gestor,
                                onTap: () => _navigateToDetail(context, gestor),
                                onEdit: () => _navigateToEdit(context, gestor),
                                onDelete: () => _confirmDelete(context, gestor),
                              );
                            },
                          ),
                        ),
                      ),

                      PaginationWidget(
                        currentPage: state.currentPage,
                        totalPages: state.totalPages,
                        totalItems: state.totalItems,
                        onPageChanged: (page) {
                          context.read<GestoresCubit>().goToPage(page);
                        },
                        isLoading: state is GestoresLoading,
                      ),
                    ],
                  );
                }

                // Fallback para loading se não houver dados e estiver em transição
                if (state is GestoresLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                return const SizedBox();
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _navigateToCreate(context),
        icon: const Icon(Icons.add),
        label: const Text('Novo Gestor'),
      ),
    );
  }

  void _showFilters(BuildContext context) {
    final gestoresCubit = context.read<GestoresCubit>();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => BlocProvider.value(
        value: gestoresCubit,
        child: const GestorFilters(),
      ),
    );
  }

  void _navigateToCreate(BuildContext context) async {
    final gestoresCubit = context.read<GestoresCubit>();
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => BlocProvider.value(
          value: gestoresCubit,
          child: const GestorFormScreen(),
        ),
      ),
    );
    // Cubit recarrega sozinho no sucesso
  }

  void _navigateToEdit(BuildContext context, Gestor gestor) async {
    final gestoresCubit = context.read<GestoresCubit>();
    print('📋 [LIST] Navegando para edição do gestor ID: ${gestor.id}');
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => BlocProvider.value(
          value: gestoresCubit,
          child: GestorFormScreen(gestor: gestor),
        ),
      ),
    );
    // Cubit recarrega sozinho no sucesso
  }

  void _navigateToDetail(BuildContext context, Gestor gestor) {
    final gestoresCubit = context.read<GestoresCubit>();
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => BlocProvider.value(
          value: gestoresCubit,
          child: GestorDetailScreen(gestor: gestor),
        ),
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
