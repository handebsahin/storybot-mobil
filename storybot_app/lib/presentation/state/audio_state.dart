import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/errors/app_exception.dart';
import '../../data/models/audio_sync_model.dart';
import '../../domain/services/audio_service.dart';

/// Ses durumunu temsil eden sınıf
class AudioState {
  final bool isLoading;
  final AudioSyncModel? audioSync;
  final AppException? error;
  final bool isPlaying;
  final int currentPosition; // milisaniye cinsinden
  final int currentSegmentIndex; // şu an çalınan segment indeksi
  final bool isInitialized; // ses oynatıcı başlatıldı mı

  const AudioState({
    this.isLoading = false,
    this.audioSync,
    this.error,
    this.isPlaying = false,
    this.currentPosition = 0,
    this.currentSegmentIndex = -1,
    this.isInitialized = false,
  });

  /// Başlangıç durumu
  factory AudioState.initial() => const AudioState();

  /// Yükleme durumu
  factory AudioState.loading() => const AudioState(isLoading: true);

  /// Senkronizasyon bilgisi yüklendiği durum
  factory AudioState.syncLoaded(AudioSyncModel audioSync) =>
      AudioState(audioSync: audioSync, isLoading: false, isInitialized: true);

  /// Hata durumu
  factory AudioState.error(AppException error) =>
      AudioState(error: error, isLoading: false);

  /// Yeni değerlerle güncellenen bir kopya oluşturur
  AudioState copyWith({
    bool? isLoading,
    AudioSyncModel? audioSync,
    AppException? error,
    bool? isPlaying,
    int? currentPosition,
    int? currentSegmentIndex,
    bool? isInitialized,
  }) {
    return AudioState(
      isLoading: isLoading ?? this.isLoading,
      audioSync: audioSync ?? this.audioSync,
      error: error,
      isPlaying: isPlaying ?? this.isPlaying,
      currentPosition: currentPosition ?? this.currentPosition,
      currentSegmentIndex: currentSegmentIndex ?? this.currentSegmentIndex,
      isInitialized: isInitialized ?? this.isInitialized,
    );
  }

  /// Mevcut pozisyona göre aktif segment indeksini bulur
  int findActiveSegmentIndex(int position) {
    if (audioSync == null || audioSync!.segments.isEmpty) {
      return -1;
    }

    for (int i = 0; i < audioSync!.segments.length; i++) {
      final segment = audioSync!.segments[i];
      if (position >= segment.start && position <= segment.end) {
        return i;
      }
    }

    // Eğer pozisyon son segmentin sonundan büyükse, son segmenti döndür
    if (position > audioSync!.segments.last.end) {
      return audioSync!.segments.length - 1;
    }

    return -1;
  }

  /// Mevcut segment için metin aralığını döndürür
  TextRange? getCurrentTextRange() {
    if (currentSegmentIndex < 0 ||
        audioSync == null ||
        audioSync!.segments.isEmpty ||
        currentSegmentIndex >= audioSync!.segments.length) {
      return null;
    }

    final segment = audioSync!.segments[currentSegmentIndex];
    return TextRange(start: segment.textStart, end: segment.textEnd);
  }
}

/// Metin aralığını temsil eden sınıf
class TextRange {
  final int start;
  final int end;

  TextRange({required this.start, required this.end});
}

/// AudioState notifier sınıfı
class AudioStateNotifier extends StateNotifier<AudioState> {
  final AudioService _audioService;
  bool _isDisposed = false;

  AudioStateNotifier({required AudioService audioService})
      : _audioService = audioService,
        super(AudioState.initial());

  @override
  void dispose() {
    _isDisposed = true;
    resetState();
    super.dispose();
  }

  /// Ses senkronizasyon bilgilerini yükler
  Future<void> loadAudioSync(int storyId, int sectionNumber) async {
    if (_isDisposed) return;

    state = AudioState.loading();
    try {
      final audioSync = await _audioService.getAudioSyncInfo(
        storyId,
        sectionNumber,
      );

      if (_isDisposed) return;
      state = AudioState.syncLoaded(audioSync);
    } on AppException catch (e) {
      if (_isDisposed) return;
      state = AudioState.error(e);
    } catch (e) {
      if (_isDisposed) return;
      state = AudioState.error(
        AppException(
          message: 'Ses bilgileri yüklenirken bir hata oluştu: ${e.toString()}',
        ),
      );
    }
  }

  /// Oynatma durumunu günceller
  void updatePlayingState(bool isPlaying) {
    if (_isDisposed) return;

    // Provider hatasını önlemek için mikro-task ile sarmala
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_isDisposed) {
        state = state.copyWith(isPlaying: isPlaying);
      }
    });
  }

  /// Mevcut pozisyonu günceller
  void updatePosition(int position) {
    if (_isDisposed) return;
    try {
      final segmentIndex = state.findActiveSegmentIndex(position);
      state = state.copyWith(
        currentPosition: position,
        currentSegmentIndex: segmentIndex,
      );
    } catch (e) {
      print('Error updating position: $e');
    }
  }

  /// Hata durumunu temizler
  void clearError() {
    if (_isDisposed) return;
    state = state.copyWith(error: null);
  }

  /// Durum sıfırlama
  void resetState() {
    if (_isDisposed) return;
    try {
      state = AudioState.initial();
    } catch (e) {
      print('Error resetting audio state: $e');
    }
  }
}

/// AudioState provider'ı
final audioStateProvider =
    StateNotifierProvider<AudioStateNotifier, AudioState>((ref) {
  final audioService = ref.watch(audioServiceProvider);
  return AudioStateNotifier(audioService: audioService);
});
