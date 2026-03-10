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
    WidgetsBinding.instance.addPostFrameCallback((_) {
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

        // 🔥 USA O RESPONSIVE LAYOUT COM A NOVA LÓGICA
        return ResponsiveLayout(
          // Layout Mobile: AppBar com drawer (tradicional)
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
            drawer: const HomeDrawer(), // Drawer tradicional
            body: content,
          ),
          
          // Layout Web: Sidebar permanente + conteúdo centralizado
          webLayout: Scaffold(
            body: Row(
              children: [
                // Sidebar fixa (NUNCA SOME NA WEB)
                const SideMenu(isCompact: false),
                
                // Área de conteúdo
                Expanded(
                  child: Column(
                    children: [
                      // AppBar simplificada (só com título e ações)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        decoration: BoxDecoration(
                          color: Theme.of(context).scaffoldBackgroundColor,
                          border: Border(
                            bottom: BorderSide(
                              color: Theme.of(context).dividerColor,
                            ),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              title,
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                            Row(
                              children: [
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
                                // 🔥 SEM BOTÃO DE MENU - SIDEBAR SEMPRE VISÍVEL
                              ],
                            ),
                          ],
                        ),
                      ),
                      
                      // Conteúdo centralizado com largura máxima
                      Expanded(
                        child: Center(
                          child: ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 1200),
                            child: content,
                          ),
                        ),
                      ),
                    ],
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
