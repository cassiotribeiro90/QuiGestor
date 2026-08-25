import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../modules/home/widgets/side_menu.dart';
import '../modules/theme/bloc/theme_cubit.dart';
import '../modules/theme/bloc/theme_state.dart';

class MainShell extends StatelessWidget {
  final Widget child;
  final GlobalKey<ScaffoldState> scaffoldKey;

  const MainShell({
    super.key,
    required this.child,
    required this.scaffoldKey,
  });

  String _getTitle(String location) {
    final titles = {
      '/dashboard': 'Dashboard',
      '/gestores': 'Gestores',
      '/lojistas': 'Lojistas',
      '/clientes': 'Clientes',
      '/lojas': 'Lojas',
      '/categorias': 'Categorias',
      '/pedidos': 'Pedidos',
      '/configuracoes': 'Configurações',
      '/subcategorias': 'Subcategorias',
    };
    return titles[location] ?? 'quiGestor';
  }

  @override
  Widget build(BuildContext context) {
    // 🔥 Obtém a URL atual
    final location = GoRouter.of(context)
        .routerDelegate
        .currentConfiguration
        .uri
        .path;
    final title = _getTitle(location);

    return LayoutBuilder(
      builder: (context, constraints) {
        // 🔥 RESPONSIVIDADE: menu fixo em telas largas, hambúrguer em telas pequenas
        final bool showSidebar = constraints.maxWidth > 600;

        return Scaffold(
          key: scaffoldKey,
          drawer: !showSidebar ? const SideMenu() : null,
          body: Row(
            children: [
              // 🔥 MENU LATERAL FIXO (em telas largas)
              if (showSidebar) const SideMenu(isCompact: false),
              Expanded(
                child: Scaffold(
                  appBar: AppBar(
                    // 🔥 BOTÃO DO MENU (só aparece em telas pequenas)
                    leading: !showSidebar
                        ? IconButton(
                      icon: const Icon(Icons.menu),
                      onPressed: () => scaffoldKey.currentState?.openDrawer(),
                    )
                        : null,
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
                  body: Center(
                    child: ConstrainedBox(
                      // 🔥 CENTRALIZA O CONTEÚDO COM LARGURA MÁXIMA (como no HomeScreen original)
                      constraints: const BoxConstraints(maxWidth: 820),
                      child: child,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}