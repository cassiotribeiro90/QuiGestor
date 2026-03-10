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
    // 🔥 AGORA É UM CONTAINER SIMPLES, SEM CARD
    Widget content = Container(
      color: color ?? Colors.transparent, // Sem cor de fundo por padrão
      child: Padding(
        padding: padding ?? const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: child,
      ),
    );

    if (horizontalScroll && enableFade) {
      content = FadeHorizontalScroll(
        fadeColor: color ?? Colors.transparent,
        child: content,
      );
    } else if (horizontalScroll) {
      content = SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: content,
      );
    }

    if (onTap != null) {
      return Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          child: content,
        ),
      );
    }

    return content;
  }
}
