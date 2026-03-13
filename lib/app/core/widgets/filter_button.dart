import 'package:flutter/material.dart';
import 'filter_sheet.dart';
import '../models/filter_model.dart';
import '../../theme/app_colors.dart';

class FilterButton extends StatelessWidget {
  final FilterConfig config;
  final Function(Map<String, String>) onApply;
  final int activeCount;

  const FilterButton({
    super.key,
    required this.config,
    required this.onApply,
    required this.activeCount,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          decoration: BoxDecoration(
            color: activeCount > 0
                ? AppColors.primary.withOpacity(0.1)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(30),
            border: Border.all(
              color: activeCount > 0
                  ? AppColors.primary
                  : AppColors.divider,
            ),
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () {
                FilterSheet.show(
                  context: context,
                  config: config,
                  onApply: onApply,
                );
              },
              borderRadius: BorderRadius.circular(30),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.filter_list,
                      size: 18,
                      color: activeCount > 0
                          ? AppColors.primary
                          : AppColors.textSecondary,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      activeCount > 0 ? 'Filtros ($activeCount)' : 'Filtros',
                      style: TextStyle(
                        color: activeCount > 0
                            ? AppColors.primary
                            : AppColors.textSecondary,
                        fontWeight: activeCount > 0 ? FontWeight.w600 : FontWeight.normal,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        if (activeCount > 0)
          Positioned(
            top: -4,
            right: -4,
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.background, width: 2),
              ),
              constraints: const BoxConstraints(
                minWidth: 20,
                minHeight: 20,
              ),
              child: Center(
                child: Text(
                  '$activeCount',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
