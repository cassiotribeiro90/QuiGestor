import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../widgets/side_menu.dart';
import '../../theme/bloc/theme_cubit.dart';
import '../../theme/bloc/theme_state.dart';
import '../../dashboard/views/DashboardScreen.dart';
import '../../gestores/views/gestor_form_screen.dart';
import '../../gestores/models/gestor.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen> {
  // 🔥 Controlador simples de navegação interna
  Widget _currentContent = const DashboardScreen();
  String _currentTitle = 'Dashboard';
  
  // Pilha de navegação para voltar
  final List<Map<String, dynamic>> _navigationStack = [];

  @override
  void initState() {
    super.initState();
    _navigationStack.add({
      'title': _currentTitle,
      'content': _currentContent,
    });
  }

  void navigateTo(Widget content, String title) {
    setState(() {
      _currentContent = content;
      _currentTitle = title;
      _navigationStack.add({
        'title': title,
        'content': content,
      });
    });
  }

  void goBack() {
    if (_navigationStack.length > 1) {
      setState(() {
        _navigationStack.removeLast();
        final last = _navigationStack.last;
        _currentContent = last['content'];
        _currentTitle = last['title'];
      });
    }
  }

  // Métodos públicos para navegação (serão chamados pelos outros screens)
  void openGestorForm({Gestor? gestor}) {
    navigateTo(
      GestorFormScreen(
        gestor: gestor,
        onSaved: () => goBack(), // Volta após salvar
      ),
      gestor == null ? 'Novo Gestor' : 'Editar Gestor',
    );
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // 🔥 MENU SEMPRE VISÍVEL PARA WEB > 600
        final bool showSidebar = constraints.maxWidth > 600;

        if (!showSidebar) {
          // 📱 VERSÃO MOBILE (com drawer)
          return Scaffold(
            appBar: AppBar(
              title: Text(_currentTitle),
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
            drawer: const SideMenu(), // Drawer para mobile
            body: _currentContent,
          );
        } else {
          // 💻 VERSÃO WEB (menu lateral sempre visível)
          return Scaffold(
            body: Row(
              children: [
                // Menu lateral fixo
                const SideMenu(
                  isCompact: false,
                ),
                
                // Área de conteúdo
                Expanded(
                  child: Scaffold(
                    appBar: AppBar(
                      title: Text(_currentTitle),
                      leading: _navigationStack.length > 1
                          ? IconButton(
                              icon: const Icon(Icons.arrow_back_rounded),
                              onPressed: goBack,
                            )
                          : null,
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
                        constraints: const BoxConstraints(maxWidth: 820),
                        child: _currentContent,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        }
      },
    );
  }
}
