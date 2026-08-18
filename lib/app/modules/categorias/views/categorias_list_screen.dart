import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../apparte/widgets/app_text.dart';
import '../../../../apparte/widgets/loading_skeleton.dart';
import '../bloc/categorias_cubit.dart';
import '../bloc/categorias_state.dart';
import '../models/categoria.dart';
import '../widgets/categoria_card.dart';
import '../widgets/categoria_filters.dart';
import 'categoria_form_screen.dart';
import '../../../core/constants/icon_constants.dart';

class CategoriasListScreen extends StatefulWidget {
  const CategoriasListScreen({super.key});

  @override
  State<CategoriasListScreen> createState() => _CategoriasListScreenState();
}

class _CategoriasListScreenState extends State<CategoriasListScreen> {
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<CategoriasCubit>().fetchCategorias();
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _showFilters() {
    final categoriasCubit = context.read<CategoriasCubit>();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (bottomSheetContext) => CategoriaFilters(
        categoriasCubit: categoriasCubit, // ✅ Passa o Cubit
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const TextH2('Categorias', fontWeight: FontWeight.bold),
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
                hintText: 'Buscar categorias...',
                prefixIcon: const Icon(AppIcons.search),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(AppIcons.clear),
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
              SnackBar(content: TextBody2(state.message, color: Colors.white), backgroundColor: Colors.red),
            );
          } else if (state is CategoriaOperationSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: TextBody2(state.message, color: Colors.white), backgroundColor: Colors.green),
            );
          }
        },
        builder: (context, state) {
          if (state is CategoriasLoading) {
            return GridView.builder(
              padding: const EdgeInsets.all(12),
              gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                maxCrossAxisExtent: 300,
                childAspectRatio: 1.8,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
              ),
              itemCount: 6,
              itemBuilder: (_, __) => const CardSkeleton(),
            );
          }

          if (state is CategoriasLoaded) {
            final categorias = state.categoriasFiltradas;

            if (categorias.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(AppIcons.category, size: 60, color: Colors.grey[400]),
                    const SizedBox(height: 12),
                    const TextH3('Nenhuma categoria encontrada'),
                  ],
                ),
              );
            }

            return RefreshIndicator(
              onRefresh: () => context.read<CategoriasCubit>().fetchCategorias(),
              child: GridView.builder(
                padding: const EdgeInsets.all(12),
                gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                  maxCrossAxisExtent: 300,
                  childAspectRatio: 1.8,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                ),
                itemCount: categorias.length,
                itemBuilder: (context, index) {
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
        label: const TextInverse('Nova Categoria', fontWeight: FontWeight.bold),
        icon: const Icon(AppIcons.add),
      ),
    );
  }

  void _abrirFormCategoria(BuildContext context, {Categoria? categoria}) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => BlocProvider.value(
          value: context.read<CategoriasCubit>(),
          child: CategoriaFormScreen(categoria: categoria),
        ),
      ),
    );
  }
}
