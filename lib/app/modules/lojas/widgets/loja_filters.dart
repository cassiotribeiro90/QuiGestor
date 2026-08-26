import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../apparte/widgets/app_text.dart';
import '../../../../apparte/widgets/filter_option.dart';
import '../../../../apparte/widgets/filter_section_widget.dart';
import '../../../../apparte/widgets/qui_button.dart';
import '../bloc/lojas_cubit.dart';

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
        selected: (cubit.activeFilters['status'] ?? '').split(',').contains(s['value'].toString()),
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
        selected: (cubit.activeFilters['categoria'] ?? '').split(',').contains(c['value'].toString()),
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
          selected: cubit.activeFilters['destaque'] == '1',
        ),
        FilterOptionModel(
          value: 'verificado',
          label: 'Verificado',
          emoji: '✅',
          count: filterOptions['verificado'],
          selected: cubit.activeFilters['verificado'] == '1',
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
              const TextH2('Filtrar Lojas', fontWeight: FontWeight.bold),
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
                  child: const TextBody2('limpar'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: QuiButton(
                  label: 'APLICAR',
                  height: 48,
                  onPressed: () {
                    final outros = _outrosSection.getSelectedValues();
                    final filters = <String, String>{};
                    
                    final status = _statusSection.getSelectedValues();
                    if (status.isNotEmpty) filters['status'] = status.join(',');
                    
                    final categorias = _categoriaSection.getSelectedValues();
                    if (categorias.isNotEmpty) filters['categoria'] = categorias.join(',');
                    
                    if (outros.contains('destaque')) filters['destaque'] = '1';
                    if (outros.contains('verificado')) filters['verificado'] = '1';

                    context.read<LojasCubit>().applyFilters(filters);
                    Navigator.pop(context);
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
