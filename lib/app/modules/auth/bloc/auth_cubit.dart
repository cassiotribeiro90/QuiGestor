import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'auth_state.dart';
import '../repository/auth_repository.dart';
import '../../../../shared/services/token_service.dart';

class AuthCubit extends Cubit<AuthState> {
  final AuthRepository _authRepository;
  final TokenService _tokenService;

  AuthCubit(this._authRepository, this._tokenService)
      : super(const AuthInitial()) {
    debugPrint('🔐 [AUTH] Cubit inicializado');
  }

  Future<void> checkAuthStatus() async {
    debugPrint('🚀 [AUTH] Verificando status...');
    try {
      final hasToken = await _tokenService.hasValidToken();
      if (hasToken) {
        debugPrint('✅ [AUTH] Autenticado com tokens válidos');
        emit(const AuthAuthenticated({}));
      } else {
        debugPrint('❌ [AUTH] Sem tokens');
        emit(const AuthUnauthenticated());
      }
    } catch (e) {
      debugPrint('❌ [AUTH] Erro: $e');
      emit(const AuthUnauthenticated());
    }
  }

  Future<void> login(String email, String password) async {
    debugPrint('🔐 [AUTH] Tentando login...');
    emit(const AuthLoading());
    try {
      final loginResponse = await _authRepository.login(email, password);
      final accessToken = loginResponse.data.accessToken;
      final refreshToken = loginResponse.data.refreshToken;

      if (accessToken.isNotEmpty) {
        await _tokenService.saveTokens(
          accessToken: accessToken,
          refreshToken: refreshToken ?? '',
          tokenType: loginResponse.data.tokenType,
          expiresIn: loginResponse.data.expiresIn,
        );
      }
      debugPrint('✅ [AUTH] Login bem-sucedido');
      emit(AuthAuthenticated({
        'id': loginResponse.data.id,
        'nome': loginResponse.data.nome,
        'email': loginResponse.data.email,
        'nivel': loginResponse.data.nivel,
      }));
    } catch (e) {
      debugPrint('❌ [AUTH] Falha no login: $e');
      emit(AuthError(e.toString()));
    }
  }

  Future<bool> refreshToken() async {
    debugPrint('🔄 [AUTH] Tentando refresh...');
    try {
      final refreshTokenVal = await _tokenService.getRefreshToken();
      if (refreshTokenVal == null) {
        debugPrint('❌ [AUTH] Refresh token não disponível');
        return false;
      }

      final response = await _authRepository.refreshToken(refreshTokenVal);
      if (response['success'] == true) {
        final data = response['data'];
        final newAccessToken = data['access_token'];
        if (newAccessToken != null) {
          await _tokenService.saveAccessToken(newAccessToken);

          // Se o backend retornar um novo refresh_token, salve-o também
          final newRefreshToken = data['refresh_token'];
          if (newRefreshToken != null && newRefreshToken != refreshTokenVal) {
            await _tokenService.saveTokens(
              accessToken: newAccessToken,
              refreshToken: newRefreshToken,
              tokenType: data['token_type'],
              expiresIn: data['expires_in'],
            );
          }

          debugPrint('✅ [AUTH] Refresh bem-sucedido');
          return true;
        }
      }

      debugPrint('❌ [AUTH] Falha no refresh');
      return false;
    } catch (e) {
      debugPrint('❌ [AUTH] Erro no refresh: $e');
      return false;
    }
  }

  Future<void> logout() async {
    debugPrint('🔐 [AUTH] Logout');
    await _tokenService.clearTokens();
    emit(const AuthUnauthenticated());
  }
}
