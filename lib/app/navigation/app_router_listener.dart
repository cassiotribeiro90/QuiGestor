import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'navigation_cubit.dart';
import 'navigation_state.dart';

class AppRouterListener extends StatelessWidget {
  final Widget child;
  const AppRouterListener({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return BlocListener<NavigationCubit, NavigationState>(
      listener: (context, state) {
        debugPrint('👂 [LISTENER] Estado: ${state.type}');
        try {
          if (state.type == NavigationType.push) {
            debugPrint('📤 [LISTENER] Push para: ${state.location}');
            context.push(state.location!, extra: state.extra);
          } else if (state.type == NavigationType.go) {
            debugPrint('🚀 [LISTENER] Go para: ${state.location}');
            context.go(state.location!, extra: state.extra);
          } else if (state.type == NavigationType.pop) {
            debugPrint('⬅️ [LISTENER] Pop');
            context.pop();
          }
        } catch (e) {
          debugPrint('⚠️ [LISTENER] GoRouter não disponível: $e');
        }
      },
      child: child,
    );
  }
}
