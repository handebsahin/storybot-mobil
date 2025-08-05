# 📱 Öykülem Mobil Uygulaması

Öykülem, yapay zeka destekli eğitici hikayeler sunan bir mobil uygulama projesidir. Flutter framework'ü kullanılarak geliştirilmiştir ve Clean Architecture prensiplerine uygun olarak yapılandırılmıştır.

## 🎯 Temel Özellikler

### 📚 Hikaye Yönetimi
- Kişiselleştirilmiş eğitici hikayeler
- Farklı bilgi seviyelerine göre içerik (Başlangıç, Orta, İleri)
- Hikaye kategorileri ve filtreleme
- Çoklu dil desteği (TR/EN)

### 🎧 Ses Özellikleri
- Metinden sese dönüştürme
- Profesyonel ses kayıtları
- Ses hızı kontrolü
- Bölüm bazlı ses kontrolü

### 💡 Eğitim Özellikleri
- Anahtar kavramlar ve açıklamaları
- İlerleme takibi
- Başarı rozetleri
- Öğrenme istatistikleri

### 🎨 Kullanıcı Arayüzü
- Material Design 3 tasarım
- Karanlık/Aydınlık tema desteği
- Responsive tasarım
- Özelleştirilebilir font boyutları
- Erişilebilirlik desteği

## 🏗 Teknik Mimari

### Clean Architecture
```
lib/
├── core/              # Temel bileşenler
│   ├── config/        # Yapılandırmalar
│   ├── constants/     # Sabitler
│   ├── errors/        # Hata yönetimi
│   └── utils/         # Yardımcı fonksiyonlar
├── data/              # Veri katmanı
│   ├── models/        # Veri modelleri
│   ├── repositories/  # Veri işlemleri
│   └── providers/     # Veri sağlayıcıları
├── domain/            # İş mantığı
│   ├── entities/      # Varlıklar
│   ├── services/      # Servisler
│   └── usecases/      # Kullanım durumları
└── presentation/      # Sunum katmanı
    ├── screens/       # Ekranlar
    ├── widgets/       # Bileşenler
    ├── navigation/    # Navigasyon
    └── state/         # Durum yönetimi
```

### 🔧 Kullanılan Teknolojiler
- **State Management:** Riverpod
- **Navigation:** Go Router
- **HTTP Client:** Dio
- **Local Storage:** Shared Preferences
- **Audio:** Just Audio
- **Localization:** Flutter Localizations
- **Testing:** Flutter Test

## 📱 Ekranlar ve Özellikler

### 🏠 Ana Ekran
- Hikaye listesi
- Kategori filtreleme
- Arama fonksiyonu
- İlerleme durumu gösterimi

### 📖 Hikaye Detay Ekranı
- Hikaye içeriği
- Sesli anlatım kontrolü
- Bölüm navigasyonu
- Anahtar kavramlar

### 👤 Profil Ekranı
- Kullanıcı bilgileri
- İlerleme istatistikleri
- Başarı rozetleri
- Ayarlar

### ⚙️ Ayarlar
- Tema seçimi
- Dil seçimi
- Bildirim tercihleri
- Ses ayarları
- Font boyutu ayarı

## 🔒 Güvenlik Özellikleri
- JWT tabanlı kimlik doğrulama
- Güvenli veri depolama
- API anahtar yönetimi
- SSL pinning

## 🚀 Performans Optimizasyonları
- Lazy loading
- Image caching
- Önbellek yönetimi
- Ağ çağrıları optimizasyonu

## 📊 Analytics ve Hata Takibi
- Firebase Analytics entegrasyonu
- Crash reporting
- Kullanıcı davranış analizi
- Performans metrikleri

## 🧪 Test Stratejisi
- Unit Tests
- Widget Tests
- Integration Tests
- E2E Tests

## 🔄 CI/CD Pipeline
- GitHub Actions
- Automated testing
- Code quality checks
- Automated deployment

## 📦 Dağıtım
- App Store
- Google Play Store
- Internal testing
- Beta testing

## 🌐 Backend Entegrasyonu
- REST API entegrasyonu
- WebSocket bağlantıları
- Offline mod desteği
- Veri senkronizasyonu

## 💻 Geliştirme Gereksinimleri
- Flutter SDK (3.0.0+)
- Dart SDK (3.0.0+)
- Android Studio / VS Code
- iOS için: Xcode
- Android için: Android SDK

## 🚀 Başlangıç

### Kurulum
```bash
# Repository'yi klonla
git clone [REPO_URL]

# Proje dizinine git
cd storybot-mobil/storybot_app

# Bağımlılıkları yükle
flutter pub get

# Uygulamayı çalıştır
flutter run
```

### Ortam Değişkenleri
```env
API_BASE_URL=https://api.example.com
API_VERSION=v1
```

## 👥 Katkıda Bulunma
1. Fork yapın
2. Feature branch oluşturun
3. Değişikliklerinizi commit edin
4. Branch'inizi push edin
5. Pull Request açın

## 📝 Sürüm Geçmişi
Detaylı değişiklikler için [CHANGELOG.md](CHANGELOG.md) dosyasına bakın.