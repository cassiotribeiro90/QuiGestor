import 'dart:io';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import '../../../core/services/device_service.dart';
import '../../../../shared/api/api_client.dart';
import '../../../../app/app_config.dart';
import '../models/login_response.dart';

class AuthRepository {
  final ApiClient _apiClient;
  final DeviceService _deviceService;

  AuthRepository(this._apiClient, this._deviceService);

  Future<LoginResponse> login(String email, String password) async {
    try {
      // 🔥 OBTÉM DEVICE ID
      final deviceId = await _deviceService.getDeviceId();
      
      // 🔥 OBTÉM DEVICE TOKEN
      String? deviceToken;
      if (!kIsWeb && !Platform.isWindows) {
        try {
          deviceToken = await FirebaseMessaging.instance.getToken();
          if (kDebugMode) {
            debugPrint('[LOGIN] 📱 Device Token: ${deviceToken?.substring(0, 20)}...');
          }
        } catch (e) {
          if (kDebugMode) {
            debugPrint('[LOGIN] ⚠️ Erro ao obter device token: $e');
          }
          deviceToken = '';
        }
      } else {
        if (kDebugMode) {
          debugPrint('[LOGIN] ⏳ Web/Windows detectado: ignorando FCM Token');
        }
      }
      
      if (kDebugMode) {
        debugPrint('[LOGIN] 📱 Device ID: $deviceId');
      }

      final response = await _apiClient.post(
        AppConfig.LOGIN,
        data: {
          'email': email,
          'senha': password,
          'device_id': deviceId,
          'device_token': deviceToken ?? '',
        },
        requiresAuth: false,
      );

      if (kDebugMode) {
        debugPrint('[LOGIN] 📱 Status: ${response.statusCode}');
        debugPrint('[LOGIN] 📱 Response: ${response.data}');
      }

      if (response.statusCode == 200 && response.data['success'] == true) {
        return LoginResponse.fromJson(response.data);
      }

      throw Exception('Erro ao fazer login: ${response.data['message'] ?? 'Erro desconhecido'}');
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[LOGIN] ❌ Erro: $e');
      }
      rethrow;
    }
  }

  Future<void> logout() async {
    try {
      await _apiClient.post('/gestor/gestor-usuarios/logout');
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[LOGOUT] ❌ Erro: $e');
      }
    }
  }

  Future<Map<String, dynamic>> refreshToken(String token) async {
    try {
      final response = await _apiClient.post(
        AppConfig.REFRESH_TOKEN,
        data: {'refresh_token': token},
        requiresAuth: false,
      );
      return response.data;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[REFRESH] ❌ Erro: $e');
      }
      rethrow;
    }
  }
}
