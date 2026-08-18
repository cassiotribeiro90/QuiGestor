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
import 'package:quigestor/app/modules/subcategorias/widgets/filtros_subcategorias.dart';
import 'package:quigestor/app/modules/categorias/bloc/categorias_cubit.dart';

import '../../../di/dependencies.dart';

class SubcategoriasListScreen extends StatefulWidget {
  final int? categoriaId;
  const SubcategoriasListScreen({super.key, this.categoriaId});

  @override
  State<SubcategoriasListScreen> createState() => _SubcategoriasListScreenState();
}

class _SubcategoriasListScreenState extends State<SubcategoriasListScreen> {
  int? _categoriaIdFiltro;
  String _searchQuery = '';
  int? _statusFiltro;
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _categoriaIdFiltro = widget.categoriaId;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _carregar();
        context.read<CategoriasCubit>().fetchCategorias();
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _carregar() {
    context.read<SubcategoriaCubit>().carregar(
      categoriaId: _categoriaIdFiltro,
      search: _searchQuery,
      status: _statusFiltro,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Filtros
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: [
              Expanded(
                child: FiltrosSubcategorias(
                  categoriaId: _categoriaIdFiltro,
                  searchQuery: _searchQuery,
                  statusFiltro: _statusFiltro,
                  searchController: _searchController,
                  onCategoriaChanged: (val) {
                    setState(() => _categoriaIdFiltro = val);
                    _carregar();
                  },
                  onSearchChanged: (val) {
                    setState(() => _searchQuery = val);
                    _carregar();
                  },
                  onStatusChanged: (val) {
                    setState(() => _statusFiltro = val);
                    _carregar();
                  },
                  onClearFilters: () {
                    setState(() {
                      _searchController.clear();
                      _searchQuery = '';
                      _categoriaIdFiltro = widget.categoriaId;
                      _statusFiltro = null;
                    });
                    _carregar();
                  }, categoriasCubit: context.read<CategoriasCubit>(),
                ),
              ),
              IconButton(
                icon: const Icon(AppIcons.refresh),
                onPressed: _carregar,
                tooltip: 'Atualizar',
              ),
            ],
          ),
        ),

        // Conteúdo (com Expanded para evitar overflow)
        Expanded(
          child: BlocConsumer<SubcategoriaCubit, SubcategoriaState>(
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
              if (state is SubcategoriaLoading) {
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

              if (state is SubcategoriaLoaded) {
                final subcategorias = state.subcategorias;

                if (subcategorias.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(AppIcons.category, size: 60, color: Colors.grey[400]),
                        const SizedBox(height: 12),
                        const TextH3('Nenhuma subcategoria encontrada'),
                      ],
                    ),
                  );
                }

                return RefreshIndicator(
                  onRefresh: () async => _carregar(),
                  child: GridView.builder(
                    padding: const EdgeInsets.all(12),
                    gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                      maxCrossAxisExtent: 300,
                      childAspectRatio: 1.8,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                    ),
                    itemCount: subcategorias.length,
                    itemBuilder: (context, index) {
                      final sub = subcategorias[index];
                      return QuiGestorCard(
                        onTap: () => _abrirFormSubcategoria(context, subcategoria: sub),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        child: Row(
                          children: [
                            Container(
                              width: 44,
                              height: 44,
                              decoration: BoxDecoration(
                                color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Center(
                                child: (sub.categoriaEmoji != null && sub.categoriaEmoji!.isNotEmpty)
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
    );
  }

  void _abrirFormSubcategoria(BuildContext context, {Subcategoria? subcategoria}) {
    final categoriasCubit = context.read<CategoriasCubit>(); // ✅ Obtém antes

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => MultiBlocProvider(
          providers: [
            BlocProvider(
              create: (_) => getIt<SubcategoriaCubit>(),
            ),
            BlocProvider.value(
              value: categoriasCubit, // ✅ Passa o Cubit existente
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