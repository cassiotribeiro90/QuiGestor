import 'package:flutter/material.dart';
import 'fade_horizontal_scroll.dart';

class QuiGestorCard extends StatelessWidget {
  final Widget child;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry? padding;
  final Color? color;
  final bool horizontalScroll;
  final bool enableFade;

  const QuiGestorCard({
    super.key,
    required this.child,
    this.onTap,
    this.padding,
    this.color,
    this.horizontalScroll = false,
    this.enableFade = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cardColor = color ?? theme.cardTheme.color ?? theme.colorScheme.surface;

    Widget content;
    if (horizontalScroll && enableFade) {
      content = FadeHorizontalScroll(
        fadeColor: cardColor,
        child: Padding(
          padding: padding ?? const EdgeInsets.all(16),
          child: child,
        ),
      );
    } else if (horizontalScroll) {
      content = SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: padding ?? const EdgeInsets.all(16),
        child: child,
      );
    } else {
      content = Padding(
        padding: padding ?? const EdgeInsets.all(16),
        child: child,
      );
    }

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          decoration: BoxDecoration(
            color: cardColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: theme.brightness == Brightness.light 
                  ? Colors.grey[200]! 
                  : Colors.grey[800]!,
            ),
          ),
          child: content,
        ),
      ),
    );
  }
}
