import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/audio_sync_model.dart';
import '../../data/repositories/audio_repository.dart';

/// Ses servis sınıfı
class AudioService {
  final AudioRepository _audioRepository;

  AudioService({required AudioRepository audioRepository})
      : _audioRepository = audioRepository;

  /// Hikaye bölümünün ses senkronizasyon bilgilerini getirir
  Future<AudioSyncModel> getAudioSyncInfo(
      int storyId, int sectionNumber) async {
    try {
      return await _audioRepository.getAudioSyncInfo(storyId, sectionNumber);
    } catch (e) {
      rethrow;
    }
  }
}

/// AudioService provider'ı
final audioServiceProvider = Provider<AudioService>((ref) {
  throw UnimplementedError('audioServiceProvider has not been initialized');
});
