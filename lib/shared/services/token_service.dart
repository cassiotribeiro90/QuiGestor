import 'dart:math';
import 'package:shared_preferences/shared_preferences.dart';

class TokenService {
  static const String _accessTokenKey = 'access_token';
  
  final SharedPreferences _prefs;

  TokenService(this._prefs) {
    _logTokenStatus('TokenService inicializado');
  }

  void _logTokenStatus(String mensagem) {
    final token = _prefs.getString(_accessTokenKey);
    if (token != null) {
      final int length = token.length;
      final int subEnd = min(20, length);
      print('🔑 [TokenService] $mensagem - Token existe: ${token.substring(0, subEnd)}...');
    } else {
      print('🔑 [TokenService] $mensagem - Token NÃO existe');
    }
  }

  Future<void> saveToken(String token) async {
    final cleanToken = token.trim().replaceAll('"', ''); // Limpeza extra
    final int length = cleanToken.length;
    final int subEnd = min(20, length);
    
    print('🔑 [TokenService] Salvando token (len: $length): ${cleanToken.substring(0, subEnd)}...');
    await _prefs.setString(_accessTokenKey, cleanToken);
    _logTokenStatus('Após salvar');
  }

  Future<void> clearToken() async {
    print('🔑 [TokenService] Limpando token');
    await _prefs.remove(_accessTokenKey);
    _logTokenStatus('Após limpar');
  }

  String? getToken() {
    final token = _prefs.getString(_accessTokenKey);
    return token;
  }

  Map<String, String> getAuthHeader() {
    final token = getToken();
    if (token != null && token.isNotEmpty) {
      return {'Authorization': 'Bearer $token'};
    }
    return {};
  }

  bool hasToken() {
    final token = getToken();
    return token != null && token.isNotEmpty;
  }
}
