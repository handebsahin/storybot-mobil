import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/story_request_model.dart';
import '../../data/models/task_model.dart';
import '../../data/repositories/story_creation_repository.dart';

/// Hikaye oluşturma servis sınıfı
class StoryCreationService {
  final StoryCreationRepository _storyCreationRepository;

  StoryCreationService({
    required StoryCreationRepository storyCreationRepository,
  }) : _storyCreationRepository = storyCreationRepository;

  /// Hikaye oluşturma isteği gönderir
  Future<String> generateStory(StoryRequestModel request) async {
    try {
      return await _storyCreationRepository.generateStory(request);
    } catch (e) {
      rethrow;
    }
  }

  /// Görev durumunu kontrol eder
  Future<TaskModel> checkTaskStatus(String taskId) async {
    try {
      return await _storyCreationRepository.checkTaskStatus(taskId);
    } catch (e) {
      rethrow;
    }
  }
}

/// StoryCreationService provider'ı
final storyCreationServiceProvider = Provider<StoryCreationService>((ref) {
  throw UnimplementedError(
    'storyCreationServiceProvider has not been initialized',
  );
});
