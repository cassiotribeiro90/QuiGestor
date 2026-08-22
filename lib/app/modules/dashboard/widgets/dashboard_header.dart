import 'package:flutter/material.dart';

class DashboardHeader extends StatelessWidget {
  const DashboardHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final isMobile = MediaQuery.of(context).size.width < 600;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Visão Geral da Gestão',
              style: TextStyle(
                fontSize: isMobile ? 22 : 28,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Acompanhe o desempenho das lojas',
              style: TextStyle(
                fontSize: isMobile ? 14 : 16,
                color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
              ),
            ),
          ],
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: isDark ? Colors.blue.shade900.withOpacity(0.3) : Colors.blue.shade50,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: isDark ? Colors.blue.shade700 : Colors.blue.shade200,
            ),
          ),
          child: Row(
            children: [
              Icon(
                Icons.business_center,
                size: 16,
                color: isDark ? Colors.blue.shade300 : Colors.blue.shade600,
              ),
              const SizedBox(width: 6),
              Text(
                'Gestor',
                style: TextStyle(
                  color: isDark ? Colors.blue.shade300 : Colors.blue.shade700,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}