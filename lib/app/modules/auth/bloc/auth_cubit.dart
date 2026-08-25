import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/foundation.dart';
import '../../../../shared/api/api_client.dart';
import '../../../core/services/fcm_service.dart';
import '../repository/auth_repository.dart';
import 'auth_state.dart';
import 'dart:math';

class AuthCubit extends Cubit<AuthState> {
  final AuthRepository _authRepository;
  final ApiClient _apiClient;

  AuthCubit(this._authRepository, this._apiClient) : super(AuthInitial());

  Future<void> login(String email, String senha) async {
    emit(AuthLoading());

    try {
      if (kDebugMode) {
        debugPrint('📱 [LOGIN] Tentando login com email: $email');
      }

      final response = await _authRepository.login(email, senha);
      
      if (response.success) {
        final data = response.data;
        
        if (data.accessToken.isNotEmpty) {
          if (kDebugMode) {
            debugPrint('📱 [LOGIN] Token recebido: ${data.accessToken.substring(0, min(20, data.accessToken.length))}...');
          }

          await _apiClient.tokenService.saveTokens(
            data.accessToken,
            data.refreshToken,
            expiresIn: data.expiresIn,
          );

          await _apiClient.tokenService.saveBaseUrl(_apiClient.dio.options.baseUrl);

          // 🔥 ENVIA O TOKEN FCM PARA O BACKEND
          try {
            await FcmService().sendTokenToBackend(data.accessToken);
            if (kDebugMode) {
              debugPrint('[LOGIN] 📱 Token FCM enviado ao backend');
            }
          } catch (e) {
            if (kDebugMode) {
              debugPrint('[LOGIN] ⚠️ Erro ao enviar token FCM: $e');
            }
          }

          emit(AuthSuccess(accessToken: data.accessToken));
        } else {
          emit(const AuthError(message: 'Token não recebido'));
        }
      } else {
        emit(AuthError(message: response.message));
      }
    } on DioException catch (e) {
      final message = e.response?.data['message'] ?? 'Erro de conexão';
      emit(AuthError(message: message));
    } catch (e) {
      emit(const AuthError(message: 'Erro inesperado'));
    }
  }

  Future<void> logout() async {
    if (kDebugMode) {
      debugPrint('📱 [LOGOUT] Iniciando logout...');
    }
    
    try {
      await _authRepository.logout();
    } catch (_) {}
    
    // 🔥 LIMPA DEVICE ID (Opcional, dependendo do roteiro)
    // await DeviceService().clearDeviceId();
    
    await _apiClient.tokenService.clearTokens();
    emit(AuthInitial());
  }

  Future<void> checkAuth() async {
    try {
      final String? token = _apiClient.tokenService.getAccessToken();
      if (token != null && token.isNotEmpty) {
        if (_apiClient.tokenService.isTokenExpired()) {
          await _attemptRefresh();
        } else {
          emit(AuthSuccess(accessToken: token));
        }
      } else {
        emit(AuthUnauthenticated());
      }
    } catch (e) {
      emit(AuthUnauthenticated());
    }
  }

  Future<void> _attemptRefresh() async {
    final refreshToken = _apiClient.tokenService.getRefreshToken();
    if (refreshToken == null || refreshToken.isEmpty) {
      await _apiClient.tokenService.clearTokens();
      emit(AuthUnauthenticated());
      return;
    }

    try {
      final response = await _apiClient.post(
        '/gestor/gestor-usuarios/refresh-token',
        data: {'refresh_token': refreshToken},
        requiresAuth: false,
      );

      if (response.statusCode == 200 && response.data['success'] == true) {
        final data = response.data['data'];
        final newAccessToken = data['access_token']?.toString() ?? '';
        final newRefreshToken = data['refresh_token']?.toString();
        final expiresIn = data['expires_in'] ?? 7200;

        await _apiClient.tokenService.saveTokens(
          newAccessToken,
          newRefreshToken,
          expiresIn: expiresIn,
        );
        emit(AuthSuccess(accessToken: newAccessToken));
      } else {
        await _apiClient.tokenService.clearTokens();
        emit(AuthUnauthenticated());
      }
    } catch (e) {
      await _apiClient.tokenService.clearTokens();
      emit(AuthUnauthenticated());
    }
  }
}
