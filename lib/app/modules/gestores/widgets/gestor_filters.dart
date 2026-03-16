import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/gestores_cubit.dart';
import '../../../../apparte/widgets/app_text.dart';
import '../../../../apparte/widgets/filter_option.dart';
import '../../../../apparte/widgets/filter_section_widget.dart';
import '../../../../apparte/widgets/qui_button.dart';

class GestorFilters extends StatefulWidget {
  const GestorFilters({super.key});

  @override
  State<GestorFilters> createState() => _GestorFiltersState();
}

class _GestorFiltersState extends State<GestorFilters> {
  late FilterSectionModel _nivelSection;
  late FilterSectionModel _statusSection;

  @override
  void initState() {
    super.initState();
    final cubit = context.read<GestoresCubit>();
    final counts = cubit.getFilterCounts();

    _nivelSection = FilterSectionModel(
      id: 'nivel',
      title: 'NÍVEL',
      isRadio: false, // Múltipla escolha (Checkbox)
      options: [
        FilterOptionModel(
          value: 'admin',
          label: 'Admin',
          emoji: '👤',
          count: counts['nivel']?['admin'],
          selected: cubit.currentNiveis.contains('admin'),
        ),
        FilterOptionModel(
          value: 'comercial',
          label: 'Comercial',
          emoji: '💼',
          count: counts['nivel']?['comercial'],
          selected: cubit.currentNiveis.contains('comercial'),
        ),
        FilterOptionModel(
          value: 'suporte',
          label: 'Suporte',
          emoji: '🛠️',
          count: counts['nivel']?['suporte'],
          selected: cubit.currentNiveis.contains('suporte'),
        ),
        FilterOptionModel(
          value: 'financeiro',
          label: 'Financeiro',
          emoji: '💰',
          count: counts['nivel']?['financeiro'],
          selected: cubit.currentNiveis.contains('financeiro'),
        ),
      ],
    );

    _statusSection = FilterSectionModel(
      id: 'status',
      title: 'STATUS',
      isRadio: true, // Única escolha (Radio)
      options: [
        FilterOptionModel(
          value: '1',
          label: 'Ativo',
          emoji: '✅',
          count: counts['status']?[1],
          selected: cubit.currentStatusList.contains(1),
        ),
        FilterOptionModel(
          value: '0',
          label: 'Inativo',
          emoji: '❌',
          count: counts['status']?[0],
          selected: cubit.currentStatusList.contains(0),
        ),
        FilterOptionModel(
          value: '2',
          label: 'Bloqueado',
          emoji: '🔒',
          count: counts['status']?[2],
          selected: cubit.currentStatusList.contains(2),
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
          const TextH2('Filtrar Gestores', fontWeight: FontWeight.bold),
          const SizedBox(height: 20),
          
          FilterSectionWidget(
            section: _nivelSection,
            onOptionTap: (val) => _handleOptionTap(_nivelSection, val),
          ),
          
          const SizedBox(height: 20),
          
          FilterSectionWidget(
            section: _statusSection,
            onOptionTap: (val) => _handleOptionTap(_statusSection, val),
          ),
          
          const SizedBox(height: 32),
          
          Row(
            children: [
              Expanded(
                child: TextButton(
                  onPressed: () {
                    context.read<GestoresCubit>().clearFilters();
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
                    context.read<GestoresCubit>().applyFilters(
                      niveis: _nivelSection.getSelectedValues(),
                      status: _statusSection.getSelectedValues().map(int.parse).toList(),
                    );
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
