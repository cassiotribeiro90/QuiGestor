import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/home_cubit.dart';
import '../widgets/side_menu.dart';
import '../widgets/home_drawer.dart';
import '../../theme/bloc/theme_cubit.dart';
import '../../theme/bloc/theme_state.dart';
import '../../dashboard/views/DashboardScreen.dart';
import '../../../../core/widgets/responsive_layout.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    print('🏠 [HomeScreen] Inicializando...');
    WidgetsBinding.instance.addPostFrameCallback((_) {
      print('🏠 [HomeScreen] Navegação inicial para Dashboard');
      context.read<HomeCubit>().navigateTo(0, 'Dashboard', const DashboardScreen());
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

        // 🔥 USA O RESPONSIVE LAYOUT PARA DECIDIR BASEADO NO BREAKPOINT
        return ResponsiveLayout(
          // Layout Mobile: AppBar + drawer
          mobileLayout: Scaffold(
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
              ],
            ),
            drawer: const HomeDrawer(),
            body: content,
          ),
          
          // Layout Web: Sidebar permanente + conteúdo centralizado com maxWidth
          webLayout: Scaffold(
            body: Row(
              children: [
                // Sidebar fixa
                const SideMenu(isCompact: false),
                
                // Área de conteúdo centralizada com largura máxima
                Expanded(
                  child: Container(
                    color: Theme.of(context).scaffoldBackgroundColor,
                    child: Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 1000), // Largura máxima 1000px
                        child: content,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
