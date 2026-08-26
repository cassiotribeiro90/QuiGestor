import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../modules/filter/cubit/filter_cubit.dart';
import '../models/filter_option.dart';
import '../utils/debounce.dart';

class GenericFilterWidget extends StatefulWidget {
  final List<FilterGroup> groups;
  final Function(Map<String, String> params) onApply;
  final int totalItems;
  final Map<String, String>? initialFilters; // 🔥 NOVO

  const GenericFilterWidget({
    super.key,
    required this.groups,
    required this.onApply,
    this.totalItems = 0,
    this.initialFilters,
  });

  @override
  State<GenericFilterWidget> createState() => _GenericFilterWidgetState();
}

class _GenericFilterWidgetState extends State<GenericFilterWidget> {
  late final Debouncer _debouncer;
  late final TextEditingController _searchController;

  @override
  void initState() {
    super.initState();
    _debouncer = Debouncer(delay: const Duration(milliseconds: 500));
    _searchController = TextEditingController();

    // 🔥 Se houver filtro de busca inicial, preenche o controller
    if (widget.initialFilters?.containsKey('search') == true) {
      _searchController.text = widget.initialFilters!['search']!;
    }
  }

  @override
  void dispose() {
    _debouncer.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) {
        final cubit = FilterCubit();
        // 🔥 Sincroniza com os filtros iniciais (período, status, loja_id, etc)
        if (widget.initialFilters != null) {
          for (var entry in widget.initialFilters!.entries) {
            // Ignora parâmetros de paginação e busca (search já está no controller)
            if (entry.key != 'search' && entry.key != 'page' && entry.key != 'per_page') {
              cubit.selectValue(entry.key, entry.value);
            }
          }
        }
        return cubit;
      },
      child: _FilterContent(
        groups: widget.groups,
        onApply: widget.onApply,
        totalItems: widget.totalItems,
        debouncer: _debouncer,
        searchController: _searchController,
      ),
    );
  }
}

class _FilterContent extends StatelessWidget {
  final List<FilterGroup> groups;
  final Function(Map<String, String> params) onApply;
  final int totalItems;
  final Debouncer debouncer;
  final TextEditingController searchController;

  const _FilterContent({
    required this.groups,
    required this.onApply,
    required this.totalItems,
    required this.debouncer,
    required this.searchController,
  });

  @override
  Widget build(BuildContext context) {
    final cubit = context.watch<FilterCubit>();
    final state = cubit.state;

    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 🔍 Barra de busca
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: TextField(
            controller: searchController,
            onChanged: (query) {
              cubit.setSearchQuery(query);
              debouncer.call(() {
                cubit.applyFilters();
                onApply(cubit.getFilterParams());
              });
            },
            decoration: InputDecoration(
              hintText: 'Pesquisar...',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              filled: true,
              fillColor: isDark ? theme.colorScheme.surfaceContainerHighest : Colors.grey[50],
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
            ),
          ),
        ),

        // 📊 Resumo da pesquisa
        if (totalItems > 0 || cubit.hasActiveFilters)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Row(
              children: [
                Text(
                  cubit.hasActiveFilters
                      ? 'Mostrando ${totalItems > 0 ? totalItems : 0} resultados'
                      : 'Total: $totalItems itens',
                  style: theme.textTheme.bodySmall,
                ),
                const Spacer(),
                if (cubit.hasActiveFilters)
                  TextButton(
                    onPressed: () {
                      searchController.clear();
                      cubit.clearFilters();
                      onApply({});
                    },
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.zero,
                      minimumSize: const Size(0, 30),
                    ),
                    child: const Text('Limpar filtros'),
                  ),
              ],
            ),
          ),

        // 🏷️ Filtros (sempre expandidos)
        ...groups.map((group) => _FilterGroupChip(
          group: group,
          selectedRadio: state.selectedValues[group.key],
          selectedMulti: state.selectedMultiValues[group.key] ?? [],
          onSelectRadio: (value) {
            cubit.selectValue(group.key, value);
            cubit.applyFilters();
            onApply(cubit.getFilterParams());
          },
          onToggleMulti: (value) {
            cubit.toggleMultiValue(group.key, value);
            cubit.applyFilters();
            onApply(cubit.getFilterParams());
          },
        )),

        const SizedBox(height: 8),
      ],
    );
  }
}

class _FilterGroupChip extends StatelessWidget {
  final FilterGroup group;
  final String? selectedRadio;
  final List<String> selectedMulti;
  final Function(String) onSelectRadio;
  final Function(String) onToggleMulti;

  const _FilterGroupChip({
    required this.group,
    required this.selectedRadio,
    required this.selectedMulti,
    required this.onSelectRadio,
    required this.onToggleMulti,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // 🔥 IGNORA GRUPOS VAZIOS (SEM OPÇÕES)
    if (group.options.isEmpty) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Cabeçalho do grupo
          Text(
            group.label,
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 6),

          // Opções
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: group.options.map((option) {
              final isOptionSelected = group.type == FilterType.radio
                  ? selectedRadio == option.value
                  : selectedMulti.contains(option.value);

              return GestureDetector(
                onTap: () {
                  if (group.type == FilterType.radio) {
                    onSelectRadio(option.value);
                  } else {
                    onToggleMulti(option.value);
                  }
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: isOptionSelected
                        ? theme.primaryColor
                        : (isDark ? theme.colorScheme.surfaceContainerHigh : Colors.grey[100]),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isOptionSelected
                          ? theme.primaryColor
                          : (isDark ? theme.colorScheme.outlineVariant : Colors.grey[300]!),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (option.icon != null) ...[
                        Text(option.icon!),
                        const SizedBox(width: 4),
                      ],
                      Text(
                        option.count != null
                            ? '${option.label} (${option.count})'
                            : option.label,
                        style: TextStyle(
                          color: isOptionSelected
                              ? Colors.white
                              : (isDark ? Colors.white70 : Colors.black87),
                          fontSize: 13,
                          fontWeight: isOptionSelected
                              ? FontWeight.bold
                              : FontWeight.normal,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}