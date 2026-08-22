import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:dio/dio.dart';
import '../../../core/services/fcm_service.dart';
import '../../../core/services/device_service.dart';
import '../../../core/storage/auth_storage.dart';
import '../../../core/config/api_config.dart';
import '../repository/auth_repository.dart';
import '../models/auth_response_model.dart';
import 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  final AuthRepository _repository;
  final AuthStorage _authStorage = AuthStorage();
  final DeviceService _deviceService = DeviceService();
  // ignore: unused_field
  final FcmService _fcmService = FcmService();

  AuthCubit(this._repository) : super(AuthInitial());

  // ==================== LOGIN ====================

  Future<void> login(String email, String senha) async {
    emit(AuthLoading());
    try {
      // 🔥 OBTÉM O FCM TOKEN
      final fcmToken = await FirebaseMessaging.instance.getToken();

      final response = await _repository.login(email, senha, deviceToken: fcmToken);
      final authData = AuthResponseModel.fromJson(response.data);

      await _authStorage.saveTokens(authData.accessToken, authData.refreshToken);
      await _authStorage.saveUserInfo(
        authData.id,
        authData.nome,
        authData.nivel,
      );

      emit(AuthAuthenticated(authData));
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  // ==================== LOGOUT ====================

  Future<void> logout() async {
    try {
      await _repository.logout();
    } catch (_) {}
    finally {
      await _authStorage.clear();
      await _deviceService.clearDeviceId();
      emit(AuthInitial());
    }
  }

  // ==================== REFRESH ====================

  Future<void> refreshToken() async {
    try {
      final refreshToken = await _authStorage.getRefreshToken();
      if (refreshToken == null) return;

      final response = await _repository.refreshToken(refreshToken);
      final data = response.data as Map<String, dynamic>;
      await _authStorage.saveTokens(data['access_token'], data['refresh_token']);
    } catch (e) {
      await logout();
    }
  }

  // ==================== CHECK AUTH ====================

  Future<bool> checkAuth() async {
    final token = await _authStorage.getAccessToken();
    if (token == null) return false;

    try {
      // Verifica se o token é válido
      final dio = Dio();
      await dio.get(
        '${ApiConfig.baseUrl}gestor/gestor-usuarios/check-token',
        options: Options(
          headers: {'Authorization': 'Bearer $token'},
        ),
      );
      return true;
    } catch (e) {
      await logout();
      return false;
    }
  }

  // ==================== GET USER ====================

  Future<Map<String, dynamic>?> getUserInfo() async {
    final id = await _authStorage.getUserId();
    final nome = await _authStorage.getUserNome();
    final nivel = await _authStorage.getUserNivel();

    if (id == null || nome == null || nivel == null) return null;
    return {'id': id, 'nome': nome, 'nivel': nivel};
  }
}
