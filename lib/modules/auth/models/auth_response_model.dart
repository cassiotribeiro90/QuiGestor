class AuthResponseModel {
  final int id;
  final String nome;
  final String email;
  final String nivel;
  final String accessToken;
  final String refreshToken;
  final int expiresIn;
  final String tokenType;
  final String? deviceId;
  final String? deviceToken;

  AuthResponseModel({
    required this.id,
    required this.nome,
    required this.email,
    required this.nivel,
    required this.accessToken,
    required this.refreshToken,
    required this.expiresIn,
    required this.tokenType,
    this.deviceId,
    this.deviceToken,
  });

  factory AuthResponseModel.fromJson(Map<String, dynamic> json) {
    return AuthResponseModel(
      id: json['id'] as int,
      nome: json['nome'] as String,
      email: json['email'] as String,
      nivel: json['nivel'] as String,
      accessToken: json['access_token'] as String,
      refreshToken: json['refresh_token'] as String,
      expiresIn: json['expires_in'] as int,
      tokenType: json['token_type'] as String,
      deviceId: json['device_id'] as String?,
      deviceToken: json['device_token'] as String?,
    );
  }
}
