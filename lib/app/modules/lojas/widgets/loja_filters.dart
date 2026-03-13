import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/lojas_cubit.dart';
import '../../../../apparte/widgets/app_text.dart';
import '../../../../apparte/widgets/filter_option.dart';
import '../../../../apparte/widgets/filter_section_widget.dart';

class LojaFilters extends StatefulWidget {
  const LojaFilters({super.key});

  @override
  State<LojaFilters> createState() => _LojaFiltersState();
}

class _LojaFiltersState extends State<LojaFilters> {
  late FilterSectionModel _statusSection;
  late FilterSectionModel _categoriaSection;
  late FilterSectionModel _outrosSection;

  @override
  void initState() {
    super.initState();
    final cubit = context.read<LojasCubit>();
    final filterOptions = cubit.filterOptions ?? {};

    // STATUS
    final List<dynamic> statusData = filterOptions['status'] ?? [];
    _statusSection = FilterSectionModel(
      id: 'status',
      title: 'STATUS',
      isRadio: false,
      options: statusData.map((s) => FilterOptionModel(
        value: s['value'].toString(),
        label: s['label'].toString(),
        count: s['count'],
        selected: cubit.currentStatusList.contains(s['value'].toString()),
      )).toList(),
    );

    // CATEGORIAS
    final List<dynamic> categoriasData = filterOptions['categorias'] ?? [];
    _categoriaSection = FilterSectionModel(
      id: 'categorias',
      title: 'CATEGORIAS',
      isRadio: false,
      options: categoriasData.map((c) => FilterOptionModel(
        value: c['value'].toString(),
        label: c['label'].toString(),
        count: c['count'],
        selected: cubit.currentCategorias.contains(c['value'].toString()),
      )).toList(),
    );

    // OUTROS (Destaque, Verificado)
    _outrosSection = FilterSectionModel(
      id: 'outros',
      title: 'OUTROS',
      isRadio: false,
      options: [
        FilterOptionModel(
          value: 'destaque',
          label: 'Destaque',
          emoji: '⭐',
          count: filterOptions['destaque'],
          selected: cubit.currentDestaque == true,
        ),
        FilterOptionModel(
          value: 'verificado',
          label: 'Verificado',
          emoji: '✅',
          count: filterOptions['verificado'],
          selected: cubit.currentVerificado == true,
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

    return Container(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 20,
        bottom: MediaQuery.of(context).padding.bottom + 20,
      ),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const TextH2('Filtrar Lojas'),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          const SizedBox(height: 20),
          
          Flexible(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  FilterSectionWidget(
                    section: _statusSection,
                    onOptionTap: (val) => _handleOptionTap(_statusSection, val),
                  ),
                  const SizedBox(height: 20),
                  
                  FilterSectionWidget(
                    section: _categoriaSection,
                    onOptionTap: (val) => _handleOptionTap(_categoriaSection, val),
                  ),
                  const SizedBox(height: 20),

                  FilterSectionWidget(
                    section: _outrosSection,
                    onOptionTap: (val) => _handleOptionTap(_outrosSection, val),
                  ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 32),
          
          Row(
            children: [
              Expanded(
                child: TextButton(
                  onPressed: () {
                    context.read<LojasCubit>().clearFilters();
                    Navigator.pop(context);
                  },
                  child: const Text('limpar'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    final outros = _outrosSection.getSelectedValues();
                    context.read<LojasCubit>().applyFilters(
                      status: _statusSection.getSelectedValues(),
                      categorias: _categoriaSection.getSelectedValues(),
                      destaque: outros.contains('destaque') ? true : null,
                      verificado: outros.contains('verificado') ? true : null,
                    );
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.colorScheme.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
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
