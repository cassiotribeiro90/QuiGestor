import 'package:flutter/material.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import '../models/filter_model.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';

class FilterSheet extends StatefulWidget {
  final FilterConfig config;
  final Function(Map<String, String>) onApply;
  final VoidCallback? onClear;

  const FilterSheet({
    super.key,
    required this.config,
    required this.onApply,
    this.onClear,
  });

  @override
  State<FilterSheet> createState() => _FilterSheetState();

  static Future<void> show({
    required BuildContext context,
    required FilterConfig config,
    required Function(Map<String, String>) onApply,
    VoidCallback? onClear,
  }) {
    return showMaterialModalBottomSheet(
      context: context,
      expand: false,
      backgroundColor: Colors.transparent,
      builder: (context) => FilterSheet(
        config: config,
        onApply: onApply,
        onClear: onClear,
      ),
    );
  }
}

class _FilterSheetState extends State<FilterSheet> {
  late FilterConfig _config;

  @override
  void initState() {
    super.initState();
    _config = widget.config;
  }

  void _toggleOption(int sectionIndex, int optionIndex) {
    setState(() {
      final section = _config.sections[sectionIndex];
      final option = section.options[optionIndex];
      
      if (section.multiple) {
        option.selected = !option.selected;
      } else {
        for (var i = 0; i < section.options.length; i++) {
          section.options[i].selected = i == optionIndex;
        }
      }
    });
  }

  void _clearAll() {
    setState(() {
      _config.clearAll();
    });
    widget.onClear?.call();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final activeCount = _config.activeFilterCount;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
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
                  _config.title,
                  style: AppTextStyles.h2.copyWith(
                    color: AppColors.textPrimary,
                  ),
                ),
                Row(
                  children: [
                    if (activeCount > 0)
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
                          '$activeCount',
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

          const Divider(color: AppColors.divider, height: 1),

          // Conteúdo
          Flexible(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: _config.sections.asMap().entries.map((entry) {
                  final sectionIndex = entry.key;
                  final section = entry.value;

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Título da seção
                      Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Row(
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
                      ),

                      // Opções
                      ...section.options.asMap().entries.map((optEntry) {
                        final optionIndex = optEntry.key;
                        final option = optEntry.value;

                        return Container(
                          margin: const EdgeInsets.only(bottom: 4),
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
                                if (option.count != null)
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
                            onChanged: (_) => _toggleOption(sectionIndex, optionIndex),
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

          const Divider(color: AppColors.divider, height: 1),

          // Botões
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
                      final filters = _config.getSelectedFilters();
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
                      style: AppTextStyles.button.copyWith(color: Colors.white),
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
