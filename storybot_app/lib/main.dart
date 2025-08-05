import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'core/constants/app_theme.dart';
import 'data/providers/dio_provider.dart';
import 'data/repositories/audio_repository.dart';
import 'data/repositories/auth_repository.dart';
import 'data/repositories/story_creation_repository.dart';
import 'data/repositories/story_repository.dart';
import 'domain/services/audio_service.dart';
import 'domain/services/auth_service.dart';
import 'domain/services/story_creation_service.dart';
import 'domain/services/story_service.dart';
import 'presentation/navigation/app_router.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Bağımlılıkları oluştur
  final secureStorage = const FlutterSecureStorage();
  final dioProvider = DioProvider(secureStorage: secureStorage);
  final dio = dioProvider.getDio();
  final googleSignIn = GoogleSignIn();

  final authRepository = AuthRepository(dio: dio, secureStorage: secureStorage);
  final storyRepository = StoryRepository(dio: dio);
  final audioRepository = AudioRepository(dio: dio);
  final storyCreationRepository = StoryCreationRepository(dio: dio);

  final authService = AuthService(
    authRepository: authRepository,
    googleSignIn: googleSignIn,
  );

  final storyService = StoryService(storyRepository: storyRepository);
  final audioService = AudioService(audioRepository: audioRepository);
  final storyCreationService = StoryCreationService(
    storyCreationRepository: storyCreationRepository,
  );

  // Provider override'ları oluştur
  final providerContainer = ProviderContainer(
    overrides: [
      authServiceProvider.overrideWithValue(authService),
      storyServiceProvider.overrideWithValue(storyService),
      audioServiceProvider.overrideWithValue(audioService),
      storyCreationServiceProvider.overrideWithValue(storyCreationService),
    ],
  );

  runApp(
    UncontrolledProviderScope(
      container: providerContainer,
      child: const MyApp(),
    ),
  );
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);

    return MaterialApp.router(
      title: 'Öykülem',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      routerConfig: router,
      debugShowCheckedModeBanner: false,
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [Locale('tr', 'TR'), Locale('en', 'US')],
    );
  }
}
