import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:quigestor/app/core/constants/icon_constants.dart';
import 'package:quigestor/app/modules/categorias/bloc/categorias_cubit.dart';
import 'package:quigestor/app/modules/categorias/bloc/categorias_state.dart';
import 'package:quigestor/app/modules/categorias/models/categoria.dart';

class FiltrosSubcategorias extends StatelessWidget {
  final CategoriasCubit categoriasCubit; // ✅ Novo campo
  final int? categoriaId;
  final String searchQuery;
  final int? statusFiltro;
  final TextEditingController searchController;
  final ValueChanged<int?> onCategoriaChanged;
  final ValueChanged<String> onSearchChanged;
  final ValueChanged<int?> onStatusChanged;
  final VoidCallback onClearFilters;

  const FiltrosSubcategorias({
    super.key,
    required this.categoriasCubit, // ✅ Obrigatório
    required this.categoriaId,
    required this.searchQuery,
    required this.statusFiltro,
    required this.searchController,
    required this.onCategoriaChanged,
    required this.onSearchChanged,
    required this.onStatusChanged,
    required this.onClearFilters,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Dropdown de categorias (usando bloc explicitamente)
        BlocBuilder<CategoriasCubit, CategoriasState>(
          bloc: categoriasCubit, // ✅ Usa o Cubit passado
          builder: (context, state) {
            List<Categoria> cats = [];
            if (state is CategoriasLoaded) {
              cats = state.categorias;
            }
            return DropdownButtonFormField<int?>(
              initialValue: categoriaId,
              isDense: true,
              decoration: const InputDecoration(
                labelText: 'Categoria',
                border: OutlineInputBorder(),
                contentPadding:
                EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              ),
              items: [
                const DropdownMenuItem(
                  value: null,
                  child: Text('Todas', style: TextStyle(fontSize: 15)),
                ),
                ...cats.map(
                      (c) => DropdownMenuItem(
                    value: c.id,
                    child: Text(
                      c.nome,
                      style: const TextStyle(fontSize: 15),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
              ],
              onChanged: onCategoriaChanged,
            );
          },
        ),
        const SizedBox(height: 12),

        // Campo de busca (largura total)
        TextFormField(
          controller: searchController,
          decoration: const InputDecoration(
            hintText: 'Buscar...',
            prefixIcon: Icon(Icons.search, size: 24),
            border: OutlineInputBorder(),
            contentPadding:
            EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            isDense: true,
          ),
          style: const TextStyle(fontSize: 15),
          onChanged: onSearchChanged,
        ),
        const SizedBox(height: 12),

        // Dropdown de status (largura total)
        DropdownButtonFormField<int?>(
          initialValue: statusFiltro,
          isDense: true,
          decoration: const InputDecoration(
            labelText: 'Status',
            border: OutlineInputBorder(),
            contentPadding:
            EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          ),
          items: const [
            DropdownMenuItem(
              value: null,
              child: Text('Todos', style: TextStyle(fontSize: 15)),
            ),
            DropdownMenuItem(
              value: 1,
              child: Text('Ativos', style: TextStyle(fontSize: 15)),
            ),
            DropdownMenuItem(
              value: 0,
              child: Text('Inativos', style: TextStyle(fontSize: 15)),
            ),
          ],
          onChanged: onStatusChanged,
        ),

        // Botão limpar (aparece se houver filtro ativo)
        if (searchQuery.isNotEmpty ||
            categoriaId != null ||
            statusFiltro != null)
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: Align(
              alignment: Alignment.centerRight,
              child: TextButton.icon(
                onPressed: onClearFilters,
                icon: const Icon(AppIcons.clear, size: 18, color: Colors.red),
                label: const Text(
                  'Limpar Filtros',
                  style: TextStyle(color: Colors.red, fontSize: 14),
                ),
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}