import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../shared/api/api_client.dart';
import '../../../core/widgets/module_navigator.dart';
import '../../../di/dependencies.dart';
import '../../dashboard/bloc/dashboard_cubit.dart';
import '../widgets/side_menu.dart';
import '../../theme/bloc/theme_cubit.dart';
import '../../theme/bloc/theme_state.dart';
import '../bloc/home_cubit.dart';
import '../../dashboard/views/DashboardScreen.dart';
import '../../gestores/views/gestores_list_screen.dart';
import '../../gestores/views/gestor_form_screen.dart';
import '../../gestores/models/gestor.dart';
import '../../lojas/views/lojas_list_screen.dart';
import '../../lojas/views/loja_form_screen.dart';
import '../../lojas/models/loja.dart';
import '../../lojas/bloc/lojas_cubit.dart';
import '../../gestores/bloc/gestores_cubit.dart';
import '../../categorias/bloc/categorias_cubit.dart';
import '../../categorias/views/categorias_list_screen.dart';
import '../../produtos/views/produtos_list_screen.dart';
import '../../produtos/bloc/produtos_cubit.dart';
import '../../lojistas/views/lojistas_list_page.dart';
import '../../lojistas/views/lojista_form_page.dart';
import '../../lojistas/bloc/lojistas_cubit.dart';
import '../../lojistas/bloc/lojista_form_cubit.dart';
import '../../subcategorias/views/subcategorias_list_screen.dart';
import '../../subcategorias/bloc/subcategoria_cubit.dart';

class HomeScreen extends StatefulWidget {
  static final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen> {
  late final List<GlobalKey<ModuleNavigatorState>> _navKeys;
  final Map<int, ModuleNavigator> _moduleCache = {};

  @override
  void initState() {
    super.initState();
    _navKeys = List.generate(9, (_) => GlobalKey<ModuleNavigatorState>());

    // Configurar callbacks de reset no Cubit
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final callbacks = _navKeys.map((key) {
        return () {
          key.currentState?.reset();
        };
      }).cast<VoidCallback>().toList();
      context.read<HomeCubit>().setResetCallbacks(callbacks);
    });
  }

  /// Cria o ModuleNavigator sob demanda, apenas quando o menu é acessado
  ModuleNavigator _createModuleNavigator(int index) {
    final apiClient = context.read<ApiClient>();

    switch (index) {
      case 0:
        return ModuleNavigator(
          key: _navKeys[0],
          moduleName: 'Dashboard',
          initialScreen: BlocProvider(
            create: (_) => DashboardCubit(apiClient),
            child: const DashboardScreen(),
          ),
        );
      case 1:
        return ModuleNavigator(
          key: _navKeys[1],
          moduleName: 'Gestores',
          initialScreen: BlocProvider(
            create: (_) => GestoresCubit(apiClient)..fetchGestores(perPage: 10),
            child: const GestoresListScreen(),
          ),
        );
      case 2:
        return ModuleNavigator(
          key: _navKeys[2],
          moduleName: 'Lojistas',
          initialScreen: BlocProvider(
            create: (_) => getIt<LojistasCubit>(),
            child: const LojistasListPage(),
          ),
        );
      case 3:
        return ModuleNavigator(
          key: _navKeys[3],
          moduleName: 'Clientes',
          initialScreen: const Center(child: Text('Clientes Screen')),
        );
      case 4:
        return ModuleNavigator(
          key: _navKeys[4],
          moduleName: 'Lojas',
          initialScreen: BlocProvider(
            create: (_) => LojasCubit(apiClient)..fetchLojas(perPage: 10),
            child: const LojasListScreen(),
          ),
        );
      case 5:
        return ModuleNavigator(
          key: _navKeys[5],
          moduleName: 'Categorias',
          initialScreen: BlocProvider(
            create: (_) => CategoriasCubit(apiClient)..fetchCategorias(),
            child: const CategoriasListScreen(),
          ),
        );
      case 6:
        return ModuleNavigator(
          key: _navKeys[6],
          moduleName: 'Pedidos',
          initialScreen: const Center(child: Text('Pedidos Screen')),
        );
      case 7:
        return ModuleNavigator(
          key: _navKeys[7],
          moduleName: 'Configurações',
          initialScreen: const Center(child: Text('Configurações Screen')),
        );
      case 8:
        return ModuleNavigator(
          key: _navKeys[8],
          moduleName: 'Subcategorias',
          initialScreen: BlocProvider(
            create: (_) => getIt<SubcategoriaCubit>(),
            child: const SubcategoriasListScreen(),
          ),
        );
      default:
        throw Exception('Módulo inválido: $index');
    }
  }

  /// Recria o módulo do zero (para refresh ao trocar de menu)
  ModuleNavigator _refreshModuleNavigator(int index) {
    // Remove do cache para forçar recriação
    _moduleCache.remove(index);
    // Cria um novo GlobalKey para o módulo
    _navKeys[index] = GlobalKey<ModuleNavigatorState>();
    return _getModuleNavigator(index);
  }

  /// Retorna o ModuleNavigator do cache ou cria um novo
  ModuleNavigator _getModuleNavigator(int index) {
    return _moduleCache.putIfAbsent(index, () => _createModuleNavigator(index));
  }

  /// Método genérico para empilhar uma tela no módulo atual
  void navigateTo(Widget content) {
    final state = context.read<HomeCubit>().state;
    if (state is HomeModuleChanged) {
      _navKeys[state.moduleIndex].currentState?.push(
        MaterialPageRoute(builder: (_) => content),
      );
    } else {
      _navKeys[0].currentState?.push(
        MaterialPageRoute(builder: (_) => content),
      );
    }
  }

  /// Abre o formulário de gestor dentro do módulo de Gestores (índice 1)
  void openGestorForm({Gestor? gestor}) {
    _navKeys[1].currentState?.push(
      MaterialPageRoute(
        builder: (context) => BlocProvider.value(
          value: context.read<GestoresCubit>(),
          child: GestorFormScreen(gestor: gestor),
        ),
      ),
    );
  }

  /// Abre o formulário de lojista dentro do módulo de Lojistas (índice 2)
  void openLojistaForm({int? id}) {
    _navKeys[2].currentState?.push(
      MaterialPageRoute(
        builder: (context) => BlocProvider(
          create: (_) => getIt<LojistaFormCubit>(),
          child: LojistaFormPage(id: id),
        ),
      ),
    );
  }

  /// Abre o formulário de loja dentro do módulo de Lojas (índice 4)
  void openLojaForm({Loja? loja}) {
    _navKeys[4].currentState?.push(
      MaterialPageRoute(
        builder: (context) => BlocProvider.value(
          value: context.read<LojasCubit>(),
          child: LojaFormScreen(loja: loja),
        ),
      ),
    );
  }

  /// Abre a lista de produtos de uma loja dentro do módulo de Lojas (índice 4)
  void openProdutosList({required int lojaId, required String lojaNome}) {
    _navKeys[4].currentState?.push(
      MaterialPageRoute(
        builder: (context) => BlocProvider(
          create: (_) => ProdutosCubit(context.read<ApiClient>(), lojaId),
          child: ProdutosListScreen(lojaId: lojaId, lojaNome: lojaNome),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HomeCubit, HomeState>(
      builder: (context, state) {
        int currentIndex = 0;
        String currentTitle = 'Dashboard';

        if (state is HomeModuleChanged) {
          currentIndex = state.moduleIndex;
          currentTitle = state.moduleTitle;
        }

        return LayoutBuilder(
          builder: (context, constraints) {
            final bool showSidebar = constraints.maxWidth > 600;

            return Scaffold(
              key: HomeScreen.scaffoldKey,
              drawer: !showSidebar ? const SideMenu() : null,
              body: Row(
                children: [
                  if (showSidebar) const SideMenu(isCompact: false),
                  Expanded(
                    child: Scaffold(
                      appBar: AppBar(
                        leading: LayoutBuilder(
                          builder: (context, constraints) {
                            final bool showSidebar = MediaQuery.of(context).size.width > 600;
                            if (!showSidebar) {
                              return IconButton(
                                icon: const Icon(Icons.menu),
                                onPressed: () => HomeScreen.scaffoldKey.currentState?.openDrawer(),
                              );
                            }
                            return const SizedBox.shrink();
                          },
                        ),
                        title: Text(currentTitle),
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
                          constraints: const BoxConstraints(maxWidth: 820),
                          // Usa o módulo atual SEM IndexedStack para forçar recriação
                          child: _getModuleNavigator(currentIndex),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}