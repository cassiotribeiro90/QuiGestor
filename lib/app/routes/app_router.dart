import 'package:flutter/material.dart';
import '../modules/auth/views/login_screen.dart';
import '../modules/auth/views/splash_screen.dart';
import '../modules/home/views/home_screen.dart';
import '../modules/debug/debug_screen.dart';
import 'app_routes.dart';

class AppRouter {
  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case Routes.SPLASH:
        return MaterialPageRoute(builder: (_) => const SplashScreen());
      case Routes.LOGIN:
        return MaterialPageRoute(builder: (_) => const LoginScreen());
      case Routes.HOME:
        return MaterialPageRoute(builder: (_) => const HomeScreen());
      case '/debug':
        return MaterialPageRoute(builder: (_) => const DebugScreen());
      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(child: Text('Rota não encontrada: ${settings.name}')),
          ),
        );
    }
  }
}
