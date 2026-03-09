import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../../app/di/dependencies.dart';
import '../services/token_service.dart';

class ApiClient {
  late final Dio _dio;
  late final TokenService _tokenService;

  ApiClient() {
    _tokenService = getIt<TokenService>();
    
    final options = BaseOptions(
      baseUrl: kIsWeb 
          ? 'http://localhost:8001/api'
          : (defaultTargetPlatform == TargetPlatform.android 
              ? 'http://10.0.2.2:8001/api' 
              : 'http://localhost:8001/api'),
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
      headers: {
        'Content-Type': 'application/json',
        'X-Requested-With': 'XMLHttpRequest'
      }
    );

    _dio = Dio(options);

    // 🛡️ INTERCEPTOR DE AUTENTICAÇÃO (O "Cérebro" do Sistema)
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) {
        // Verifica a flag 'requiresAuth' nos extras (padrão: true)
        final bool requiresAuth = options.extra['requiresAuth'] ?? true;
        
        if (requiresAuth) {
          final token = _tokenService.getToken();
          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = ['Bearer $token'];
            debugPrint('🚀 [DIO] Header Authorization injetado com sucesso');
          } else {
            debugPrint('⚠️ [DIO] Requisição requer auth, mas TokenService retornou null/vazio');
          }
        }
        return handler.next(options);
      },
      onError: (e, handler) {
        if (e.response?.statusCode == 401) {
          debugPrint('🚫 [DIO] Erro 401 detectado no interceptor');
        }
        return handler.next(e);
      }
    ));

    _dio.interceptors.add(LogInterceptor(
      requestHeader: true, 
      requestBody: true,
      responseBody: true,
      responseHeader: false,
    ));
  }
  
  Future<Response> get(String path, {bool requiresAuth = true}) async {
    return _dio.get(path, options: Options(extra: {'requiresAuth': requiresAuth}));
  }
  
  Future<Response> post(String path, {dynamic data, bool requiresAuth = true}) async {
    return _dio.post(path, data: data, options: Options(extra: {'requiresAuth': requiresAuth}));
  }
  
  Future<Response> put(String path, {dynamic data, bool requiresAuth = true}) async {
    return _dio.put(path, data: data, options: Options(extra: {'requiresAuth': requiresAuth}));
  }
  
  Future<Response> delete(String path, {bool requiresAuth = true}) async {
    return _dio.delete(path, options: Options(extra: {'requiresAuth': requiresAuth}));
  }
}
