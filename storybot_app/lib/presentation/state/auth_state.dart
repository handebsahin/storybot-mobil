import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/user_model.dart';
import '../../domain/services/auth_service.dart';
import '../../core/errors/app_exception.dart';

/// Kimlik doğrulama durumunu temsil eden sınıf
class AuthState {
  final bool isLoading;
  final UserModel? user;
  final String? token;
  final AppException? error;

  const AuthState({this.isLoading = false, this.user, this.token, this.error});

  /// Başlangıç durumu
  factory AuthState.initial() => const AuthState();

  /// Yükleme durumu
  factory AuthState.loading() => const AuthState(isLoading: true);

  /// Kimlik doğrulama başarılı durumu
  factory AuthState.authenticated(UserModel user, String token) =>
      AuthState(user: user, token: token, isLoading: false);

  /// Kimlik doğrulama hatası durumu
  factory AuthState.error(AppException error) =>
      AuthState(error: error, isLoading: false);

  /// Yeni değerlerle güncellenen bir kopya oluşturur
  AuthState copyWith({
    bool? isLoading,
    UserModel? user,
    String? token,
    AppException? error,
  }) {
    return AuthState(
      isLoading: isLoading ?? this.isLoading,
      user: user ?? this.user,
      token: token ?? this.token,
      error: error,
    );
  }

  /// Kullanıcının giriş yapmış olup olmadığını kontrol eder
  bool get isAuthenticated => user != null && token != null;
}

/// AuthState notifier sınıfı
class AuthStateNotifier extends StateNotifier<AuthState> {
  final AuthService _authService;

  AuthStateNotifier({required AuthService authService})
    : _authService = authService,
      super(AuthState.initial()) {
    // Başlangıçta mevcut kullanıcı kontrolü yap
    _initializeAuth();
  }

  /// Başlangıç kimlik doğrulama kontrolü
  Future<void> _initializeAuth() async {
    state = AuthState.loading();
    try {
      final user = await _authService.getCurrentUser();
      final token = await _authService.getAuthToken();

      if (user != null && token != null) {
        state = AuthState.authenticated(user, token);
      } else {
        state = AuthState.initial();
      }
    } catch (e) {
      state = AuthState.initial();
    }
  }

  /// E-posta ve şifre ile giriş yapar
  Future<void> loginWithEmail({
    required String email,
    required String password,
  }) async {
    state = AuthState.loading();
    try {
      final authResponse = await _authService.loginWithEmail(
        email: email,
        password: password,
      );

      state = AuthState.authenticated(
        authResponse.user,
        authResponse.accessToken,
      );
    } on AppException catch (e) {
      state = AuthState.error(e);
    } catch (e) {
      state = AuthState.error(
        AppException(
          message: 'Giriş yapılırken bir hata oluştu: ${e.toString()}',
        ),
      );
    }
  }

  /// Yeni kullanıcı kaydı oluşturur
  Future<void> register({
    required String email,
    required String password,
    required String fullName,
    String? ageGroup,
    String preferredLanguage = 'tr',
  }) async {
    state = AuthState.loading();
    try {
      final authResponse = await _authService.register(
        email: email,
        password: password,
        fullName: fullName,
        ageGroup: ageGroup,
        preferredLanguage: preferredLanguage,
      );

      state = AuthState.authenticated(
        authResponse.user,
        authResponse.accessToken,
      );
    } on AppException catch (e) {
      state = AuthState.error(e);
    } catch (e) {
      state = AuthState.error(
        AppException(message: 'Kayıt olurken bir hata oluştu: ${e.toString()}'),
      );
    }
  }

  /// Google ile giriş yapar
  Future<void> loginWithGoogle() async {
    state = AuthState.loading();
    try {
      final authResponse = await _authService.loginWithGoogle();

      state = AuthState.authenticated(
        authResponse.user,
        authResponse.accessToken,
      );
    } on AppException catch (e) {
      state = AuthState.error(e);
    } catch (e) {
      state = AuthState.error(
        AppException(
          message:
              'Google ile giriş yapılırken bir hata oluştu: ${e.toString()}',
        ),
      );
    }
  }

  /// Kullanıcı çıkışı yapar
  Future<void> logout() async {
    state = AuthState.loading();
    try {
      await _authService.logout();
      state = AuthState.initial();
    } on AppException catch (e) {
      state = AuthState.error(e);
    } catch (e) {
      state = AuthState.error(
        AppException(
          message: 'Çıkış yapılırken bir hata oluştu: ${e.toString()}',
        ),
      );
    }
  }

  /// Hata durumunu temizler
  void clearError() {
    state = state.copyWith(error: null);
  }
}

/// AuthState provider'ı
final authStateProvider = StateNotifierProvider<AuthStateNotifier, AuthState>((
  ref,
) {
  final authService = ref.watch(authServiceProvider);
  return AuthStateNotifier(authService: authService);
});
