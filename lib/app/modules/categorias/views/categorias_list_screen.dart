import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../apparte/widgets/app_text.dart';
import '../../../../apparte/widgets/loading_skeleton.dart';
import '../../../models/filter_option.dart';
import '../../../widgets/generic_filter_widget.dart';
import '../bloc/categorias_cubit.dart';
import '../bloc/categorias_state.dart';
import '../models/categoria.dart';
import '../widgets/categoria_card.dart';
import 'categoria_form_screen.dart';
import '../../../core/constants/icon_constants.dart';

class CategoriasListScreen extends StatefulWidget {
  const CategoriasListScreen({super.key});

  @override
  State<CategoriasListScreen> createState() => _CategoriasListScreenState();
}

class _CategoriasListScreenState extends State<CategoriasListScreen> {
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
  Widget build(BuildContext context) {
    final categoriasCubit = context.read<CategoriasCubit>();

    return Scaffold(
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
          final filterOptions = categoriasCubit.filterOptions;
          final pagination = state is CategoriasLoaded ? state.pagination : null;

          return SelectionArea(
            child: RefreshIndicator(
              onRefresh: () => categoriasCubit.fetchCategorias(),
              child: CustomScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              slivers: [
                if (filterOptions != null)
                  SliverToBoxAdapter(
                    child: GenericFilterWidget(
                      groups: (filterOptions).entries
                          .map((entry) => FilterGroup.fromJson(entry.key, entry.value))
                          .whereType<FilterGroup>()
                          .toList(),
                      onApply: (params) => categoriasCubit.fetchCategorias(filters: params),
                      totalItems: pagination?['total'] ?? 0,
                    ),
                  ),
                _buildListContentSliver(state),
              ],
            ),
          ));
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _abrirFormCategoria(context),
        label: const TextInverse('Nova Categoria', fontWeight: FontWeight.bold),
        icon: const Icon(AppIcons.add),
      ),
    );
  }

  Widget _buildListContentSliver(CategoriasState state) {
    if (state is CategoriasLoading) {
      return SliverPadding(
        padding: const EdgeInsets.all(12),
        sliver: SliverGrid(
          gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
            maxCrossAxisExtent: 300,
            childAspectRatio: 1.8,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
          ),
          delegate: SliverChildBuilderDelegate(
            (_, __) => const CardSkeleton(),
            childCount: 6,
          ),
        ),
      );
    }

    if (state is CategoriasLoaded) {
      final categorias = state.categoriasFiltradas;

      if (categorias.isEmpty) {
        return SliverFillRemaining(
          hasScrollBody: false,
          child: Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 40),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(AppIcons.category, size: 60, color: Colors.grey[400]),
                  const SizedBox(height: 12),
                  const TextH3('Nenhuma categoria encontrada'),
                ],
              ),
            ),
          ),
        );
      }

      return SliverPadding(
        padding: const EdgeInsets.all(12),
        sliver: SliverGrid(
          gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
            maxCrossAxisExtent: 300,
            childAspectRatio: 1.8,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
          ),
          delegate: SliverChildBuilderDelegate(
            (context, index) {
              final categoria = categorias[index];
              return RepaintBoundary(
                child: CategoriaCard(
                  categoria: categoria,
                  onTap: () => _abrirFormCategoria(context, categoria: categoria),
                ),
              );
            },
            childCount: categorias.length,
          ),
        ),
      );
    }

    return const SliverToBoxAdapter(child: SizedBox());
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
