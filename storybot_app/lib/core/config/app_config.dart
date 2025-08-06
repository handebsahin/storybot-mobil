/// Uygulama yapılandırma ayarlarını içeren sınıf
class AppConfig {
  // API yapılandırması
  // Emülatör için 10.0.2.2, gerçek cihaz için IP adresi kullanılmalı
  // localhost yerine 10.0.2.2 kullanılarak emülatörden API'ye erişim sağlanır
  static const String apiBaseUrl = 'http://192.168.1.49:8000';
  static const String apiVersion = 'v1';
  static const Duration apiTimeout = Duration(seconds: 30);

  // Endpoint'ler
  static const String registerEndpoint = '/api/$apiVersion/auth/register';
  static const String loginEndpoint = '/api/$apiVersion/auth/login';
  static const String googleLoginEndpoint = '/api/$apiVersion/auth/google';
  static const String generateStoryEndpoint =
      '/api/$apiVersion/stories/generate';
  static const String taskStatusEndpoint = '/api/$apiVersion/tasks/';
  static const String storyDetailsEndpoint = '/api/$apiVersion/stories/';
  static const String userStoriesEndpoint = '/api/$apiVersion/stories';

  // Ses ile ilgili endpoint'ler
  static const String audioInfoEndpoint =
      '/api/$apiVersion/stories/{story_id}/sections/{section_number}/audio/info';

  // Secure Storage anahtarları
  static const String tokenKey = 'auth_token';
  static const String userIdKey = 'user_id';
  static const String userEmailKey = 'user_email';
  static const String userNameKey = 'user_name';

  // Shared Preferences anahtarları
  static const String themeKey = 'app_theme';
  static const String languageKey = 'app_language';
  static const String ageGroupKey = 'age_group';
  static const String firstLaunchKey = 'first_launch';

  // Diğer yapılandırma değerleri
  static const int storyRefreshInterval = 5; // saniye
}
