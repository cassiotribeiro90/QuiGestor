import 'package:flutter/material.dart';

class ModuleNavigator extends StatefulWidget {
  final Widget initialScreen;
  final String moduleName;

  const ModuleNavigator({
    super.key,
    required this.initialScreen,
    required this.moduleName,
  });

  @override
  State<ModuleNavigator> createState() => ModuleNavigatorState();
}

class ModuleNavigatorState extends State<ModuleNavigator> {
  final GlobalKey<NavigatorState> _navigatorKey = GlobalKey<NavigatorState>();

  /// Limpa o stack de navegação do módulo (volta para a tela inicial)
  void reset() {
    _navigatorKey.currentState?.popUntil((route) => route.isFirst);
  }

  /// Pushes a new route into this module's navigator
  Future<T?> push<T>(Route<T> route) {
    return _navigatorKey.currentState!.push(route);
  }

  /// Pops the current route from this module's navigator
  void pop<T>([T? result]) {
    _navigatorKey.currentState!.pop(result);
  }

  @override
  Widget build(BuildContext context) {
    return Navigator(
      key: _navigatorKey,
      onGenerateRoute: (settings) {
        return MaterialPageRoute(
          builder: (context) => widget.initialScreen,
          settings: settings,
        );
      },
    );
  }
}
