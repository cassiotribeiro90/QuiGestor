import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../app/di/dependencies.dart';
import '../services/token_service.dart';
import '../../app/routes/app_routes.dart';
import '../../app/modules/dashboard/bloc/dashboard_cubit.dart';

class RefreshInterceptor extends QueuedInterceptor {
  final Dio _dio;
  final TokenService _tokenService;
  
  // Cache para evitar loop infinito
  final Set<String> _refreshAttempts = {};

  RefreshInterceptor(this._dio, this._tokenService);

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    final bool requiresAuth = options.extra['requiresAuth'] ?? true;

    if (requiresAuth) {
      final headers = _tokenService.getAuthHeader();
      if (headers.isNotEmpty) {
        options.headers.addAll(headers);
        print('🔐 [Interceptor] Token adicionado ao header para: ${options.path}');
      }
    }
    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    // 🔥 NUNCA tenta refresh em login ou refresh
    if (err.requestOptions.path.contains('/login') || 
        err.requestOptions.path.contains('/refresh')) {
      print('🚫 [Interceptor] Ignorando refresh para ${err.requestOptions.path}');
      return handler.next(err);
    }

    // Se não for 401, passa adiante
    if (err.response?.statusCode != 401) {
      return handler.next(err);
    }

    final requestKey = '${err.requestOptions.path}:${err.requestOptions.method}';
    if (_refreshAttempts.contains(requestKey)) {
      print('🚫 [Interceptor] Já tentou refresh para esta requisição, abortando: $requestKey');
      _refreshAttempts.remove(requestKey);
      _redirectToLogin();
      return handler.next(err);
    }

    _refreshAttempts.add(requestKey);
    print('🔄 [Interceptor] Token 401 detectado, tentando refresh...');

    try {
      // Tenta renovar o token
      final success = await _tokenService.refreshToken(_dio);

      if (success) {
        print('✅ [Interceptor] Refresh bem-sucedido, refazendo requisição original');
        
        // Pega o novo token
        final newHeaders = _tokenService.getAuthHeader();
        
        // Reconfigura a requisição original com o novo token
        final newRequest = err.requestOptions;
        newRequest.headers.addAll(newHeaders);
        
        // Limpa o cache da tentativa antes de refazer
        _refreshAttempts.remove(requestKey);
        
        // Refaz a requisição original
        final response = await _dio.fetch(newRequest);
        
        // 🔥 NOTIFICA OS CUBITS QUE O TOKEN FOI RENOVADO
        _notifyTokenRefreshed();
        
        // Retorna a resposta bem-sucedida
        return handler.resolve(response);
      } else {
        print('❌ [Interceptor] Refresh falhou, redirecionando para login');
        _refreshAttempts.remove(requestKey);
        _redirectToLogin();
        return handler.next(err);
      }
    } catch (e) {
      print('❌ [Interceptor] Erro no processo de refresh: $e');
      _refreshAttempts.remove(requestKey);
      _redirectToLogin();
      return handler.next(err);
    }
  }

  void _notifyTokenRefreshed() {
    // Dispara um evento para que os cubits possam reagir
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final context = getIt<GlobalKey<NavigatorState>>().currentContext;
      if (context != null) {
        try {
          // Reexecuta o DashboardCubit se ele existir no contexto
          final dashboardCubit = context.read<DashboardCubit>();
          print('🔄 [Interceptor] Notificando DashboardCubit para recarregar...');
          dashboardCubit.fetchDashboard(); // 🔥 REFAZ A REQUISIÇÃO
        } catch (e) {
          print('⚠️ [Interceptor] DashboardCubit não encontrado no contexto atual: $e');
        }
      }
    });
  }

  void _redirectToLogin() {
    _tokenService.clearTokens();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final context = getIt<GlobalKey<NavigatorState>>().currentContext;
      if (context != null) {
        Navigator.of(context).pushNamedAndRemoveUntil(
          Routes.LOGIN,
          (route) => false,
        );
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Sessão expirada. Faça login novamente.'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    });
  }
}
