import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart'; // Adicionado
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:shared_preferences/shared_preferences.dart'; // Adicionado
import 'package:quigestor/app/modules/auth/bloc/auth_cubit.dart';
import 'package:quigestor/app/modules/auth/bloc/auth_state.dart';
import 'package:quigestor/app/modules/theme/bloc/theme_cubit.dart';
import 'package:quigestor/app/modules/theme/bloc/theme_state.dart';
import 'package:quigestor/app/modules/home/bloc/home_cubit.dart';
import 'package:quigestor/app/routes/app_router.dart';
import 'package:quigestor/app/navigation/navigation_cubit.dart';
import 'package:quigestor/app/navigation/app_router_listener.dart';
import 'package:quigestor/app/di/dependencies.dart';
import 'package:quigestor/app/theme/app_theme.dart';
import 'package:quigestor/shared/api/api_client.dart';
import 'package:quigestor/app/core/services/fcm_service.dart';
import 'package:quigestor/firebase_options.dart';
import 'package:url_strategy/url_strategy.dart';

void main() async {
  setPathUrlStrategy(); // ← remove o # da URL
  WidgetsFlutterBinding.ensureInitialized();

  // 🔥 Para Web, inicializa SharedPreferences antes de tudo
  if (kIsWeb) {
    debugPrint('🌐 [WEB] Inicializando SharedPreferences...');
    await SharedPreferences.getInstance();
  }

  // 🔥 INICIALIZA FIREBASE
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  await setupDependencies();

  // 🔥 INICIALIZA FCM (Sem bloquear a inicialização do app)
  try {
    final fcmService = getIt<FcmService>();
    fcmService.init();
  } catch (e) {
    debugPrint('⚠️ [FCM] Erro ao inicializar FCM: $e');
  }

  final apiClient = ApiClient();
  final authCubit = getIt<AuthCubit>();

  runApp(QuiGestorApp(apiClient: apiClient, authCubit: authCubit));
}

class QuiGestorApp extends StatelessWidget {
  final ApiClient apiClient;
  final AuthCubit? authCubit;

  const QuiGestorApp({
    super.key,
    required this.apiClient,
    this.authCubit,
  });

  @override
  Widget build(BuildContext context) {
    final resolvedAuthCubit = authCubit ?? getIt<AuthCubit>();
    return RepositoryProvider.value(
      value: apiClient,
      child: MultiBlocProvider(
        providers: [
          BlocProvider<ThemeCubit>(create: (_) => ThemeCubit()),
          BlocProvider<AuthCubit>.value(value: resolvedAuthCubit),
          BlocProvider<NavigationCubit>(create: (_) => NavigationCubit()),
          BlocProvider<HomeCubit>(create: (_) => HomeCubit()),
        ],
        child: BlocBuilder<ThemeCubit, ThemeState>(
          builder: (context, themeState) {
            return MaterialApp.router(

              debugShowCheckedModeBanner: false,
              theme: AppTheme.lightTheme,
              darkTheme: AppTheme.darkTheme,
              themeMode: themeState.themeMode,
              routerConfig: appRouter,
              scrollBehavior: const MaterialScrollBehavior().copyWith(
                dragDevices: {
                  PointerDeviceKind.mouse,
                  PointerDeviceKind.touch,
                  PointerDeviceKind.stylus,
                  PointerDeviceKind.unknown,
                },
              ),
              builder: (context, child) {
                return BlocListener<AuthCubit, AuthState>(
                  listener: (context, state) {
                    debugPrint('🔐 [AUTH_LISTENER] Estado recebido: $state');
                    if (state is AuthAuthenticated) {
                      debugPrint('✅ [AUTH_LISTENER] Autenticado');
                      try {
                        final router = GoRouter.of(context);
                        final currentLocation = router.routerDelegate.currentConfiguration.uri.path;
                        final protected = ['/dashboard', '/pedidos', '/cardapio', '/configuracoes'];
                        if (!protected.contains(currentLocation) && currentLocation != '/') {
                          context.read<NavigationCubit>().go('/dashboard');
                        }
                      } catch (_) {
                        context.read<NavigationCubit>().go('/dashboard');
                      }
                    } else if (state is AuthUnauthenticated) {
                      debugPrint('❌ [AUTH_LISTENER] Não autenticado - redirecionando para login');
                      try {
                        final router = GoRouter.of(context);
                        final currentLocation = router.routerDelegate.currentConfiguration.uri.path;
                        if (currentLocation != '/login' && currentLocation != '/splash') {
                          context.read<NavigationCubit>().go('/login');
                        }
                      } catch (e) {
                        debugPrint('⚠️ [AUTH_LISTENER] Erro ao redirecionar: $e');
                        context.read<NavigationCubit>().go('/login');
                      }
                    }
                  },
                  child: AppRouterListener(
                    child: child ?? const SizedBox.shrink(),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
