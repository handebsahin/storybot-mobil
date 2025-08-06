import 'dart:convert';
import 'dart:typed_data';

import 'package:base64_audio_source/base64_audio_source.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:just_audio/just_audio.dart';

import '../../../core/constants/app_colors.dart';
import '../../../data/models/audio_sync_model.dart';
import '../../state/audio_state.dart';

/// Ses oynatıcı widget'ı
class AudioPlayerWidget extends ConsumerStatefulWidget {
  final AudioSyncModel audioSync;
  final Function(int position) onPositionChanged;
  final Function(bool isPlaying) onPlayingStateChanged;

  const AudioPlayerWidget({
    super.key,
    required this.audioSync,
    required this.onPositionChanged,
    required this.onPlayingStateChanged,
  });

  @override
  ConsumerState<AudioPlayerWidget> createState() => _AudioPlayerWidgetState();
}

class _AudioPlayerWidgetState extends ConsumerState<AudioPlayerWidget> {
  late AudioPlayer _audioPlayer;
  bool _isInitialized = false;
  bool _isLoading = true;
  String? _errorMessage;
  int _retryCount = 0;
  static const int _maxRetries = 3;

  @override
  void initState() {
    super.initState();
    _initAudioPlayer();
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  Future<void> _initAudioPlayer() async {
    _audioPlayer = AudioPlayer();

    try {
      // Base64 ses verisi kontrolü
      if (widget.audioSync.effectiveAudioData != null) {
        final audioData = widget.audioSync.effectiveAudioData!;
        print(
            'Loading audio from base64 data with length: ${audioData.length}');

        // Base64 verisi içeriğini detaylı kontrol et
        if (audioData.length > 10) {
          print('Base64 data sample: ${audioData.substring(0, 10)}...');

          try {
            // Önce temizlenmiş base64 oluştur
            String cleanedBase64 = _cleanBase64(audioData);
            print('Cleaned base64 length: ${cleanedBase64.length}');

            // Base64AudioSource paketi ile dene (önceki çalışan yöntem)
            print('Trying with Base64AudioSource package...');
            await _audioPlayer.setAudioSource(
                Base64AudioSource(cleanedBase64, kAudioFormatMP3));
            print('Base64AudioSource package used successfully');
          } catch (base64Error) {
            print('Base64AudioSource failed: $base64Error');

            // Fallback: Manuel decode ile dene
            try {
              String cleanedBase64 = _cleanBase64(audioData);
              final decodedBytes = base64Decode(cleanedBase64);
              print(
                  'Successfully decoded base64, bytes length: ${decodedBytes.length}');

              // MP3 header kontrolü
              bool seemsValid = _checkMp3Header(decodedBytes);
              print('MP3 header check: $seemsValid');

              // Manuel olarak ses kaynağını oluştur
              await _audioPlayer.setAudioSource(BytesAudioSource(decodedBytes));
              print('Manually created BytesAudioSource set successfully');
            } catch (decodeError) {
              print('All audio loading methods failed: $decodeError');
              throw Exception('Ses verisi yüklenemedi: $decodeError');
            }
          }
        } else {
          throw Exception('Base64 verisi çok kısa veya boş');
        }
      }
      // URL ses verisi kontrolü
      else if (widget.audioSync.audioUrl != null) {
        print('Loading audio from URL: ${widget.audioSync.audioUrl}');
        await _audioPlayer.setUrl(widget.audioSync.audioUrl!);
      }
      // Ses verisi yoksa hata fırlat
      else {
        throw Exception('Ses verisi bulunamadı');
      }

      // Pozisyon değişiklikleri artık StreamBuilder ile dinleniyor
      // Bu sayede UI otomatik olarak güncellenecek

      // Oynatma durumu değişiklikleri artık StreamBuilder ile dinleniyor
      // Sadece loglamak için basit bir listener ekleyelim
      _audioPlayer.playerStateStream.listen((playerState) {
        // Oynatıcı durumunu detaylı logla
        print(
            'Audio player state: ${playerState.processingState}, playing: ${playerState.playing}');

        // Hata durumunu kontrol et
        if (playerState.processingState == ProcessingState.completed) {
          print('Audio playback completed');
        } else if (playerState.processingState == ProcessingState.ready) {
          print('Audio player is ready, waiting for user to press play button');
        }
      });

      setState(() {
        _isInitialized = true;
        _isLoading = false;
      });

      print('Audio player initialized successfully');
      print('Audio source: ${_audioPlayer.audioSource}');
      print('Audio duration: ${_audioPlayer.duration}');

      // Otomatik oynatmayı kaldırıyoruz
      // Kullanıcı oynat butonuna basarak ses oynatımını başlatacak
      print('Audio player initialized, waiting for user to press play button');
    } catch (e) {
      print('Audio player initialization error: $e');
      _retryLoadingIfNeeded();
    }
  }

  /// Base64 formatını temizler
  String _cleanBase64(String base64String) {
    // Data URL formatını kontrol et ve temizle
    if (base64String.startsWith('data:audio/')) {
      int commaIndex = base64String.indexOf(',');
      if (commaIndex != -1) {
        base64String = base64String.substring(commaIndex + 1);
        print('Data URL format detected and cleaned');
      }
    }

    // Boşlukları, satır sonlarını ve diğer geçersiz karakterleri temizle
    String cleaned = base64String
        .trim()
        .replaceAll('\n', '')
        .replaceAll('\r', '')
        .replaceAll(' ', '');

    // URL güvenli formatı standart formata dönüştür
    cleaned = cleaned.replaceAll('-', '+').replaceAll('_', '/');

    // Padding kontrolü
    int padNeeded = (4 - (cleaned.length % 4)) % 4;
    cleaned = cleaned + ('=' * padNeeded);

    return cleaned;
  }

  /// MP3 header kontrolü yapar
  bool _checkMp3Header(Uint8List bytes) {
    if (bytes.length < 4) return false;

    // MP3 dosyaları genellikle "ID3" veya 0xFF, 0xFB ile başlar
    if (bytes[0] == 0x49 && bytes[1] == 0x44 && bytes[2] == 0x33) {
      print('ID3 header found');
      return true;
    }

    // MP3 frame header kontrolü
    for (int i = 0; i < bytes.length - 1; i++) {
      if (bytes[i] == 0xFF && (bytes[i + 1] & 0xE0) == 0xE0) {
        print('MP3 frame header found at position $i');
        return true;
      }
    }

    print('No valid MP3 header found');
    return false;
  }

  /// Gerekirse ses yüklemeyi tekrar dener
  void _retryLoadingIfNeeded() {
    if (_retryCount < _maxRetries) {
      _retryCount++;
      print('Retrying audio loading (attempt $_retryCount of $_maxRetries)');

      // Kısa bir gecikme ile tekrar dene
      Future.delayed(const Duration(seconds: 1), () {
        _initAudioPlayer();
      });
    } else {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Ses dosyası yüklenemedi. Lütfen tekrar deneyin.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final audioState = ref.watch(audioStateProvider);

    // Yükleme durumunda gösterge
    if (_isLoading) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: const Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 12),
              Text('Ses dosyası yükleniyor...'),
            ],
          ),
        ),
      );
    }

    // Hata durumunda mesaj
    if (_errorMessage != null) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.error_outline,
                color: AppColors.error,
                size: 48,
              ),
              const SizedBox(height: 12),
              Text(
                _errorMessage!,
                style: const TextStyle(color: AppColors.error),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: () {
                  setState(() {
                    _isLoading = true;
                    _errorMessage = null;
                    _retryCount = 0;
                  });
                  _initAudioPlayer();
                },
                icon: const Icon(Icons.refresh),
                label: const Text('Tekrar Dene'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (!_isInitialized) {
      return const Center(child: CircularProgressIndicator());
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // İlerleme çubuğu
          StreamBuilder<Duration>(
            stream: _audioPlayer.positionStream,
            builder: (context, snapshot) {
              final position = snapshot.hasData
                  ? snapshot.data!.inMilliseconds.toDouble()
                  : 0.0;

              // Pozisyon değişimini bildir
              if (snapshot.hasData) {
                widget.onPositionChanged(position.toInt());
              }

              return SliderTheme(
                data: SliderThemeData(
                  trackHeight: 6,
                  thumbShape:
                      const RoundSliderThumbShape(enabledThumbRadius: 8),
                  overlayShape:
                      const RoundSliderOverlayShape(overlayRadius: 16),
                  activeTrackColor: AppColors.primary,
                  inactiveTrackColor: AppColors.primary.withOpacity(0.2),
                  thumbColor: AppColors.primary,
                  overlayColor: AppColors.primary.withOpacity(0.2),
                ),
                child: Slider(
                  min: 0,
                  max: widget.audioSync.duration.toDouble(),
                  value: position.clamp(
                    0,
                    widget.audioSync.duration.toDouble(),
                  ),
                  onChanged: (value) {
                    _audioPlayer.seek(Duration(milliseconds: value.toInt()));
                  },
                ),
              );
            },
          ),

          // Süre bilgisi ve kontrol butonları
          // Yatay kaydırma ile overflow sorununu çözüyoruz
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Süre bilgisi
                  StreamBuilder<Duration>(
                    stream: _audioPlayer.positionStream,
                    builder: (context, snapshot) {
                      final position = snapshot.hasData
                          ? snapshot.data!.inMilliseconds
                          : audioState.currentPosition;

                      return Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.lightBackground,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          '${_formatDuration(position)} / ${_formatDuration(widget.audioSync.duration)}',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(width: 4),

                  // Kontrol butonları
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // 10 saniye geri
                      IconButton(
                        padding: const EdgeInsets.all(8),
                        constraints: const BoxConstraints(),
                        icon: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.replay_10,
                            size: 20,
                            color: AppColors.primary,
                          ),
                        ),
                        onPressed: () {
                          final currentPosition =
                              _audioPlayer.position.inMilliseconds;
                          final newPosition = currentPosition - 10000;
                          _audioPlayer.seek(
                            Duration(
                              milliseconds: newPosition < 0 ? 0 : newPosition,
                            ),
                          );
                        },
                      ),

                      // Oynat/Duraklat
                      StreamBuilder<PlayerState>(
                        stream: _audioPlayer.playerStateStream,
                        builder: (context, snapshot) {
                          final playerState = snapshot.data;
                          final isPlaying = playerState?.playing ?? false;

                          // Oynatma durumunu bildir
                          widget.onPlayingStateChanged(isPlaying);

                          return Container(
                            margin: const EdgeInsets.symmetric(horizontal: 8),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  AppColors.primary,
                                  AppColors.primaryLight,
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.primary.withOpacity(0.3),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: IconButton(
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                              icon: Icon(
                                isPlaying ? Icons.pause : Icons.play_arrow,
                                size: 32,
                                color: Colors.white,
                              ),
                              onPressed: () async {
                                try {
                                  if (isPlaying) {
                                    await _audioPlayer.pause();
                                    print('Audio paused successfully');
                                  } else {
                                    // Ses oynatıcının hazır olup olmadığını kontrol et
                                    if (_audioPlayer.audioSource != null) {
                                      await _audioPlayer.play();
                                      print(
                                          'Audio play command sent successfully');
                                    } else {
                                      print(
                                          'Audio source is null, cannot play');
                                      if (mounted) {
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          const SnackBar(
                                            content:
                                                Text('Ses dosyası yüklenemedi'),
                                            backgroundColor: Colors.red,
                                          ),
                                        );
                                      }
                                    }
                                  }
                                } catch (error) {
                                  print('Audio control error: $error');
                                  // Hata durumunda kullanıcıya bilgi ver
                                  if (mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content:
                                            Text('Ses kontrolü hatası: $error'),
                                        backgroundColor: Colors.red,
                                      ),
                                    );
                                  }
                                }
                              },
                            ),
                          );
                        },
                      ),

                      // 10 saniye ileri
                      IconButton(
                        padding: const EdgeInsets.all(8),
                        constraints: const BoxConstraints(),
                        icon: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.forward_10,
                            size: 20,
                            color: AppColors.primary,
                          ),
                        ),
                        onPressed: () {
                          final currentPosition =
                              _audioPlayer.position.inMilliseconds;
                          final newPosition = currentPosition + 10000;
                          _audioPlayer.seek(
                            Duration(
                              milliseconds:
                                  newPosition > widget.audioSync.duration
                                      ? widget.audioSync.duration
                                      : newPosition,
                            ),
                          );
                        },
                      ),
                    ],
                  ),

                  const SizedBox(width: 4),

                  // Hız kontrolü
                  StreamBuilder<double>(
                    stream: _audioPlayer.speedStream,
                    initialData: _audioPlayer.speed,
                    builder: (context, snapshot) {
                      final speed = snapshot.data ?? 1.0;

                      return Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.lightBackground,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: PopupMenuButton<double>(
                          initialValue: speed,
                          tooltip: 'Oynatma hızı',
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.speed,
                                size: 14,
                                color: AppColors.primary,
                              ),
                              const SizedBox(width: 2),
                              Text(
                                '${speed}x',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.primary,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                          onSelected: (double speed) {
                            _audioPlayer.setSpeed(speed);
                          },
                          itemBuilder: (BuildContext context) =>
                              <PopupMenuEntry<double>>[
                            const PopupMenuItem<double>(
                                value: 0.5, child: Text('0.5x')),
                            const PopupMenuItem<double>(
                              value: 0.75,
                              child: Text('0.75x'),
                            ),
                            const PopupMenuItem<double>(
                                value: 1.0, child: Text('1.0x')),
                            const PopupMenuItem<double>(
                              value: 1.25,
                              child: Text('1.25x'),
                            ),
                            const PopupMenuItem<double>(
                                value: 1.5, child: Text('1.5x')),
                            const PopupMenuItem<double>(
                                value: 2.0, child: Text('2.0x')),
                          ],
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Süreyi formatlar (mm:ss)
  String _formatDuration(int milliseconds) {
    final duration = Duration(milliseconds: milliseconds);
    final minutes = duration.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }
}

/// Byte array'den ses kaynağı oluşturmak için yardımcı sınıf
class BytesAudioSource extends StreamAudioSource {
  final Uint8List _bytes;

  BytesAudioSource(this._bytes);

  @override
  Future<StreamAudioResponse> request([int? start, int? end]) async {
    start ??= 0;
    end ??= _bytes.length;

    print(
        'BytesAudioSource.request: start=$start, end=$end, total length=${_bytes.length}');

    return StreamAudioResponse(
      sourceLength: _bytes.length,
      contentLength: end - start,
      offset: start,
      stream: Stream.value(_bytes.sublist(start, end)),
      contentType: 'audio/mpeg', // MP3 formatı
    );
  }
}
