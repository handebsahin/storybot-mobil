import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../../data/models/auth_response_model.dart';
import '../../data/models/user_model.dart';
import '../../data/repositories/auth_repository.dart';
import '../../core/errors/app_exception.dart';

/// Kimlik doğrulama servis sınıfı
class AuthService {
  final AuthRepository _authRepository;
  final GoogleSignIn _googleSignIn;

  AuthService({
    required AuthRepository authRepository,
    required GoogleSignIn googleSignIn,
  }) : _authRepository = authRepository,
       _googleSignIn = googleSignIn;

  /// E-posta ve şifre ile giriş yapar
  Future<AuthResponseModel> loginWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      return await _authRepository.loginWithEmail(
        email: email,
        password: password,
      );
    } catch (e) {
      rethrow;
    }
  }

  /// Yeni kullanıcı kaydı oluşturur
  Future<AuthResponseModel> register({
    required String email,
    required String password,
    required String fullName,
    String? ageGroup,
    String preferredLanguage = 'tr',
  }) async {
    try {
      return await _authRepository.register(
        email: email,
        password: password,
        fullName: fullName,
        ageGroup: ageGroup,
        preferredLanguage: preferredLanguage,
      );
    } catch (e) {
      rethrow;
    }
  }

  /// Google ile giriş yapar
  Future<AuthResponseModel> loginWithGoogle() async {
    try {
      // Google hesabı ile giriş yap
      final googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        throw AuthException(message: 'Google ile giriş iptal edildi');
      }

      // Google kimlik doğrulama
      final googleAuth = await googleUser.authentication;
      final idToken = googleAuth.idToken;

      if (idToken == null) {
        throw AuthException(message: 'Google kimlik doğrulama hatası');
      }

      // Backend'e Google token'ı gönder
      return await _authRepository.loginWithGoogle(googleIdToken: idToken);
    } catch (e) {
      if (e is AppException) {
        rethrow;
      }
      throw AppException(
        message: 'Google ile giriş yapılırken bir hata oluştu: ${e.toString()}',
      );
    }
  }

  /// Kullanıcı çıkışı yapar
  Future<void> logout() async {
    try {
      // Google ile giriş yapıldıysa Google'dan da çıkış yap
      if (await _googleSignIn.isSignedIn()) {
        await _googleSignIn.signOut();
      }

      // Local oturumu kapat
      await _authRepository.logout();
    } catch (e) {
      throw AppException(
        message: 'Çıkış yapılırken bir hata oluştu: ${e.toString()}',
      );
    }
  }

  /// Mevcut kullanıcının kimlik doğrulama token'ını alır
  Future<String?> getAuthToken() async {
    return await _authRepository.getAuthToken();
  }

  /// Mevcut kullanıcının bilgilerini alır
  Future<UserModel?> getCurrentUser() async {
    return await _authRepository.getCurrentUser();
  }

  /// Kullanıcının giriş yapmış olup olmadığını kontrol eder
  Future<bool> isLoggedIn() async {
    final token = await getAuthToken();
    return token != null;
  }
}

/// AuthService provider'ı
final authServiceProvider = Provider<AuthService>((ref) {
  throw UnimplementedError('authServiceProvider has not been initialized');
});
