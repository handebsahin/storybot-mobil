import 'package:dio/dio.dart';

import '../../core/config/app_config.dart';
import '../../core/errors/app_exception.dart';
import '../models/audio_sync_model.dart';

/// Ses işlemlerini yöneten repository sınıfı
class AudioRepository {
  final Dio _dio;

  AudioRepository({required Dio dio}) : _dio = dio;

  /// Hikaye bölümünün ses senkronizasyon bilgilerini getirir
  Future<AudioSyncModel> getAudioSyncInfo(
    int storyId,
    int sectionNumber,
  ) async {
    try {
      // Endpoint'i doğru formata dönüştür
      final endpoint = AppConfig.audioInfoEndpoint
          .replaceAll('{story_id}', storyId.toString())
          .replaceAll('{section_number}', sectionNumber.toString());

      print('Requesting audio info from: $endpoint');
      final response = await _dio.get(endpoint);

      // API yanıtını kontrol et
      if (response.data is! Map<String, dynamic>) {
        print('Invalid response format: ${response.data.runtimeType}');
        throw DataException.parsingError();
      }

      // API yanıtını logla
      print('Audio sync response headers: ${response.headers}');
      print('Audio sync response status: ${response.statusCode}');

      // Yanıt içeriğinin önemli alanlarını logla (ses içeriği hariç, çok büyük olabilir)
      final Map<String, dynamic> responseData = Map.from(response.data);
      if (responseData.containsKey('audio_content')) {
        print(
            'audio_content field exists with length: ${(responseData['audio_content'] as String?)?.length ?? 0}');
        // Büyük veriyi loglamayı engelle
        responseData['audio_content'] = 'BASE64_DATA_PRESENT';
      }
      if (responseData.containsKey('audio_base64')) {
        print(
            'audio_base64 field exists with length: ${(responseData['audio_base64'] as String?)?.length ?? 0}');
        // Büyük veriyi loglamayı engelle
        responseData['audio_base64'] = 'BASE64_DATA_PRESENT';
      }
      print('Audio sync response data: $responseData');

      // Yanıtı AudioSyncModel'e dönüştür
      return AudioSyncModel.fromJson(response.data);
    } on DioException catch (e) {
      print('DioException during getAudioSyncInfo: ${e.toString()}');
      if (e.response != null) {
        print('Response status: ${e.response!.statusCode}');
        print('Response data: ${e.response!.data}');

        if (e.response!.statusCode == 404) {
          throw DataException.notFound();
        }
        throw AppException.fromApiError(e.response!.data);
      } else if (e.type == DioExceptionType.connectionTimeout) {
        throw NetworkException.timeoutError();
      } else {
        print('Connection error details: ${e.error}');
        throw NetworkException.connectionError();
      }
    } catch (e) {
      print('Exception during getAudioSyncInfo: ${e.toString()}');
      throw AppException(
        message: 'Ses bilgileri alınırken bir hata oluştu: ${e.toString()}',
      );
    }
  }
}
