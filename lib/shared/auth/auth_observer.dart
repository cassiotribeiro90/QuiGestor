import 'package:flutter/material.dart';

class AuthObserver extends NavigatorObserver {
  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPush(route, previousRoute);
    // Lógica para verificar expiração de token ou permissões ao navegar
  }
}
