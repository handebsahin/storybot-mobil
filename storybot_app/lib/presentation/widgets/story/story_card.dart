import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../data/models/story_model.dart';

/// Hikaye kartı widget'ı
class StoryCard extends StatelessWidget {
  final StoryModel story;
  final VoidCallback? onTap;

  const StoryCard({super.key, required this.story, this.onTap});

  @override
  Widget build(BuildContext context) {
    // Hikayenin görselini belirle (varsa)
    String? imageUrl;
    if (story.sections.isNotEmpty) {
      // Tüm bölümleri kontrol et ve ilk geçerli görseli bul
      for (var section in story.sections) {
        if (section.imageUrl.isNotEmpty) {
          imageUrl = section.imageUrl;
          break;
        }
      }
    }

    // Bilgi seviyesine göre renk belirle
    Color levelColor;
    switch (story.knowledgeLevel) {
      case 'beginner':
        levelColor = AppColors.beginnerColor;
        break;
      case 'intermediate':
        levelColor = AppColors.intermediateColor;
        break;
      case 'expert':
        levelColor = AppColors.expertColor;
        break;
      default:
        levelColor = AppColors.primary;
    }

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          child: Ink(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Hikaye görseli (varsa)
                ClipRRect(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                  ),
                  child: Stack(
                    children: [
                      // Görsel veya placeholder
                      if (imageUrl != null && imageUrl.isNotEmpty)
                        AspectRatio(
                          aspectRatio: 3 / 2,
                          child: Image.network(
                            imageUrl,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return _buildPlaceholderImage();
                            },
                            loadingBuilder: (context, child, loadingProgress) {
                              if (loadingProgress == null) return child;
                              return Container(
                                color: Colors.grey[200],
                                child: Center(
                                  child: CircularProgressIndicator(
                                    value: loadingProgress.expectedTotalBytes !=
                                            null
                                        ? loadingProgress
                                                .cumulativeBytesLoaded /
                                            loadingProgress.expectedTotalBytes!
                                        : null,
                                    strokeWidth: 2,
                                    color: AppColors.primary,
                                  ),
                                ),
                              );
                            },
                          ),
                        )
                      else
                        AspectRatio(
                          aspectRatio: 3 / 2,
                          child: _buildPlaceholderImage(),
                        ),

                      // Bilgi seviyesi göstergesi
                      Positioned(
                        top: 10,
                        left: 10,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 5,
                          ),
                          decoration: BoxDecoration(
                            color: levelColor.withOpacity(0.9),
                            borderRadius: BorderRadius.circular(30),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                _getKnowledgeLevelIcon(story.knowledgeLevel),
                                color: Colors.white,
                                size: 14,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                _getKnowledgeLevelText(story.knowledgeLevel),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      // Dil göstergesi
                      Positioned(
                        top: 10,
                        right: 10,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 5,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.6),
                            borderRadius: BorderRadius.circular(30),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.language,
                                color: Colors.white,
                                size: 14,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                _getLanguageText(story.language),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Hikaye bilgileri
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Hikaye başlığı
                      Text(
                        story.topic,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 8),

                      // Tür bilgisi
                      Row(
                        children: [
                          const Icon(
                            Icons.category,
                            size: 14,
                            color: AppColors.textSecondary,
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              story.genre,
                              style: const TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 12,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),

                      // Tarih bilgisi
                      if (story.createdAt.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.access_time,
                                size: 14,
                                color: AppColors.textSecondary,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                _formatDate(story.createdAt),
                                style: const TextStyle(
                                  color: AppColors.textSecondary,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Placeholder görsel widget'ı
  Widget _buildPlaceholderImage() {
    // Bilgi seviyesine göre arka plan rengi belirle
    Color startColor;
    Color endColor;

    switch (story.knowledgeLevel) {
      case 'beginner':
        startColor = AppColors.beginnerColor.withOpacity(0.3);
        endColor = AppColors.beginnerColor.withOpacity(0.1);
        break;
      case 'intermediate':
        startColor = AppColors.intermediateColor.withOpacity(0.3);
        endColor = AppColors.intermediateColor.withOpacity(0.1);
        break;
      case 'expert':
        startColor = AppColors.expertColor.withOpacity(0.3);
        endColor = AppColors.expertColor.withOpacity(0.1);
        break;
      default:
        startColor = Colors.grey[300]!;
        endColor = Colors.grey[200]!;
    }

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            startColor,
            endColor,
          ],
        ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              _getGenreIcon(story.genre),
              size: 40,
              color: _getIconColor(),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                story.topic,
                style: TextStyle(
                  color: Colors.grey[800],
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Bilgi seviyesine göre ikon rengi döndürür
  Color _getIconColor() {
    switch (story.knowledgeLevel) {
      case 'beginner':
        return AppColors.beginnerColor;
      case 'intermediate':
        return AppColors.intermediateColor;
      case 'expert':
        return AppColors.expertColor;
      default:
        return Colors.grey[600]!;
    }
  }

  /// Bilgi seviyesi metnini döndürür
  String _getKnowledgeLevelText(String level) {
    switch (level) {
      case 'beginner':
        return 'Başlangıç';
      case 'intermediate':
        return 'Orta';
      case 'expert':
        return 'İleri';
      default:
        return level;
    }
  }

  /// Bilgi seviyesi ikonunu döndürür
  IconData _getKnowledgeLevelIcon(String level) {
    switch (level) {
      case 'beginner':
        return Icons.school;
      case 'intermediate':
        return Icons.auto_stories;
      case 'expert':
        return Icons.psychology;
      default:
        return Icons.school;
    }
  }

  /// Dil metnini döndürür
  String _getLanguageText(String language) {
    switch (language) {
      case 'tr':
        return 'TR';
      case 'en':
        return 'EN';
      default:
        return language.toUpperCase();
    }
  }

  /// Tür ikonunu döndürür
  IconData _getGenreIcon(String genre) {
    // Türe göre ikon seç
    if (genre.toLowerCase().contains('bilim')) {
      return Icons.science;
    } else if (genre.toLowerCase().contains('tarih')) {
      return Icons.history_edu;
    } else if (genre.toLowerCase().contains('sanat')) {
      return Icons.palette;
    } else if (genre.toLowerCase().contains('teknoloji')) {
      return Icons.computer;
    } else if (genre.toLowerCase().contains('matematik')) {
      return Icons.functions;
    } else if (genre.toLowerCase().contains('edebiyat')) {
      return Icons.menu_book;
    } else {
      return Icons.menu_book;
    }
  }

  /// Tarihi formatlar
  String _formatDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      final now = DateTime.now();
      final difference = now.difference(date);

      if (difference.inDays < 1) {
        if (difference.inHours < 1) {
          return '${difference.inMinutes} dk önce';
        } else {
          return '${difference.inHours} saat önce';
        }
      } else if (difference.inDays < 30) {
        return '${difference.inDays} gün önce';
      } else {
        return '${date.day}/${date.month}/${date.year}';
      }
    } catch (e) {
      return dateString;
    }
  }
}
