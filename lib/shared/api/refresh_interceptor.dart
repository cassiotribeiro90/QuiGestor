import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../app/di/dependencies.dart';
import '../services/token_service.dart';
import '../../app/routes/app_routes.dart';
import '../../app/modules/auth/bloc/auth_cubit.dart';

class RefreshInterceptor extends QueuedInterceptor {
  final Dio _dio;
  final TokenService _tokenService;
  
  // Cache para evitar loop infinito
  final Set<String> _refreshAttempts = {};

  RefreshInterceptor(this._dio, this._tokenService);

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    // Verifica se a requisição requer autenticação (padrão true)
    final bool requiresAuth = options.extra['requiresAuth'] ?? true;

    if (requiresAuth) {
      final headers = _tokenService.getAuthHeader();
      if (headers.isNotEmpty) {
        options.headers.addAll(headers);
        print('🔐 [Interceptor] Token adicionado ao header para: ${options.path}');
      } else {
        print('⚠️ [Interceptor] Requisição requer auth mas não há token: ${options.path}');
      }
    }
    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    print('🔥 [Interceptor] ========== ERRO DETECTADO ==========');
    print('🔥 [Interceptor] Path: ${err.requestOptions.path}');
    print('🔥 [Interceptor] Status: ${err.response?.statusCode}');
    print('🔥 [Interceptor] requiresAuth: ${err.requestOptions.extra['requiresAuth']}');
    print('🔥 [Interceptor] Resposta: ${err.response?.data}');

    // 🔥 NUNCA tenta refresh em endpoints de autenticação
    if (err.requestOptions.path.contains('/login') || 
        err.requestOptions.path.contains('/refresh')) {
      print('🚫 [Interceptor] Ignorando refresh para ${err.requestOptions.path}');
      handler.next(err);
      return;
    }

    // Se não for 401, passa adiante
    if (err.response?.statusCode != 401) {
      handler.next(err);
      return;
    }

    // Verifica se a requisição requer autenticação
    final bool requiresAuth = err.requestOptions.extra['requiresAuth'] ?? true;
    if (!requiresAuth) {
      handler.next(err);
      return;
    }

    // Evita loop infinito (máximo 1 tentativa de refresh)
    final requestKey = '${err.requestOptions.path}:${err.requestOptions.method}';
    if (_refreshAttempts.contains(requestKey)) {
      print('🚫 [Interceptor] Já tentou refresh para esta requisição, abortando: $requestKey');
      _refreshAttempts.remove(requestKey);
      _redirectToLogin(showMessage: true);
      handler.next(err);
      return;
    }

    _refreshAttempts.add(requestKey);
    print('🔄 [Interceptor] Token 401 detectado, tentando refresh...');

    try {
      // Verifica se tem refresh token antes de tentar
      final hasRefreshToken = _tokenService.getRefreshToken() != null;
      if (!hasRefreshToken) {
        print('❌ [Interceptor] Sem refresh token disponível');
        _refreshAttempts.remove(requestKey);
        _redirectToLogin(showMessage: true);
        handler.next(err);
        return;
      }

      // Tenta renovar o token
      final success = await _tokenService.refreshToken(_dio);

      if (success) {
        print('✅ [Interceptor] Refresh bem-sucedido, refazendo requisição original');
        
        // Pega o novo token
        final newHeaders = _tokenService.getAuthHeader();
        
        // Reconfigura a requisição original com o novo token
        final newRequest = err.requestOptions;
        newRequest.headers.addAll(newHeaders);
        
        // Refaz a requisição
        final response = await _dio.fetch(newRequest);
        
        // Limpa o cache da tentativa
        _refreshAttempts.remove(requestKey);
        
        // Retorna a resposta bem-sucedida
        handler.resolve(response);
      } else {
        print('❌ [Interceptor] Refresh falhou, redirecionando para login');
        _refreshAttempts.remove(requestKey);
        _redirectToLogin(showMessage: true);
        handler.next(err);
      }
    } catch (e) {
      print('❌ [Interceptor] Erro no processo de refresh: $e');
      _refreshAttempts.remove(requestKey);
      _redirectToLogin(showMessage: true);
      handler.next(err);
    }
  }

  void _redirectToLogin({bool showMessage = true}) {
    print('🚪 [Interceptor] Redirecionando para login...');
    
    // Limpa os tokens
    _tokenService.clearTokens();
    
    // Usa o navigator para redirecionar para login
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Tenta obter o contexto atual de várias formas
      final navigatorKey = getIt<GlobalKey<NavigatorState>>();
      final context = navigatorKey.currentContext;
      
      if (context != null) {
        print('🚪 [Interceptor] Context encontrado, navegando para login');
        
        // Força logout no AuthCubit
        try {
          final authCubit = context.read<AuthCubit>();
          authCubit.logout();
        } catch (e) {
          print('⚠️ [Interceptor] Erro ao acessar AuthCubit: $e');
        }
        
        // Remove todas as rotas e vai para login
        Navigator.of(context).pushNamedAndRemoveUntil(
          Routes.LOGIN,
          (route) => false,
        );
        
        // Mostra mensagem
        if (showMessage) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Sessão expirada. Faça login novamente.'),
              backgroundColor: Colors.orange,
              duration: Duration(seconds: 3),
            ),
          );
        }
      } else {
        print('🚪 [Interceptor] Context é null! Tentando rota alternativa...');
        // Se não conseguir contexto, tenta usar o navigatorKey diretamente
        final navigator = navigatorKey.currentState;
        if (navigator != null) {
          navigator.pushNamedAndRemoveUntil(
            Routes.LOGIN,
            (route) => false,
          );
        }
      }
    });
  }
}
