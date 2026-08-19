import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/auth_cubit.dart';
import '../bloc/auth_state.dart';
import '../../../routes/app_routes.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    print('🖥️ [SPLASH] initState');
    _startApp();
  }

  Future<void> _startApp() async {
    print('🖥️ [SPLASH] Aguardando 2 segundos...');
    await Future.delayed(const Duration(seconds: 2));
    print('🖥️ [SPLASH] Chamando checkAuth()');

    if (mounted) {
      context.read<AuthCubit>().checkAuth();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: BlocConsumer<AuthCubit, AuthState>(
        listener: (context, state) {
          print('🖥️ [SPLASH] Estado recebido no listener: ${state.runtimeType}');

          if (state is AuthSuccess) {
            print('🖥️ [SPLASH] Navegando para HOME');
            Navigator.pushReplacementNamed(context, Routes.HOME);
          } else if (state is AuthUnauthenticated) {
            print('🖥️ [SPLASH] Navegando para LOGIN');
            Navigator.pushReplacementNamed(context, Routes.LOGIN);
          } else if (state is AuthError) {
            print('🖥️ [SPLASH] Navegando para LOGIN (erro: ${state.message})');
            Navigator.pushReplacementNamed(context, Routes.LOGIN);
          }
        },
        builder: (context, state) {
          print('🖥️ [SPLASH] Build com estado: ${state.runtimeType}');

          // ✅ Navegação imediata no build (fallback)
          if (state is AuthSuccess) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              Navigator.pushReplacementNamed(context, Routes.HOME);
            });
          } else if (state is AuthUnauthenticated) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              Navigator.pushReplacementNamed(context, Routes.LOGIN);
            });
          } else if (state is AuthError) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              Navigator.pushReplacementNamed(context, Routes.LOGIN);
            });
          }

          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  'assets/images/quigestor.png',
                  width: 250,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) {
                    return const Icon(
                      Icons.store_rounded,
                      size: 100,
                      color: Colors.blue,
                    );
                  },
                ),
                const SizedBox(height: 40),
                const CircularProgressIndicator(),
              ],
            ),
          );
        },
      ),
    );
  }
}