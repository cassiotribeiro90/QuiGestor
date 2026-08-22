import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:quigestor/app/modules/auth/bloc/auth_cubit.dart';
import 'package:quigestor/app/modules/theme/bloc/theme_cubit.dart';
import 'package:quigestor/app/modules/theme/bloc/theme_state.dart';
import 'package:quigestor/app/modules/home/bloc/home_cubit.dart';
import 'package:quigestor/app/routes/app_router.dart';
import 'package:quigestor/app/routes/app_routes.dart';
import 'package:quigestor/app/di/dependencies.dart';
import 'package:quigestor/app/theme/app_theme.dart';
import 'package:quigestor/shared/auth/auth_observer.dart';
import 'package:quigestor/shared/api/api_client.dart';
import 'package:quigestor/shared/services/token_service.dart';
import 'core/services/fcm_service.dart';
import 'firebase_options.dart'; // 🔥 Certifique-se de que este arquivo existe (gerado pelo FlutterFire)

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 🔥 INICIALIZA FIREBASE
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  await setupDependencies();
  await TokenService.initialize();

  // 🔥 INICIALIZA FCM
  await FcmService().init();

  final apiClient = ApiClient();
  runApp(QuiGestorApp(apiClient: apiClient));
}

class QuiGestorApp extends StatelessWidget {
  final ApiClient apiClient;
  const QuiGestorApp({super.key, required this.apiClient});

  @override
  Widget build(BuildContext context) {
    return RepositoryProvider.value(
      value: apiClient,
      child: MultiBlocProvider(
        providers: [
          BlocProvider<ThemeCubit>(create: (_) => ThemeCubit()),
          // ✅ SEM checkAuth() aqui! A SplashScreen chama.
          BlocProvider<AuthCubit>(create: (_) => AuthCubit(apiClient)),
          BlocProvider<HomeCubit>(create: (_) => HomeCubit()),
        ],
        child: BlocBuilder<ThemeCubit, ThemeState>(
          builder: (context, themeState) {
            return MaterialApp(
              title: 'QuiGestor',
              debugShowCheckedModeBanner: false,
              theme: AppTheme.lightTheme,
              darkTheme: AppTheme.darkTheme,
              themeMode: themeState.themeMode,
              scrollBehavior: const MaterialScrollBehavior().copyWith(
                dragDevices: {
                  PointerDeviceKind.mouse,
                  PointerDeviceKind.touch,
                  PointerDeviceKind.stylus,
                  PointerDeviceKind.unknown,
                },
              ),
              initialRoute: Routes.SPLASH,
              onGenerateRoute: AppRouter.onGenerateRoute,
              navigatorObservers: [AuthObserver()],
              navigatorKey: ApiClient.navigatorKey,
            );
          },
        ),
      ),
    );
  }
}