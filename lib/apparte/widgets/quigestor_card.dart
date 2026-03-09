import 'package:flutter/material.dart';

class QuiGestorCard extends StatelessWidget {
  final Widget child;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry? padding;
  final Color? color;
  final bool horizontalScroll;

  const QuiGestorCard({
    super.key,
    required this.child,
    this.onTap,
    this.padding,
    this.color,
    this.horizontalScroll = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          decoration: BoxDecoration(
            color: color ?? theme.cardTheme.color,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: theme.brightness == Brightness.light 
                  ? Colors.grey[200]! 
                  : Colors.grey[800]!,
            ),
          ),
          child: horizontalScroll 
            ? SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: padding ?? const EdgeInsets.all(16),
                child: child,
              )
            : Padding(
                padding: padding ?? const EdgeInsets.all(16),
                child: child,
              ),
        ),
      ),
    );
  }
}
