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
import '../modules/lojistas/bloc/lojista_form_cubit.dart';
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
import '../modules/clientes/bloc/clientes_cubit.dart';
import '../modules/clientes/views/clientes_list_screen.dart';
import '../modules/clientes/views/cliente_form_screen.dart';
import '../modules/avaliacoes/bloc/avaliacoes_cubit.dart';
import '../modules/avaliacoes/views/avaliacoes_list_screen.dart';
import '../modules/avaliacoes/views/avaliacao_detalhe_screen.dart';
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
    // ROTAS PÚBLICAS (fora do Shell)
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
    // ROTAS PROTEGIDAS (todas filhas diretas da ShellRoute)
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
          parentNavigatorKey: _shellNavigatorKey,
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
          parentNavigatorKey: _shellNavigatorKey,
          builder: (context, state) {
            debugPrint('👤 [ROUTER] Abrindo Gestores');
            return BlocProvider(
              create: (context) => GestoresCubit(context.read<ApiClient>())..fetchGestores(perPage: 10),
              child: const GestoresListScreen(),
            );
          },
        ),
        GoRoute(
          path: '/gestores/novo',
          name: 'gestor-novo',
          parentNavigatorKey: _shellNavigatorKey,
          builder: (context, state) {
            debugPrint('➕ [ROUTER] Criando novo Gestor');
            return BlocProvider(
              create: (context) => GestoresCubit(context.read<ApiClient>()),
              child: const GestorFormScreen(),
            );
          },
        ),
        GoRoute(
          path: '/gestores/:id',
          name: 'gestor-editar',
          parentNavigatorKey: _shellNavigatorKey,
          builder: (context, state) {
            final id = int.parse(state.pathParameters['id']!);
            debugPrint('✏️ [ROUTER] Editando Gestor ID: $id');
            return BlocProvider(
              create: (context) => GestoresCubit(context.read<ApiClient>()),
              child: GestorFormScreen(gestorId: id),
            );
          },
        ),

        // ---------- LOJISTAS ----------
        GoRoute(
          path: '/lojistas',
          name: 'lojistas',
          parentNavigatorKey: _shellNavigatorKey,
          builder: (context, state) {
            debugPrint('👥 [ROUTER] Abrindo Lojistas');
            return BlocProvider(
              create: (context) => getIt<LojistasCubit>(),
              child: const LojistasListPage(),
            );
          },
        ),
        GoRoute(
          path: '/lojistas/novo',
          name: 'lojista-novo',
          parentNavigatorKey: _shellNavigatorKey,
          builder: (context, state) {
            debugPrint('➕ [ROUTER] Criando novo Lojista');
            return BlocProvider(
              create: (context) => getIt<LojistaFormCubit>(),
              child: const LojistaFormPage(),
            );
          },
        ),
        GoRoute(
          path: '/lojistas/:id',
          name: 'lojista-editar',
          parentNavigatorKey: _shellNavigatorKey,
          builder: (context, state) {
            final id = int.parse(state.pathParameters['id']!);
            debugPrint('✏️ [ROUTER] Editando Lojista ID: $id');
            return BlocProvider(
              create: (context) => getIt<LojistaFormCubit>(),
              child: LojistaFormPage(id: id),
            );
          },
        ),

        // ---------- CLIENTES ----------
        GoRoute(
          path: '/clientes',
          name: 'clientes',
          parentNavigatorKey: _shellNavigatorKey,
          builder: (context, state) {
            debugPrint('👤 [ROUTER] Abrindo Clientes');
            return BlocProvider(
              create: (context) => ClientesCubit(context.read<ApiClient>()),
              child: const ClientesListScreen(),
            );
          },
        ),
        GoRoute(
          path: '/clientes/:id',
          name: 'cliente-editar',
          parentNavigatorKey: _shellNavigatorKey,
          builder: (context, state) {
            final id = int.parse(state.pathParameters['id']!);
            debugPrint('✏️ [ROUTER] Editando Cliente ID: $id');
            return BlocProvider(
              create: (context) => ClientesCubit(context.read<ApiClient>()),
              child: ClienteFormScreen(clienteId: id),
            );
          },
        ),

        // ---------- LOJAS ----------
        GoRoute(
          path: '/lojas',
          name: 'lojas',
          parentNavigatorKey: _shellNavigatorKey,
          builder: (context, state) {
            debugPrint('🏪 [ROUTER] Abrindo Lojas');
            return BlocProvider(
              create: (context) => LojasCubit(context.read<ApiClient>())..fetchLojas(perPage: 10),
              child: const LojasListScreen(),
            );
          },
        ),
        GoRoute(
          path: '/lojas/novo',
          name: 'loja-novo',
          parentNavigatorKey: _shellNavigatorKey,
          builder: (context, state) {
            debugPrint('➕ [ROUTER] Criando nova Loja');
            return BlocProvider(
              create: (context) => LojasCubit(context.read<ApiClient>()),
              child: const LojaFormScreen(),
            );
          },
        ),
        GoRoute(
          path: '/lojas/:id',
          name: 'loja-editar',
          parentNavigatorKey: _shellNavigatorKey,
          builder: (context, state) {
            final id = int.parse(state.pathParameters['id']!);
            debugPrint('✏️ [ROUTER] Editando Loja ID: $id');
            return BlocProvider(
              create: (context) => LojasCubit(context.read<ApiClient>()),
              child: LojaFormScreen(lojaId: id),
            );
          },
        ),
        // Produtos da loja (lista)
        GoRoute(
          path: '/lojas/:id/produtos',
          name: 'loja-produtos',
          parentNavigatorKey: _shellNavigatorKey,
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
        ),
        // Produto - Novo
        GoRoute(
          path: '/lojas/:id/produtos/novo',
          name: 'produto-novo',
          parentNavigatorKey: _shellNavigatorKey,
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
        // Produto - Editar
        GoRoute(
          path: '/lojas/:id/produtos/:produtoId',
          name: 'produto-editar',
          parentNavigatorKey: _shellNavigatorKey,
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

        // ---------- CATEGORIAS ----------
        GoRoute(
          path: '/categorias',
          name: 'categorias',
          parentNavigatorKey: _shellNavigatorKey,
          builder: (context, state) {
            debugPrint('📋 [ROUTER] Abrindo Categorias');
            return BlocProvider(
              create: (context) => CategoriasCubit(context.read<ApiClient>())..fetchCategorias(),
              child: const CategoriasListScreen(),
            );
          },
        ),
        GoRoute(
          path: '/categorias/novo',
          name: 'categoria-novo',
          parentNavigatorKey: _shellNavigatorKey,
          builder: (context, state) {
            debugPrint('➕ [ROUTER] Criando nova Categoria');
            return BlocProvider(
              create: (context) => CategoriasCubit(context.read<ApiClient>()),
              child: const CategoriaFormScreen(),
            );
          },
        ),
        GoRoute(
          path: '/categorias/:id',
          name: 'categoria-editar',
          parentNavigatorKey: _shellNavigatorKey,
          builder: (context, state) {
            final id = int.parse(state.pathParameters['id']!);
            debugPrint('✏️ [ROUTER] Editando Categoria ID: $id');
            return BlocProvider(
              create: (context) => CategoriasCubit(context.read<ApiClient>()),
              child: CategoriaFormScreen(categoriaId: id),
            );
          },
        ),

        // ---------- SUBCATEGORIAS ----------
        GoRoute(
          path: '/subcategorias',
          name: 'subcategorias',
          parentNavigatorKey: _shellNavigatorKey,
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
        GoRoute(
          path: '/subcategorias/novo',
          name: 'subcategoria-novo',
          parentNavigatorKey: _shellNavigatorKey,
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
          path: '/subcategorias/:id',
          name: 'subcategoria-editar',
          parentNavigatorKey: _shellNavigatorKey,
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

        // ---------- PEDIDOS ----------
        GoRoute(
          path: '/pedidos',
          name: 'pedidos',
          parentNavigatorKey: _shellNavigatorKey,
          builder: (context, state) {
            debugPrint('📦 [ROUTER] Abrindo Pedidos');
            return BlocProvider(
              create: (context) => PedidosCubit(context.read<ApiClient>()),
              child: const PedidosListScreen(),
            );
          },
        ),
        GoRoute(
          path: '/pedidos/:id',
          name: 'pedido-detalhe',
          parentNavigatorKey: _shellNavigatorKey,
          builder: (context, state) {
            final id = int.parse(state.pathParameters['id']!);
            debugPrint('📄 [ROUTER] Abrindo Detalhe do Pedido ID: $id');
            return BlocProvider(
              create: (context) => PedidosCubit(context.read<ApiClient>()),
              child: PedidoDetailScreen(pedidoId: id),
            );
          },
        ),

        // ---------- AVALIAÇÕES ----------
        GoRoute(
          path: '/avaliacoes',
          name: 'avaliacoes',
          parentNavigatorKey: _shellNavigatorKey,
          builder: (context, state) {
            debugPrint('⭐ [ROUTER] Abrindo Avaliações');
            return BlocProvider(
              create: (context) => getIt<AvaliacoesCubit>(),
              child: const AvaliacoesListScreen(),
            );
          },
        ),
        GoRoute(
          path: '/avaliacoes/:id',
          name: 'avaliacao-detalhe',
          parentNavigatorKey: _shellNavigatorKey,
          builder: (context, state) {
            final id = int.parse(state.pathParameters['id']!);
            debugPrint('📄 [ROUTER] Abrindo Detalhe da Avaliação ID: $id');
            return BlocProvider(
              create: (context) => getIt<AvaliacoesCubit>(),
              child: AvaliacaoDetalheScreen(avaliacaoId: id),
            );
          },
        ),

        // ---------- CONFIGURAÇÕES ----------
        GoRoute(
          path: '/configuracoes',
          name: 'configuracoes',
          parentNavigatorKey: _shellNavigatorKey,
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
  static const String avaliacoes = '/avaliacoes';
  static const String configuracoes = '/configuracoes';

  // Rotas de formulário - Gestores
  static const String gestorNovo = '/gestores/novo';
  static String gestorEditar(int id) => '/gestores/$id';

  // Rotas de formulário - Clientes
  static String clienteEditar(int id) => '/clientes/$id';

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

  // Rotas de formulário - Avaliações
  static String avaliacaoDetalhe(int id) => '/avaliacoes/$id';

  // Rotas de formulário - Produtos
  static String lojaProdutos(int lojaId) => '/lojas/$lojaId/produtos';
  static String produtoNovo(int lojaId) => '/lojas/$lojaId/produtos/novo';
  static String produtoEditar(int lojaId, int produtoId) => '/lojas/$lojaId/produtos/$produtoId';
}