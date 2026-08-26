import 'package:flutter/material.dart';
import '../bloc/gestores_cubit.dart';
import '../../../../apparte/widgets/filter_option.dart';
import '../../../../apparte/widgets/filter_section_widget.dart';

class GestorFilters extends StatefulWidget {
  final GestoresCubit gestoresCubit; // ✅ Recebe o Cubit
  const GestorFilters({super.key, required this.gestoresCubit});

  @override
  State<GestorFilters> createState() => _GestorFiltersState();
}

class _GestorFiltersState extends State<GestorFilters> {
  late FilterSectionModel _nivelSection;
  late FilterSectionModel _statusSection;

  @override
  void initState() {
    super.initState();
    final cubit = widget.gestoresCubit; // ✅ Usa o Cubit do widget
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
          selected: (cubit.activeFilters['nivel'] ?? '').split(',').contains('admin'),
        ),
        FilterOptionModel(
          value: 'comercial',
          label: 'Comercial',
          emoji: '💼',
          count: counts['nivel']?['comercial'],
          selected: (cubit.activeFilters['nivel'] ?? '').split(',').contains('comercial'),
        ),
        FilterOptionModel(
          value: 'suporte',
          label: 'Suporte',
          emoji: '🛠️',
          count: counts['nivel']?['suporte'],
          selected: (cubit.activeFilters['nivel'] ?? '').split(',').contains('suporte'),
        ),
        FilterOptionModel(
          value: 'financeiro',
          label: 'Financeiro',
          emoji: '💰',
          count: counts['nivel']?['financeiro'],
          selected: (cubit.activeFilters['nivel'] ?? '').split(',').contains('financeiro'),
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
          selected: (cubit.activeFilters['status'] ?? '').split(',').contains('1'),
        ),
        FilterOptionModel(
          value: '0',
          label: 'Inativo',
          emoji: '❌',
          count: counts['status']?[0],
          selected: (cubit.activeFilters['status'] ?? '').split(',').contains('0'),
        ),
        FilterOptionModel(
          value: '2',
          label: 'Bloqueado',
          emoji: '🔒',
          count: counts['status']?[2],
          selected: (cubit.activeFilters['status'] ?? '').split(',').contains('2'),
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
        boxShadow: [
          BoxShadow(
            color: isDark ? Colors.black.withOpacity(0.4) : Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Handle
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: isDark ? Colors.grey.shade700 : Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 16),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Filtrar Gestores',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : Colors.black87,
                ),
              ),
              IconButton(
                icon: Icon(
                  Icons.close,
                  color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                ),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
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
                child: OutlinedButton(
                  onPressed: () {
                    widget.gestoresCubit.clearFilters(); // ✅ Usa o Cubit do widget
                    Navigator.pop(context);
                  },
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    side: BorderSide(
                      color: isDark ? Colors.grey.shade700 : Colors.grey.shade300,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    'LIMPAR',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    final filters = <String, String>{};
                    final niveis = _nivelSection.getSelectedValues();
                    if (niveis.isNotEmpty) filters['nivel'] = niveis.join(',');
                    
                    final status = _statusSection.getSelectedValues();
                    if (status.isNotEmpty) filters['status'] = status.join(',');

                    widget.gestoresCubit.applyFilters(filters);
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    backgroundColor: Theme.of(context).primaryColor,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'APLICAR',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}