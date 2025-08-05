import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../state/auth_state.dart';
import '../../widgets/common/loading_overlay.dart';

/// Profil ekranı
class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  bool _notificationsEnabled = true;
  String _selectedTheme = 'system'; // system, light, dark
  String _selectedLanguage = 'tr'; // tr, en

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authStateProvider);
    final user = authState.user;

    // Hata durumunda SnackBar göster
    if (authState.error != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(authState.error!.message),
            backgroundColor: AppColors.error,
          ),
        );
        ref.read(authStateProvider.notifier).clearError();
      });
    }

    return LoadingOverlay(
      isLoading: authState.isLoading,
      child: Scaffold(
        appBar: AppBar(
          title: const Text(AppStrings.profile),
          centerTitle: true,
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Profil başlığı
                _buildProfileHeader(
                  context,
                  user?.fullName ?? 'Kullanıcı',
                  user?.email ?? '',
                ),
                const SizedBox(height: 32),

                // Profil bilgileri
                _buildSectionTitle(context, AppStrings.personalInfo),
                _buildProfileInfoCard(context),
                const SizedBox(height: 24),

                // Uygulama ayarları
                _buildSectionTitle(context, AppStrings.appSettings),
                _buildSettingsCard(context),
                const SizedBox(height: 24),

                // Gizlilik ve güvenlik
                _buildSectionTitle(context, AppStrings.privacy),
                _buildPrivacyCard(context),
                const SizedBox(height: 24),

                // Hakkında
                _buildSectionTitle(context, AppStrings.about),
                _buildAboutCard(context),
                const SizedBox(height: 24),

                // Çıkış yap butonu
                Center(
                  child: OutlinedButton.icon(
                    onPressed: () => _showLogoutConfirmation(context),
                    icon: const Icon(Icons.logout, color: AppColors.error),
                    label: Text(
                      AppStrings.logout,
                      style: const TextStyle(color: AppColors.error),
                    ),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: AppColors.error),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Profil başlığı
  Widget _buildProfileHeader(BuildContext context, String name, String email) {
    return Center(
      child: Column(
        children: [
          // Profil resmi
          CircleAvatar(
            radius: 50,
            backgroundColor: AppColors.primary.withOpacity(0.2),
            child: Text(
              name.isNotEmpty ? name[0].toUpperCase() : '?',
              style: const TextStyle(
                fontSize: 40,
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
            ),
          ),
          const SizedBox(height: 16),
          // Kullanıcı adı
          Text(
            name,
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          // Kullanıcı e-postası
          Text(
            email,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }

  /// Bölüm başlığı
  Widget _buildSectionTitle(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(
        title,
        style: Theme.of(
          context,
        ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
      ),
    );
  }

  /// Profil bilgileri kartı
  Widget _buildProfileInfoCard(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(
        children: [
          // Profili düzenle
          ListTile(
            leading: const Icon(Icons.edit, color: AppColors.primary),
            title: const Text(AppStrings.editProfile),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              // Profil düzenleme ekranına yönlendir
            },
          ),
          const Divider(height: 1),
          // Dil seçimi
          ListTile(
            leading: const Icon(Icons.language, color: AppColors.primary),
            title: const Text(AppStrings.language),
            trailing: DropdownButton<String>(
              value: _selectedLanguage,
              underline: const SizedBox(),
              items: const [
                DropdownMenuItem(value: 'tr', child: Text(AppStrings.turkish)),
                DropdownMenuItem(value: 'en', child: Text(AppStrings.english)),
              ],
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    _selectedLanguage = value;
                  });
                  // Dil değiştirme işlemi (ileride eklenecek)
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  /// Ayarlar kartı
  Widget _buildSettingsCard(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(
        children: [
          // Bildirimler
          SwitchListTile(
            secondary: const Icon(
              Icons.notifications_outlined,
              color: AppColors.primary,
            ),
            title: const Text(AppStrings.notifications),
            value: _notificationsEnabled,
            onChanged: (value) {
              setState(() {
                _notificationsEnabled = value;
              });
              // Bildirim ayarlarını kaydet (ileride eklenecek)
            },
          ),
          const Divider(height: 1),
          // Tema seçimi
          ListTile(
            leading: const Icon(
              Icons.palette_outlined,
              color: AppColors.primary,
            ),
            title: const Text(AppStrings.theme),
            trailing: DropdownButton<String>(
              value: _selectedTheme,
              underline: const SizedBox(),
              items: const [
                DropdownMenuItem(
                  value: 'system',
                  child: Text(AppStrings.systemDefault),
                ),
                DropdownMenuItem(
                  value: 'light',
                  child: Text(AppStrings.lightMode),
                ),
                DropdownMenuItem(
                  value: 'dark',
                  child: Text(AppStrings.darkMode),
                ),
              ],
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    _selectedTheme = value;
                  });
                  // Tema değiştirme işlemi (ileride eklenecek)
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  /// Gizlilik kartı
  Widget _buildPrivacyCard(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(
        children: [
          // Kullanım koşulları
          ListTile(
            leading: const Icon(
              Icons.description_outlined,
              color: AppColors.primary,
            ),
            title: const Text(AppStrings.termsAndConditions),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              // Kullanım koşulları sayfasına yönlendir
            },
          ),
          const Divider(height: 1),
          // Gizlilik politikası
          ListTile(
            leading: const Icon(
              Icons.security_outlined,
              color: AppColors.primary,
            ),
            title: const Text(AppStrings.privacyPolicy),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              // Gizlilik politikası sayfasına yönlendir
            },
          ),
        ],
      ),
    );
  }

  /// Hakkında kartı
  Widget _buildAboutCard(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(
        children: [
          // Yardım ve destek
          ListTile(
            leading: const Icon(Icons.help_outline, color: AppColors.primary),
            title: const Text(AppStrings.helpAndSupport),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              // Yardım ve destek sayfasına yönlendir
            },
          ),
          const Divider(height: 1),
          // Bize ulaşın
          ListTile(
            leading: const Icon(Icons.email_outlined, color: AppColors.primary),
            title: const Text(AppStrings.contactUs),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              // İletişim sayfasına yönlendir
            },
          ),
          const Divider(height: 1),
          // Versiyon
          ListTile(
            leading: const Icon(Icons.info_outline, color: AppColors.primary),
            title: const Text(AppStrings.version),
            trailing: const Text('1.0.0'),
          ),
        ],
      ),
    );
  }

  /// Çıkış yapmadan önce onay diyaloğu gösterir
  void _showLogoutConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(AppStrings.logout),
        content: const Text(AppStrings.logoutConfirmation),
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
              if (context.mounted &&
                  !ref.read(authStateProvider).isAuthenticated) {
                context.go('/login');
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
