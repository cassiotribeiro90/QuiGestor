import 'package:flutter/material.dart';

class FlatSection extends StatelessWidget {
  final String title;
  final String subtitle;
  final double? height;
  final Widget child;

  const FlatSection({
    super.key,
    required this.title,
    required this.subtitle,
    this.height,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : Colors.black87,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          subtitle,
          style: TextStyle(
            fontSize: 11,
            color: isDark ? Colors.grey.shade500 : Colors.grey.shade500,
          ),
        ),
        const SizedBox(height: 12),
        if (height != null)
          SizedBox(height: height, child: child)
        else
          child,
      ],
    );
  }
}