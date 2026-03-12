import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';

class FilterOptionTile extends StatelessWidget {
  final String label;
  final int? count;
  final bool isSelected;
  final Color? color;
  final VoidCallback onTap;
  final bool isFirst;
  final bool isLast;

  const FilterOptionTile({
    super.key,
    required this.label,
    this.count,
    required this.isSelected,
    this.color,
    required this.onTap,
    this.isFirst = false,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final optionColor = color ?? theme.colorScheme.primary;

    return Container(
      decoration: BoxDecoration(
        color: isSelected ? optionColor.withOpacity(0.1) : Colors.transparent,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(isFirst ? 12 : 0),
          topRight: Radius.circular(isFirst ? 12 : 0),
          bottomLeft: Radius.circular(isLast ? 12 : 0),
          bottomRight: Radius.circular(isLast ? 12 : 0),
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(isFirst ? 12 : 0),
            topRight: Radius.circular(isFirst ? 12 : 0),
            bottomLeft: Radius.circular(isLast ? 12 : 0),
            bottomRight: Radius.circular(isLast ? 12 : 0),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                // Checkbox customizado
                Container(
                  width: 22,
                  height: 22,
                  decoration: BoxDecoration(
                    color: isSelected ? optionColor : Colors.transparent,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                      color: isSelected ? optionColor : Colors.grey[400]!,
                      width: 2,
                    ),
                  ),
                  child: isSelected
                      ? const Icon(
                          Icons.check,
                          size: 16,
                          color: Colors.white,
                        )
                      : null,
                ),
                
                const SizedBox(width: 12),
                
                // Label
                Expanded(
                  child: Text(
                    label,
                    style: AppTextStyles.body2.copyWith(
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                      color: isSelected ? optionColor : theme.colorScheme.onSurface,
                    ),
                  ),
                ),
                
                // Contador
                if (count != null && count! > 0)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '$count',
                      style: AppTextStyles.caption.copyWith(
                        color: Colors.grey[700],
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
