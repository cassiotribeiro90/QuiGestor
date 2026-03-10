import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../services/token_service.dart';
import '../../app/routes/app_routes.dart';
import '../../app/modules/auth/bloc/auth_cubit.dart';

class RefreshInterceptor extends QueuedInterceptor {
  final Dio _dio;
  final TokenService _tokenService;
  final GlobalKey<NavigatorState> _navigatorKey;

  final Set<String> _refreshAttempts = {};

  RefreshInterceptor({
    required Dio dio,
    required TokenService tokenService,
    required GlobalKey<NavigatorState> navigatorKey,
  })  : _dio = dio,
        _tokenService = tokenService,
        _navigatorKey = navigatorKey;

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    final bool requiresAuth = options.extra['requiresAuth'] ?? true;

    print('📤 [Interceptor] ${options.method} ${options.path} - requiresAuth: $requiresAuth');

    if (requiresAuth) {
      final headers = _tokenService.getAuthHeader();
      if (headers.isNotEmpty) {
        options.headers.addAll(headers);
        print('🔐 [Interceptor] Token adicionado ao header');
      } else {
        print('⚠️ [Interceptor] Requisição requer auth mas não há token');
      }
    }
    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    print('❌ [Interceptor] ========== ERRO DETECTADO ==========');
    print('❌ [Interceptor] Path: ${err.requestOptions.path}');
    print('❌ [Interceptor] Method: ${err.requestOptions.method}');
    print('❌ [Interceptor] Status: ${err.response?.statusCode}');
    print('❌ [Interceptor] requiresAuth: ${err.requestOptions.extra['requiresAuth']}');
    print('❌ [Interceptor] Resposta: ${err.response?.data}');

    // 🔥 NUNCA tenta refresh em endpoints de autenticação
    if (err.requestOptions.path.contains('/login') ||
        err.requestOptions.path.contains('/refresh')) {
      print('🚫 [Interceptor] Ignorando refresh para endpoint de auth: ${err.requestOptions.path}');
      handler.next(err);
      return;
    }

    // Se não for 401, passa adiante
    if (err.response?.statusCode != 401) {
      print('ℹ️ [Interceptor] Erro não é 401, repassando...');
      handler.next(err);
      return;
    }

    // Verifica se a requisição realmente requer autenticação
    final bool requiresAuth = err.requestOptions.extra['requiresAuth'] ?? true;
    if (!requiresAuth) {
      print('ℹ️ [Interceptor] Requisição não requer auth, ignorando refresh');
      handler.next(err);
      return;
    }

    // Evita loop infinito
    final requestKey = '${err.requestOptions.path}:${err.requestOptions.method}';
    if (_refreshAttempts.contains(requestKey)) {
      print('🔄 [Interceptor] JÁ TENTOU REFRESH PARA ESTA REQUISIÇÃO: $requestKey');
      print('🚫 [Interceptor] Abortando e redirecionando para login');
      _refreshAttempts.remove(requestKey);
      _redirectToLogin(showMessage: true);
      handler.next(err);
      return;
    }

    _refreshAttempts.add(requestKey);
    print('🔄 [Interceptor] Token 401 detectado, INICIANDO PROCESSO DE REFRESH...');
    print('🔄 [Interceptor] RequestKey: $requestKey');
    print('🔄 [Interceptor] Refresh token disponível? ${_tokenService.getRefreshToken() != null}');

    try {
      // Verifica se tem refresh token
      final hasRefreshToken = _tokenService.getRefreshToken() != null;
      if (!hasRefreshToken) {
        print('❌ [Interceptor] SEM REFRESH TOKEN DISPONÍVEL!');
        _refreshAttempts.remove(requestKey);
        _redirectToLogin(showMessage: true);
        handler.next(err);
        return;
      }

      print('🔄 [Interceptor] Chamando TokenService.refreshToken()...');
      final success = await _tokenService.refreshToken(_dio);

      if (success) {
        print('✅ [Interceptor] REFRESH BEM-SUCEDIDO! Novo token obtido.');

        final newHeaders = _tokenService.getAuthHeader();
        print('✅ [Interceptor] Novo token: ${newHeaders.toString().substring(0, 30)}...');

        // Reconfigura a requisição original
        final newRequest = err.requestOptions;
        newRequest.headers.addAll(newHeaders);

        print('🔄 [Interceptor] Refazendo requisição original: ${newRequest.path}');

        // Refaz a requisição
        final response = await _dio.fetch(newRequest);

        // Limpa o cache
        _refreshAttempts.remove(requestKey);
        print('✅ [Interceptor] REQUISIÇÃO ORIGINAL BEM-SUCEDIDA APÓS REFRESH');

        handler.resolve(response);
      } else {
        print('❌ [Interceptor] REFRESH FALHOU! Token não renovado.');
        _refreshAttempts.remove(requestKey);
        _redirectToLogin(showMessage: true);
        handler.next(err);
      }
    } catch (e) {
      print('❌ [Interceptor] EXCEÇÃO NO PROCESSO DE REFRESH: $e');
      _refreshAttempts.remove(requestKey);
      _redirectToLogin(showMessage: true);
      handler.next(err);
    }
  }

  void _redirectToLogin({bool showMessage = true}) {
    print('🚪 [Interceptor] ========== REDIRECIONANDO PARA LOGIN ==========');
    print('🚪 [Interceptor] Limpando tokens...');

    _tokenService.clearTokens();

    print('🚪 [Interceptor] Tokens limpos, agendando redirecionamento...');

    WidgetsBinding.instance.addPostFrameCallback((_) {
      print('🚪 [Interceptor] Executando redirecionamento no próximo frame...');

      final navigator = _navigatorKey.currentState;
      if (navigator != null) {
        print('✅ [Interceptor] Navigator encontrado, redirecionando...');

        final context = _navigatorKey.currentContext;
        if (context != null) {
          try {
            print('🚪 [Interceptor] Chamando AuthCubit.logout()...');
            context.read<AuthCubit>().logout();
            print('✅ [Interceptor] AuthCubit.logout() executado');
          } catch (e) {
            print('⚠️ [Interceptor] Erro ao acessar AuthCubit: $e');
          }
        } else {
          print('⚠️ [Interceptor] Context é null, pulando AuthCubit.logout()');
        }

        navigator.pushNamedAndRemoveUntil(
          Routes.LOGIN,
              (route) => false,
        );
        print('✅ [Interceptor] Navegação para login executada');

        if (showMessage) {
          try {
            final context = _navigatorKey.currentContext;
            if (context != null) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Sessão expirada. Faça login novamente.'),
                  backgroundColor: Colors.orange,
                  duration: Duration(seconds: 3),
                ),
              );
              print('✅ [Interceptor] SnackBar exibido');
            }
          } catch (e) {
            print('⚠️ [Interceptor] Erro ao mostrar SnackBar: $e');
          }
        }
      } else {
        print('❌ [Interceptor] NAVIGATOR NÃO ENCONTRADO!');
      }
    });
  }
}