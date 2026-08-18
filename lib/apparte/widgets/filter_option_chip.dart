import 'package:flutter/material.dart';
import 'app_text.dart';

class FilterOptionChip extends StatelessWidget {
  final String label;
  final String? emoji;
  final IconData? icon;
  final int? count;
  final bool isSelected;
  final bool isRadio;
  final VoidCallback onTap;

  const FilterOptionChip({
    super.key,
    required this.label,
    this.emoji,
    this.icon,
    this.count,
    required this.isSelected,
    this.isRadio = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final bgColor = isSelected
        ? (isRadio
        ? theme.colorScheme.primary
        : theme.colorScheme.primary.withOpacity(isDark ? 0.3 : 0.1))
        : (isDark ? Colors.grey.shade800 : Colors.grey.shade100);

    final borderColor = isSelected
        ? theme.colorScheme.primary
        : (isDark ? Colors.grey.shade700 : Colors.transparent);

    final textColor = isSelected && isRadio
        ? Colors.white
        : (isSelected
        ? theme.colorScheme.primary
        : (isDark ? Colors.grey.shade300 : Colors.black87));

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(24),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: borderColor, width: 1.2),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (emoji != null) ...[
                _NoSelectText(emoji!), // ✅ Impede seleção
                const SizedBox(width: 6),
              ],
              if (icon != null) ...[
                Icon(icon, size: 16, color: textColor),
                const SizedBox(width: 6),
              ],
              _NoSelectText(label, color: textColor, fontWeight: isSelected ? FontWeight.bold : FontWeight.w500), // ✅
              if (count != null && count! > 0) ...[
                const SizedBox(width: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: isSelected && isRadio
                        ? Colors.white.withOpacity(0.2)
                        : (isDark ? Colors.grey.shade700 : Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: _NoSelectText(
                    '$count',
                    color: isSelected && isRadio
                        ? Colors.white
                        : (isDark ? Colors.grey.shade300 : Colors.grey.shade700),
                    fontWeight: FontWeight.bold,
                    fontSize: 11,
                  ),
                ),
              ],
              if (isSelected && !isRadio)
                Padding(
                  padding: const EdgeInsets.only(left: 6),
                  child: Icon(
                    Icons.check_circle,
                    size: 16,
                    color: theme.colorScheme.primary,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Widget que impede seleção de texto
class _NoSelectText extends StatelessWidget {
  final String text;
  final Color? color;
  final FontWeight? fontWeight;
  final double? fontSize;

  const _NoSelectText(
      this.text, {
        this.color,
        this.fontWeight,
        this.fontSize,
      });

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(
        color: color,
        fontWeight: fontWeight,
        fontSize: fontSize,
      ),
      // ✅ Impede seleção de texto
      selectionColor: Colors.transparent,
      softWrap: false,
    );
  }
}