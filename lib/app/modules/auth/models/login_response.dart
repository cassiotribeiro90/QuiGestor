class LoginResponse {
  final bool success;
  final String message;
  final LoginData data;

  LoginResponse({
    required this.success,
    required this.message,
    required this.data,
  });

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    return LoginResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      data: LoginData.fromJson(json['data'] ?? {}),
    );
  }
}

class LoginData {
  final int id;
  final String nome;
  final String email;
  final String nivel;
  final String accessToken;
  final String? refreshToken;
  final int expiresIn;
  final String tokenType;

  LoginData({
    required this.id,
    required this.nome,
    required this.email,
    required this.nivel,
    required this.accessToken,
    this.refreshToken,
    required this.expiresIn,
    required this.tokenType,
  });

  factory LoginData.fromJson(Map<String, dynamic> json) {
    return LoginData(
      id: json['id'] ?? 0,
      nome: json['nome'] ?? '',
      email: json['email'] ?? '',
      nivel: json['nivel'] ?? '',
      accessToken: json['access_token'] ?? '',
      refreshToken: json['refresh_token'],
      expiresIn: json['expires_in'] ?? 7200,
      tokenType: json['token_type'] ?? 'Bearer',
    );
  }
}
