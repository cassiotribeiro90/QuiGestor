import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'navigation_state.dart';

class NavigationCubit extends Cubit<NavigationState> {
  NavigationCubit() : super(NavigationState.initial()) {
    debugPrint('🚀 [NAVIGATION] Cubit inicializado');
  }

  void push(String location, {Object? extra}) {
    debugPrint('📤 [NAVIGATION] Push para: $location');
    emit(NavigationState.push(location, extra: extra));
  }

  void go(String location, {Object? extra}) {
    debugPrint('🚀 [NAVIGATION] Go para: $location (substituindo pilha)');
    emit(NavigationState.go(location, extra: extra));
  }

  void pop() {
    debugPrint('⬅️ [NAVIGATION] Pop');
    emit(NavigationState.pop());
  }

  // Métodos específicos
  void goToDashboard() => go('/dashboard');
  void goToPedidos() => go('/pedidos');
  void goToCardapio() => go('/cardapio');
  void goToConfiguracoes() => go('/configuracoes');
  void goToLogin() => go('/login');
  void goToSplash() => go('/splash');

  // Navegação para detalhes (push)
  void goToPedidoDetalhe(String id) => push('/pedidos/$id');
}
