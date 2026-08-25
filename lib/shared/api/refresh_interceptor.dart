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
      // 🔥 AGORA USAMOS `then` PARA LIDAR COM O FUTURE
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
    debugPrint('❌ [Interceptor] ========== ERRO DETECTADO ==========');
    debugPrint('❌ [Interceptor] Path: ${err.requestOptions.path}');
    debugPrint('❌ [Interceptor] Method: ${err.requestOptions.method}');
    debugPrint('❌ [Interceptor] Status: ${err.response?.statusCode}');
    debugPrint('❌ [Interceptor] requiresAuth: ${err.requestOptions.extra['requiresAuth']}');
    debugPrint('❌ [Interceptor] Resposta: ${err.response?.data}');

    // 🔥 NUNCA tenta refresh em endpoints de autenticação
    final path = err.requestOptions.path;
    if (path.contains('/login') ||
        path.contains('/refresh') ||
        path.contains('/verify-otp') ||
        path.contains('/phone')) {
      debugPrint('🚫 [Interceptor] Ignorando refresh para endpoint de auth: $path');
      handler.next(err);
      return;
    }

    // Se não for 401, passa adiante
    if (err.response?.statusCode != 401) {
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

    // Evita loop infinito
    final requestKey = '${err.requestOptions.path}:${err.requestOptions.method}';
    if (_refreshAttempts.contains(requestKey)) {
      debugPrint('🔄 [Interceptor] JÁ TENTOU REFRESH PARA ESTA REQUISIÇÃO: $requestKey');
      debugPrint('🚫 [Interceptor] Abortando e redirecionando para login');
      _refreshAttempts.remove(requestKey);
      _redirectToLogin(showMessage: true);
      handler.next(err);
      return;
    }

    _refreshAttempts.add(requestKey);
    debugPrint('🔄 [Interceptor] Token 401 detectado, INICIANDO PROCESSO DE REFRESH...');
    debugPrint('🔄 [Interceptor] RequestKey: $requestKey');

    // 🔥 VERIFICA SE TEM REFRESH TOKEN SALVO
    final refreshToken = await _tokenService.getRefreshToken();
    debugPrint('🔄 [Interceptor] Refresh token disponível? ${refreshToken != null}');

    if (refreshToken == null) {
      debugPrint('❌ [Interceptor] SEM REFRESH TOKEN DISPONÍVEL!');
      _refreshAttempts.remove(requestKey);
      _redirectToLogin(showMessage: true);
      handler.next(err);
      return;
    }

    try {
      debugPrint('🔄 [Interceptor] Chamando AuthCubit.refreshToken()...');
      final success = await getIt<AuthCubit>().refreshToken();

      if (success) {
        debugPrint('✅ [Interceptor] REFRESH BEM-SUCEDIDO! Novo token obtido.');

        // 🔥 OBTÉM O NOVO HEADER DE AUTENTICAÇÃO (ASSÍNCRONO)
        final newHeaders = await _tokenService.getAuthHeader();
        if (newHeaders.isNotEmpty) {
          debugPrint('✅ [Interceptor] Novo token adicionado: ${newHeaders['Authorization']?.substring(0, 30)}...');
        } else {
          debugPrint('⚠️ [Interceptor] Novo token não encontrado após refresh');
          _refreshAttempts.remove(requestKey);
          _redirectToLogin(showMessage: true);
          handler.next(err);
          return;
        }

        // Reconfigura a requisição original com o novo token
        final newRequest = err.requestOptions;
        newRequest.headers.addAll(newHeaders);

        debugPrint('🔄 [Interceptor] Refazendo requisição original: ${newRequest.path}');

        // Refaz a requisição
        final response = await _dio.fetch(newRequest);

        // Limpa o cache
        _refreshAttempts.remove(requestKey);
        debugPrint('✅ [Interceptor] REQUISIÇÃO ORIGINAL BEM-SUCEDIDA APÓS REFRESH');

        handler.resolve(response);
      } else {
        debugPrint('❌ [Interceptor] REFRESH FALHOU! Token não renovado.');
        _refreshAttempts.remove(requestKey);
        _redirectToLogin(showMessage: true);
        handler.next(err);
      }
    } catch (e) {
      debugPrint('❌ [Interceptor] EXCEÇÃO NO PROCESSO DE REFRESH: $e');
      _refreshAttempts.remove(requestKey);
      _redirectToLogin(showMessage: true);
      handler.next(err);
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