import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';

// Estados
abstract class HomeState extends Equatable {
  const HomeState();
  @override List<Object?> get props => [];
}

class HomeInitial extends HomeState {}

class HomeModuleChanged extends HomeState {
  final int moduleIndex;
  final String moduleTitle;

  const HomeModuleChanged({required this.moduleIndex, required this.moduleTitle});
  @override List<Object?> get props => [moduleIndex, moduleTitle];
}

// Cubit
class HomeCubit extends Cubit<HomeState> {
  HomeCubit() : super(HomeInitial());

  // Callbacks para resetar os módulos (serão setados pela HomeScreen)
  List<VoidCallback> _resetCallbacks = [];

  void setResetCallbacks(List<VoidCallback> callbacks) {
    _resetCallbacks = callbacks;
  }

  void changeModule(int index, String title) {
    // Reseta o módulo atual antes de trocar (opcional, mas garante que comece do início)
    if (_resetCallbacks.isNotEmpty && state is HomeModuleChanged) {
      final currentIndex = (state as HomeModuleChanged).moduleIndex;
      if (currentIndex != index && currentIndex < _resetCallbacks.length) {
        _resetCallbacks[currentIndex](); // limpa o stack do módulo atual
      }
    }
    emit(HomeModuleChanged(moduleIndex: index, moduleTitle: title));
  }

  // Método para resetar o módulo atual
  void resetCurrentModule() {
    if (state is HomeModuleChanged) {
      final index = (state as HomeModuleChanged).moduleIndex;
      if (index < _resetCallbacks.length) {
        _resetCallbacks[index]();
      }
    }
  }
}
