import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'injection.dart';
import 'features/auth/bloc/auth_cubit.dart';
import 'features/auth/views/splash_screen.dart';
import 'features/auth/views/login_screen.dart';
import 'features/home/views/home_screen.dart';

class QuiGestorApp extends StatelessWidget {
  const QuiGestorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthCubit>(create: (_) => getIt<AuthCubit>()),
      ],
      child: MaterialApp(
        title: 'QuiGestor',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
          useMaterial3: true,
        ),
        home: const SplashScreen(),
        routes: {
          '/login': (context) => const LoginScreen(),
          '/home': (context) => const HomeScreen(),
        },
      ),
    );
  }
}
