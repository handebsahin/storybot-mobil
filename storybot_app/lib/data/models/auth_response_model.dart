import 'user_model.dart';

/// Kimlik doğrulama yanıtını temsil eden model sınıfı
class AuthResponseModel {
  final UserModel user;
  final String accessToken;
  final String tokenType;
  final int expiresIn;

  AuthResponseModel({
    required this.user,
    required this.accessToken,
    required this.tokenType,
    required this.expiresIn,
  });

  /// API yanıtından AuthResponseModel oluşturur
  factory AuthResponseModel.fromJson(Map<String, dynamic> json) {
    return AuthResponseModel(
      user: UserModel.fromJson(json['user']),
      accessToken: json['access_token'],
      tokenType: json['token_type'],
      expiresIn: json['expires_in'],
    );
  }

  /// AuthResponseModel'i JSON formatına dönüştürür
  Map<String, dynamic> toJson() {
    return {
      'user': user.toJson(),
      'access_token': accessToken,
      'token_type': tokenType,
      'expires_in': expiresIn,
    };
  }
}
