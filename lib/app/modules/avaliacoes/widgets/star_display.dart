import 'package:flutter/material.dart';

class StarDisplay extends StatelessWidget {
  final int nota;
  final double size;
  final Color color;

  const StarDisplay({
    super.key,
    required this.nota,
    this.size = 24,
    this.color = Colors.amber,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (index) {
        return Icon(
          index < nota ? Icons.star : Icons.star_border,
          color: color,
          size: size,
        );
      }),
    );
  }
}
