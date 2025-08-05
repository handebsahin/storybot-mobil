/// Hikaye bölümünü temsil eden model sınıfı
class StorySectionModel {
  final int sectionNumber;
  final String textContent;
  final String imageUrl;

  StorySectionModel({
    required this.sectionNumber,
    required this.textContent,
    required this.imageUrl,
  });

  /// API yanıtından StorySectionModel oluşturur
  factory StorySectionModel.fromJson(Map<String, dynamic> json) {
    return StorySectionModel(
      sectionNumber: json['section_number'],
      textContent: json['text_content'],
      imageUrl: json['image_url'],
    );
  }

  /// StorySectionModel'i JSON formatına dönüştürür
  Map<String, dynamic> toJson() {
    return {
      'section_number': sectionNumber,
      'text_content': textContent,
      'image_url': imageUrl,
    };
  }

  /// Bölüm içeriğini döndürür
  String get content => textContent;
}

/// Anahtar kavramı temsil eden model sınıfı
class KeyConceptModel {
  final int id;
  final String keyword;
  final String explanation;
  final int? sectionNumber;

  KeyConceptModel({
    required this.id,
    required this.keyword,
    required this.explanation,
    this.sectionNumber,
  });

  /// API yanıtından KeyConceptModel oluşturur
  factory KeyConceptModel.fromJson(Map<String, dynamic> json) {
    return KeyConceptModel(
      id: json['id'],
      keyword: json['keyword'],
      explanation: json['explanation'],
      sectionNumber: json['section_number'],
    );
  }

  /// KeyConceptModel'i JSON formatına dönüştürür
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'keyword': keyword,
      'explanation': explanation,
      'section_number': sectionNumber,
    };
  }
}

/// Hikaye modelini temsil eden sınıf
class StoryModel {
  final int storyId;
  final String topic;
  final String knowledgeLevel;
  final String genre;
  final String language;
  final List<StorySectionModel> sections;
  final List<KeyConceptModel> concepts;
  final String createdAt;
  final String? updatedAt;

  StoryModel({
    required this.storyId,
    required this.topic,
    required this.knowledgeLevel,
    required this.genre,
    required this.language,
    this.sections = const [],
    this.concepts = const [],
    required this.createdAt,
    this.updatedAt,
  });

  /// API yanıtından StoryModel oluşturur
  factory StoryModel.fromJson(Map<String, dynamic> json) {
    // Bölümleri dönüştür (eğer varsa)
    List<StorySectionModel> sectionsList = [];
    if (json['sections'] != null) {
      sectionsList = (json['sections'] as List)
          .map((section) => StorySectionModel.fromJson(section))
          .toList();
    }

    // Kavramları dönüştür (eğer varsa)
    List<KeyConceptModel> conceptsList = [];
    if (json['concepts'] != null) {
      conceptsList = (json['concepts'] as List)
          .map((concept) => KeyConceptModel.fromJson(concept))
          .toList();
    }

    // API yanıtında id veya story_id kullanılabilir
    final id = json['id'] ?? json['story_id'];

    return StoryModel(
      storyId: id,
      topic: json['topic'],
      knowledgeLevel: json['knowledge_level'],
      genre: json['genre'],
      language: json['language'],
      sections: sectionsList,
      concepts: conceptsList,
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
    );
  }

  /// StoryModel'i JSON formatına dönüştürür
  Map<String, dynamic> toJson() {
    return {
      'story_id': storyId,
      'topic': topic,
      'knowledge_level': knowledgeLevel,
      'genre': genre,
      'language': language,
      'sections': sections.map((section) => section.toJson()).toList(),
      'concepts': concepts.map((concept) => concept.toJson()).toList(),
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }
}

/// Hikaye listesi yanıtını temsil eden model
class StoryListResponse {
  final List<StoryModel> stories;
  final int total;
  final int offset;
  final int limit;
  final String? userId;

  StoryListResponse({
    required this.stories,
    required this.total,
    required this.offset,
    required this.limit,
    this.userId,
  });

  /// API yanıtından StoryListResponse oluşturur
  factory StoryListResponse.fromJson(Map<String, dynamic> json) {
    // Hikayeler listesini kontrol et ve dönüştür
    List<StoryModel> storiesList = [];
    if (json['stories'] != null) {
      storiesList = (json['stories'] as List)
          .map((story) => StoryModel.fromJson(story))
          .toList();
    }

    return StoryListResponse(
      stories: storiesList,
      total: json['count'] ?? storiesList.length,
      offset: json['offset'] ?? 0,
      limit: json['limit'] ?? 20,
      userId: json['user_id'],
    );
  }
}
