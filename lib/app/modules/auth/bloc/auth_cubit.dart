import 'dart:math';
import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../shared/api/api_client.dart';
import '../../../app_config.dart';
import 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  final ApiClient _apiClient;

  AuthCubit(this._apiClient) : super(AuthInitial());

  Future<void> login(String email, String senha) async {
    emit(AuthLoading());

    try {
      print('📱 [LOGIN] Tentando login com email: $email');

      final response = await _apiClient.post(
        AppConfig.LOGIN,
        data: {'email': email, 'senha': senha},
        requiresAuth: false,
      );

      print('📱 [LOGIN] Status code: ${response.statusCode}');
      print('📱 [LOGIN] Dados: ${response.data}');

      if (response.statusCode == 200 && response.data['success'] == true) {
        final data = response.data['data'];
        final String accessToken = data['access_token']?.toString() ?? '';
        final String? refreshToken = data['refresh_token']?.toString();
        final int expiresIn = data['expires_in'] ?? 7200;

        if (accessToken.isNotEmpty) {
          final int tokenLength = accessToken.length;
          final int displayLength = min<int>(20, tokenLength);

          print('📱 [LOGIN] Token recebido: ${accessToken.substring(0, displayLength)}...');

          await _apiClient.tokenService.saveTokens(
            accessToken,
            refreshToken,
            expiresIn: expiresIn,
          );

          await _apiClient.tokenService.saveBaseUrl(_apiClient.dio.options.baseUrl);

          final savedToken = _apiClient.tokenService.getAccessToken();
          print('📱 [LOGIN] Token recuperado após salvar: ${savedToken != null ? 'OK' : 'FALHOU'}');

          emit(AuthSuccess(accessToken: accessToken));
        } else {
          print('📱 [LOGIN] Erro: Token não recebido');
          emit(const AuthError(message: 'Token não recebido'));
        }
      } else if (response.statusCode == 401 || response.data['success'] == false) {
        final message = response.data['message'] ?? 'Email ou senha inválidos';
        print('📱 [LOGIN] Falha: $message');
        emit(AuthError(message: message));
      } else {
        final message = response.data['message'] ?? 'Erro no login';
        print('📱 [LOGIN] Erro inesperado no status code: ${response.statusCode} - $message');
        emit(AuthError(message: message));
      }
    } on DioException catch (e) {
      print('📱 [LOGIN] DioException: ${e.response?.statusCode} - ${e.response?.data}');

      if (e.response?.statusCode == 401) {
        final message = e.response?.data['message'] ?? 'Email ou senha inválidos';
        emit(AuthError(message: message));
      } else {
        emit(const AuthError(message: 'Erro de conexão'));
      }
    } catch (e, stacktrace) {
      print('📱 [LOGIN] Exceção: $e');
      print('📱 [LOGIN] Stacktrace: $stacktrace');
      emit(const AuthError(message: 'Erro inesperado'));
    }
  }

  Future<void> logout() async {
    print('📱 [LOGOUT] Iniciando logout...');
    await _apiClient.tokenService.clearTokens();
    emit(AuthInitial());
  }

  // ✅ CORRIGIDO: com logs e tratamento completo
  Future<void> checkAuth() async {
    print('🔐 [CHECK_AUTH] Iniciando verificação...');

    try {
      final String? token = _apiClient.tokenService.getAccessToken();
      print('🔐 [CHECK_AUTH] Token: ${token != null ? 'ENCONTRADO (${token.substring(0, min(20, token.length))}...)' : 'NÃO ENCONTRADO'}');

      if (token != null && token.isNotEmpty) {
        if (_apiClient.tokenService.isTokenExpired()) {
          print('🔐 [CHECK_AUTH] Token expirado → tentando refresh');
          await _attemptRefresh();
        } else {
          print('🔐 [CHECK_AUTH] Token válido → AuthSuccess');
          emit(AuthSuccess(accessToken: token));
        }
      } else {
        print('🔐 [CHECK_AUTH] Sem token → AuthUnauthenticated');
        emit(AuthUnauthenticated());
      }
    } catch (e) {
      print('🔐 [CHECK_AUTH] Erro: $e');
      emit(AuthUnauthenticated());
    }
  }

  Future<void> _attemptRefresh() async {
    print('🔄 [REFRESH] Iniciando refresh...');

    final refreshToken = _apiClient.tokenService.getRefreshToken();
    print('🔄 [REFRESH] Refresh token: ${refreshToken != null ? 'ENCONTRADO' : 'NÃO ENCONTRADO'}');

    if (refreshToken == null || refreshToken.isEmpty) {
      print('🔄 [REFRESH] Sem refresh → limpar e deslogar');
      await _apiClient.tokenService.clearTokens();
      emit(AuthUnauthenticated());
      return;
    }

    try {
      print('🔄 [REFRESH] Chamando API...');
      final response = await _apiClient.post(
        AppConfig.REFRESH_TOKEN,
        data: {'refresh_token': refreshToken},
        requiresAuth: false,
      ).timeout(const Duration(seconds: 10));

      print('🔄 [REFRESH] Status: ${response.statusCode}');

      if (response.statusCode == 200 && response.data['success'] == true) {
        final data = response.data['data'];
        final newAccessToken = data['access_token']?.toString() ?? '';
        final newRefreshToken = data['refresh_token']?.toString();
        final expiresIn = data['expires_in'] ?? 7200;

        if (newAccessToken.isNotEmpty) {
          print('🔄 [REFRESH] Novo token recebido');
          await _apiClient.tokenService.saveTokens(
            newAccessToken,
            newRefreshToken,
            expiresIn: expiresIn,
          );
          emit(AuthSuccess(accessToken: newAccessToken));
        } else {
          print('🔄 [REFRESH] Token vazio → deslogar');
          await _apiClient.tokenService.clearTokens();
          emit(AuthUnauthenticated());
        }
      } else {
        print('🔄 [REFRESH] Falha na API → deslogar');
        await _apiClient.tokenService.clearTokens();
        emit(AuthUnauthenticated());
      }
    } catch (e) {
      print('🔄 [REFRESH] Erro: $e → deslogar');
      await _apiClient.tokenService.clearTokens();
      emit(AuthUnauthenticated());
    }
  }
}