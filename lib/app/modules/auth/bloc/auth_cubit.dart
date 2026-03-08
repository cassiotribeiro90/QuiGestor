import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../shared/api/api_client.dart';
import 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  AuthCubit(this._apiClient, this._prefs) : super(AuthInitial());

  final ApiClient _apiClient;
  final SharedPreferences _prefs;

  Future<void> login(String email, String senha) async {
    emit(AuthLoading());

    try {
      final response = await _apiClient.post('/gestor-usuarios/login', data: {
        'email': email,
        'senha': senha,
      });

      final success = response.data['success'] ?? false;

      if (success == true) {
        final token = response.data['token'] ?? '';
        await _prefs.setString('access_token', token);
        emit(AuthSuccess(token: token));
      } else {
        final message = response.data['message'] ?? 'Erro no login';
        emit(AuthError(message: message));
      }
    } catch (e) {
      emit(const AuthError(message: 'Erro de conexão'));
    }
  }

  Future<void> logout() async {
    await _prefs.remove('access_token');
    emit(AuthInitial());
  }

  Future<void> checkAuth() async {
    final token = _prefs.getString('access_token');
    if (token != null && token.isNotEmpty) {
      emit(AuthSuccess(token: token));
    } else {
      emit(AuthInitial());
    }
  }
}
