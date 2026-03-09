import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class QuiGestorLogo extends StatelessWidget {
  final double size;
  final Color? color;
  
  const QuiGestorLogo({
    super.key,
    this.size = 40,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return SvgPicture.asset(
      'assets/svgs/quigestor.svg',
      width: size,
      height: size,
      colorFilter: color != null 
          ? ColorFilter.mode(color!, BlendMode.srcIn) 
          : null,
    );
  }
}
