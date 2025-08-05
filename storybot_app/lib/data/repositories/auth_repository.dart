import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../../core/config/app_config.dart';
import '../../core/errors/app_exception.dart';
import '../models/auth_response_model.dart';
import '../models/user_model.dart';

/// Kimlik doğrulama işlemlerini yöneten repository sınıfı
class AuthRepository {
  final Dio _dio;
  final FlutterSecureStorage _secureStorage;

  AuthRepository({
    required Dio dio,
    required FlutterSecureStorage secureStorage,
  }) : _dio = dio,
       _secureStorage = secureStorage;

  /// E-posta ve şifre ile giriş yapar
  Future<AuthResponseModel> loginWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      print('Login attempt for: $email');

      final response = await _dio.post(
        AppConfig.loginEndpoint,
        data: {'email': email, 'password': password},
      );

      print('Login response: ${response.data}');

      final authResponse = AuthResponseModel.fromJson(response.data);

      // Token ve kullanıcı bilgilerini güvenli depolamaya kaydet
      await _saveAuthData(authResponse);

      return authResponse;
    } on DioException catch (e) {
      print('DioException during login: ${e.toString()}');
      print('Error type: ${e.type}');
      if (e.response != null) {
        print('Response data: ${e.response!.data}');
        print('Status code: ${e.response!.statusCode}');

        if (e.response!.statusCode == 401) {
          throw AuthException.invalidCredentials();
        }
        throw AppException.fromApiError(e.response!.data);
      } else if (e.type == DioExceptionType.connectionTimeout) {
        throw NetworkException.timeoutError();
      } else {
        // Bağlantı hatası detaylarını yazdır
        print('Connection error details: ${e.error}');
        throw NetworkException.connectionError();
      }
    } catch (e) {
      print('General exception during login: ${e.toString()}');
      throw AppException(
        message: 'Giriş yapılırken bir hata oluştu: ${e.toString()}',
      );
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
      print('Register attempt for: $email');

      final response = await _dio.post(
        AppConfig.registerEndpoint,
        data: {
          'email': email,
          'password': password,
          'full_name': fullName,
          'age_group': ageGroup,
          'preferred_language': preferredLanguage,
        },
      );

      print('Register response: ${response.data}');

      final authResponse = AuthResponseModel.fromJson(response.data);

      // Token ve kullanıcı bilgilerini güvenli depolamaya kaydet
      await _saveAuthData(authResponse);

      return authResponse;
    } on DioException catch (e) {
      print('DioException during register: ${e.toString()}');
      if (e.response != null) {
        print('Response data: ${e.response!.data}');
        print('Status code: ${e.response!.statusCode}');

        if (e.response!.statusCode == 400 &&
            e.response!.data['error_code'] == 'auth/email-already-in-use') {
          throw AuthException.emailAlreadyInUse();
        }
        throw AppException.fromApiError(e.response!.data);
      } else if (e.type == DioExceptionType.connectionTimeout) {
        throw NetworkException.timeoutError();
      } else {
        // Bağlantı hatası detaylarını yazdır
        print('Connection error details: ${e.error}');
        throw NetworkException.connectionError();
      }
    } catch (e) {
      print('General exception during register: ${e.toString()}');
      throw AppException(
        message: 'Kayıt olurken bir hata oluştu: ${e.toString()}',
      );
    }
  }

  /// Google ile giriş yapar
  Future<AuthResponseModel> loginWithGoogle({
    required String googleIdToken,
  }) async {
    try {
      print('Google login attempt');

      final response = await _dio.post(
        AppConfig.googleLoginEndpoint,
        data: {'google_id_token': googleIdToken},
      );

      print('Google login response: ${response.data}');

      final authResponse = AuthResponseModel.fromJson(response.data);

      // Token ve kullanıcı bilgilerini güvenli depolamaya kaydet
      await _saveAuthData(authResponse);

      return authResponse;
    } on DioException catch (e) {
      print('DioException during Google login: ${e.toString()}');
      if (e.response != null) {
        print('Response data: ${e.response!.data}');
        print('Status code: ${e.response!.statusCode}');

        throw AppException.fromApiError(e.response!.data);
      } else if (e.type == DioExceptionType.connectionTimeout) {
        throw NetworkException.timeoutError();
      } else {
        // Bağlantı hatası detaylarını yazdır
        print('Connection error details: ${e.error}');
        throw NetworkException.connectionError();
      }
    } catch (e) {
      print('General exception during Google login: ${e.toString()}');
      throw AppException(
        message: 'Google ile giriş yapılırken bir hata oluştu: ${e.toString()}',
      );
    }
  }

  /// Kullanıcı çıkışı yapar
  Future<void> logout() async {
    try {
      await _secureStorage.delete(key: AppConfig.tokenKey);
      await _secureStorage.delete(key: AppConfig.userIdKey);
      await _secureStorage.delete(key: AppConfig.userEmailKey);
      await _secureStorage.delete(key: AppConfig.userNameKey);
    } catch (e) {
      print('Exception during logout: ${e.toString()}');
      throw AppException(
        message: 'Çıkış yapılırken bir hata oluştu: ${e.toString()}',
      );
    }
  }

  /// Mevcut kullanıcının kimlik doğrulama token'ını alır
  Future<String?> getAuthToken() async {
    try {
      return await _secureStorage.read(key: AppConfig.tokenKey);
    } catch (e) {
      print('Exception getting auth token: ${e.toString()}');
      return null;
    }
  }

  /// Mevcut kullanıcının bilgilerini alır
  Future<UserModel?> getCurrentUser() async {
    try {
      final userJson = await _secureStorage.read(key: AppConfig.userIdKey);
      if (userJson == null) return null;

      return UserModel.fromJson(jsonDecode(userJson));
    } catch (e) {
      print('Exception getting current user: ${e.toString()}');
      return null;
    }
  }

  /// Kimlik doğrulama verilerini güvenli depolamaya kaydeder
  Future<void> _saveAuthData(AuthResponseModel authResponse) async {
    await _secureStorage.write(
      key: AppConfig.tokenKey,
      value: authResponse.accessToken,
    );

    await _secureStorage.write(
      key: AppConfig.userIdKey,
      value: jsonEncode(authResponse.user.toJson()),
    );

    await _secureStorage.write(
      key: AppConfig.userEmailKey,
      value: authResponse.user.email,
    );

    await _secureStorage.write(
      key: AppConfig.userNameKey,
      value: authResponse.user.fullName,
    );

    print('Auth data saved successfully');
  }
}
