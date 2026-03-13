import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../apparte/widgets/app_text.dart';
import '../../../../apparte/widgets/filter_option.dart';
import '../../../../apparte/widgets/filter_section_widget.dart';
import '../bloc/categorias_cubit.dart';

class CategoriaFilters extends StatefulWidget {
  const CategoriaFilters({super.key});

  @override
  State<CategoriaFilters> createState() => _CategoriaFiltersState();
}

class _CategoriaFiltersState extends State<CategoriaFilters> {
  late FilterSectionModel _statusSection;
  late FilterSectionModel _destaqueSection;

  @override
  void initState() {
    super.initState();
    final cubit = context.read<CategoriasCubit>();
    final filterOptions = cubit.filterOptions ?? {};

    // STATUS (Ativo/Inativo)
    _statusSection = FilterSectionModel(
      id: 'ativo',
      title: 'STATUS',
      isRadio: true, // Única escolha para simplificar
      options: [
        FilterOptionModel(
          value: '1',
          label: 'Ativo',
          emoji: '✅',
          selected: cubit.currentAtivo == true,
        ),
        FilterOptionModel(
          value: '0',
          label: 'Inativo',
          emoji: '❌',
          selected: cubit.currentAtivo == false,
        ),
      ],
    );

    // DESTAQUE
    _destaqueSection = FilterSectionModel(
      id: 'destaque',
      title: 'DESTAQUE',
      isRadio: true,
      options: [
        FilterOptionModel(
          value: '1',
          label: 'Sim',
          emoji: '⭐',
          selected: cubit.currentDestaque == true,
        ),
        FilterOptionModel(
          value: '0',
          label: 'Não',
          emoji: '⚪',
          selected: cubit.currentDestaque == false,
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
              const TextH2('Filtrar Categorias'),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.pop(context),
              ),
            ],
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
                child: TextButton(
                  onPressed: () {
                    context.read<CategoriasCubit>().clearFilters();
                    Navigator.pop(context);
                  },
                  child: const Text('limpar'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    final statusVal = _statusSection.getSelectedValues().firstOrNull;
                    final destaqueVal = _destaqueSection.getSelectedValues().firstOrNull;
                    
                    context.read<CategoriasCubit>().applyFilters(
                      ativo: statusVal == '1' ? true : (statusVal == '0' ? false : null),
                      destaque: destaqueVal == '1' ? true : (destaqueVal == '0' ? false : null),
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
