import 'dart:async';
import 'package:flutter/material.dart';

/// Aplica um debounce em uma função callback.
/// Útil para evitar múltiplas chamadas em eventos rápidos (ex: digitação).
class Debouncer {
  final Duration delay;
  Timer? _timer;

  Debouncer({this.delay = const Duration(milliseconds: 500)});

  void call(VoidCallback action) {
    _timer?.cancel();
    _timer = Timer(delay, action);
  }

  void dispose() {
    _timer?.cancel();
  }
}
