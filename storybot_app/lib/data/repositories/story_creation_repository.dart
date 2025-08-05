import 'package:dio/dio.dart';

import '../../core/config/app_config.dart';
import '../../core/errors/app_exception.dart';
import '../models/story_request_model.dart';
import '../models/task_model.dart';

/// Hikaye oluşturma işlemlerini yöneten repository sınıfı
class StoryCreationRepository {
  final Dio _dio;

  StoryCreationRepository({required Dio dio}) : _dio = dio;

  /// Hikaye oluşturma isteği gönderir
  Future<String> generateStory(StoryRequestModel request) async {
    try {
      final response = await _dio.post(
        AppConfig.generateStoryEndpoint,
        data: request.toJson(),
      );

      // API yanıtını kontrol et
      if (response.data is! Map<String, dynamic>) {
        throw DataException.parsingError();
      }

      // Task ID'yi döndür
      final taskId = response.data['task_id'];
      if (taskId == null) {
        throw DataException.parsingError();
      }

      return taskId;
    } on DioException catch (e) {
      print('DioException during generateStory: ${e.toString()}');
      if (e.response != null) {
        print('Response data: ${e.response!.data}');
        print('Status code: ${e.response!.statusCode}');

        throw AppException.fromApiError(e.response!.data);
      } else if (e.type == DioExceptionType.connectionTimeout) {
        throw NetworkException.timeoutError();
      } else {
        print('Connection error details: ${e.error}');
        throw NetworkException.connectionError();
      }
    } catch (e) {
      print('Exception during generateStory: ${e.toString()}');
      throw AppException(
        message: 'Hikaye oluşturulurken bir hata oluştu: ${e.toString()}',
      );
    }
  }

  /// Görev durumunu kontrol eder
  Future<TaskModel> checkTaskStatus(String taskId) async {
    try {
      final response = await _dio.get('${AppConfig.taskStatusEndpoint}$taskId');

      // API yanıtını kontrol et
      if (response.data is! Map<String, dynamic>) {
        throw DataException.parsingError();
      }

      // Yanıtı TaskModel'e dönüştür
      return TaskModel.fromJson(response.data);
    } on DioException catch (e) {
      print('DioException during checkTaskStatus: ${e.toString()}');
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
      print('Exception during checkTaskStatus: ${e.toString()}');
      throw AppException(
        message:
            'Görev durumu kontrol edilirken bir hata oluştu: ${e.toString()}',
      );
    }
  }
}
