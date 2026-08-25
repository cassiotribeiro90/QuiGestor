import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../modules/auth/bloc/auth_cubit.dart';
import '../widgets/splash_screen.dart';

class AppInitializer extends StatefulWidget {
  final Widget child;
  const AppInitializer({super.key, required this.child});

  @override
  State<AppInitializer> createState() => _AppInitializerState();
}

class _AppInitializerState extends State<AppInitializer> {
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    debugPrint('🚀 [INIT] Inicializando...');
    _initialize();
  }

  Future<void> _initialize() async {
    try {
      await Future.delayed(const Duration(milliseconds: 100));
      debugPrint('✅ [INIT] Verificando autenticação...');
      if (mounted) {
        await context.read<AuthCubit>().checkAuthStatus();
      }
      setState(() => _isInitialized = true);
    } catch (e) {
      debugPrint('❌ [INIT] Erro: $e');
      setState(() => _isInitialized = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_isInitialized) return const SplashScreen();
    return widget.child;
  }
}
