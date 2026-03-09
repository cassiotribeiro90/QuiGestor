import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'app/di/dependencies.dart';
import 'app/modules/auth/bloc/auth_cubit.dart';
import 'app/modules/dashboard/bloc/dashboard_cubit.dart';
import 'app/modules/theme/bloc/theme_cubit.dart';
import 'app/modules/theme/bloc/theme_state.dart';
import 'app/modules/home/bloc/home_cubit.dart';
import 'app/routes/app_router.dart';
import 'app/routes/app_routes.dart';
import 'app/theme/app_theme.dart';
import 'shared/auth/auth_observer.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await setupDependencies();
  runApp(const QuiGestorApp());
}

class QuiGestorApp extends StatelessWidget {
  const QuiGestorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<ThemeCubit>(create: (_) => getIt<ThemeCubit>()),
        BlocProvider<AuthCubit>(create: (_) => getIt<AuthCubit>()),
        BlocProvider<DashboardCubit>(create: (_) => getIt<DashboardCubit>()),
        BlocProvider<HomeCubit>(create: (_) => getIt<HomeCubit>()),
      ],
      child: BlocBuilder<ThemeCubit, ThemeState>(
        builder: (context, themeState) {
          return MaterialApp(
            title: 'QuiGestor',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: themeState.themeMode,
            initialRoute: Routes.SPLASH,
            onGenerateRoute: AppRouter.onGenerateRoute,
            navigatorObservers: [AuthObserver()],
          );
        },
      ),
    );
  }
}
