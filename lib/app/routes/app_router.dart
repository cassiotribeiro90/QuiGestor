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
import '../modules/lojas/views/loja_form_screen.dart';
import '../modules/lojistas/bloc/lojistas_cubit.dart';
import '../modules/lojistas/views/lojistas_list_page.dart';
import '../modules/lojistas/views/lojista_form_page.dart';
import '../modules/lojistas/bloc/lojista_form_cubit.dart'; // 🔥 ADICIONADO
import '../modules/gestores/bloc/gestores_cubit.dart';
import '../modules/gestores/views/gestores_list_screen.dart';
import '../modules/gestores/views/gestor_form_screen.dart';
import '../modules/pedidos/bloc/pedidos_cubit.dart';
import '../modules/pedidos/views/pedido_detail_screen.dart';
import '../modules/pedidos/views/pedidos_list_screen.dart';
import '../modules/categorias/bloc/categorias_cubit.dart';
import '../modules/categorias/views/categorias_list_screen.dart';
import '../modules/categorias/views/categoria_form_screen.dart';
import '../modules/settings/views/settings_screen.dart';
import '../modules/subcategorias/bloc/subcategoria_cubit.dart';
import '../modules/subcategorias/views/subcategorias_list_screen.dart';
import '../modules/subcategorias/views/subcategoria_form_screen.dart';
import '../modules/produtos/bloc/produtos_cubit.dart';
import '../modules/produtos/views/produtos_list_screen.dart';
import '../modules/produtos/views/produto_form_screen.dart';
import '../modules/produtos/bloc/produto_cubit.dart';
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
          routes: [
            GoRoute(
              path: 'novo',
              name: 'gestor-novo',
              builder: (context, state) {
                debugPrint('➕ [ROUTER] Criando novo Gestor');
                // 🔥 Usa GestoresCubit (já tem create/update)
                return BlocProvider(
                  create: (context) => GestoresCubit(context.read<ApiClient>()),
                  child: const GestorFormScreen(),
                );
              },
            ),
            GoRoute(
              path: ':id',
              name: 'gestor-editar',
              builder: (context, state) {
                final id = int.parse(state.pathParameters['id']!);
                debugPrint('✏️ [ROUTER] Editando Gestor ID: $id');
                return BlocProvider(
                  create: (context) => GestoresCubit(context.read<ApiClient>()),
                  child: GestorFormScreen(gestorId: id),
                );
              },
            ),
          ],
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
          routes: [
            GoRoute(
              path: 'novo',
              name: 'lojista-novo',
              builder: (context, state) {
                debugPrint('➕ [ROUTER] Criando novo Lojista');
                // 🔥 Usa LojistaFormCubit (específico para o formulário)
                return BlocProvider(
                  create: (context) => getIt<LojistaFormCubit>(),
                  child: const LojistaFormPage(),
                );
              },
            ),
            GoRoute(
              path: ':id',
              name: 'lojista-editar',
              builder: (context, state) {
                final id = int.parse(state.pathParameters['id']!);
                debugPrint('✏️ [ROUTER] Editando Lojista ID: $id');
                return BlocProvider(
                  create: (context) => getIt<LojistaFormCubit>(),
                  child: LojistaFormPage(id: id),
                );
              },
            ),
          ],
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
          routes: [
            GoRoute(
              path: 'novo',
              name: 'loja-novo',
              builder: (context, state) {
                debugPrint('➕ [ROUTER] Criando nova Loja');
                return BlocProvider(
                  create: (context) => LojasCubit(context.read<ApiClient>()),
                  child: const LojaFormScreen(),
                );
              },
            ),
            GoRoute(
              path: ':id',
              name: 'loja-editar',
              builder: (context, state) {
                final id = int.parse(state.pathParameters['id']!);
                debugPrint('✏️ [ROUTER] Editando Loja ID: $id');
                return BlocProvider(
                  create: (context) => LojasCubit(context.read<ApiClient>()),
                  child: LojaFormScreen(lojaId: id),
                );
              },
            ),
            // 🔥 ROTA: Produtos da loja (lista)
            GoRoute(
              path: ':id/produtos',
              name: 'loja-produtos',
              builder: (context, state) {
                final id = int.parse(state.pathParameters['id']!);
                debugPrint('📦 [ROUTER] Abrindo Produtos da Loja ID: $id');
                return BlocProvider(
                  create: (context) => ProdutosCubit(
                    context.read<ApiClient>(),
                    id,
                  ),
                  child: ProdutosListScreen(
                    lojaId: id,
                    lojaNome: '',
                  ),
                );
              },
              routes: [
                // 🔥 ROTA: Produto (novo)
                GoRoute(
                  path: 'novo',
                  name: 'produto-novo',
                  builder: (context, state) {
                    final lojaId = int.parse(state.pathParameters['id']!);
                    debugPrint('➕ [ROUTER] Criando novo Produto para Loja ID: $lojaId');
                    return BlocProvider(
                      create: (context) => ProdutoCubit(
                        context.read<ApiClient>(),
                      )..loadInitialData(produtoId: null),
                      child: ProdutoFormScreen(
                        produtoId: null,
                        initialLojaId: lojaId,
                      ),
                    );
                  },
                ),
                // 🔥 ROTA: Produto (editar)
                GoRoute(
                  path: ':produtoId',
                  name: 'produto-editar',
                  builder: (context, state) {
                    final lojaId = int.parse(state.pathParameters['id']!);
                    final produtoId = int.parse(state.pathParameters['produtoId']!);
                    debugPrint('✏️ [ROUTER] Editando Produto ID: $produtoId da Loja ID: $lojaId');
                    return BlocProvider(
                      create: (context) => ProdutoCubit(
                        context.read<ApiClient>(),
                      )..loadInitialData(produtoId: produtoId),
                      child: ProdutoFormScreen(
                        produtoId: produtoId,
                        initialLojaId: lojaId,
                      ),
                    );
                  },
                ),
              ],
            ),
          ],
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
          routes: [
            GoRoute(
              path: 'novo',
              name: 'categoria-novo',
              builder: (context, state) {
                debugPrint('➕ [ROUTER] Criando nova Categoria');
                return BlocProvider(
                  create: (context) => CategoriasCubit(context.read<ApiClient>()),
                  child: const CategoriaFormScreen(),
                );
              },
            ),
            GoRoute(
              path: ':id',
              name: 'categoria-editar',
              builder: (context, state) {
                final id = int.parse(state.pathParameters['id']!);
                debugPrint('✏️ [ROUTER] Editando Categoria ID: $id');
                return BlocProvider(
                  create: (context) => CategoriasCubit(context.read<ApiClient>()),
                  child: CategoriaFormScreen(categoriaId: id),
                );
              },
            ),
          ],
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
          routes: [
            GoRoute(
              path: 'novo',
              name: 'subcategoria-novo',
              builder: (context, state) {
                debugPrint('➕ [ROUTER] Criando nova Subcategoria');
                return MultiBlocProvider(
                  providers: [
                    BlocProvider(create: (context) => getIt<SubcategoriaCubit>()),
                    BlocProvider(create: (context) => CategoriasCubit(context.read<ApiClient>())..fetchCategorias()),
                  ],
                  child: const SubcategoriaFormScreen(),
                );
              },
            ),
            GoRoute(
              path: ':id',
              name: 'subcategoria-editar',
              builder: (context, state) {
                final id = int.parse(state.pathParameters['id']!);
                debugPrint('✏️ [ROUTER] Editando Subcategoria ID: $id');
                return MultiBlocProvider(
                  providers: [
                    BlocProvider(create: (context) => getIt<SubcategoriaCubit>()),
                    BlocProvider(create: (context) => CategoriasCubit(context.read<ApiClient>())..fetchCategorias()),
                  ],
                  child: SubcategoriaFormScreen(subcategoriaId: id),
                );
              },
            ),
          ],
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
            GoRoute(
              path: ':id',
              name: 'pedido-detalhe',
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

// ============================================================
// CLASSE ROUTES COM TODOS OS CAMINHOS
// ============================================================
class Routes {
  // Rotas públicas
  static const String splash = '/splash';
  static const String login = '/login';

  // Rotas do shell
  static const String dashboard = '/dashboard';
  static const String gestores = '/gestores';
  static const String lojistas = '/lojistas';
  static const String clientes = '/clientes';
  static const String lojas = '/lojas';
  static const String categorias = '/categorias';
  static const String subcategorias = '/subcategorias';
  static const String pedidos = '/pedidos';
  static const String configuracoes = '/configuracoes';

  // Rotas de formulário - Gestores
  static const String gestorNovo = '/gestores/novo';
  static String gestorEditar(int id) => '/gestores/$id';

  // Rotas de formulário - Lojistas
  static const String lojistaNovo = '/lojistas/novo';
  static String lojistaEditar(int id) => '/lojistas/$id';

  // Rotas de formulário - Lojas
  static const String lojaNovo = '/lojas/novo';
  static String lojaEditar(int id) => '/lojas/$id';

  // Rotas de formulário - Categorias
  static const String categoriaNovo = '/categorias/novo';
  static String categoriaEditar(int id) => '/categorias/$id';

  // Rotas de formulário - Subcategorias
  static const String subcategoriaNovo = '/subcategorias/novo';
  static String subcategoriaEditar(int id) => '/subcategorias/$id';

  // Rotas de formulário - Pedidos
  static String pedidoDetalhe(int id) => '/pedidos/$id';

  // Rotas de formulário - Produtos
  static String lojaProdutos(int lojaId) => '/lojas/$lojaId/produtos';
  static String produtoNovo(int lojaId) => '/lojas/$lojaId/produtos/novo';
  static String produtoEditar(int lojaId, int produtoId) => '/lojas/$lojaId/produtos/$produtoId';
}