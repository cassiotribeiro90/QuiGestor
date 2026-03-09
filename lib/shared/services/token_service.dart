import 'dart:async';
import 'dart:math';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dio/dio.dart';

class TokenService {
  static const String _accessTokenKey = 'access_token';
  static const String _refreshTokenKey = 'refresh_token';
  static const String _tokenExpiresAtKey = 'token_expires_at';
  
  final SharedPreferences _prefs;
  
  bool _isRefreshing = false;
  final List<Completer<bool>> _refreshCompleters = [];

  TokenService(this._prefs);

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

  /// Tenta renovar o token usando o refresh_token
  Future<bool> refreshToken(Dio dio) async {
    if (_isRefreshing) {
      print('🔄 [TokenService] Já está refrescando, adicionando à fila...');
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

      print('🔄 [TokenService] Chamando endpoint de refresh...');
      
      final tempDio = Dio(BaseOptions(
        baseUrl: dio.options.baseUrl,
        headers: {'Content-Type': 'application/json'},
      ));

      final response = await tempDio.post(
        '/gestor/gestor-usuarios/refresh',
        data: {'refresh_token': refreshTokenValue},
        options: Options(
          extra: {'requiresAuth': false},
        ),
      );

      print('🔄 [TokenService] Resposta do refresh: ${response.statusCode}');
      print('🔄 [TokenService] Dados: ${response.data}');

      if (response.statusCode == 200 && response.data['success'] == true) {
        final data = response.data['data'];
        final newAccessToken = data['access_token'];
        final newRefreshToken = data['refresh_token'];
        final expiresIn = data['expires_in'] ?? 7200;

        await saveTokens(newAccessToken, newRefreshToken, expiresIn: expiresIn);
        
        print('✅ [TokenService] Token renovado com sucesso!');
        
        for (var completer in _refreshCompleters) {
          completer.complete(true);
        }
        _refreshCompleters.clear();
        
        return true;
      } else {
        print('❌ [TokenService] Falha no refresh: ${response.data['message']}');
        await clearTokens();
        
        for (var completer in _refreshCompleters) {
          completer.complete(false);
        }
        _refreshCompleters.clear();
        
        return false;
      }
    } on DioException catch (e) {
      print('❌ [TokenService] DioException no refresh: ${e.response?.statusCode} - ${e.response?.data}');
      await clearTokens();
      
      for (var completer in _refreshCompleters) {
        completer.complete(false);
      }
      _refreshCompleters.clear();
      
      return false;
    } catch (e) {
      print('❌ [TokenService] Erro no refresh: $e');
      await clearTokens();
      
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
