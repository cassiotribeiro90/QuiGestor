import 'dart:async';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../shared/api/api_client.dart';

part 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  AuthCubit(this._apiClient, this._prefs) : super(AuthInitial());

  final ApiClient _apiClient;
  final SharedPreferences _prefs;

  Future<void> login(String email, String senha) async {
    emit(AuthLoading());

    try {
      print('📤 Enviando login: $email');

      final response = await _apiClient.post('/gestor-usuarios/login', data: {
        'email': email,
        'senha': senha,
      });

      print('📥 Resposta: ${response.data}');

      final success = response.data['success'] ?? false;

      if (success == true) {
        print('✅ Login OK! Indo para Home');
        emit(const AuthSuccess(token: ''));
      } else {
        final message = response.data['message'] ?? 'Erro no login';
        print('❌ Erro: $message');
        emit(AuthError(message: message));
      }

    } catch (e) {
      print('❌ Exceção: $e');
      emit(const AuthError(message: 'Erro de conexão'));
    }
  }

  Future<void> logout() async {
    await _prefs.remove('access_token');
    emit(AuthInitial());
  }

  Future<void> checkAuth() async {
    emit(AuthInitial());
  }
}
