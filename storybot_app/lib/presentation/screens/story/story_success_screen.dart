import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../data/models/story_model.dart';

/// Hikaye oluşturma başarı ekranı
class StorySuccessScreen extends StatelessWidget {
  final StoryModel story;

  const StorySuccessScreen({super.key, required this.story});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Başarı ikonu
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check_circle,
                  color: AppColors.primary,
                  size: 80,
                ),
              ),
              const SizedBox(height: 32),

              // Başlık
              Text(
                AppStrings.storySuccess,
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),

              // Açıklama
              Text(
                AppStrings.storySuccessDescription,
                style: Theme.of(
                  context,
                ).textTheme.bodyLarge?.copyWith(color: AppColors.textSecondary),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),

              // Hikaye bilgileri kartı
              _buildStoryInfoCard(context),
              const SizedBox(height: 32),

              // Hikayeyi görüntüle butonu
              ElevatedButton.icon(
                onPressed: () => _navigateToStoryDetail(context),
                icon: const Icon(Icons.auto_stories),
                label: Text(AppStrings.viewStory),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 16,
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Ana sayfaya dön butonu
              TextButton.icon(
                onPressed: () => _navigateToHome(context),
                icon: const Icon(Icons.home),
                label: Text(AppStrings.goToHome),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Hikaye bilgileri kartı
  Widget _buildStoryInfoCard(BuildContext context) {
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

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Hikaye başlığı
            Text(
              story.topic,
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),

            // Hikaye detayları
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                // Bilgi seviyesi
                _buildInfoChip(
                  context,
                  _getKnowledgeLevelText(story.knowledgeLevel),
                  Icons.school,
                  levelColor,
                ),

                // Tür
                _buildInfoChip(
                  context,
                  _getGenreText(story.genre),
                  Icons.category,
                  AppColors.primary,
                ),

                // Dil
                _buildInfoChip(
                  context,
                  _getLanguageText(story.language),
                  Icons.language,
                  AppColors.info,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// Bilgi çipi
  Widget _buildInfoChip(
    BuildContext context,
    String label,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 16),
          const SizedBox(width: 6),
          Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: color,
                  fontWeight: FontWeight.bold,
                ),
          ),
        ],
      ),
    );
  }

  /// Hikaye detay sayfasına yönlendirir
  void _navigateToStoryDetail(BuildContext context) {
    context.go('/story/${story.storyId}');
  }

  /// Ana sayfaya yönlendirir
  void _navigateToHome(BuildContext context) {
    context.go('/');
  }

  /// Bilgi seviyesi metnini döndürür
  String _getKnowledgeLevelText(String level) {
    switch (level) {
      case 'beginner':
        return AppStrings.beginner;
      case 'intermediate':
        return AppStrings.intermediate;
      case 'expert':
        return AppStrings.expert;
      default:
        return level;
    }
  }

  /// Tür metnini döndürür
  String _getGenreText(String genre) {
    switch (genre) {
      case 'fantasy':
        return 'Fantastik';
      case 'science_fiction':
        return 'Bilim Kurgu';
      case 'adventure':
        return 'Macera';
      case 'mystery':
        return 'Gizem';
      case 'historical':
        return 'Tarihsel';
      case 'educational':
        return 'Eğitici';
      default:
        return genre;
    }
  }

  /// Dil metnini döndürür
  String _getLanguageText(String language) {
    switch (language) {
      case 'tr':
        return AppStrings.turkish;
      case 'en':
        return AppStrings.english;
      default:
        return language;
    }
  }
}
