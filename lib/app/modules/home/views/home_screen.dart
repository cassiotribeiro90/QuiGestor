import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/home_cubit.dart';
import '../widgets/home_drawer.dart';
import '../../auth/bloc/auth_cubit.dart';
import '../../theme/bloc/theme_cubit.dart';
import '../../theme/bloc/theme_state.dart';
import '../../dashboard/views/DashboardScreen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    // Inicia com Dashboard
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<HomeCubit>().navigateTo(
            0,
            'Dashboard',
            const DashboardScreen(),
          );
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HomeCubit, HomeState>(
      builder: (context, state) {
        String title = 'QuiGestor';
        Widget content = const DashboardScreen();

        if (state is HomePageChanged) {
          title = state.pageTitle;
          content = state.pageContent;
        }

        return Scaffold(
          appBar: AppBar(
            title: Text(title),
            actions: [
              BlocBuilder<ThemeCubit, ThemeState>(
                builder: (context, themeState) {
                  return IconButton(
                    icon: Icon(
                      themeState.themeMode == ThemeMode.dark
                          ? Icons.light_mode_outlined
                          : Icons.dark_mode_outlined,
                    ),
                    onPressed: () => context.read<ThemeCubit>().toggleTheme(),
                  );
                },
              ),
              IconButton(
                icon: const Icon(Icons.refresh_rounded),
                onPressed: () {
                  // A lógica específica pode ser disparada aqui se necessário
                  // ou dentro de cada Widget de conteúdo
                },
              ),
            ],
          ),
          drawer: const HomeDrawer(),
          body: content,
        );
      },
    );
  }
}
