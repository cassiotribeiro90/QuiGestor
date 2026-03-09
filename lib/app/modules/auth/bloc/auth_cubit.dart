import 'dart:math';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../shared/api/api_client.dart';
import '../../../../shared/services/token_service.dart';
import 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  AuthCubit(this._apiClient, this._prefs, this._tokenService) : super(AuthInitial());

  final ApiClient _apiClient;
  // ignore: unused_field
  final SharedPreferences _prefs;
  final TokenService _tokenService;

  Future<void> login(String email, String senha) async {
    emit(AuthLoading());

    try {
      print('📱 [LOGIN] Tentando login com email: $email');
      
      // 🔥 requiresAuth: false - login NÃO envia token
      final response = await _apiClient.post(
        '/gestor/gestor-usuarios/login', 
        data: {'email': email, 'senha': senha},
        requiresAuth: false,
      );

      print('📱 [LOGIN] Resposta recebida: ${response.statusCode}');
      print('📱 [LOGIN] Dados: ${response.data}');

      final success = response.data['success'] ?? false;

      if (success == true) {
        final data = response.data['data'];
        final String accessToken = data['access_token']?.toString() ?? '';
        
        if (accessToken.isNotEmpty) {
          // Solução para o erro do min(): Garantir tipos int explícitos
          final int tokenLength = accessToken.length;
          final int displayLength = min<int>(20, tokenLength);
          
          print('📱 [LOGIN] Token recebido: ${accessToken.substring(0, displayLength)}...');
          
          // Salva token usando o TokenService
          await _tokenService.saveToken(accessToken);
          
          // Verifica se salvou
          final savedToken = _tokenService.getToken();
          print('📱 [LOGIN] Token recuperado após salvar: ${savedToken != null ? 'OK' : 'FALHOU'}');
          
          emit(AuthSuccess(accessToken: accessToken));
        } else {
          emit(const AuthError(message: 'Token não recebido'));
        }
      } else {
        print('📱 [LOGIN] Falha: ${response.data['message']}');
        emit(AuthError(message: response.data['message'] ?? 'Erro no login'));
      }
    } catch (e, stacktrace) {
      print('📱 [LOGIN] Exceção: $e');
      print('📱 [LOGIN] Stacktrace: $stacktrace');
      emit(const AuthError(message: 'Erro de conexão'));
    }
  }

  Future<void> logout() async {
    await _tokenService.clearToken();
    emit(AuthInitial());
  }

  Future<void> checkAuth() async {
    final String? token = _tokenService.getToken();
    if (token != null && token.isNotEmpty) {
      emit(AuthSuccess(accessToken: token));
    } else {
      emit(AuthInitial());
    }
  }

  Future<void> refreshToken() async {
     // Implementação futura se necessário com o novo sistema
  }
}
