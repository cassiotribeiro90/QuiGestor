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
import 'package:quigestor/app/modules/categorias/bloc/categorias_state.dart';
import 'package:quigestor/app/modules/categorias/models/categoria.dart';

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
    _carregar();
    // Carregar categorias para o filtro
    context.read<CategoriasCubit>().fetchCategorias();
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
    return Scaffold(
      appBar: AppBar(
        title: const TextH2('Subcategorias', fontWeight: FontWeight.bold),
        actions: [
          IconButton(
            icon: const Icon(AppIcons.refresh),
            onPressed: _carregar,
          ),
        ],
      ),
      body: Column(
        children: [
          _buildFilterBar(),
          Expanded(
            child: BlocConsumer<SubcategoriaCubit, SubcategoriaState>(
              listener: (context, state) {
                if (state is SubcategoriaError) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: TextBody2(state.message, color: Colors.white), backgroundColor: Colors.red),
                  );
                } else if (state is SubcategoriaOperationSuccess) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: TextBody2(state.message, color: Colors.white), backgroundColor: Colors.green),
                  );
                }
              },
              builder: (context, state) {
                if (state is SubcategoriaLoading) {
                  return GridView.builder(
                    padding: const EdgeInsets.all(12),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 3.2,
                      crossAxisSpacing: 8,
                      mainAxisSpacing: 8,
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
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        childAspectRatio: 3.2,
                        crossAxisSpacing: 8,
                        mainAxisSpacing: 8,
                      ),
                      itemCount: subcategorias.length,
                      itemBuilder: (context, index) {
                        final sub = subcategorias[index];
                        return QuiGestorCard(
                          onTap: () => _abrirFormSubcategoria(context, subcategoria: sub),
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          child: Row(
                            children: [
                              Container(
                                width: 28,
                                height: 28,
                                decoration: BoxDecoration(
                                  color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Icon(
                                  Icons.subdirectory_arrow_right,
                                  color: Theme.of(context).colorScheme.primary,
                                  size: 14,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      sub.nome,
                                      style: const TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    if (sub.categoriaNome != null)
                                      Text(
                                        sub.categoriaNome!,
                                        style: TextStyle(
                                          color: Colors.grey[600],
                                          fontSize: 8,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                  ],
                                ),
                              ),
                              IconButton(
                                icon: const Icon(AppIcons.delete, size: 14, color: Colors.red),
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(),
                                onPressed: () => _confirmarExclusao(context, sub),
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
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _abrirFormSubcategoria(context),
        label: const TextInverse('Nova', fontWeight: FontWeight.bold),
        icon: const Icon(AppIcons.add, size: 18),
      ),
    );
  }

  Widget _buildFilterBar() {
    return Container(
      height: 50,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border(bottom: BorderSide(color: Colors.grey[200]!)),
      ),
      child: Row(
        children: [
          // Dropdown de Categorias Clean
          BlocBuilder<CategoriasCubit, CategoriasState>(
            builder: (context, state) {
              List<Categoria> cats = [];
              if (state is CategoriasLoaded) cats = state.categorias;

              return DropdownButton<int?>(
                value: _categoriaIdFiltro,
                hint: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(AppIcons.category, size: 16, color: Colors.grey[600]),
                    const SizedBox(width: 4),
                    const Text('Categoria', style: TextStyle(fontSize: 13)),
                  ],
                ),
                underline: const SizedBox.shrink(),
                icon: const Icon(Icons.arrow_drop_down, size: 16),
                items: [
                  const DropdownMenuItem(value: null, child: Text('Todas', style: TextStyle(fontSize: 13))),
                  ...cats.map((c) => DropdownMenuItem(
                    value: c.id,
                    child: Text(c.nome, style: const TextStyle(fontSize: 13)),
                  )),
                ],
                onChanged: (val) {
                  setState(() => _categoriaIdFiltro = val);
                  _carregar();
                },
              );
            },
          ),
          const VerticalDivider(width: 24, indent: 15, endIndent: 15),
          
          // Campo de busca clean
          Expanded(
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Buscar...',
                hintStyle: TextStyle(color: Colors.grey[400], fontSize: 13),
                prefixIcon: Icon(Icons.search, size: 16, color: Colors.grey[600]),
                border: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.zero,
              ),
              style: const TextStyle(fontSize: 13),
              onChanged: (val) {
                _searchQuery = val;
                _carregar();
              },
            ),
          ),

          // Toggle Ativo Clean
          IconButton(
            icon: Icon(
              _statusFiltro == 1 ? Icons.visibility : Icons.visibility_off,
              color: _statusFiltro == 1 ? Colors.green : Colors.grey,
              size: 18,
            ),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
            onPressed: () {
              setState(() {
                _statusFiltro = _statusFiltro == 1 ? null : 1;
              });
              _carregar();
            },
            tooltip: 'Filtrar ativos',
          ),
        ],
      ),
    );
  }

  void _abrirFormSubcategoria(BuildContext context, {Subcategoria? subcategoria}) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => BlocProvider.value(
          value: context.read<SubcategoriaCubit>(),
          child: SubcategoriaFormScreen(subcategoria: subcategoria, initialCategoriaId: widget.categoriaId),
        ),
      ),
    );
  }

  void _confirmarExclusao(BuildContext context, Subcategoria sub) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const TextH3('Excluir Subcategoria'),
        content: TextBody2('Deseja realmente excluir a subcategoria "${sub.nome}"?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const TextBody2('Cancelar')),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              context.read<SubcategoriaCubit>().deletar(sub.id);
            },
            child: const TextBody2('Excluir', color: Colors.red),
          ),
        ],
      ),
    );
  }
}
