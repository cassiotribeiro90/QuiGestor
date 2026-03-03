import 'dart:async';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../shared/api/api_client.dart';
import '../../../core/utils/event_bus.dart';

part 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  AuthCubit(this._apiClient, this._prefs, this._eventBus) : super(AuthInitial());

  final ApiClient _apiClient;
  final SharedPreferences _prefs;
  final EventBus _eventBus;
  Timer? _expirationTimer;

  Future<void> login(String email, String senha) async {
    emit(AuthLoading());
    
    try {
      final response = await _apiClient.post('/auth-lojista/login', data: {
        'email': email,
        'senha': senha,
      });
      
      final token = response.data['token_acesso'];
      await _prefs.setString('access_token', token);
      
      // Salva timestamp de expiração (Missão 2)
      final expiresIn = 60; // 1 minuto para testes
      final expiresAt = DateTime.now().add(Duration(seconds: expiresIn)).millisecondsSinceEpoch;
      await _prefs.setInt('token_expires_at', expiresAt);
      
      _startExpirationTimer(expiresIn);
      
      emit(AuthSuccess(token: token));
    } catch (e) {
      emit(AuthError(message: e.toString()));
    }
  }

  Future<void> logout() async {
    _expirationTimer?.cancel();
    await _prefs.remove('access_token');
    await _prefs.remove('token_expires_at');
    emit(AuthInitial());
  }

  Future<void> checkAuth() async {
    final token = _prefs.getString('access_token');
    final expiresAt = _prefs.getInt('token_expires_at');

    if (token != null && token.isNotEmpty) {
      if (expiresAt != null) {
        final remaining = expiresAt - DateTime.now().millisecondsSinceEpoch;
        if (remaining > 0) {
          _startExpirationTimer(remaining ~/ 1000);
          emit(AuthSuccess(token: token));
        } else {
          await logout();
        }
      } else {
        emit(AuthSuccess(token: token));
      }
    } else {
      emit(AuthInitial());
    }
  }

  void _startExpirationTimer(int seconds) {
    _expirationTimer?.cancel();
    _expirationTimer = Timer(Duration(seconds: seconds), () {
      _eventBus.fire(SessionExpiredEvent(message: 'Sua sessão expirou por inatividade.'));
      logout();
    });
  }

  @override
  Future<void> close() {
    _expirationTimer?.cancel();
    return super.close();
  }
}
