import 'package:dio/dio.dart';
import '../../../core/services/device_service.dart';

class AuthRepository {
  final Dio _dio;
  final DeviceService _deviceService = DeviceService();

  AuthRepository(this._dio);

  // ==================== LOGIN ====================

  /// 🔥 LOGIN COM EMAIL/SENHA
  Future<Response> login(String email, String senha, {String? deviceToken}) async {
    final deviceId = await _deviceService.getDeviceId();
    final data = {
      'email': email,
      'senha': senha,
      'device_id': deviceId,
    };
    if (deviceToken != null) {
      data['device_token'] = deviceToken;
    }
    return await _dio.post(
      'gestor/gestor-usuarios/login',
      data: data,
    );
  }

  // ==================== LOGOUT ====================

  /// 🔥 LOGOUT
  Future<void> logout() async {
    await _dio.post('gestor/gestor-usuarios/logout');
  }

  // ==================== REFRESH TOKEN ====================

  /// 🔥 REFRESH TOKEN
  Future<Response> refreshToken(String refreshToken) async {
    return await _dio.post(
      'gestor/gestor-usuarios/refresh-token',
      data: {'refresh_token': refreshToken},
    );
  }

  // ==================== DEVICE TOKEN ====================

  /// 🔥 ENVIA DEVICE TOKEN
  Future<void> sendDeviceToken(String deviceToken) async {
    final deviceId = await _deviceService.getDeviceId();
    await _dio.post(
      'gestor/gestor-usuarios/device-token',
      data: {
        'device_token': deviceToken,
        'device_id': deviceId,
      },
    );
  }
}
