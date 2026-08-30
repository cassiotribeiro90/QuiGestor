import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TokenService {
  static const String _accessTokenKey = 'access_token';
  static const String _refreshTokenKey = 'refresh_token';
  static const String _tokenTypeKey = 'token_type';
  static const String _expiresInKey = 'expires_in';

  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  SharedPreferences? _prefs;

  Future<void> _ensureInitialized() async {
    if (_prefs == null) {
      debugPrint('🔐 [TOKEN] Inicializando SharedPreferences...');
      _prefs = await SharedPreferences.getInstance();
    }
  }

  // ============================================================
  // 🔥 1. SALVAR TOKENS
  // ============================================================
  Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
    String? tokenType,
    int? expiresIn,
  }) async {
    debugPrint('🔐 [TOKEN] Salvando tokens...');
    debugPrint('   Access Token: ${accessToken.substring(0, 10)}...');
    debugPrint('   Refresh Token: ${refreshToken.substring(0, 10)}...');

    if (kIsWeb) {
      await _ensureInitialized();
      await _prefs?.setString(_accessTokenKey, accessToken);
      await _prefs?.setString(_refreshTokenKey, refreshToken);
      if (tokenType != null) await _prefs?.setString(_tokenTypeKey, tokenType);
      if (expiresIn != null) await _prefs?.setInt(_expiresInKey, expiresIn);
    } else {
      await _storage.write(key: _accessTokenKey, value: accessToken);
      await _storage.write(key: _refreshTokenKey, value: refreshToken);
      if (tokenType != null) await _storage.write(key: _tokenTypeKey, value: tokenType);
      if (expiresIn != null) await _storage.write(key: _expiresInKey, value: expiresIn.toString());
    }

    // Verificação
    final savedRefresh = await getRefreshToken();
    debugPrint('✅ [TOKEN] Tokens salvos. Refresh token verificado: ${savedRefresh != null ? 'OK' : 'FALHOU'}');
  }

  // ============================================================
  // 🔥 2. OBTER TOKENS
  // ============================================================
  Future<String?> getAccessToken() async {
    if (kIsWeb) {
      await _ensureInitialized();
      return _prefs?.getString(_accessTokenKey);
    }
    return _storage.read(key: _accessTokenKey);
  }

  Future<String?> getRefreshToken() async {
    if (kIsWeb) {
      await _ensureInitialized();
      return _prefs?.getString(_refreshTokenKey);
    }
    return _storage.read(key: _refreshTokenKey);
  }

  // 🔥 Metodo assíncrono que retorna o header com token
  Future<Map<String, String>> getAuthHeader() async {
    final token = await getAccessToken();
    if (token != null && token.isNotEmpty) {
      debugPrint('🔐 [TOKEN] Header com token obtido: ${token.substring(0, 20)}...');
      return {'Authorization': 'Bearer $token'};
    }
    debugPrint('⚠️ [TOKEN] Nenhum token disponível para header');
    return {};
  }

  // ============================================================
  // 🔥 3. VERIFICAR SE HÁ TOKEN VÁLIDO
  // ============================================================
  Future<bool> hasValidToken() async {
    final access = await getAccessToken();
    final refresh = await getRefreshToken();
    debugPrint('🔐 [TOKEN] Verificando tokens: access=${access != null}, refresh=${refresh != null}');
    return access != null && refresh != null;
  }

  // ============================================================
  // 🔥 4. SALVAR APENAS O ACCESS TOKEN (APÓS REFRESH)
  // ============================================================
  Future<void> saveAccessToken(String accessToken) async {
    debugPrint('🔐 [TOKEN] Atualizando access token');
    if (kIsWeb) {
      await _ensureInitialized();
      await _prefs?.setString(_accessTokenKey, accessToken);
    } else {
      await _storage.write(key: _accessTokenKey, value: accessToken);
    }
    debugPrint('✅ [TOKEN] Access token atualizado');
  }

  // ============================================================
  // 🔥 6. LIMPAR TOKENS (LOGOUT)
  // ============================================================
  Future<void> clearTokens() async {
    debugPrint('🔐 [TOKEN] Limpando tokens');
    if (kIsWeb) {
      await _ensureInitialized();
      await _prefs?.remove(_accessTokenKey);
      await _prefs?.remove(_refreshTokenKey);
      await _prefs?.remove(_tokenTypeKey);
      await _prefs?.remove(_expiresInKey);
    } else {
      await _storage.delete(key: _accessTokenKey);
      await _storage.delete(key: _refreshTokenKey);
      await _storage.delete(key: _tokenTypeKey);
      await _storage.delete(key: _expiresInKey);
    }
    debugPrint('✅ [TOKEN] Tokens removidos');
  }
}
