import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../state/auth_state.dart';
import '../../state/story_state.dart';
import '../../widgets/common/animated_fade_transition.dart';
import '../../widgets/common/animated_scale_transition.dart';
import '../../widgets/common/animated_slide_transition.dart';
import '../../widgets/common/loading_overlay.dart';
import '../../widgets/story/story_card.dart';

/// Ana ekran sayfası
class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  final ScrollController _scrollController = ScrollController();
  bool _isScrolled = false;

  @override
  void initState() {
    super.initState();
    // Hikaye listesini yükle
    Future.microtask(() {
      ref.read(storyStateProvider.notifier).loadUserStories();
    });

    // Scroll kontrolcüsünü dinle
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  // Scroll durumunu kontrol et
  void _onScroll() {
    if (_scrollController.offset > 0 && !_isScrolled) {
      setState(() {
        _isScrolled = true;
      });
    } else if (_scrollController.offset <= 0 && _isScrolled) {
      setState(() {
        _isScrolled = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authStateProvider);
    final storyState = ref.watch(storyStateProvider);
    final user = authState.user;
    final size = MediaQuery.of(context).size;

    // Hata durumunda SnackBar göster
    if (storyState.error != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(storyState.error!.message),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            margin: EdgeInsets.only(
              bottom: size.height * 0.1,
              left: 20,
              right: 20,
            ),
          ),
        );
        ref.read(storyStateProvider.notifier).clearError();
      });
    }

    return LoadingOverlay(
      isLoading: authState.isLoading || storyState.isLoading,
      child: Scaffold(
        backgroundColor: AppColors.lightBackground,
        body: SafeArea(
          child: NestedScrollView(
            controller: _scrollController,
            headerSliverBuilder: (context, innerBoxIsScrolled) {
              return [
                // Uygulama barı
                SliverAppBar(
                  floating: true,
                  snap: true,
                  forceElevated: _isScrolled,
                  backgroundColor: AppColors.surface,
                  elevation: _isScrolled ? 4 : 0,
                  title: AnimatedFadeTransition(
                    duration: const Duration(milliseconds: 600),
                    child: Row(
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: AppColors.primary.withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.menu_book,
                            color: AppColors.primary,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 12),
                        const Text(
                          AppStrings.appName,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  actions: [
                    // Profil butonu
                    AnimatedScaleTransition(
                      duration: const Duration(milliseconds: 600),
                      delay: const Duration(milliseconds: 100),
                      child: IconButton(
                        icon: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.person,
                            color: AppColors.primary,
                            size: 20,
                          ),
                        ),
                        tooltip: AppStrings.profile,
                        onPressed: () {
                          context.push('/profile');
                        },
                      ),
                    ),
                    // Çıkış butonu
                    AnimatedScaleTransition(
                      duration: const Duration(milliseconds: 600),
                      delay: const Duration(milliseconds: 200),
                      child: IconButton(
                        icon: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: AppColors.error.withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.logout,
                            color: AppColors.error,
                            size: 20,
                          ),
                        ),
                        tooltip: AppStrings.logout,
                        onPressed: () {
                          _showLogoutConfirmation(context, ref);
                        },
                      ),
                    ),
                    const SizedBox(width: 8),
                  ],
                ),
              ];
            },
            body: RefreshIndicator(
              onRefresh: () async {
                await ref.read(storyStateProvider.notifier).loadUserStories();
              },
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 24),

                    // Kullanıcı karşılama bölümü
                    AnimatedSlideTransition(
                      duration: const Duration(milliseconds: 800),
                      curve: Curves.easeOutQuint,
                      child: AnimatedFadeTransition(
                        duration: const Duration(milliseconds: 800),
                        curve: Curves.easeOutQuint,
                        child: Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                AppColors.primary,
                                AppColors.primaryLight,
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.primary.withOpacity(0.3),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Merhaba, ${user?.fullName ?? 'Kullanıcı'}!',
                                style: const TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(height: 8),
                              const Text(
                                'Bugün ne öğrenmek istersin?',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.white,
                                  fontWeight: FontWeight.w300,
                                ),
                              ),
                              const SizedBox(height: 20),

                              // Hikaye oluştur butonu
                              ElevatedButton.icon(
                                onPressed: () {
                                  context.push('/create-story');
                                },
                                icon: const Icon(Icons.add),
                                label: const Text(AppStrings.createStory),
                                style: ElevatedButton.styleFrom(
                                  foregroundColor: AppColors.primary,
                                  backgroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 20,
                                    vertical: 12,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 30),

                    // Hikayelerim başlığı
                    AnimatedSlideTransition(
                      duration: const Duration(milliseconds: 800),
                      delay: const Duration(milliseconds: 200),
                      curve: Curves.easeOutQuint,
                      child: AnimatedFadeTransition(
                        duration: const Duration(milliseconds: 800),
                        delay: const Duration(milliseconds: 200),
                        curve: Curves.easeOutQuint,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              AppStrings.myStories,
                              style: Theme.of(context)
                                  .textTheme
                                  .titleLarge
                                  ?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                            if (storyState.stories.isNotEmpty)
                              Text(
                                '${storyState.stories.length} hikaye',
                                style: TextStyle(
                                  color: AppColors.textSecondary,
                                  fontSize: 14,
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Hikaye listesi
                    AnimatedSlideTransition(
                      duration: const Duration(milliseconds: 800),
                      delay: const Duration(milliseconds: 300),
                      curve: Curves.easeOutQuint,
                      child: AnimatedFadeTransition(
                        duration: const Duration(milliseconds: 800),
                        delay: const Duration(milliseconds: 300),
                        curve: Curves.easeOutQuint,
                        child: _buildStoryList(storyState),
                      ),
                    ),

                    // Alt boşluk
                    const SizedBox(height: 30),
                  ],
                ),
              ),
            ),
          ),
        ),

        // Yüzen hikaye oluşturma butonu
        floatingActionButton: storyState.stories.isNotEmpty
            ? AnimatedScaleTransition(
                duration: const Duration(milliseconds: 600),
                delay: const Duration(milliseconds: 800),
                child: FloatingActionButton(
                  onPressed: () {
                    context.push('/create-story');
                  },
                  backgroundColor: AppColors.primary,
                  child: const Icon(Icons.add),
                ),
              )
            : null,
      ),
    );
  }

  /// Hikaye listesini oluşturur
  Widget _buildStoryList(StoryState storyState) {
    // Hikaye yoksa
    if (storyState.stories.isEmpty && !storyState.isLoading) {
      return Container(
        padding: const EdgeInsets.symmetric(vertical: 40),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.menu_book,
                  size: 64,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'Henüz hikayen yok',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              const Text(
                'Yeni bir hikaye oluşturmak için yukarıdaki butona tıkla.',
                style: TextStyle(
                  fontSize: 16,
                  color: AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: () {
                  context.push('/create-story');
                },
                icon: const Icon(Icons.add),
                label: const Text('Hikaye Oluştur'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
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

    // Hikaye listesi
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.7,
        crossAxisSpacing: 15,
        mainAxisSpacing: 15,
      ),
      itemCount: storyState.stories.length,
      itemBuilder: (context, index) {
        final story = storyState.stories[index];
        return AnimatedScaleTransition(
          duration: const Duration(milliseconds: 600),
          delay: Duration(milliseconds: 400 + (index * 100)),
          child: StoryCard(
            story: story,
            onTap: () {
              // Hikaye detay sayfasına yönlendir
              context.push('/story/${story.storyId}');
            },
          ),
        );
      },
    );
  }

  /// Çıkış yapmadan önce onay diyaloğu gösterir
  void _showLogoutConfirmation(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: const Text('Çıkış Yap'),
        content: const Text(
          'Hesabınızdan çıkış yapmak istediğinize emin misiniz?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(AppStrings.cancel),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context); // Dialog'u kapat

              // Çıkış işlemi
              await ref.read(authStateProvider.notifier).logout();

              // Yönlendirme artık router tarafından otomatik yapılacak
              // Ek olarak manuel yönlendirme gerekirse:
              if (context.mounted &&
                  !ref.read(authStateProvider).isAuthenticated) {
                GoRouter.of(context).go('/login');
              }
            },
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text(AppStrings.logout),
          ),
        ],
      ),
    );
  }
}
