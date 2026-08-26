import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../constants/icon_constants.dart';

mixin BackButtonMixin {
  Widget buildBackButton(BuildContext context, {VoidCallback? onPressed}) {
    return IconButton(
      icon: const Icon(AppIcons.arrowBack),
      onPressed: onPressed ?? () {
        if (context.canPop()) {
          context.pop();
        } else {
          // Fallback: volta para a rota principal (lista) removendo o último segmento
          final String currentRoute = GoRouterState.of(context).uri.path;
          final segments = currentRoute.split('/');
          
          if (segments.length > 1) {
            // Remove o último segmento
            final parentRoute = segments.sublist(0, segments.length - 1).join('/');
            context.go(parentRoute.isNotEmpty ? parentRoute : '/');
          } else {
            context.go('/');
          }
        }
      },
    );
  }
}
