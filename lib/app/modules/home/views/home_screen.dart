import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../shared/api/api_client.dart';
import '../widgets/side_menu.dart';
import '../../theme/bloc/theme_cubit.dart';
import '../../theme/bloc/theme_state.dart';
import '../../dashboard/views/DashboardScreen.dart';
import '../../gestores/views/gestor_form_screen.dart';
import '../../gestores/models/gestor.dart';
import '../../lojas/views/loja_form_screen.dart';
import '../../lojas/models/loja.dart';
import '../../lojas/bloc/lojas_cubit.dart';
import '../../gestores/bloc/gestores_cubit.dart';
import '../../categorias/bloc/categorias_cubit.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen> {
  Widget _currentContent = const DashboardScreen();
  String _currentTitle = 'Dashboard';
  
  final List<Map<String, dynamic>> _navigationStack = [
    {'title': 'Dashboard', 'content': const DashboardScreen()}
  ];

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final bool showSidebar = constraints.maxWidth > 600;

        return Scaffold(
          drawer: !showSidebar ? const SideMenu() : null,
          body: Row(
            children: [
              if (showSidebar) const SideMenu(isCompact: false),
              Expanded(
                child: Scaffold(
                  appBar: AppBar(
                    title: Text(_currentTitle),
                    leading: showSidebar && _navigationStack.length > 1
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
                  body: Align(
                    alignment: Alignment.topCenter,
                    child: ConstrainedBox(
                      // 🔥 TODAS AS TELAS CENTRALIZADAS COM maxWidth 820
                      constraints: const BoxConstraints(maxWidth: 820),
                      child: _currentContent,
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

  void goBack() {
    if (_navigationStack.length > 1) {
      setState(() {
        _navigationStack.removeLast();
        final last = _navigationStack.last;

        // Recriamos o conteúdo ao voltar para garantir o refresh dos dados
        _currentContent = _buildPageContent(last['title'], last['content']);
        _currentTitle = last['title'];
      });
    }
  }

  void navigateTo(Widget content, String title) {
    setState(() {
      _currentContent = _buildPageContent(title, content);
      _currentTitle = title;
      _navigationStack.add({'title': title, 'content': content});
    });
  }

  Widget _buildPageContent(String title, Widget content) {
    final apiClient = context.read<ApiClient>();
    
    if (title == 'Todas as Lojas') {
      return BlocProvider(
        key: ValueKey('lojas_${DateTime.now().millisecondsSinceEpoch}'),
        create: (_) => LojasCubit(apiClient)..fetchLojas(perPage: 10),
        child: content,
      );
    }
    
    if (title == 'Gestores') {
      return BlocProvider(
        key: ValueKey('gestores_${DateTime.now().millisecondsSinceEpoch}'),
        create: (_) => GestoresCubit(apiClient)..fetchGestores(perPage: 10),
        child: content,
      );
    }

    if (title == 'Categorias') {
      return BlocProvider(
        key: ValueKey('categorias_${DateTime.now().millisecondsSinceEpoch}'),
        create: (_) => CategoriasCubit(apiClient)..fetchCategorias(),
        child: content,
      );
    }
    
    return content;
  }

  void openGestorForm({Gestor? gestor}) {
    navigateTo(
      GestorFormScreen(gestor: gestor, onSaved: goBack),
      gestor == null ? 'Novo Gestor' : 'Editar Gestor',
    );
  }

  void openLojaForm({Loja? loja}) {
    navigateTo(
      LojaFormScreen(loja: loja, onSaved: goBack),
      loja == null ? 'Nova Loja' : 'Editar Loja',
    );
  }
}
