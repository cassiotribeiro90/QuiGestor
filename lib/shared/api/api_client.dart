import 'dart:async';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../features/auth/bloc/auth_cubit.dart';
import '../../injection.dart';
import '../../core/utils/event_bus.dart';

class ApiClient {
  late final Dio _dio;
  
  ApiClient() {
    _dio = Dio(BaseOptions(
      baseUrl: const String.fromEnvironment(
        'API_URL',
        defaultValue: 'http://localhost/api',
      ),
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
      headers: {'Content-Type': 'application/json'},
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

    // Missão 1: Interceptor Robusto
    if (err.response?.statusCode == 401) {
      final prefs = getIt<SharedPreferences>();
      await prefs.remove('access_token');
      await prefs.remove('token_expires_at');
      
      // Notificar expiração via EventBus
      getIt<EventBus>().fire(SessionExpiredEvent(
        message: 'Sua sessão expirou. Por favor, faça login novamente.'
      ));
      
      // Logout no Cubit
      getIt<AuthCubit>().logout();
    }

    handler.next(err);
  }
}
