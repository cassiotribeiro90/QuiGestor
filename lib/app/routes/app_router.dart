import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../shared/api/api_client.dart';
import '../modules/auth/views/splash_screen.dart';
import '../modules/auth/views/login_screen.dart';
import '../modules/dashboard/bloc/dashboard_cubit.dart';
import '../modules/dashboard/views/DashboardScreen.dart';
import '../modules/lojas/bloc/lojas_cubit.dart';
import '../modules/lojas/views/lojas_list_screen.dart';
import '../modules/lojistas/bloc/lojistas_cubit.dart';
import '../modules/lojistas/views/lojistas_list_page.dart';
import '../modules/gestores/bloc/gestores_cubit.dart';
import '../modules/gestores/views/gestores_list_screen.dart';
import '../modules/pedidos/bloc/pedidos_cubit.dart';
import '../modules/pedidos/views/pedido_detail_screen.dart';
import '../modules/pedidos/views/pedidos_list_screen.dart';
import '../modules/categorias/bloc/categorias_cubit.dart';
import '../modules/categorias/views/categorias_list_screen.dart';
import '../modules/settings/views/settings_screen.dart';
import '../modules/subcategorias/bloc/subcategoria_cubit.dart';
import '../modules/subcategorias/views/subcategorias_list_screen.dart';
import '../di/dependencies.dart';
import '../widgets/main_shell.dart';

// Chaves de navegação
final GlobalKey<NavigatorState> rootNavigatorKey = GlobalKey<NavigatorState>();
final GlobalKey<NavigatorState> _shellNavigatorKey = GlobalKey<NavigatorState>();
final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

final GoRouter appRouter = GoRouter(
  navigatorKey: rootNavigatorKey,
  initialLocation: '/splash',
  debugLogDiagnostics: true,
  routes: [
    // ============================================================
    // ROTAS PÚBLICAS
    // ============================================================
    GoRoute(
      path: '/splash',
      name: 'splash',
      builder: (context, state) {
        debugPrint('🔄 [ROUTER] Abrindo Splash');
        return const SplashScreen();
      },
    ),
    GoRoute(
      path: '/login',
      name: 'login',
      builder: (context, state) {
        debugPrint('🔐 [ROUTER] Abrindo Login');
        return const LoginScreen();
      },
    ),

    // ============================================================
    // ROTAS PROTEGIDAS (com ShellRoute)
    // ============================================================
    ShellRoute(
      navigatorKey: _shellNavigatorKey,
      builder: (context, state, child) {
        debugPrint('🏠 [ROUTER] Construindo Shell (MainShell)');
        return MainShell(scaffoldKey: scaffoldKey, child: child);
      },
      routes: [
        // ---------- DASHBOARD ----------
        GoRoute(
          path: '/dashboard',
          name: 'dashboard',
          builder: (context, state) {
            debugPrint('📊 [ROUTER] Abrindo Dashboard');
            return BlocProvider(
              create: (context) => DashboardCubit(context.read<ApiClient>()),
              child: const DashboardScreen(),
            );
          },
        ),

        // ---------- GESTORES ----------
        GoRoute(
          path: '/gestores',
          name: 'gestores',
          builder: (context, state) {
            debugPrint('👤 [ROUTER] Abrindo Gestores');
            return BlocProvider(
              create: (context) => GestoresCubit(context.read<ApiClient>())..fetchGestores(perPage: 10),
              child: const GestoresListScreen(),
            );
          },
        ),

        // ---------- LOJISTAS ----------
        GoRoute(
          path: '/lojistas',
          name: 'lojistas',
          builder: (context, state) {
            debugPrint('👥 [ROUTER] Abrindo Lojistas');
            return BlocProvider(
              create: (context) => getIt<LojistasCubit>(),
              child: const LojistasListPage(),
            );
          },
        ),

        // ---------- CLIENTES (placeholder) ----------
        GoRoute(
          path: '/clientes',
          name: 'clientes',
          builder: (context, state) {
            debugPrint('👤 [ROUTER] Abrindo Clientes');
            return const Scaffold(
              body: Center(child: Text('Clientes - Em breve')),
            );
          },
        ),

        // ---------- LOJAS ----------
        GoRoute(
          path: '/lojas',
          name: 'lojas',
          builder: (context, state) {
            debugPrint('🏪 [ROUTER] Abrindo Lojas');
            return BlocProvider(
              create: (context) => LojasCubit(context.read<ApiClient>())..fetchLojas(perPage: 10),
              child: const LojasListScreen(),
            );
          },
        ),

        // ---------- CATEGORIAS ----------
        GoRoute(
          path: '/categorias',
          name: 'categorias',
          builder: (context, state) {
            debugPrint('📋 [ROUTER] Abrindo Categorias');
            return BlocProvider(
              create: (context) => CategoriasCubit(context.read<ApiClient>())..fetchCategorias(),
              child: const CategoriasListScreen(),
            );
          },
        ),

        // ---------- SUBCATEGORIAS ----------
        GoRoute(
          path: '/subcategorias',
          name: 'subcategorias',
          builder: (context, state) {
            debugPrint('📂 [ROUTER] Abrindo Subcategorias');
            return MultiBlocProvider(
              providers: [
                BlocProvider(create: (context) => getIt<SubcategoriaCubit>()),
                BlocProvider(create: (context) => CategoriasCubit(context.read<ApiClient>())..fetchCategorias()),
              ],
              child: const SubcategoriasListScreen(),
            );
          },
        ),

        // ---------- PEDIDOS ----------
        GoRoute(
          path: '/pedidos',
          name: 'pedidos',
          builder: (context, state) {
            debugPrint('📦 [ROUTER] Abrindo Pedidos');
            return BlocProvider(
              create: (context) => PedidosCubit(context.read<ApiClient>()),
              child: const PedidosListScreen(),
            );
          },
          routes: [
            // 🔥 FILHA: detalhe do pedido (compartilha o mesmo shell)
            GoRoute(
              path: ':id',
              name: 'pedido-detalhe',
              // parentNavigatorKey: NÃO USAR (herda do pai)
              builder: (context, state) {
                final id = int.parse(state.pathParameters['id']!);
                debugPrint('📄 [ROUTER] Abrindo Detalhe do Pedido ID: $id');
                return BlocProvider(
                  create: (context) => PedidosCubit(context.read<ApiClient>()),
                  child: PedidoDetailScreen(pedidoId: id),
                );
              },
            ),
          ],
        ),

        // ---------- CONFIGURAÇÕES ----------
        GoRoute(
          path: '/configuracoes',
          name: 'configuracoes',
          builder: (context, state) {
            debugPrint('⚙️ [ROUTER] Abrindo Configurações');
            return const SettingsScreen();
          },
        ),


      ],
    ),
  ],
);