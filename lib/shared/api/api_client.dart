// lib/shared/api/api_client.dart

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../../app/core/constants/app_constants.dart'; // 🔥 IMPORT
import '../services/token_service.dart';
import 'refresh_interceptor.dart';
import '../../app/routes/app_router.dart';

class ApiClient {
  // 🔥 Singleton manual
  static final ApiClient _instance = ApiClient._internal();
  factory ApiClient() => _instance;

  late final TokenService _tokenService;
  late final Dio _dio;

  ApiClient._internal() {
    _tokenService = TokenService();

    // 🔥 USAR AppConstants.apiBaseUrl
    final options = BaseOptions(
        baseUrl: AppConstants.apiBaseUrl,
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 10),
        headers: {
          'Content-Type': 'application/json',
          'X-Requested-With': 'XMLHttpRequest'
        }
    );

    _dio = Dio(options);

    _dio.interceptors.add(RefreshInterceptor(
      dio: _dio,
      tokenService: _tokenService,
      navigatorKey: rootNavigatorKey,
    ));

    if (kDebugMode) {
      _dio.interceptors.add(LogInterceptor(
        responseBody: true,
        requestBody: true,
        requestHeader: true,
      ));
    }
  }

  Future<Response> post(String path, {dynamic data, Map<String, dynamic>? queryParameters, bool requiresAuth = true}) =>
      _dio.post(path, data: data, queryParameters: queryParameters, options: Options(extra: {'requiresAuth': requiresAuth}));

  Future<Response> get(
      String path, {
        Map<String, dynamic>? queryParameters,
        bool requiresAuth = true
      }) => _dio.get(
      path,
      queryParameters: queryParameters,
      options: Options(extra: {'requiresAuth': requiresAuth})
  );

  Future<Response> put(String path, {dynamic data, Map<String, dynamic>? queryParameters, bool requiresAuth = true}) =>
      _dio.put(path, data: data, queryParameters: queryParameters, options: Options(extra: {'requiresAuth': requiresAuth}));

  Future<Response> delete(String path, {Map<String, dynamic>? queryParameters, bool requiresAuth = true}) =>
      _dio.delete(path, queryParameters: queryParameters, options: Options(extra: {'requiresAuth': requiresAuth}));

  // 🔥 MÉTODOS PARA IMAGENS (centralizados)
  String getImageUrl(String? path) {
    if (path == null || path.isEmpty) return '';

    if (path.startsWith('http://') || path.startsWith('https://')) {
      return path;
    }

    final cleanPath = path.startsWith('/') ? path.substring(1) : path;
    return '${AppConstants.imageBaseUrl}/$cleanPath';
  }

  String? extractImagePath(String? url) {
    if (url == null || url.isEmpty) return null;

    if (!url.startsWith('http://') && !url.startsWith('https://')) {
      return url.startsWith('/') ? url.substring(1) : url;
    }

    try {
      final uri = Uri.parse(url);
      final path = uri.path;
      return path.startsWith('/') ? path.substring(1) : path;
    } catch (e) {
      return url;
    }
  }

  Dio get dio => _dio;
  TokenService get tokenService => _tokenService;
}