import 'package:flutter/material.dart';
import '../modules/auth/views/login_screen.dart';
import '../modules/auth/views/splash_screen.dart';
import '../modules/home/views/home_screen.dart';
import '../modules/loja/views/criar_loja_screen.dart';
import '../modules/settings/views/settings_screen.dart';
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
      case Routes.DASHBOARD:  // NOVO
        return MaterialPageRoute(builder: (_) => const DashboardScreen());
      case Routes.USUARIOS:   // NOVO
        return MaterialPageRoute(builder: (_) => const UsuariosListScreen());
      case Routes.USUARIO_FORM:  // NOVO
        return MaterialPageRoute(
          builder: (_) => UsuarioFormScreen(
            usuario: settings.arguments as Map<String, dynamic>?,
          ),
        );
      case Routes.CRIAR_LOJA:
        return MaterialPageRoute(builder: (_) => const CriarLojaScreen());
      case Routes.SETTINGS:
        return MaterialPageRoute(builder: (_) => const SettingsScreen());
      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(child: Text('No route defined for ${settings.name}')),
          ),
        );
    }
  }
}