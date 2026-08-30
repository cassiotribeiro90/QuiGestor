import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../app/di/dependencies.dart';
import '../../apparte/widgets/app_text.dart';
import '../services/token_service.dart';
import '../../app/routes/app_router.dart';
import '../../app/modules/auth/bloc/auth_cubit.dart';

class RefreshInterceptor extends QueuedInterceptor {
  final Dio _dio;
  final TokenService _tokenService;
  final GlobalKey<NavigatorState> _navigatorKey;

  final Set<String> _refreshAttempts = {};
  bool _isRefreshing = false;

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

    debugPrint('📤 [Interceptor] ${options.method} ${options.path} - requiresAuth: $requiresAuth');

    if (requiresAuth) {
      _tokenService.getAuthHeader().then((headers) {
        if (headers.isNotEmpty) {
          options.headers.addAll(headers);
          debugPrint('🔐 [Interceptor] Token adicionado ao header: ${headers['Authorization']?.substring(0, 30)}...');
        } else {
          debugPrint('⚠️ [Interceptor] Requisição requer auth mas não há token');
        }
        handler.next(options);
      }).catchError((e) {
        debugPrint('❌ [Interceptor] Erro ao obter token: $e');
        handler.next(options);
      });
    } else {
      handler.next(options);
    }
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    final path = err.requestOptions.path;
    final statusCode = err.response?.statusCode;

    debugPrint('❌ [Interceptor] ========== ERRO DETECTADO ==========');
    debugPrint('❌ [Interceptor] Path: $path');
    debugPrint('❌ [Interceptor] Status: $statusCode');

    // 🔥 NUNCA tenta refresh em endpoints de autenticação
    if (path.contains('/login') ||
        path.contains('/refresh') ||
        path.contains('/verify-otp') ||
        path.contains('/phone')) {
      debugPrint('🚫 [Interceptor] Ignorando refresh para endpoint de auth: $path');
      handler.next(err);
      return;
    }

    // Se não for 401, passa adiante
    if (statusCode != 401) {
      debugPrint('ℹ️ [Interceptor] Erro não é 401, repassando...');
      handler.next(err);
      return;
    }

    // Verifica se a requisição realmente requer autenticação
    final bool requiresAuth = err.requestOptions.extra['requiresAuth'] ?? true;
    if (!requiresAuth) {
      debugPrint('ℹ️ [Interceptor] Requisição não requer auth, ignorando refresh');
      handler.next(err);
      return;
    }

    // O QueuedInterceptor garante que apenas uma execução de onError (ou onRequest/onResponse)
    // aconteça por vez. Isso é crucial para o refresh token.
    
    try {
      // 1. Verifica se o token já foi renovado por outra requisição que estava na fila
      final requestToken = err.requestOptions.headers['Authorization']?.toString().replaceFirst('Bearer ', '');
      final currentToken = await _tokenService.getAccessToken();

      if (currentToken != null && requestToken != null && currentToken != requestToken) {
        debugPrint('🔄 [Interceptor] Token já foi renovado por outra requisição previa. Reexecutando com novo token...');
        final newHeaders = await _tokenService.getAuthHeader();
        final newRequest = err.requestOptions;
        newRequest.headers.addAll(newHeaders);
        
        final response = await _dio.fetch(newRequest);
        handler.resolve(response);
        return;
      }

      // 2. Se chegou aqui, esta é a primeira requisição a falhar com este token
      // Evita loop infinito para a mesma requisição (mesmo endpoint + mesmo token)
      final requestKey = '${err.requestOptions.path}:${err.requestOptions.method}:$requestToken';
      if (_refreshAttempts.contains(requestKey)) {
        debugPrint('🔄 [Interceptor] LOOP DETECTADO: Já tentou refresh para esta request e token: $requestKey');
        _refreshAttempts.remove(requestKey);
        _redirectToLogin(showMessage: true);
        handler.next(err);
        return;
      }

      _refreshAttempts.add(requestKey);
      debugPrint('🔄 [Interceptor] INICIANDO PROCESSO DE REFRESH para: $path');
      
      _isRefreshing = true;

      final refreshToken = await _tokenService.getRefreshToken();
      debugPrint('🔑 [Interceptor] Refresh token disponível? ${refreshToken != null ? 'SIM' : 'NÃO'}');

      if (refreshToken == null) {
        debugPrint('❌ [Interceptor] Refresh token NÃO ENCONTRADO no storage');
        _isRefreshing = false;
        _refreshAttempts.remove(requestKey);
        _redirectToLogin(showMessage: true);
        handler.next(err);
        return;
      }

      debugPrint('🔄 [Interceptor] Chamando AuthCubit.refreshToken()...');
      
      // Timeout de segurança para evitar travamentos no Web/Edge
      final refreshFuture = getIt<AuthCubit>().refreshToken();
      final success = await refreshFuture.timeout(
        const Duration(seconds: 15),
        onTimeout: () {
          debugPrint('⏰ [Interceptor] TIMEOUT (15s) no refreshToken()');
          return false;
        },
      );

      if (success) {
        debugPrint('✅ [Interceptor] REFRESH BEM-SUCEDIDO!');

        final newHeaders = await _tokenService.getAuthHeader();
        if (newHeaders.isNotEmpty) {
          final newRequest = err.requestOptions;
          newRequest.headers.addAll(newHeaders);
          
          debugPrint('🔄 [Interceptor] Reexecutando requisição original...');
          final response = await _dio.fetch(newRequest);
          
          _refreshAttempts.remove(requestKey);
          debugPrint('✅ [Interceptor] REQUISIÇÃO ORIGINAL CONCLUÍDA COM SUCESSO APÓS REFRESH');
          handler.resolve(response);
        } else {
          debugPrint('⚠️ [Interceptor] Novos headers vazios após refresh');
          throw Exception('Token headers empty after refresh');
        }
      } else {
        debugPrint('❌ [Interceptor] REFRESH FALHOU (Backend retornou erro ou AuthCubit falhou)');
        _refreshAttempts.remove(requestKey);
        _redirectToLogin(showMessage: true);
        handler.next(err);
      }
    } catch (e) {
      debugPrint('❌ [Interceptor] EXCEÇÃO NO PROCESSO DE REFRESH: $e');
      _refreshAttempts.remove(err.requestOptions.path); // Limpeza preventiva
      _redirectToLogin(showMessage: true);
      handler.next(err);
    } finally {
      _isRefreshing = false;
    }
  }

  void _redirectToLogin({bool showMessage = true}) {
    debugPrint('🚪 [Interceptor] ========== REDIRECIONANDO PARA LOGIN ==========');
    debugPrint('🚪 [Interceptor] Limpando tokens...');

    _tokenService.clearTokens();

    debugPrint('🚪 [Interceptor] Tokens limpos, agendando redirecionamento...');

    WidgetsBinding.instance.addPostFrameCallback((_) {
      debugPrint('🚪 [Interceptor] Executando redirecionamento no próximo frame...');

      final navigator = _navigatorKey.currentState;
      if (navigator != null) {
        debugPrint('✅ [Interceptor] Navigator encontrado, redirecionando...');

        final context = _navigatorKey.currentContext;
        if (context != null) {
          try {
            debugPrint('🚪 [Interceptor] Chamando AuthCubit.logout()...');
            context.read<AuthCubit>().logout();
            debugPrint('✅ [Interceptor] AuthCubit.logout() executado');
          } catch (e) {
            debugPrint('⚠️ [Interceptor] Erro ao acessar AuthCubit: $e');
          }
        } else {
          debugPrint('⚠️ [Interceptor] Context é null, pulando AuthCubit.logout()');
        }

        appRouter.go('/login');
        debugPrint('✅ [Interceptor] Navegação para login executada');

        if (showMessage) {
          try {
            final context = _navigatorKey.currentContext;
            if (context != null) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: TextBody2('Sessão expirada. Faça login novamente.', color: Colors.white),
                  backgroundColor: Colors.orange,
                  duration: Duration(seconds: 3),
                ),
              );
              debugPrint('✅ [Interceptor] SnackBar exibido');
            }
          } catch (e) {
            debugPrint('⚠️ [Interceptor] Erro ao mostrar SnackBar: $e');
          }
        }
      } else {
        debugPrint('❌ [Interceptor] NAVIGATOR NÃO ENCONTRADO!');
      }
    });
  }
}