import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../screens/auth/login_screen.dart';
import '../screens/auth/register_screen.dart';
import '../screens/home/home_screen.dart';
import '../screens/profile/profile_screen.dart';
import '../screens/story/create_story_screen.dart';
import '../screens/story/story_detail_screen.dart';
import '../screens/story/story_success_screen.dart';
import '../state/auth_state.dart';
import '../state/story_creation_state.dart';

/// Router yapılandırması
final routerProvider = Provider<GoRouter>((ref) {
  final authStateRefreshNotifier = AuthStateRefreshNotifier(ref);

  return GoRouter(
    initialLocation: '/',
    debugLogDiagnostics: true,
    refreshListenable: authStateRefreshNotifier,
    redirect: (context, state) => _handleRedirect(state, ref),
    routes: [
      // Giriş ekranı
      GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
      // Kayıt ekranı
      GoRoute(
        path: '/register',
        builder: (context, state) => const RegisterScreen(),
      ),
      // Ana ekran
      GoRoute(path: '/', builder: (context, state) => const HomeScreen()),
      // Profil ekranı
      GoRoute(
        path: '/profile',
        builder: (context, state) => const ProfileScreen(),
      ),
      // Hikaye oluşturma ekranı
      GoRoute(
        path: '/create-story',
        builder: (context, state) => const CreateStoryScreen(),
      ),
      // Hikaye başarı ekranı
      GoRoute(
        path: '/story-success',
        builder: (context, state) {
          final creationState = ref.read(storyCreationStateProvider);
          final story = creationState.generatedStory;

          // Eğer hikaye yoksa ana sayfaya yönlendir
          if (story == null) {
            return const HomeScreen();
          }

          return StorySuccessScreen(story: story);
        },
      ),
      // Hikaye detay ekranı
      GoRoute(
        path: '/story/:id',
        builder: (context, state) {
          final storyId = int.parse(state.pathParameters['id']!);
          final initialSection =
              int.tryParse(state.uri.queryParameters['section'] ?? '1') ?? 1;
          return StoryDetailScreen(
            storyId: storyId,
            initialSection: initialSection,
          );
        },
      ),
    ],
  );
});

/// Yönlendirme işleyicisi
Future<String?> _handleRedirect(GoRouterState state, Ref ref) async {
  final authState = ref.read(authStateProvider);
  final isLoggedIn = authState.isAuthenticated;

  final isGoingToLogin = state.matchedLocation == '/login';
  final isGoingToRegister = state.matchedLocation == '/register';
  final isGoingToAuth = isGoingToLogin || isGoingToRegister;

  // Giriş yapmış kullanıcı giriş/kayıt sayfalarına erişmeye çalışırsa ana sayfaya yönlendir
  if (isLoggedIn && isGoingToAuth) {
    return '/';
  }

  // Giriş yapmamış kullanıcı korumalı sayfalara erişmeye çalışırsa giriş sayfasına yönlendir
  if (!isLoggedIn && !isGoingToAuth) {
    return '/login';
  }

  // Yönlendirme gerekmiyorsa null döndür
  return null;
}

/// Auth state değişikliklerini dinleyen notifier
class AuthStateRefreshNotifier extends ChangeNotifier {
  final Ref _ref;
  bool _isInitialized = false;

  AuthStateRefreshNotifier(this._ref) {
    _init();
  }

  void _init() {
    if (_isInitialized) return;
    _isInitialized = true;

    _ref.listen(authStateProvider, (_, __) {
      notifyListeners();
    });
  }
}
