import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:quigestor/app/modules/auth/bloc/auth_cubit.dart';
import 'package:quigestor/app/modules/dashboard/bloc/dashboard_cubit.dart';
import 'package:quigestor/app/modules/theme/bloc/theme_cubit.dart';
import 'package:quigestor/app/modules/theme/bloc/theme_state.dart';
import 'package:quigestor/app/modules/home/bloc/home_cubit.dart';
import 'package:quigestor/app/modules/gestores/bloc/gestores_cubit.dart';
import 'package:quigestor/app/modules/loja/bloc/loja_cubit.dart';
import 'package:quigestor/app/modules/lojas/bloc/lojas_cubit.dart';
import 'package:quigestor/app/modules/usuarios/usuario_state.dart';
import 'package:quigestor/app/routes/app_router.dart';
import 'package:quigestor/app/routes/app_routes.dart';
import 'package:quigestor/app/theme/app_theme.dart';
import 'package:quigestor/shared/auth/auth_observer.dart';
import 'package:quigestor/shared/api/api_client.dart';
import 'package:quigestor/shared/services/token_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await TokenService.initialize();
  final apiClient = ApiClient();
  runApp(QuiGestorApp(apiClient: apiClient));
}

class QuiGestorApp extends StatelessWidget {
  final ApiClient apiClient;
  const QuiGestorApp({super.key, required this.apiClient});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<ThemeCubit>(create: (_) => ThemeCubit()),
        BlocProvider<AuthCubit>(create: (_) => AuthCubit(apiClient)),
        BlocProvider<DashboardCubit>(create: (_) => DashboardCubit(apiClient)),
        BlocProvider<HomeCubit>(create: (_) => HomeCubit()),
        BlocProvider<GestoresCubit>(create: (_) => GestoresCubit(apiClient)),
        BlocProvider<LojaCubit>(create: (_) => LojaCubit(apiClient)),
        BlocProvider<LojasCubit>(create: (_) => LojasCubit(apiClient)),
        BlocProvider<UsuarioCubit>(create: (_) => UsuarioCubit(apiClient)),
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
    );
  }
}
