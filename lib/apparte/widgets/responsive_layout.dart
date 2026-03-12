import 'package:flutter/material.dart';

class ResponsiveLayout extends StatelessWidget {
  final Widget mobileLayout;
  final Widget webLayout;
  final double breakpoint; // Largura mínima para considerar web

  const ResponsiveLayout({
    super.key,
    required this.mobileLayout,
    required this.webLayout,
    this.breakpoint = 800, // Valor padrão: abaixo disso é mobile
  });

  static bool isMobile(BuildContext context) =>
      MediaQuery.of(context).size.width < 800;

  static bool isWeb(BuildContext context) =>
      MediaQuery.of(context).size.width >= 800;

  @override
  Widget build(BuildContext context) {
    print('📱 [ResponsiveLayout] Build - Width: ${MediaQuery.of(context).size.width}');
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < breakpoint) {
          return mobileLayout;
        } else {
          return webLayout;
        }
      },
    );
  }
}

// Extensão para facilitar o uso
extension ResponsiveExtension on BuildContext {
  bool get isMobile => MediaQuery.of(this).size.width < 800;
  bool get isWeb => MediaQuery.of(this).size.width >= 800;
}
