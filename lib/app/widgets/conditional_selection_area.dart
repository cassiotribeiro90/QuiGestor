import 'package:flutter/material.dart';
import '../app_config.dart';

/// Envolve o [child] com [SelectionArea] apenas se a flag [AppConfig.useSelectableText] estiver ativa.
/// Útil para testes de performance entre texto selecionável e normal.
class ConditionalSelectionArea extends StatelessWidget {
  final Widget child;

  const ConditionalSelectionArea({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    if (AppConfig.useSelectableText) {
      return SelectionArea(child: child);
    }
    return child;
  }
}
