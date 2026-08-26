import 'package:flutter/material.dart';
import '../../../../apparte/widgets/filter_option.dart';
import '../../../../apparte/widgets/filter_section_widget.dart';
import '../bloc/categorias_cubit.dart';

class CategoriaFilters extends StatefulWidget {
  final CategoriasCubit categoriasCubit;

  const CategoriaFilters({super.key, required this.categoriasCubit});

  @override
  State<CategoriaFilters> createState() => _CategoriaFiltersState();
}

class _CategoriaFiltersState extends State<CategoriaFilters> {
  late FilterSectionModel _statusSection;
  late FilterSectionModel _destaqueSection;

  @override
  void initState() {
    super.initState();
    _inicializarFiltros();
  }

  void _inicializarFiltros() {
    final cubit = widget.categoriasCubit;
    final active = cubit.activeFilters;

    _statusSection = FilterSectionModel(
      id: 'ativo',
      title: 'STATUS',
      isRadio: true,
      options: [
        FilterOptionModel(
          value: '1',
          label: 'Ativo',
          emoji: '✅',
          selected: active['ativo'] == '1',
        ),
        FilterOptionModel(
          value: '0',
          label: 'Inativo',
          emoji: '❌',
          selected: active['ativo'] == '0',
        ),
      ],
    );

    _destaqueSection = FilterSectionModel(
      id: 'destaque',
      title: 'DESTAQUE',
      isRadio: true,
      options: [
        FilterOptionModel(
          value: '1',
          label: 'Sim',
          emoji: '⭐',
          selected: active['destaque'] == '1',
        ),
        FilterOptionModel(
          value: '0',
          label: 'Não',
          emoji: '⚪',
          selected: active['destaque'] == '0',
        ),
      ],
    );
  }

  void _handleOptionTap(FilterSectionModel section, String value) {
    setState(() {
      section.toggleOption(value);
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 20,
        bottom: MediaQuery.of(context).padding.bottom + 20,
      ),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey.shade900 : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Filtrar Categorias',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          FilterSectionWidget(
            section: _statusSection,
            onOptionTap: (val) => _handleOptionTap(_statusSection, val),
          ),
          const SizedBox(height: 20),
          FilterSectionWidget(
            section: _destaqueSection,
            onOptionTap: (val) => _handleOptionTap(_destaqueSection, val),
          ),
          const SizedBox(height: 32),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    widget.categoriasCubit.clearFilters();
                    Navigator.pop(context);
                  },
                  child: const Text('LIMPAR'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    final filters = Map<String, String>.from(widget.categoriasCubit.activeFilters);
                    final statusVal = _statusSection.getSelectedValues().firstOrNull;
                    final destaqueVal = _destaqueSection.getSelectedValues().firstOrNull;

                    if (statusVal != null) filters['ativo'] = statusVal; else filters.remove('ativo');
                    if (destaqueVal != null) filters['destaque'] = destaqueVal; else filters.remove('destaque');

                    widget.categoriasCubit.applyFilters(filters);
                    Navigator.pop(context);
                  },
                  child: const Text('APLICAR'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
