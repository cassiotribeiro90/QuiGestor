import 'dart:math';
import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../shared/api/api_client.dart';
import 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  final ApiClient _apiClient;

  AuthCubit(this._apiClient) : super(AuthInitial());

  Future<void> login(String email, String senha) async {
    emit(AuthLoading());

    try {
      print('📱 [LOGIN] Tentando login com email: $email');
      
      final response = await _apiClient.post(
        '/gestor/gestor-usuarios/login', 
        data: {'email': email, 'senha': senha},
        requiresAuth: false,
      );

      print('📱 [LOGIN] Status code: ${response.statusCode}');
      print('📱 [LOGIN] Dados: ${response.data}');

      // 🔥 Verifica tanto o status code quanto o campo success
      if (response.statusCode == 200 && response.data['success'] == true) {
        // Login bem-sucedido
        final data = response.data['data'];
        final String accessToken = data['access_token']?.toString() ?? '';
        final String? refreshToken = data['refresh_token']?.toString();
        final int expiresIn = data['expires_in'] ?? 7200;
        
        if (accessToken.isNotEmpty) {
          final int tokenLength = accessToken.length;
          final int displayLength = min<int>(20, tokenLength);
          
          print('📱 [LOGIN] Token recebido: ${accessToken.substring(0, displayLength)}...');
          
          // Salva tokens usando o TokenService via ApiClient
          await _apiClient.tokenService.saveTokens(
            accessToken, 
            refreshToken, 
            expiresIn: expiresIn
          );
          
          // Salva a base URL para o refresh token
          await _apiClient.tokenService.saveBaseUrl(_apiClient.dio.options.baseUrl);
          
          // Verifica se salvou
          final savedToken = _apiClient.tokenService.getAccessToken();
          print('📱 [LOGIN] Token recuperado após salvar: ${savedToken != null ? 'OK' : 'FALHOU'}');
          
          emit(AuthSuccess(accessToken: accessToken));
        } else {
          print('📱 [LOGIN] Erro: Token não recebido');
          emit(const AuthError(message: 'Token não recebido'));
        }
      } 
      // 🔥 Se for 401 ou success = false, trata como erro de credenciais
      else if (response.statusCode == 401 || response.data['success'] == false) {
        final message = response.data['message'] ?? 'Email ou senha inválidos';
        print('📱 [LOGIN] Falha: $message');
        emit(AuthError(message: message));
      } 
      // Outros erros
      else {
        final message = response.data['message'] ?? 'Erro no login';
        print('📱 [LOGIN] Erro inesperado no status code: ${response.statusCode} - $message');
        emit(AuthError(message: message));
      }
      
    } on DioException catch (e) {
      // 🔥 Se mesmo assim cair em exceção, trata aqui
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

  Future<void> checkAuth() async {
    final String? token = _apiClient.tokenService.getAccessToken();
    if (token != null && token.isNotEmpty) {
      if (_apiClient.tokenService.isTokenExpired()) {
        await _attemptRefresh();
      } else {
        emit(AuthSuccess(accessToken: token));
      }
    } else {
      emit(AuthInitial());
    }
  }

  Future<void> _attemptRefresh() async {
    final refreshToken = _apiClient.tokenService.getRefreshToken();
    
    if (refreshToken == null || refreshToken.isEmpty) {
      emit(AuthInitial());
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
          expiresIn: expiresIn
        );
        
        emit(AuthSuccess(accessToken: newAccessToken));
      } else {
        emit(AuthInitial());
      }
    } catch (e) {
      emit(AuthInitial());
    }
  }
}
