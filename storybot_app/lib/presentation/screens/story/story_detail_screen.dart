import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../data/models/story_model.dart';
import '../../state/audio_state.dart';
import '../../state/story_state.dart';
import '../../widgets/story/audio_player_widget.dart';
// import '../../widgets/story/highlighted_text.dart'; // Senkronize metin özelliği kaldırıldı
import '../../widgets/story/key_concept_card.dart';
import '../../widgets/story/markdown_text_widget.dart';

/// Hikaye detay ekranı
class StoryDetailScreen extends ConsumerStatefulWidget {
  final int storyId;
  final int initialSection;

  const StoryDetailScreen({
    super.key,
    required this.storyId,
    this.initialSection = 1,
  });

  @override
  ConsumerState<StoryDetailScreen> createState() => _StoryDetailScreenState();
}

class _StoryDetailScreenState extends ConsumerState<StoryDetailScreen> {
  int _currentSection = 1;
  List<String> _keywordList = [];
  bool _isAudioLoading = false;
  bool _isDisposed = false;

  @override
  void initState() {
    super.initState();
    _currentSection = widget.initialSection;

    // Hikaye detaylarını yükle
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadStoryDetails();
    });
  }

  @override
  void dispose() {
    _isDisposed = true;
    // Ses durumunu sıfırla ve oynatıcıyı durdur
    final audioState = ref.read(audioStateProvider);
    if (audioState.isPlaying) {
      print('Stopping audio player on dispose');
      // AudioPlayerWidget'a doğrudan erişemiyoruz, bu yüzden durum üzerinden resetliyoruz
      ref.read(audioStateProvider.notifier).resetState();
    } else {
      ref.read(audioStateProvider.notifier).resetState();
    }
    super.dispose();
  }

  /// Hikaye detaylarını yükler
  Future<void> _loadStoryDetails() async {
    try {
      await ref
          .read(storyStateProvider.notifier)
          .loadStoryDetails(widget.storyId);

      // Hikaye yüklenip yüklenmediğini kontrol et
      final storyState = ref.read(storyStateProvider);
      if (storyState.storyDetails != null) {
        print('Story loaded successfully: ${storyState.storyDetails!.topic}');
        if (storyState.storyDetails!.sections.isNotEmpty) {
          print('Sections count: ${storyState.storyDetails!.sections.length}');
          final section =
              storyState.storyDetails!.sections[_currentSection - 1];
          print(
              'Current section content: ${section.content.substring(0, min(100, section.content.length))}...');
        } else {
          print('Story has no sections');
        }
      } else {
        print('Story details is null after loading');
      }

      // Hikaye yüklendikten sonra ses bilgilerini yükle
      _loadAudioInfo();

      // Anahtar kelimeleri çıkar
      _extractKeywords();
    } catch (e) {
      print('Error loading story details: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Hikaye yüklenirken hata: $e')),
        );
      }
    }
  }

  /// Ses bilgilerini yükler
  Future<void> _loadAudioInfo() async {
    if (_isDisposed) return;

    setState(() {
      _isAudioLoading = true;
    });

    try {
      await ref
          .read(audioStateProvider.notifier)
          .loadAudioSync(widget.storyId, _currentSection);

      // Ses bilgilerini logla
      final audioState = ref.read(audioStateProvider);
      if (audioState.audioSync != null) {
        print('Audio sync loaded: hasAudio=${audioState.audioSync!.hasAudio}, '
            'hasBase64Audio=${audioState.audioSync!.hasBase64Audio}, '
            'hasAudioContent=${audioState.audioSync!.hasAudioContent}, '
            'audioUrl=${audioState.audioSync!.audioUrl != null}');
      }
    } catch (e) {
      print('Error loading audio info: $e');
    } finally {
      if (mounted && !_isDisposed) {
        setState(() {
          _isAudioLoading = false;
        });
      }
    }
  }

  /// Hikayeden anahtar kelimeleri çıkarır
  void _extractKeywords() {
    if (_isDisposed) return;

    final storyState = ref.read(storyStateProvider);
    if (storyState.storyDetails != null) {
      // Mevcut bölüme ait anahtar kelimeleri filtrele
      final currentSectionConcepts = storyState.storyDetails!.concepts
          .where((concept) => concept.sectionNumber == _currentSection)
          .toList();

      // Anahtar kelimeleri listeye ekle
      if (mounted && !_isDisposed) {
        setState(() {
          _keywordList =
              currentSectionConcepts.map((concept) => concept.keyword).toList();
          print('Extracted keywords: $_keywordList');
        });
      }

      // Konsola hikaye içeriğini yazdır
      if (storyState.storyDetails!.sections.isNotEmpty) {
        final sectionIndex = _currentSection - 1;
        if (sectionIndex >= 0 &&
            sectionIndex < storyState.storyDetails!.sections.length) {
          final section = storyState.storyDetails!.sections[sectionIndex];
          print(
              'Section content: ${section.content.substring(0, min(100, section.content.length))}...');
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final storyState = ref.watch(storyStateProvider);
    final audioState = ref.watch(audioStateProvider);
    final story = storyState.storyDetails;

    // Debug loglarını kaldır
    // print('Building StoryDetailScreen: story=${story != null}, '
    //     'isLoading=${storyState.isLoading}, '
    //     'hasError=${storyState.error != null}');

    // if (story != null) {
    //   print('Story sections: ${story.sections.length}');
    //   if (story.sections.isNotEmpty) {
    //     print(
    //         'First section content: ${story.sections[0].content.substring(0, min(50, story.sections[0].content.length))}...');
    //   }
    // }

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(story?.topic ?? AppStrings.storyDetails),
        backgroundColor: AppColors.primary.withOpacity(0.95),
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            bottom: Radius.circular(20),
          ),
        ),
        actions: story != null && story.sections.isNotEmpty
            ? [
                // Bölüm bilgisi
                Container(
                  margin: const EdgeInsets.only(right: 16),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '${_currentSection}/${story.sections.length}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ]
            : null,
      ),
      body: storyState.isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : storyState.error != null
              ? _buildErrorView(storyState.error!.message)
              : story == null
                  ? const Center(child: Text('Hikaye yükleniyor...'))
                  : _buildStoryDetailView(story, audioState),
    );
  }

  /// Hikaye detay görünümünü oluşturur
  Widget _buildStoryDetailView(StoryModel story, AudioState audioState) {
    // Mevcut bölümü al
    final currentSectionIndex = _currentSection - 1;

    // Bölüm kontrolü
    if (story.sections.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 48, color: Colors.amber),
            const SizedBox(height: 16),
            Text(
              'Bu hikayenin bölümleri bulunamadı',
              style: Theme.of(context).textTheme.titleLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: () => context.go('/'),
              child: const Text('Ana Sayfaya Dön'),
            ),
          ],
        ),
      );
    }

    // Geçerli indeks kontrolü
    if (currentSectionIndex < 0 ||
        currentSectionIndex >= story.sections.length) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 48, color: Colors.amber),
            const SizedBox(height: 16),
            Text(
              'Bölüm $_currentSection bulunamadı',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _currentSection = 1; // İlk bölüme dön
                });
                _loadAudioInfo();
                _extractKeywords();
              },
              child: const Text('İlk Bölüme Dön'),
            ),
          ],
        ),
      );
    }

    final section = story.sections[currentSectionIndex];
    final sectionContent = section.content;

    // Debug mesajlarını azalt
    // print('Building section content: ${sectionContent.substring(0, min(50, sectionContent.length))}...');

    // Bölüme ait anahtar kavramları filtrele
    final sectionConcepts = story.concepts
        .where((concept) => concept.sectionNumber == _currentSection)
        .toList();

    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(
          16.0,
          MediaQuery.of(context).padding.top + kToolbarHeight + 16.0,
          16.0,
          16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Bölüm navigasyon butonları
          Container(
            margin: const EdgeInsets.symmetric(vertical: 16),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Önceki bölüm butonu
                if (_currentSection > 1)
                  Container(
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: IconButton(
                      onPressed: () {
                        setState(() {
                          _currentSection--;
                        });
                        _loadAudioInfo();
                        _extractKeywords();
                      },
                      icon: const Icon(Icons.arrow_back,
                          color: AppColors.primary),
                      tooltip: AppStrings.previousSection,
                    ),
                  )
                else
                  const SizedBox(width: 48),

                // Bölüm bilgisi
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: AppColors.lightBackground,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    'Bölüm $_currentSection / ${story.sections.length}',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                  ),
                ),

                // Sonraki bölüm butonu
                if (_currentSection < story.sections.length)
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          AppColors.primary,
                          AppColors.primaryLight,
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withOpacity(0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: IconButton(
                      onPressed: () {
                        setState(() {
                          _currentSection++;
                        });
                        _loadAudioInfo();
                        _extractKeywords();
                      },
                      icon:
                          const Icon(Icons.arrow_forward, color: Colors.white),
                      tooltip: AppStrings.nextSection,
                    ),
                  )
                else
                  const SizedBox(width: 48),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Hikaye içeriği
          Container(
            margin: const EdgeInsets.only(bottom: 16),
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
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Bölüm görseli (eğer varsa)
                if (section.imageUrl.isNotEmpty)
                  ClipRRect(
                    borderRadius:
                        const BorderRadius.vertical(top: Radius.circular(16)),
                    child: Stack(
                      children: [
                        Image.network(
                          section.imageUrl,
                          width: double.infinity,
                          height: 180,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            print('Image error: $error');
                            return Container(
                              width: double.infinity,
                              height: 120,
                              color:
                                  _getKnowledgeLevelColor(story.knowledgeLevel)
                                      .withOpacity(0.2),
                              child: Center(
                                child: Icon(
                                  _getKnowledgeLevelIcon(story.knowledgeLevel),
                                  size: 48,
                                  color: _getKnowledgeLevelColor(
                                      story.knowledgeLevel),
                                ),
                              ),
                            );
                          },
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return Container(
                              width: double.infinity,
                              height: 180,
                              color: Colors.grey.shade100,
                              child: Center(
                                child: CircularProgressIndicator(
                                  value: loadingProgress.expectedTotalBytes !=
                                          null
                                      ? loadingProgress.cumulativeBytesLoaded /
                                          loadingProgress.expectedTotalBytes!
                                      : null,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    _getKnowledgeLevelColor(
                                        story.knowledgeLevel),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                        // Hikaye bilgisi badge
                        Positioned(
                          top: 8,
                          right: 8,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 5),
                            decoration: BoxDecoration(
                              color:
                                  _getKnowledgeLevelColor(story.knowledgeLevel),
                              borderRadius: BorderRadius.circular(12),
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
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        // Konu badge
                        Positioned(
                          bottom: 8,
                          left: 8,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 5),
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.6),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              story.topic,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                // Hikaye içeriği
                Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Başlık
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withOpacity(0.1),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.menu_book,
                              color: AppColors.primary,
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            'Hikaye İçeriği',
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.primary,
                                ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      // Debug bilgisi - içerik uzunluğu
                      if (sectionContent.isEmpty)
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(16),
                          alignment: Alignment.center,
                          child: Column(
                            children: [
                              const Icon(Icons.warning_amber_rounded,
                                  color: Colors.amber, size: 48),
                              const SizedBox(height: 16),
                              Text(
                                'Hikaye içeriği yüklenemedi',
                                style: Theme.of(context).textTheme.titleMedium,
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 8),
                              ElevatedButton(
                                onPressed: _loadStoryDetails,
                                child: const Text('Yeniden Yükle'),
                              ),
                            ],
                          ),
                        ),
                      // Markdown metin içeriği
                      MarkdownTextWidget(text: sectionContent),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Ses oynatıcı
          _buildAudioPlayer(audioState),
          const SizedBox(height: 24),

          // Anahtar kavramlar
          if (sectionConcepts.isNotEmpty) ...[
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.lightbulb_outline,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  AppStrings.keyConcepts,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ...sectionConcepts.map((concept) => Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: KeyConceptCard(concept: concept),
                )),
          ],

          // Alt boşluk
          const SizedBox(height: 40),
        ],
      ),
    );
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

  /// Bilgi seviyesine göre ikon döndürür
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

  /// Bilgi seviyesine göre renk döndürür
  Color _getKnowledgeLevelColor(String level) {
    switch (level) {
      case 'beginner':
        return AppColors.beginnerColor;
      case 'intermediate':
        return AppColors.intermediateColor;
      case 'expert':
        return AppColors.expertColor;
      default:
        return AppColors.primary;
    }
  }

  /// Ses oynatıcı widget'ını oluşturur
  Widget _buildAudioPlayer(AudioState audioState) {
    if (_isAudioLoading) {
      return Card(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Center(
            child: Column(
              children: [
                const CircularProgressIndicator(),
                const SizedBox(height: 12),
                Text(
                  'Ses dosyası yükleniyor...',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                ),
              ],
            ),
          ),
        ),
      );
    } else if (audioState.audioSync != null && audioState.audioSync!.hasAudio) {
      return Card(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: AudioPlayerWidget(
            audioSync: audioState.audioSync!,
            onPositionChanged: (position) {
              // Senkronize metin özelliği kaldırıldı
            },
            onPlayingStateChanged: (isPlaying) {
              // Senkronize metin özelliği kaldırıldı
            },
          ),
        ),
      );
    } else if (audioState.error != null) {
      return Card(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              const Icon(Icons.error_outline, color: Colors.red, size: 48),
              const SizedBox(height: 12),
              Text(
                'Ses yüklenirken hata oluştu',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.error,
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                audioState.error!.message,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.textSecondary,
                    ),
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: _loadAudioInfo,
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
    } else {
      return Card(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              const Icon(Icons.music_off,
                  color: AppColors.textSecondary, size: 48),
              const SizedBox(height: 12),
              Text(
                AppStrings.audioNotAvailable,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.textSecondary,
                    ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: _loadAudioInfo,
                icon: const Icon(Icons.download),
                label: const Text('Ses Dosyasını Yükle'),
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
  }

  /// Hata görünümünü oluşturur
  Widget _buildErrorView(String errorMessage) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.error.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.error_outline,
                color: AppColors.error,
                size: 48,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Bir Hata Oluştu',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              errorMessage,
              style: const TextStyle(color: AppColors.textSecondary),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: _loadStoryDetails,
              icon: const Icon(Icons.refresh),
              label: const Text('Tekrar Dene'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 16),
            TextButton.icon(
              onPressed: () => context.go('/'),
              icon: const Icon(Icons.home),
              label: const Text('Ana Sayfaya Dön'),
              style: TextButton.styleFrom(
                foregroundColor: AppColors.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Yardımcı fonksiyon
  int min(int a, int b) => a < b ? a : b;
}
