import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/errors/app_exception.dart';
import '../../data/models/story_model.dart';
import '../../data/models/story_request_model.dart';
import '../../domain/services/story_creation_service.dart';
import '../../domain/services/story_service.dart';

/// Hikaye oluşturma durumunu temsil eden sınıf
class StoryCreationState {
  final bool isLoading;
  final bool isGenerating;
  final String? taskId;
  final double? progress;
  final StoryModel? generatedStory;
  final AppException? error;

  const StoryCreationState({
    this.isLoading = false,
    this.isGenerating = false,
    this.taskId,
    this.progress,
    this.generatedStory,
    this.error,
  });

  /// Başlangıç durumu
  factory StoryCreationState.initial() => const StoryCreationState();

  /// Yükleme durumu
  factory StoryCreationState.loading() =>
      const StoryCreationState(isLoading: true);

  /// Hikaye oluşturma durumu
  factory StoryCreationState.generating(String taskId, [double? progress]) =>
      StoryCreationState(
        isGenerating: true,
        taskId: taskId,
        progress: progress,
      );

  /// Hikaye oluşturma başarılı durumu
  factory StoryCreationState.success(StoryModel story) =>
      StoryCreationState(generatedStory: story, isGenerating: false);

  /// Hata durumu
  factory StoryCreationState.error(AppException error) =>
      StoryCreationState(error: error, isLoading: false, isGenerating: false);

  /// Yeni değerlerle güncellenen bir kopya oluşturur
  StoryCreationState copyWith({
    bool? isLoading,
    bool? isGenerating,
    String? taskId,
    double? progress,
    StoryModel? generatedStory,
    AppException? error,
  }) {
    return StoryCreationState(
      isLoading: isLoading ?? this.isLoading,
      isGenerating: isGenerating ?? this.isGenerating,
      taskId: taskId ?? this.taskId,
      progress: progress ?? this.progress,
      generatedStory: generatedStory ?? this.generatedStory,
      error: error,
    );
  }
}

/// StoryCreationState notifier sınıfı
class StoryCreationStateNotifier extends StateNotifier<StoryCreationState> {
  final StoryCreationService _storyCreationService;
  final StoryService _storyService;
  Timer? _pollingTimer;
  int _retryCount = 0;
  static const int _maxRetries = 3;

  StoryCreationStateNotifier({
    required StoryCreationService storyCreationService,
    required StoryService storyService,
  }) : _storyCreationService = storyCreationService,
       _storyService = storyService,
       super(StoryCreationState.initial());

  @override
  void dispose() {
    _pollingTimer?.cancel();
    super.dispose();
  }

  /// Hikaye oluşturma isteği gönderir
  Future<void> generateStory(StoryRequestModel request) async {
    state = StoryCreationState.loading();
    try {
      final taskId = await _storyCreationService.generateStory(request);
      state = StoryCreationState.generating(taskId);
      _startPolling(taskId);
    } on AppException catch (e) {
      state = StoryCreationState.error(e);
    } catch (e) {
      state = StoryCreationState.error(
        AppException(
          message: 'Hikaye oluşturulurken bir hata oluştu: ${e.toString()}',
        ),
      );
    }
  }

  /// Görev durumunu düzenli aralıklarla kontrol eder
  void _startPolling(String taskId) {
    _pollingTimer?.cancel();
    _retryCount = 0;
    _pollingTimer = Timer.periodic(
      const Duration(seconds: 3),
      (timer) => _checkTaskStatus(taskId, timer),
    );
  }

  /// Görev durumunu kontrol eder
  Future<void> _checkTaskStatus(String taskId, Timer timer) async {
    try {
      // Eğer hikaye zaten oluşturulduysa polling'i durdur
      if (state.generatedStory != null) {
        timer.cancel();
        return;
      }

      final task = await _storyCreationService.checkTaskStatus(taskId);

      if (task.isCompleted) {
        timer.cancel();
        if (task.result != null) {
          try {
            // Hikaye detaylarını yükle
            final storyId = int.parse(task.result!);
            final story = await _storyService.getStoryDetails(storyId);
            state = StoryCreationState.success(story);
          } catch (e) {
            print('Hikaye detayları yüklenirken hata: $e');
            state = StoryCreationState.error(
              AppException(
                message:
                    'Hikaye oluşturuldu ancak detaylar alınamadı: ${e.toString()}',
              ),
            );
          }
        } else {
          state = StoryCreationState.error(
            AppException(
              message: 'Hikaye oluşturuldu ancak detaylar alınamadı.',
            ),
          );
        }
      } else if (task.hasError) {
        timer.cancel();
        state = StoryCreationState.error(
          AppException(
            message: task.error ?? 'Hikaye oluşturulurken bir hata oluştu.',
          ),
        );
      } else if (task.isInProgress) {
        state = StoryCreationState.generating(taskId, task.progress);
      }
    } catch (e) {
      print('Error checking task status: $e');
      _retryCount++;

      // Maksimum yeniden deneme sayısına ulaşıldıysa hata ver ve polling'i durdur
      if (_retryCount >= _maxRetries) {
        timer.cancel();
        state = StoryCreationState.error(
          AppException(
            message:
                'Görev durumu kontrol edilirken bir hata oluştu: ${e.toString()}',
          ),
        );
      }
      // Aksi takdirde bir sonraki kontrol denemesinde tekrar denenecek
    }
  }

  /// Durumu sıfırlar
  void reset() {
    _pollingTimer?.cancel();
    state = StoryCreationState.initial();
  }

  /// Hata durumunu temizler
  void clearError() {
    state = state.copyWith(error: null);
  }
}

/// StoryCreationState provider'ı
final storyCreationStateProvider =
    StateNotifierProvider<StoryCreationStateNotifier, StoryCreationState>((
      ref,
    ) {
      final storyCreationService = ref.watch(storyCreationServiceProvider);
      final storyService = ref.watch(storyServiceProvider);
      return StoryCreationStateNotifier(
        storyCreationService: storyCreationService,
        storyService: storyService,
      );
    });
