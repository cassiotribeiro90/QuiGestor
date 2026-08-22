import 'dart:io';
import 'package:dio/dio.dart';
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
      if (!Platform.isWindows) {
        try {
          deviceToken = await FirebaseMessaging.instance.getToken();
          if (kDebugMode) {
            print('[LOGIN] 📱 Device Token: ${deviceToken?.substring(0, 20)}...');
          }
        } catch (e) {
          if (kDebugMode) {
            print('[LOGIN] ⚠️ Erro ao obter device token: $e');
          }
          deviceToken = '';
        }
      } else {
        if (kDebugMode) {
          print('[LOGIN] ⏳ Windows detectado: ignorando FCM Token');
        }
      }
      
      if (kDebugMode) {
        print('[LOGIN] 📱 Device ID: $deviceId');
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
        print('[LOGIN] 📱 Status: ${response.statusCode}');
        print('[LOGIN] 📱 Response: ${response.data}');
      }

      if (response.statusCode == 200 && response.data['success'] == true) {
        return LoginResponse.fromJson(response.data);
      }

      throw Exception('Erro ao fazer login: ${response.data['message'] ?? 'Erro desconhecido'}');
    } catch (e) {
      if (kDebugMode) {
        print('[LOGIN] ❌ Erro: $e');
      }
      rethrow;
    }
  }

  Future<void> logout() async {
    try {
      await _apiClient.post('/gestor/gestor-usuarios/logout');
    } catch (e) {
      if (kDebugMode) {
        print('[LOGOUT] ❌ Erro: $e');
      }
    }
  }
}
