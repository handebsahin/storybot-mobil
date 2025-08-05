/// Hikaye oluşturma isteği için model sınıfı
class StoryRequestModel {
  final String topic;
  final String knowledgeLevel;
  final String genre;
  final String language;

  StoryRequestModel({
    required this.topic,
    required this.knowledgeLevel,
    required this.genre,
    required this.language,
  });

  /// StoryRequestModel'i JSON formatına dönüştürür
  Map<String, dynamic> toJson() {
    return {
      'topic': topic,
      'knowledge_level': knowledgeLevel,
      'genre': genre,
      'language': language,
    };
  }
}

/// Hikaye türleri
class StoryGenres {
  static const String fantasy = 'fantasy';
  static const String scienceFiction = 'science_fiction';
  static const String adventure = 'adventure';
  static const String mystery = 'mystery';
  static const String historical = 'historical';
  static const String educational = 'educational';

  /// Tür adını görüntüleme adına dönüştürür
  static String getDisplayName(String genre) {
    switch (genre) {
      case fantasy:
        return 'Fantastik';
      case scienceFiction:
        return 'Bilim Kurgu';
      case adventure:
        return 'Macera';
      case mystery:
        return 'Gizem';
      case historical:
        return 'Tarihsel';
      case educational:
        return 'Eğitici';
      default:
        return genre;
    }
  }

  /// Tüm türlerin listesini döndürür
  static List<String> getAll() {
    return [
      fantasy,
      scienceFiction,
      adventure,
      mystery,
      historical,
      educational,
    ];
  }
}

/// Bilgi seviyeleri
class KnowledgeLevels {
  static const String beginner = 'beginner';
  static const String intermediate = 'intermediate';
  static const String expert = 'expert';

  /// Bilgi seviyesi adını görüntüleme adına dönüştürür
  static String getDisplayName(String level) {
    switch (level) {
      case beginner:
        return 'Başlangıç';
      case intermediate:
        return 'Orta';
      case expert:
        return 'İleri';
      default:
        return level;
    }
  }

  /// Tüm bilgi seviyelerinin listesini döndürür
  static List<String> getAll() {
    return [beginner, intermediate, expert];
  }
}

/// Hikaye dilleri
class StoryLanguages {
  static const String turkish = 'tr';
  static const String english = 'en';

  /// Dil kodunu görüntüleme adına dönüştürür
  static String getDisplayName(String language) {
    switch (language) {
      case turkish:
        return 'Türkçe';
      case english:
        return 'İngilizce';
      default:
        return language;
    }
  }

  /// Tüm dillerin listesini döndürür
  static List<String> getAll() {
    return [turkish, english];
  }
}
