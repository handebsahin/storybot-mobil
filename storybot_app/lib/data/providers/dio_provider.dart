import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../../core/config/app_config.dart';

/// Dio HTTP istemcisi için provider sınıfı
class DioProvider {
  final FlutterSecureStorage _secureStorage;

  DioProvider({required FlutterSecureStorage secureStorage})
    : _secureStorage = secureStorage;

  /// Yapılandırılmış bir Dio örneği oluşturur
  Dio getDio() {
    final dio = Dio(
      BaseOptions(
        baseUrl: AppConfig.apiBaseUrl,
        connectTimeout: AppConfig.apiTimeout,
        receiveTimeout: AppConfig.apiTimeout,
        contentType: 'application/json',
        responseType: ResponseType.json,
        // Hata ayıklama için daha fazla bilgi ekle
        validateStatus: (status) {
          return status != null && status < 500;
        },
      ),
    );

    // İstek interceptor'ı ekle
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: _onRequest,
        onResponse: _onResponse,
        onError: _onError,
      ),
    );

    // Loglama interceptor'ı ekle
    dio.interceptors.add(
      LogInterceptor(requestBody: true, responseBody: true, error: true),
    );

    return dio;
  }

  /// Her istekten önce çalışır
  Future<void> _onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    print('DioProvider: Sending request to ${options.uri}');

    // Token varsa Authorization header'ına ekle
    final token = await _secureStorage.read(key: AppConfig.tokenKey);
    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
      print('DioProvider: Added auth token to request');
    }

    // İsteği devam ettir
    handler.next(options);
  }

  /// Başarılı yanıtlar için çalışır
  void _onResponse(Response response, ResponseInterceptorHandler handler) {
    print('DioProvider: Received response from ${response.requestOptions.uri}');
    print('DioProvider: Status code: ${response.statusCode}');

    // Yanıtı işle ve devam et
    handler.next(response);
  }

  /// Hata durumunda çalışır
  void _onError(DioException error, ErrorInterceptorHandler handler) {
    print('DioProvider: Error on ${error.requestOptions.uri}');
    print('DioProvider: Error type: ${error.type}');
    print('DioProvider: Error message: ${error.message}');

    // 401 Unauthorized hatası durumunda token'ı temizle
    if (error.response?.statusCode == 401) {
      print('DioProvider: Unauthorized error, clearing token');
      _secureStorage.delete(key: AppConfig.tokenKey);
    }

    // Hatayı devam ettir
    handler.next(error);
  }
}
