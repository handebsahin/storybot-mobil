import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/errors/app_exception.dart';
import '../../data/models/story_model.dart';
import '../../domain/services/story_service.dart';

/// Hikaye durumunu temsil eden sınıf
class StoryState {
  final bool isLoading;
  final List<StoryModel> stories;
  final StoryModel? storyDetails;
  final AppException? error;

  const StoryState({
    this.isLoading = false,
    this.stories = const [],
    this.storyDetails,
    this.error,
  });

  /// Başlangıç durumu
  factory StoryState.initial() => const StoryState();

  /// Yükleme durumu
  factory StoryState.loading() => const StoryState(isLoading: true);

  /// Hikayelerin yüklendiği durum
  factory StoryState.loaded(List<StoryModel> stories) =>
      StoryState(stories: stories, isLoading: false);

  /// Hikaye detaylarının yüklendiği durum
  factory StoryState.detailsLoaded(StoryModel story) =>
      StoryState(storyDetails: story, isLoading: false);

  /// Hata durumu
  factory StoryState.error(AppException error) =>
      StoryState(error: error, isLoading: false);

  /// Yeni değerlerle güncellenen bir kopya oluşturur
  StoryState copyWith({
    bool? isLoading,
    List<StoryModel>? stories,
    StoryModel? storyDetails,
    AppException? error,
  }) {
    return StoryState(
      isLoading: isLoading ?? this.isLoading,
      stories: stories ?? this.stories,
      storyDetails: storyDetails ?? this.storyDetails,
      error: error,
    );
  }
}

/// StoryState notifier sınıfı
class StoryStateNotifier extends StateNotifier<StoryState> {
  final StoryService _storyService;

  StoryStateNotifier({required StoryService storyService})
      : _storyService = storyService,
        super(StoryState.initial());

  /// Kullanıcının hikayelerini yükler
  Future<void> loadUserStories() async {
    state = StoryState.loading();
    try {
      final stories = await _storyService.getUserStories();
      state = StoryState.loaded(stories);
    } on AppException catch (e) {
      state = StoryState.error(e);
    } catch (e) {
      state = StoryState.error(
        AppException(
          message: 'Hikayeler yüklenirken bir hata oluştu: ${e.toString()}',
        ),
      );
    }
  }

  /// Hikaye detaylarını yükler
  Future<void> loadStoryDetails(int storyId) async {
    state = state.copyWith(isLoading: true);
    try {
      final storyDetails = await _storyService.getStoryDetails(storyId);
      state = state.copyWith(storyDetails: storyDetails, isLoading: false);
    } on AppException catch (e) {
      state = state.copyWith(error: e, isLoading: false);
    } catch (e) {
      state = state.copyWith(
        error: AppException(
          message:
              'Hikaye detayları yüklenirken bir hata oluştu: ${e.toString()}',
        ),
        isLoading: false,
      );
    }
  }

  /// Hata durumunu temizler
  void clearError() {
    state = state.copyWith(error: null);
  }
}

/// StoryState provider'ı
final storyStateProvider =
    StateNotifierProvider<StoryStateNotifier, StoryState>((ref) {
  final storyService = ref.watch(storyServiceProvider);
  return StoryStateNotifier(storyService: storyService);
});
