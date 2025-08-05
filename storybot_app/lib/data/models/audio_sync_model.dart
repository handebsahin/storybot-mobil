/// Ses senkronizasyon bilgisini temsil eden model
class AudioSyncModel {
  final String? audioUrl; // URL veya null (base64 kullanılırken)
  final String? audioBase64; // Base64 formatında ses verisi
  final String? audioContent; // Alternatif ses içeriği alanı
  final String? audioTextHash; // Ses metni hash değeri
  final List<AudioTimeSegment> segments;
  final int sectionNumber;
  final int storyId;
  final int duration; // milisaniye cinsinden

  AudioSyncModel({
    this.audioUrl,
    this.audioBase64,
    this.audioContent,
    this.audioTextHash,
    required this.segments,
    required this.sectionNumber,
    required this.storyId,
    required this.duration,
  });

  /// API yanıtından AudioSyncModel oluşturur
  factory AudioSyncModel.fromJson(Map<String, dynamic> json) {
    // Zaman segmentlerini oluştur
    List<AudioTimeSegment> segmentsList = [];

    // Eski format: segments dizisi
    if (json['segments'] != null) {
      segmentsList = (json['segments'] as List)
          .map((segment) => AudioTimeSegment.fromJson(segment))
          .toList();
    }
    // Yeni format: audio_timepoints dizisi
    else if (json['audio_timepoints'] != null) {
      final timepoints = json['audio_timepoints'] as List;

      for (int i = 0; i < timepoints.length; i++) {
        final point = timepoints[i];
        final startTimeSecs = (point['startTimeSecs'] as num).toDouble();
        final endTimeSecs = (point['endTimeSecs'] as num).toDouble();
        final word = point['word'] as String;

        // Milisaniyeye çevir
        final startMs = (startTimeSecs * 1000).round();
        final endMs = (endTimeSecs * 1000).round();

        // Metin indekslerini hesapla
        // Basit yaklaşım: Her kelime arasında bir boşluk olduğunu varsayalım
        int textStart;
        int textEnd;

        if (i == 0) {
          textStart = 0;
          textEnd = word.length;
        } else {
          // Önceki kelimenin bitişinden sonra bir boşluk ekleyerek devam et
          textStart = segmentsList[i - 1].textEnd + 1; // +1 boşluk için
          textEnd = textStart + word.length;
        }

        segmentsList.add(
          AudioTimeSegment(
            start: startMs,
            end: endMs,
            text: word,
            textStart: textStart,
            textEnd: textEnd,
          ),
        );

        segmentsList.add(
          AudioTimeSegment(
            start: startMs,
            end: endMs,
            text: word,
            textStart: textStart,
            textEnd: textEnd,
          ),
        );
      }
    }

    // Ses içeriğini kontrol et - API'den farklı alanlarda gelebilir
    String? audioBase64Content;
    if (json['audio_base64'] != null && json['audio_base64'] is String) {
      audioBase64Content = json['audio_base64'] as String;
      print('Found audio_base64 with length: ${audioBase64Content.length}');
    } else if (json['audio_content'] != null &&
        json['audio_content'] is String) {
      audioBase64Content = json['audio_content'] as String;
      print('Found audio_content with length: ${audioBase64Content.length}');

      // Base64 başlangıç ve bitiş kontrolü
      if (audioBase64Content.startsWith("data:audio/")) {
        // Data URL formatı, base64 kısmını çıkar
        int commaIndex = audioBase64Content.indexOf(',');
        if (commaIndex != -1) {
          audioBase64Content = audioBase64Content.substring(commaIndex + 1);
          print(
              'Extracted base64 from data URL, new length: ${audioBase64Content.length}');
        }
      }
    }

    // Süreyi hesapla (milisaniye cinsinden)
    int duration = 0;
    if (json['duration'] != null) {
      if (json['duration'] is int) {
        duration = json['duration'] as int;
      } else if (json['duration'] is double) {
        duration = (json['duration'] as double).round();
      } else if (json['duration'] is String) {
        duration = int.tryParse(json['duration'] as String) ?? 0;
      }
    } else if (segmentsList.isNotEmpty) {
      duration = segmentsList.last.end;
    }

    // Minimum süre kontrolü
    if (duration <= 0) {
      duration = 30000; // Varsayılan 30 saniye
    }

    return AudioSyncModel(
      audioUrl: json['audio_url'] as String?,
      audioBase64: audioBase64Content,
      audioContent: json['audio_content'] as String?,
      audioTextHash: json['audio_text_hash'] as String?,
      segments: segmentsList,
      sectionNumber: json['section_number'] ?? 1,
      storyId: json['story_id'] ?? 0,
      duration: duration,
    );
  }

  /// Ses verisi var mı kontrol eder
  bool get hasAudio => audioUrl != null || hasBase64Audio || hasAudioContent;

  /// Base64 formatında ses verisi var mı kontrol eder
  bool get hasBase64Audio => audioBase64 != null && audioBase64!.isNotEmpty;

  /// Audio content var mı kontrol eder
  bool get hasAudioContent => audioContent != null && audioContent!.isNotEmpty;

  /// Kullanılabilir ses verisini döndürür
  String? get effectiveAudioData {
    if (hasBase64Audio) {
      return audioBase64;
    } else if (hasAudioContent) {
      return audioContent;
    }
    return null;
  }
}

/// Ses zaman segmentini temsil eden model
class AudioTimeSegment {
  final int start; // milisaniye cinsinden başlangıç zamanı
  final int end; // milisaniye cinsinden bitiş zamanı
  final String text; // bu zaman aralığında okunan metin
  final int textStart; // orijinal metindeki başlangıç indeksi
  final int textEnd; // orijinal metindeki bitiş indeksi

  AudioTimeSegment({
    required this.start,
    required this.end,
    required this.text,
    required this.textStart,
    required this.textEnd,
  });

  /// API yanıtından AudioTimeSegment oluşturur
  factory AudioTimeSegment.fromJson(Map<String, dynamic> json) {
    return AudioTimeSegment(
      start: json['start'],
      end: json['end'],
      text: json['text'],
      textStart: json['text_start'],
      textEnd: json['text_end'],
    );
  }
}
