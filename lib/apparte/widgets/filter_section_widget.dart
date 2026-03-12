import 'package:flutter/material.dart';
import 'filter_option_chip.dart';
import 'filter_option.dart';

class FilterSectionWidget extends StatelessWidget {
  final FilterSectionModel section;
  final Function(String) onOptionTap;

  const FilterSectionWidget({
    super.key,
    required this.section,
    required this.onOptionTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              section.title,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: section.isRadio ? Colors.blue : Colors.green,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                section.isRadio ? 'única' : 'múltipla',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: section.options.map((option) {
            return FilterOptionChip(
              label: option.label,
              emoji: option.emoji,
              icon: option.icon,
              count: option.count,
              isSelected: option.selected,
              isRadio: section.isRadio,
              onTap: () => onOptionTap(option.value),
            );
          }).toList(),
        ),
      ],
    );
  }
}
