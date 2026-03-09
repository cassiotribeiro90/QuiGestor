import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../../app/di/dependencies.dart';
import '../services/token_service.dart';
import 'refresh_interceptor.dart';

class ApiClient {
  late final Dio _dio;
  late final TokenService _tokenService;
  late final RefreshInterceptor _refreshInterceptor;

  static final navigatorKey = GlobalKey<NavigatorState>();

  ApiClient() {
    print('🌐 [ApiClient] Inicializando...');
    _tokenService = getIt<TokenService>();
    
    const String baseUrlEnv = String.fromEnvironment('API_URL');
    
    final options = BaseOptions(
      baseUrl: baseUrlEnv.isNotEmpty 
          ? baseUrlEnv 
          : (kIsWeb 
               ? 'http://localhost:8001/api'
              : (defaultTargetPlatform == TargetPlatform.android 
                  ? 'http://10.0.2.2:8001/api' 
                  : 'http://localhost:8001/api')),
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
      headers: {
        'Content-Type': 'application/json',
        'X-Requested-With': 'XMLHttpRequest'
      },
    );

    _dio = Dio(options);
    
    // Configura o interceptor de refresh (DEVE VIR ANTES DOS OUTROS)
    _refreshInterceptor = RefreshInterceptor(_dio, _tokenService);
    
    _dio.interceptors.add(_refreshInterceptor);
    _dio.interceptors.add(LogInterceptor(
      request: true,
      requestBody: true,
      responseBody: true,
      responseHeader: false,
    ));
    print('🌐 [ApiClient] Configurado com RefreshInterceptor');
  }
  
  Future<Response> get(String path, {bool requiresAuth = true, Map<String, dynamic>? queryParameters}) async {
    print('🌐 [API] GET $path - requiresAuth: $requiresAuth - query: $queryParameters');
    return _dio.get(
      path, 
      queryParameters: queryParameters,
      options: Options(extra: {'requiresAuth': requiresAuth}),
    );
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
