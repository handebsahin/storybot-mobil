import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../data/models/story_request_model.dart';
import '../../state/story_creation_state.dart';
import '../../widgets/common/loading_overlay.dart';

/// Hikaye oluşturma ekranı
class CreateStoryScreen extends ConsumerStatefulWidget {
  const CreateStoryScreen({super.key});

  @override
  ConsumerState<CreateStoryScreen> createState() => _CreateStoryScreenState();
}

class _CreateStoryScreenState extends ConsumerState<CreateStoryScreen> {
  final _formKey = GlobalKey<FormState>();
  final _topicController = TextEditingController();
  String _selectedKnowledgeLevel = KnowledgeLevels.beginner;
  String _selectedGenre = StoryGenres.educational;
  String _selectedLanguage = StoryLanguages.turkish;
  bool _isNavigating = false;

  @override
  void dispose() {
    _topicController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final creationState = ref.watch(storyCreationStateProvider);
    final textTheme = Theme.of(context).textTheme;

    // Hikaye oluşturulduysa başarı sayfasına yönlendir
    if (creationState.generatedStory != null && !_isNavigating) {
      _isNavigating = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        context.go('/story-success');
      });
    }

    // Hata durumunda SnackBar göster
    if (creationState.error != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        // Hata mesajını daha detaylı göster
        String errorMessage = creationState.error!.message;

        // İnternet bağlantısı hatası için özel mesaj
        if (errorMessage.contains('İnternet bağlantısı') ||
            errorMessage.contains('connection') ||
            errorMessage.contains('network')) {
          errorMessage =
              'İnternet bağlantısı hatası. Lütfen bağlantınızı kontrol edin ve tekrar deneyin.';
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Hata Oluştu',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(errorMessage),
              ],
            ),
            backgroundColor: AppColors.error,
            duration: const Duration(seconds: 5),
            action: SnackBarAction(
              label: 'Tekrar Dene',
              textColor: Colors.white,
              onPressed: () {
                // Hata durumunu temizle ve tekrar dene
                ref.read(storyCreationStateProvider.notifier).clearError();
              },
            ),
          ),
        );
        ref.read(storyCreationStateProvider.notifier).clearError();
      });
    }

    return LoadingOverlay(
      isLoading: creationState.isLoading,
      child: Scaffold(
        appBar: AppBar(
          title: const Text(AppStrings.createStory),
          centerTitle: true,
        ),
        body: creationState.isGenerating
            ? _buildGeneratingView(context, creationState)
            : _buildCreateStoryForm(context, textTheme),
      ),
    );
  }

  /// Hikaye oluşturma formunu oluşturur
  Widget _buildCreateStoryForm(BuildContext context, TextTheme textTheme) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Form başlığı
              Text(
                AppStrings.createStoryTitle,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                AppStrings.createStoryDescription,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.textSecondary,
                    ),
              ),
              const SizedBox(height: 32),

              // Konu alanı
              _buildSectionTitle(context, AppStrings.selectTopic),
              const SizedBox(height: 8),
              TextFormField(
                controller: _topicController,
                decoration: InputDecoration(
                  hintText: AppStrings.topicHint,
                  prefixIcon: const Icon(Icons.topic),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return AppStrings.topicRequired;
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),

              // Bilgi seviyesi seçimi
              _buildSectionTitle(context, AppStrings.selectKnowledgeLevel),
              const SizedBox(height: 8),
              _buildKnowledgeLevelSelector(),
              const SizedBox(height: 24),

              // Tür seçimi
              _buildSectionTitle(context, AppStrings.selectGenre),
              const SizedBox(height: 8),
              _buildGenreSelector(),
              const SizedBox(height: 24),

              // Dil seçimi
              _buildSectionTitle(context, AppStrings.selectLanguage),
              const SizedBox(height: 8),
              _buildLanguageSelector(),
              const SizedBox(height: 32),

              // Hikaye oluştur butonu
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _generateStory,
                  icon: const Icon(Icons.auto_stories),
                  label: const Text(AppStrings.generate),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Hikaye oluşturma durumunu gösteren görünümü oluşturur
  Widget _buildGeneratingView(BuildContext context, StoryCreationState state) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Animasyonlu ilerleme göstergesi
            const CircularProgressIndicator(),
            const SizedBox(height: 24),
            // Başlık
            Text(
              AppStrings.generating,
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            // Açıklama
            Text(
              AppStrings.generatingDescription,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            // İlerleme göstergesi (eğer varsa)
            if (state.progress != null) ...[
              LinearProgressIndicator(
                value: state.progress! / 100,
                backgroundColor: AppColors.primary.withOpacity(0.2),
                valueColor: const AlwaysStoppedAnimation<Color>(
                  AppColors.primary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '%${state.progress!.toInt()}',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          ],
        ),
      ),
    );
  }

  /// Bölüm başlığı
  Widget _buildSectionTitle(BuildContext context, String title) {
    return Text(
      title,
      style: Theme.of(
        context,
      ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
    );
  }

  /// Bilgi seviyesi seçici
  Widget _buildKnowledgeLevelSelector() {
    return Card(
      elevation: 0,
      color: Theme.of(context).colorScheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: Theme.of(context).colorScheme.outline.withOpacity(0.5),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Column(
          children: KnowledgeLevels.getAll().map((level) {
            final displayName = KnowledgeLevels.getDisplayName(level);

            // Seviyeye göre renk belirle
            Color levelColor;
            IconData levelIcon;
            switch (level) {
              case KnowledgeLevels.beginner:
                levelColor = AppColors.beginnerColor;
                levelIcon = Icons.school;
                break;
              case KnowledgeLevels.intermediate:
                levelColor = AppColors.intermediateColor;
                levelIcon = Icons.auto_stories;
                break;
              case KnowledgeLevels.expert:
                levelColor = AppColors.expertColor;
                levelIcon = Icons.psychology;
                break;
              default:
                levelColor = AppColors.primary;
                levelIcon = Icons.school;
            }

            return RadioListTile<String>(
              title: Row(
                children: [
                  Icon(levelIcon, color: levelColor),
                  const SizedBox(width: 12),
                  Text(displayName),
                ],
              ),
              value: level,
              groupValue: _selectedKnowledgeLevel,
              activeColor: levelColor,
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    _selectedKnowledgeLevel = value;
                  });
                }
              },
            );
          }).toList(),
        ),
      ),
    );
  }

  /// Tür seçici
  Widget _buildGenreSelector() {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: StoryGenres.getAll().map((genre) {
        final displayName = StoryGenres.getDisplayName(genre);
        final bool isSelected = _selectedGenre == genre;

        // Türe göre ikon belirle
        IconData genreIcon;
        switch (genre) {
          case StoryGenres.fantasy:
            genreIcon = Icons.auto_fix_high;
            break;
          case StoryGenres.scienceFiction:
            genreIcon = Icons.rocket_launch;
            break;
          case StoryGenres.adventure:
            genreIcon = Icons.explore;
            break;
          case StoryGenres.mystery:
            genreIcon = Icons.search;
            break;
          case StoryGenres.historical:
            genreIcon = Icons.history_edu;
            break;
          case StoryGenres.educational:
            genreIcon = Icons.school;
            break;
          default:
            genreIcon = Icons.book;
        }

        return ChoiceChip(
          label: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                genreIcon,
                size: 16,
                color: isSelected ? Colors.white : AppColors.primary,
              ),
              const SizedBox(width: 8),
              Text(displayName),
            ],
          ),
          selected: isSelected,
          onSelected: (selected) {
            if (selected) {
              setState(() {
                _selectedGenre = genre;
              });
            }
          },
          backgroundColor: Theme.of(context).colorScheme.surface,
          selectedColor: AppColors.primary,
          labelStyle: TextStyle(color: isSelected ? Colors.white : null),
        );
      }).toList(),
    );
  }

  /// Dil seçici
  Widget _buildLanguageSelector() {
    return Card(
      elevation: 0,
      color: Theme.of(context).colorScheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: Theme.of(context).colorScheme.outline.withOpacity(0.5),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Column(
          children: StoryLanguages.getAll().map((language) {
            final displayName = StoryLanguages.getDisplayName(language);

            // Dile göre bayrak belirle
            String flag;
            switch (language) {
              case StoryLanguages.turkish:
                flag = '🇹🇷';
                break;
              case StoryLanguages.english:
                flag = '🇬🇧';
                break;
              default:
                flag = '🌍';
            }

            return RadioListTile<String>(
              title: Row(
                children: [
                  Text(flag, style: const TextStyle(fontSize: 20)),
                  const SizedBox(width: 12),
                  Text(displayName),
                ],
              ),
              value: language,
              groupValue: _selectedLanguage,
              activeColor: AppColors.primary,
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    _selectedLanguage = value;
                  });
                }
              },
            );
          }).toList(),
        ),
      ),
    );
  }

  /// Hikaye oluşturma işlemi
  void _generateStory() {
    if (_formKey.currentState!.validate()) {
      FocusScope.of(context).unfocus();

      // Hikaye oluşturma isteği oluştur
      final request = StoryRequestModel(
        topic: _topicController.text.trim(),
        knowledgeLevel: _selectedKnowledgeLevel,
        genre: _selectedGenre,
        language: _selectedLanguage,
      );

      // Hikaye oluşturma isteğini gönder
      ref.read(storyCreationStateProvider.notifier).generateStory(request);
    }
  }
}
