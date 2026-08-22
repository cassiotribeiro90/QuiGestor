import 'package:flutter/material.dart';
import '../../../../apparte/widgets/filter_option.dart';
import '../../../../apparte/widgets/filter_section_widget.dart';
import '../bloc/categorias_cubit.dart';

class CategoriaFilters extends StatefulWidget {
  final CategoriasCubit categoriasCubit; // ✅ Recebe o Cubit

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

    _statusSection = FilterSectionModel(
      id: 'ativo',
      title: 'STATUS',
      isRadio: true,
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
          // Handle (indicador visual)
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

          // Título
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Filtrar Categorias',
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

          // Seção STATUS
          _buildSectionTitle('STATUS', isDark),
          const SizedBox(height: 8),
          FilterSectionWidget(
            section: _statusSection,
            onOptionTap: (val) => _handleOptionTap(_statusSection, val),
          ),
          const SizedBox(height: 24),

          // Seção DESTAQUE
          _buildSectionTitle('DESTAQUE', isDark),
          const SizedBox(height: 8),
          FilterSectionWidget(
            section: _destaqueSection,
            onOptionTap: (val) => _handleOptionTap(_destaqueSection, val),
          ),

          const SizedBox(height: 32),

          // Botões
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    widget.categoriasCubit.clearFilters();
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
                    final statusVal = _statusSection.getSelectedValues().firstOrNull;
                    final destaqueVal = _destaqueSection.getSelectedValues().firstOrNull;

                    widget.categoriasCubit.applyFilters(
                      ativo: statusVal == '1' ? true : (statusVal == '0' ? false : null),
                      destaque: destaqueVal == '1' ? true : (destaqueVal == '0' ? false : null),
                    );
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

  Widget _buildSectionTitle(String title, bool isDark) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.bold,
        letterSpacing: 1.2,
        color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
      ),
    );
  }
}