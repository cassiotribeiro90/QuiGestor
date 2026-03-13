import 'package:flutter/material.dart';

class CardSkeleton extends StatelessWidget {
  final double height;
  const CardSkeleton({super.key, this.height = 100});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      height: height,
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      decoration: BoxDecoration(
        color: isDark 
            ? Colors.grey[900]!.withOpacity(0.5) 
            : Colors.grey[100],
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? Colors.white10 : Colors.black.withOpacity(0.05),
        ),
      ),
      child: Center(
        child: CircularProgressIndicator(
          strokeWidth: 2,
          valueColor: AlwaysStoppedAnimation<Color>(
            isDark ? Colors.white24 : Colors.grey[300]!,
          ),
        ),
      ),
    );
  }
}

class LojaCardSkeleton extends StatelessWidget {
  const LojaCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return const CardSkeleton();
  }
}

class CategoriaCardSkeleton extends StatelessWidget {
  const CategoriaCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return const CardSkeleton(height: 80);
  }
}
