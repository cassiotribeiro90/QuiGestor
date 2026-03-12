import 'package:flutter/material.dart';

class FilterOptionChip extends StatelessWidget {
  final String label;
  final String? emoji;
  final IconData? icon;
  final int? count;
  final bool isSelected;
  final bool isRadio; // ← para estilo diferente se quiser
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
    
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected 
              ? (isRadio 
                  ? theme.colorScheme.primary 
                  : theme.colorScheme.primary.withOpacity(0.1))
              : Colors.grey[100],
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected 
                ? theme.colorScheme.primary 
                : Colors.transparent,
            width: isRadio ? 1 : 0,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (emoji != null) ...[
              Text(emoji!, style: const TextStyle(fontSize: 16)),
              const SizedBox(width: 4),
            ],
            if (icon != null) ...[
              Icon(icon, size: 16, color: isSelected && isRadio ? Colors.white : (isSelected ? theme.colorScheme.primary : Colors.grey[600])),
              const SizedBox(width: 4),
            ],
            Text(
              label,
              style: TextStyle(
                color: isSelected && isRadio 
                    ? Colors.white 
                    : (isSelected ? theme.colorScheme.primary : Colors.black87),
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
            if (count != null && count! > 0) ...[
              const SizedBox(width: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: isSelected && isRadio 
                      ? Colors.white.withOpacity(0.2)
                      : Colors.grey[300],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '$count',
                  style: TextStyle(
                    fontSize: 10,
                    color: isSelected && isRadio ? Colors.white : Colors.grey[700],
                  ),
                ),
              ),
            ],
            if (isSelected && !isRadio)
              Padding(
                padding: const EdgeInsets.only(left: 4),
                child: Icon(
                  Icons.check,
                  size: 14,
                  color: theme.colorScheme.primary,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
