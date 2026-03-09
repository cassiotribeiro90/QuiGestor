import 'dart:math';
import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../shared/api/api_client.dart';
import '../../../../shared/services/token_service.dart';
import 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  final ApiClient _apiClient;
  // ignore: unused_field
  final SharedPreferences _prefs;
  final TokenService _tokenService;

  AuthCubit(this._apiClient, this._prefs, this._tokenService) : super(AuthInitial());

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
          
          // Salva tokens usando o TokenService
          await _tokenService.saveTokens(
            accessToken, 
            refreshToken, 
            expiresIn: expiresIn
          );
          
          // Verifica se salvou
          final savedToken = _tokenService.getAccessToken();
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
    await _tokenService.clearTokens();
    emit(AuthInitial());
  }

  Future<void> checkAuth() async {
    final String? token = _tokenService.getAccessToken();
    if (token != null && token.isNotEmpty) {
      emit(AuthSuccess(accessToken: token));
    } else {
      emit(AuthInitial());
    }
  }
}
