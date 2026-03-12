import 'package:flutter/material.dart';
import 'filter_option_tile.dart';
import '../../theme/app_text_styles.dart';

class FilterSection extends StatelessWidget {
  final String title;
  final IconData icon;
  final List<FilterOptionData> options;
  final Function(int) onOptionTap;

  const FilterSection({
    super.key,
    required this.title,
    required this.icon,
    required this.options,
    required this.onOptionTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

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
                  color: theme.colorScheme.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  icon,
                  size: 18,
                  color: theme.colorScheme.primary,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                title,
                style: AppTextStyles.body1.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),

        // Opções
        Container(
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey[300]!),
          ),
          child: Column(
            children: List.generate(options.length, (index) {
              final option = options[index];
              return FilterOptionTile(
                label: option.label,
                count: option.count,
                isSelected: option.isSelected,
                color: option.color,
                onTap: () => onOptionTap(index),
                isFirst: index == 0,
                isLast: index == options.length - 1,
              );
            }),
          ),
        ),

        const SizedBox(height: 24),
      ],
    );
  }
}

class FilterOptionData {
  final String label;
  final int? count;
  final bool isSelected;
  final Color? color;

  FilterOptionData({
    required this.label,
    this.count,
    required this.isSelected,
    this.color,
  });
}
