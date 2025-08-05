/// Kullanıcı bilgilerini temsil eden model sınıfı
class UserModel {
  final String id;
  final String email;
  final String fullName;
  final String? ageGroup;
  final String preferredLanguage;
  final String authProvider;
  final String? pictureUrl;
  final bool emailVerified;
  final bool isActive;
  final Map<String, dynamic> profileData;
  final String? lastLoginAt;
  final String createdAt;

  UserModel({
    required this.id,
    required this.email,
    required this.fullName,
    this.ageGroup,
    required this.preferredLanguage,
    required this.authProvider,
    this.pictureUrl,
    required this.emailVerified,
    required this.isActive,
    required this.profileData,
    this.lastLoginAt,
    required this.createdAt,
  });

  /// API yanıtından UserModel oluşturur
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'],
      email: json['email'],
      fullName: json['full_name'],
      ageGroup: json['age_group'],
      preferredLanguage: json['preferred_language'],
      authProvider: json['auth_provider'],
      pictureUrl: json['picture_url'],
      emailVerified: json['email_verified'],
      isActive: json['is_active'],
      profileData: json['profile_data'] ?? {},
      lastLoginAt: json['last_login_at'],
      createdAt: json['created_at'],
    );
  }

  /// UserModel'i JSON formatına dönüştürür
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'full_name': fullName,
      'age_group': ageGroup,
      'preferred_language': preferredLanguage,
      'auth_provider': authProvider,
      'picture_url': pictureUrl,
      'email_verified': emailVerified,
      'is_active': isActive,
      'profile_data': profileData,
      'last_login_at': lastLoginAt,
      'created_at': createdAt,
    };
  }

  /// Yeni değerlerle güncellenen bir kopya oluşturur
  UserModel copyWith({
    String? id,
    String? email,
    String? fullName,
    String? ageGroup,
    String? preferredLanguage,
    String? authProvider,
    String? pictureUrl,
    bool? emailVerified,
    bool? isActive,
    Map<String, dynamic>? profileData,
    String? lastLoginAt,
    String? createdAt,
  }) {
    return UserModel(
      id: id ?? this.id,
      email: email ?? this.email,
      fullName: fullName ?? this.fullName,
      ageGroup: ageGroup ?? this.ageGroup,
      preferredLanguage: preferredLanguage ?? this.preferredLanguage,
      authProvider: authProvider ?? this.authProvider,
      pictureUrl: pictureUrl ?? this.pictureUrl,
      emailVerified: emailVerified ?? this.emailVerified,
      isActive: isActive ?? this.isActive,
      profileData: profileData ?? this.profileData,
      lastLoginAt: lastLoginAt ?? this.lastLoginAt,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
