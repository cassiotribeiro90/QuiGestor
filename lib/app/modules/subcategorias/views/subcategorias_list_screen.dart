import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:quigestor/apparte/widgets/app_text.dart';
import 'package:quigestor/apparte/widgets/loading_skeleton.dart';
import 'package:quigestor/app/core/constants/icon_constants.dart';
import 'package:quigestor/app/modules/subcategorias/models/subcategoria.dart';
import 'package:quigestor/app/modules/subcategorias/bloc/subcategoria_cubit.dart';
import 'package:quigestor/app/modules/subcategorias/bloc/subcategoria_state.dart';
import 'package:quigestor/app/modules/categorias/bloc/categorias_cubit.dart';
import 'package:quigestor/app/models/filter_option.dart';
import 'package:quigestor/app/widgets/generic_filter_widget.dart';
import 'package:quigestor/app/widgets/conditional_selection_area.dart';
import 'package:quigestor/app/modules/subcategorias/widgets/subcategoria_card.dart';
import 'package:quigestor/app/routes/app_router.dart';

class SubcategoriasListScreen extends StatefulWidget {
  final int? categoriaId;

  const SubcategoriasListScreen({super.key, this.categoriaId});

  @override
  State<SubcategoriasListScreen> createState() =>
      _SubcategoriasListScreenState();
}

class _SubcategoriasListScreenState extends State<SubcategoriasListScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _carregar();
        context.read<CategoriasCubit>().fetchCategorias();
      }
    });
  }

  void _carregar({Map<String, String>? filters}) {
    context.read<SubcategoriaCubit>().carregar(filters: filters);
  }

  // 🔥 CORRIGIDO: Usando GoRouter
  void _abrirFormSubcategoria(BuildContext context, {Subcategoria? subcategoria}) {
    if (subcategoria != null) {
      context.go(Routes.subcategoriaEditar(subcategoria.id));
    } else {
      context.go(Routes.subcategoriaNovo);
    }
  }

  @override
  Widget build(BuildContext context) {
    final subcategoriaCubit = context.read<SubcategoriaCubit>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _abrirFormSubcategoria(context),
        label: TextBody1(
          'Nova Subcategoria',
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
        icon: const Icon(AppIcons.add, color: Colors.white),
      ),
      body: BlocConsumer<SubcategoriaCubit, SubcategoriaState>(
        listener: (context, state) {
          if (state is SubcategoriaError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: TextBody2(state.message, color: Colors.white),
                backgroundColor: Colors.red,
              ),
            );
          } else if (state is SubcategoriaOperationSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: TextBody2(state.message, color: Colors.white),
                backgroundColor: Colors.green,
              ),
            );
          }
        },
        builder: (context, state) {
          final filterOptions = subcategoriaCubit.filterOptions;
          final pagination =
          state is SubcategoriaLoaded ? state.pagination : null;

          return ConditionalSelectionArea(
            child: RefreshIndicator(
              onRefresh: () async => _carregar(),
              child: CustomScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                slivers: [
                  if (filterOptions != null)
                    SliverToBoxAdapter(
                      child: GenericFilterWidget(
                        groups: (filterOptions)
                            .entries
                            .map((entry) =>
                            FilterGroup.fromJson(entry.key, entry.value))
                            .whereType<FilterGroup>()
                            .toList(),
                        onApply: (params) => _carregar(filters: params),
                        totalItems: pagination?['total'] ?? 0,
                      ),
                    ),
                  if (filterOptions == null)
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        child: Row(
                          children: [
                            const Spacer(),
                            IconButton(
                              icon: const Icon(AppIcons.refresh),
                              onPressed: _carregar,
                              tooltip: 'Atualizar',
                            ),
                          ],
                        ),
                      ),
                    ),

                  // Conteúdo
                  _buildListContentSliver(state),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildListContentSliver(SubcategoriaState state) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (state is SubcategoriaLoading) {
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

    if (state is SubcategoriaLoaded) {
      final subcategorias = state.subcategorias;

      if (subcategorias.isEmpty) {
        return SliverFillRemaining(
          hasScrollBody: false,
          child: Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 40),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    AppIcons.category,
                    size: 60,
                    color: isDark ? Colors.grey[600] : Colors.grey[400],
                  ),
                  const SizedBox(height: 12),
                  TextH3(
                    'Nenhuma subcategoria encontrada',
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                  const SizedBox(height: 8),
                  TextBody2(
                    'Clique no botão + para adicionar',
                    color: isDark ? Colors.grey[400] : Colors.grey[500],
                  ),
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
              final sub = subcategorias[index];
              return RepaintBoundary(
                child: SubcategoriaCard(
                  subcategoria: sub,
                  onTap: () => _abrirFormSubcategoria(
                    context,
                    subcategoria: sub,
                  ),
                ),
              );
            },
            childCount: subcategorias.length,
          ),
        ),
      );
    }

    return const SliverToBoxAdapter(child: SizedBox.shrink());
  }
}