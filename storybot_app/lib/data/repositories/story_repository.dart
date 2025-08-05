import 'package:dio/dio.dart';

import '../../core/config/app_config.dart';
import '../../core/errors/app_exception.dart';
import '../models/story_model.dart';

/// Hikaye işlemlerini yöneten repository sınıfı
class StoryRepository {
  final Dio _dio;

  StoryRepository({required Dio dio}) : _dio = dio;

  /// Kullanıcının hikayelerini listeler
  Future<List<StoryModel>> getUserStories({
    int limit = 20,
    int offset = 0,
  }) async {
    try {
      final response = await _dio.get(
        AppConfig.userStoriesEndpoint,
        queryParameters: {'limit': limit, 'offset': offset},
      );

      // API yanıtını kontrol et ve detaylı log ekle
      print('Response Text:');
      print(response.data.toString());
      print('');

      if (response.data is! Map<String, dynamic>) {
        throw DataException.parsingError();
      }

      // Yanıtı StoryListResponse modeline dönüştür
      final storyListResponse = StoryListResponse.fromJson(response.data);

      return storyListResponse.stories;
    } on DioException catch (e) {
      print('DioException during getUserStories: ${e.toString()}');
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
      print('Exception during getUserStories: ${e.toString()}');
      throw AppException(
        message: 'Hikayeler alınırken bir hata oluştu: ${e.toString()}',
      );
    }
  }

  /// Hikaye detaylarını getirir
  Future<StoryModel> getStoryDetails(int storyId) async {
    try {
      final response = await _dio.get(
        '${AppConfig.storyDetailsEndpoint}$storyId',
      );

      // API yanıtını kontrol et
      if (response.data is! Map<String, dynamic>) {
        throw DataException.parsingError();
      }

      // Yanıtı StoryModel'e dönüştür
      return StoryModel.fromJson(response.data);
    } on DioException catch (e) {
      print('DioException during getStoryDetails: ${e.toString()}');
      if (e.response != null) {
        if (e.response!.statusCode == 404) {
          throw DataException.notFound();
        }
        throw AppException.fromApiError(e.response!.data);
      } else if (e.type == DioExceptionType.connectionTimeout) {
        throw NetworkException.timeoutError();
      } else {
        throw NetworkException.connectionError();
      }
    } catch (e) {
      print('Exception during getStoryDetails: ${e.toString()}');
      throw AppException(
        message: 'Hikaye detayları alınırken bir hata oluştu: ${e.toString()}',
      );
    }
  }
}
