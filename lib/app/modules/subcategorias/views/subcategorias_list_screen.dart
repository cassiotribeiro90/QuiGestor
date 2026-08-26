import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:quigestor/apparte/widgets/app_text.dart';
import 'package:quigestor/apparte/widgets/loading_skeleton.dart';
import 'package:quigestor/apparte/widgets/quigestor_card.dart';
import 'package:quigestor/app/core/constants/icon_constants.dart';
import 'package:quigestor/app/modules/subcategorias/views/subcategoria_form_screen.dart';
import 'package:quigestor/app/modules/subcategorias/models/subcategoria.dart';
import 'package:quigestor/app/modules/subcategorias/bloc/subcategoria_cubit.dart';
import 'package:quigestor/app/modules/subcategorias/bloc/subcategoria_state.dart';
import 'package:quigestor/app/modules/categorias/bloc/categorias_cubit.dart';
import 'package:quigestor/app/models/filter_option.dart';
import 'package:quigestor/app/widgets/generic_filter_widget.dart';
import 'package:quigestor/app/widgets/conditional_selection_area.dart';

import '../../../di/dependencies.dart';

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

  @override
  Widget build(BuildContext context) {
    final subcategoriaCubit = context.read<SubcategoriaCubit>();

    return BlocConsumer<SubcategoriaCubit, SubcategoriaState>(
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
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
        ));
      },
    );
  }

  Widget _buildListContentSliver(SubcategoriaState state) {
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
                  Icon(AppIcons.category, size: 60, color: Colors.grey[400]),
                  const SizedBox(height: 12),
                  const TextH3('Nenhuma subcategoria encontrada'),
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
                  child: QuiGestorCard(
                onTap: () => _abrirFormSubcategoria(context, subcategoria: sub),
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: Theme.of(context)
                            .colorScheme
                            .primary
                            .withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Center(
                        child: (sub.categoriaEmoji != null &&
                                sub.categoriaEmoji!.isNotEmpty)
                            ? Text(
                                sub.categoriaEmoji!,
                                style: const TextStyle(fontSize: 22),
                                textAlign: TextAlign.center,
                              )
                            : Icon(
                                Icons.subdirectory_arrow_right,
                                color: Theme.of(context).colorScheme.primary,
                                size: 24,
                              ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            sub.nome,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          if (sub.categoriaNome != null)
                            Text(
                              sub.categoriaNome!,
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 12,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ));
            },
            childCount: subcategorias.length,
          ),
        ),
      );
    }

    return const SliverToBoxAdapter(child: SizedBox.shrink());
  }

  void _abrirFormSubcategoria(BuildContext context,
      {Subcategoria? subcategoria}) {
    final categoriasCubit = context.read<CategoriasCubit>();

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => MultiBlocProvider(
          providers: [
            BlocProvider(
              create: (_) => getIt<SubcategoriaCubit>(),
            ),
            BlocProvider.value(
              value: categoriasCubit,
            ),
          ],
          child: SubcategoriaFormScreen(
            subcategoria: subcategoria,
            initialCategoriaId: widget.categoriaId,
          ),
        ),
      ),
    );
  }
}
