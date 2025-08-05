/// Uygulama genelinde kullanılacak özel hata sınıfı
class AppException implements Exception {
  final String message;
  final String? code;
  final dynamic details;

  // super parametrelerini kullanarak daha temiz kod
  AppException({required this.message, this.code, this.details});

  @override
  String toString() {
    return 'AppException: $message${code != null ? ' (Code: $code)' : ''}';
  }

  /// API hatalarını işlemek için factory metodu
  factory AppException.fromApiError(Map<String, dynamic> errorJson) {
    return AppException(
      message: errorJson['message'] ?? 'Bilinmeyen hata',
      code: errorJson['error_code'],
      details: errorJson['details'],
    );
  }
}

/// Kimlik doğrulama hatalarını temsil eden sınıf
class AuthException extends AppException {
  // super parametrelerini kullanarak daha temiz kod
  AuthException({required super.message, super.code, super.details});

  /// Geçersiz kimlik bilgileri hatası
  factory AuthException.invalidCredentials() {
    return AuthException(
      message: 'Geçersiz e-posta veya şifre',
      code: 'auth/invalid-credentials',
    );
  }

  /// Kayıtlı e-posta hatası
  factory AuthException.emailAlreadyInUse() {
    return AuthException(
      message: 'Bu e-posta adresi zaten kullanımda',
      code: 'auth/email-already-in-use',
    );
  }

  /// Geçersiz token hatası
  factory AuthException.invalidToken() {
    return AuthException(
      message: 'Oturum süresi doldu, lütfen tekrar giriş yapın',
      code: 'auth/invalid-token',
    );
  }
}

/// Ağ hatalarını temsil eden sınıf
class NetworkException extends AppException {
  // super parametrelerini kullanarak daha temiz kod
  NetworkException({required super.message, super.code, super.details});

  /// Bağlantı hatası
  factory NetworkException.connectionError() {
    return NetworkException(
      message: 'İnternet bağlantısı hatası',
      code: 'network/connection-error',
    );
  }

  /// Zaman aşımı hatası
  factory NetworkException.timeoutError() {
    return NetworkException(
      message: 'İstek zaman aşımına uğradı',
      code: 'network/timeout',
    );
  }

  /// Sunucu hatası
  factory NetworkException.serverError() {
    return NetworkException(
      message: 'Sunucu hatası',
      code: 'network/server-error',
    );
  }
}

/// Veri işleme hatalarını temsil eden sınıf
class DataException extends AppException {
  // super parametrelerini kullanarak daha temiz kod
  DataException({required super.message, super.code, super.details});

  /// Veri çözümleme hatası
  factory DataException.parsingError() {
    return DataException(
      message: 'Veri işlenirken bir hata oluştu',
      code: 'data/parsing-error',
    );
  }

  /// Bulunamadı hatası
  factory DataException.notFound() {
    return DataException(
      message: 'İstenen veri bulunamadı',
      code: 'data/not-found',
    );
  }
}
