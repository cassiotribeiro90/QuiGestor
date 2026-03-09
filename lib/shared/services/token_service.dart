import 'dart:async';
import 'dart:math';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dio/dio.dart';

class TokenService {
  static const String _accessTokenKey = 'access_token';
  static const String _refreshTokenKey = 'refresh_token';
  static const String _tokenExpiresAtKey = 'token_expires_at';
  
  final SharedPreferences _prefs;
  
  // Controla se já está tentando refresh para evitar múltiplas chamadas
  bool _isRefreshing = false;
  // Fila de requisições que esperam o refresh
  final List<Completer<bool>> _refreshCompleters = [];

  TokenService(this._prefs);

  // ========== MÉTODOS BÁSICOS ==========

  Future<void> saveTokens(String accessToken, String? refreshToken, {int expiresIn = 7200}) async {
    final cleanAccessToken = accessToken.trim().replaceAll('"', '');
    await _prefs.setString(_accessTokenKey, cleanAccessToken);
    
    if (refreshToken != null) {
      final cleanRefreshToken = refreshToken.trim().replaceAll('"', '');
      await _prefs.setString(_refreshTokenKey, cleanRefreshToken);
    }
    
    final expiresAt = DateTime.now().add(Duration(seconds: expiresIn)).millisecondsSinceEpoch;
    await _prefs.setInt(_tokenExpiresAtKey, expiresAt);
    
    print('🔑 [TokenService] Tokens salvos - Access: ${cleanAccessToken.substring(0, min(20, cleanAccessToken.length))}...');
  }

  Future<void> clearTokens() async {
    await _prefs.remove(_accessTokenKey);
    await _prefs.remove(_refreshTokenKey);
    await _prefs.remove(_tokenExpiresAtKey);
    print('🔑 [TokenService] Tokens removidos');
  }

  String? getAccessToken() {
    return _prefs.getString(_accessTokenKey);
  }

  String? getRefreshToken() {
    return _prefs.getString(_refreshTokenKey);
  }

  // Mantido para compatibilidade temporária
  String? getToken() => getAccessToken();
  Future<void> saveToken(String token) => saveTokens(token, null);
  Future<void> clearToken() => clearTokens();

  bool hasToken() {
    return getAccessToken() != null;
  }

  bool isTokenValid() {
    final token = getAccessToken();
    if (token == null) return false;
    
    final expiresAt = _prefs.getInt(_tokenExpiresAtKey);
    if (expiresAt == null) return true;
    
    final now = DateTime.now().millisecondsSinceEpoch;
    return now < expiresAt;
  }

  Map<String, String> getAuthHeader() {
    final token = getAccessToken();
    if (token != null && token.isNotEmpty) {
      return {'Authorization': 'Bearer $token'};
    }
    return {};
  }

  // ========== MÉTODO DE REFRESH ==========

  /// Tenta renovar o token usando o refresh_token
  Future<bool> refreshToken(Dio dio) async {
    // Se já estiver refrescando, aguarda na fila
    if (_isRefreshing) {
      print('🔄 [TokenService] Já está refrescando, aguardando...');
      final completer = Completer<bool>();
      _refreshCompleters.add(completer);
      return completer.future;
    }

    _isRefreshing = true;
    print('🔄 [TokenService] Iniciando refresh token...');

    try {
      final refreshTokenValue = getRefreshToken();
      if (refreshTokenValue == null || refreshTokenValue.isEmpty) {
        print('❌ [TokenService] Sem refresh token disponível');
        await clearTokens();
        return false;
      }

      print('🔄 [TokenService] Chamando endpoint de refresh com token: ${refreshTokenValue.substring(0, min(20, refreshTokenValue.length))}...');
      
      // Cria um Dio temporário sem interceptores para evitar loop
      final tempDio = Dio(BaseOptions(
        baseUrl: dio.options.baseUrl,
        headers: {'Content-Type': 'application/json'},
      ));

      final response = await tempDio.post(
        '/gestor/gestor-usuarios/refresh',
        data: {'refresh_token': refreshTokenValue},
      );

      print('🔄 [TokenService] Resposta do refresh: ${response.statusCode}');
      print('🔄 [TokenService] Dados: ${response.data}');

      if (response.statusCode == 200 && response.data['success'] == true) {
        final data = response.data['data'];
        final newAccessToken = data['access_token'];
        final newRefreshToken = data['refresh_token'];
        final expiresIn = data['expires_in'] ?? 7200;

        // Salva os novos tokens
        await saveTokens(newAccessToken, newRefreshToken, expiresIn: expiresIn);
        
        print('✅ [TokenService] Token renovado com sucesso!');
        
        // Completa todas as requisições na fila com sucesso
        for (var completer in _refreshCompleters) {
          completer.complete(true);
        }
        _refreshCompleters.clear();
        
        return true;
      } else {
        print('❌ [TokenService] Falha no refresh: ${response.data['message']}');
        await clearTokens();
        
        // Completa todas com falha
        for (var completer in _refreshCompleters) {
          completer.complete(false);
        }
        _refreshCompleters.clear();
        
        return false;
      }
    } catch (e) {
      print('❌ [TokenService] Erro no refresh: $e');
      await clearTokens();
      
      // Completa todas com falha
      for (var completer in _refreshCompleters) {
        completer.complete(false);
      }
      _refreshCompleters.clear();
      
      return false;
    } finally {
      _isRefreshing = false;
    }
  }
}
