import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/story_model.dart';
import '../../data/repositories/story_repository.dart';

/// Hikaye servis sınıfı
class StoryService {
  final StoryRepository _storyRepository;

  StoryService({required StoryRepository storyRepository})
    : _storyRepository = storyRepository;

  /// Kullanıcının hikayelerini listeler
  Future<List<StoryModel>> getUserStories({
    int limit = 20,
    int offset = 0,
  }) async {
    try {
      return await _storyRepository.getUserStories(
        limit: limit,
        offset: offset,
      );
    } catch (e) {
      rethrow;
    }
  }

  /// Hikaye detaylarını getirir
  Future<StoryModel> getStoryDetails(int storyId) async {
    try {
      return await _storyRepository.getStoryDetails(storyId);
    } catch (e) {
      rethrow;
    }
  }
}

/// StoryService provider'ı
final storyServiceProvider = Provider<StoryService>((ref) {
  throw UnimplementedError('storyServiceProvider has not been initialized');
});
