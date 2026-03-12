import 'package:flutter/material.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import '../../app/theme/app_colors.dart';
import '../../app/theme/app_text_styles.dart';

class FilterOption {
  final String value;
  final String label;
  final int count;
  bool selected;

  FilterOption({
    required this.value,
    required this.label,
    this.count = 0,
    this.selected = false,
  });

  FilterOption copyWith({bool? selected}) {
    return FilterOption(
      value: value,
      label: label,
      count: count,
      selected: selected ?? this.selected,
    );
  }
}

class FilterSection {
  final String title;
  final IconData icon;
  final List<FilterOption> options;

  FilterSection({
    required this.title,
    required this.icon,
    required this.options,
  });
}

class FilterBottomSheet extends StatefulWidget {
  final String title;
  final List<FilterSection> sections;
  final VoidCallback? onClear;
  final Function(Map<String, List<String>>) onApply;

  const FilterBottomSheet({
    super.key,
    required this.title,
    required this.sections,
    this.onClear,
    required this.onApply,
  });

  @override
  State<FilterBottomSheet> createState() => _FilterBottomSheetState();

  static Future<void> show({
    required BuildContext context,
    required String title,
    required List<FilterSection> sections,
    VoidCallback? onClear,
    required Function(Map<String, List<String>>) onApply,
  }) {
    return showMaterialModalBottomSheet(
      context: context,
      expand: false,
      backgroundColor: Colors.transparent,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => FilterBottomSheet(
        title: title,
        sections: sections,
        onClear: onClear,
        onApply: onApply,
      ),
    );
  }
}

class _FilterBottomSheetState extends State<FilterBottomSheet> {
  late List<FilterSection> _sections;

  @override
  void initState() {
    super.initState();
    _sections = widget.sections.map((section) {
      return FilterSection(
        title: section.title,
        icon: section.icon,
        options: section.options.map((opt) => opt.copyWith()).toList(),
      );
    }).toList();
  }

  void _toggleOption(int sectionIndex, int optionIndex) {
    setState(() {
      final option = _sections[sectionIndex].options[optionIndex];
      _sections[sectionIndex].options[optionIndex] = option.copyWith(
        selected: !option.selected,
      );
    });
  }

  void _clearAll() {
    setState(() {
      for (var section in _sections) {
        for (var i = 0; i < section.options.length; i++) {
          section.options[i] = section.options[i].copyWith(selected: false);
        }
      }
    });
    widget.onClear?.call();
  }

  Map<String, List<String>> _getSelectedFilters() {
    final filters = <String, List<String>>{};
    
    for (var section in _sections) {
      final selected = section.options
          .where((opt) => opt.selected)
          .map((opt) => opt.value)
          .toList();
      
      if (selected.isNotEmpty) {
        final paramName = _getParamName(section.title);
        filters[paramName] = selected;
      }
    }
    return filters;
  }

  String _getParamName(String sectionTitle) {
    switch (sectionTitle.toUpperCase()) {
      case 'NÍVEL DE ACESSO':
        return 'nivel';
      case 'STATUS':
        return 'status';
      default:
        return sectionTitle.toLowerCase().replaceAll(' ', '_');
    }
  }

  int _getTotalSelected() {
    int total = 0;
    for (var section in _sections) {
      total += section.options.where((opt) => opt.selected).length;
    }
    return total;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final totalSelected = _getTotalSelected();

    return Container(
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.divider,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          
          // Header
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  widget.title,
                  style: AppTextStyles.h2.copyWith(
                    color: AppColors.textPrimary,
                  ),
                ),
                Row(
                  children: [
                    if (totalSelected > 0)
                      Container(
                        margin: const EdgeInsets.only(right: 8),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '$totalSelected',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                      style: IconButton.styleFrom(
                        backgroundColor: AppColors.surface,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Divider
          const Divider(color: AppColors.divider, height: 1),

          // Conteúdo (scrollable)
          Flexible(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: _sections.asMap().entries.map((entry) {
                  final sectionIndex = entry.key;
                  final section = entry.value;
                  
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Título da seção com ícone
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(
                              section.icon,
                              size: 18,
                              color: AppColors.primary,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            section.title,
                            style: AppTextStyles.body1.copyWith(
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Opções
                      ...section.options.asMap().entries.map((optEntry) {
                        final optionIndex = optEntry.key;
                        final option = optEntry.value;
                        
                        return Container(
                          margin: const EdgeInsets.only(bottom: 8),
                          decoration: BoxDecoration(
                            color: option.selected
                                ? AppColors.primary.withOpacity(0.05)
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: CheckboxListTile(
                            title: Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    option.label,
                                    style: AppTextStyles.body2.copyWith(
                                      fontWeight: option.selected
                                          ? FontWeight.w600
                                          : FontWeight.normal,
                                      color: option.selected
                                          ? AppColors.primary
                                          : AppColors.textPrimary,
                                    ),
                                  ),
                                ),
                                if (option.count > 0)
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 2,
                                    ),
                                    decoration: BoxDecoration(
                                      color: AppColors.divider,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(
                                      '${option.count}',
                                      style: AppTextStyles.caption.copyWith(
                                        color: AppColors.textSecondary,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                            value: option.selected,
                            onChanged: (selected) {
                              _toggleOption(sectionIndex, optionIndex);
                            },
                            activeColor: AppColors.primary,
                            checkColor: Colors.white,
                            controlAffinity: ListTileControlAffinity.leading,
                            dense: true,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 0,
                            ),
                            visualDensity: VisualDensity.compact,
                          ),
                        );
                      }).toList(),

                      const SizedBox(height: 24),
                    ],
                  );
                }).toList(),
              ),
            ),
          ),

          // Divider
          const Divider(color: AppColors.divider, height: 1),

          // Botões de ação
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: _clearAll,
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: const BorderSide(color: AppColors.divider),
                      ),
                    ),
                    child: Text(
                      'Limpar',
                      style: AppTextStyles.button.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      final filters = _getSelectedFilters();
                      widget.onApply(filters);
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      'Aplicar',
                      style: AppTextStyles.button.copyWith(
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
