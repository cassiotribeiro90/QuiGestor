import 'dart:async';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../features/auth/bloc/auth_cubit.dart';
import '../../injection.dart';

class ApiClient {
  late final Dio _dio;
  
  ApiClient() {
    _dio = Dio(BaseOptions(
      baseUrl: const String.fromEnvironment(
        'API_URL',
        defaultValue: 'http://localhost:8001/api/gestor',
      ),
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
      headers: {'Content-Type': 'application/json', 'X-Requested-With': 'XMLHttpRequest'}
    ));
    
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
    // Evita loop infinito na rota de login
    if (err.requestOptions.path.contains('/login')) {
      handler.next(err);
      return;
    }

    if (err.response?.statusCode == 401) {
      final prefs = getIt<SharedPreferences>();
      await prefs.remove('access_token');
      await prefs.remove('token_expires_at');
      
      // Logout no Cubit
      getIt<AuthCubit>().logout();
    }

    handler.next(err);
  }
}
