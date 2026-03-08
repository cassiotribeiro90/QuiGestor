import 'dart:async';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../app/modules/auth/bloc/auth_cubit.dart';
import '../../app/di/dependencies.dart';

class ApiClient {
  late final Dio _dio;

  ApiClient() {
    const String baseUrlEnv = String.fromEnvironment('API_URL');
    
    // Se a variável de ambiente não estiver vazia, usamos ela como const.
    // Caso contrário, usamos a lógica dinâmica, mas sem o 'const' no BaseOptions.
    
    final options = BaseOptions(
      baseUrl: baseUrlEnv.isNotEmpty 
          ? baseUrlEnv 
          : (kIsWeb 
              ? 'http://localhost:8001/api/gestor' 
              : (defaultTargetPlatform == TargetPlatform.android 
                  ? 'http://10.0.2.2:8001/api/gestor' 
                  : 'http://localhost:8001/api/gestor')),
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
      headers: {
        'Content-Type': 'application/json',
        'X-Requested-With': 'XMLHttpRequest'
      }
    );

    _dio = Dio(options);
    
    _dio.interceptors.add(AuthInterceptor());
    _dio.interceptors.add(LogInterceptor(responseBody: true, requestBody: true));
  }
  
  Future<Response> post(String path, {dynamic data}) => 
      _dio.post(path, data: data);
      
  Future<Response> get(String path) => _dio.get(path);
      
  Future<Response> put(String path, {dynamic data}) => 
      _dio.put(path, data: data);
      
  Future<Response> delete(String path) => _dio.delete(path);
}

class AuthInterceptor extends QueuedInterceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    final prefs = getIt<SharedPreferences>();
    final token = prefs.getString('access_token');
    
    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    
    handler.next(options);
  }
  
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    if (err.requestOptions.path.contains('/login')) {
      handler.next(err);
      return;
    }

    if (err.response?.statusCode == 401) {
      final prefs = getIt<SharedPreferences>();
      await prefs.remove('access_token');
      
      try {
        getIt<AuthCubit>().logout();
      } catch (_) {}
    }

    handler.next(err);
  }
}
