import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:form_field_validator/form_field_validator.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../state/auth_state.dart';
import '../../widgets/auth/social_login_button.dart';
import '../../widgets/common/loading_overlay.dart';

/// Kayıt ekranı
class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _fullNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;
  String? _selectedAgeGroup;

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  /// Ad soyad doğrulama validatörü
  final fullNameValidator = RequiredValidator(
    errorText: AppStrings.fullNameRequired,
  );

  /// E-posta doğrulama validatörü
  final emailValidator = MultiValidator([
    RequiredValidator(errorText: AppStrings.emailRequired),
    EmailValidator(errorText: AppStrings.invalidEmail),
  ]);

  /// Şifre doğrulama validatörü
  final passwordValidator = MultiValidator([
    RequiredValidator(errorText: AppStrings.passwordRequired),
    MinLengthValidator(8, errorText: AppStrings.passwordTooShort),
  ]);

  /// Kayıt işlemi
  void _register() {
    if (_formKey.currentState!.validate()) {
      if (_passwordController.text != _confirmPasswordController.text) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(AppStrings.passwordsDontMatch),
            backgroundColor: AppColors.error,
          ),
        );
        return;
      }

      FocusScope.of(context).unfocus();
      ref
          .read(authStateProvider.notifier)
          .register(
            email: _emailController.text.trim(),
            password: _passwordController.text,
            fullName: _fullNameController.text.trim(),
            ageGroup: _selectedAgeGroup,
            preferredLanguage: 'tr', // Varsayılan dil Türkçe
          );
    }
  }

  /// Google ile giriş işlemi
  void _loginWithGoogle() {
    ref.read(authStateProvider.notifier).loginWithGoogle();
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authStateProvider);
    final textTheme = Theme.of(context).textTheme;

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
        appBar: AppBar(title: const Text(AppStrings.register)),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Başlık
                Text(
                  AppStrings.createAccount,
                  style: textTheme.headlineMedium,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  AppStrings.registerMessage,
                  style: textTheme.bodyMedium?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                // Kayıt formu
                Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Ad soyad alanı
                      TextFormField(
                        controller: _fullNameController,
                        validator: fullNameValidator,
                        decoration: const InputDecoration(
                          labelText: AppStrings.fullName,
                          prefixIcon: Icon(Icons.person_outline),
                          hintText: 'Adınız Soyadınız',
                        ),
                      ),
                      const SizedBox(height: 16),
                      // E-posta alanı
                      TextFormField(
                        controller: _emailController,
                        validator: emailValidator,
                        keyboardType: TextInputType.emailAddress,
                        decoration: const InputDecoration(
                          labelText: AppStrings.email,
                          prefixIcon: Icon(Icons.email_outlined),
                          hintText: 'ornek@email.com',
                        ),
                      ),
                      const SizedBox(height: 16),
                      // Şifre alanı
                      TextFormField(
                        controller: _passwordController,
                        validator: passwordValidator,
                        obscureText: !_isPasswordVisible,
                        decoration: InputDecoration(
                          labelText: AppStrings.password,
                          prefixIcon: const Icon(Icons.lock_outlined),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _isPasswordVisible
                                  ? Icons.visibility_off
                                  : Icons.visibility,
                            ),
                            onPressed: () {
                              setState(() {
                                _isPasswordVisible = !_isPasswordVisible;
                              });
                            },
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      // Şifre onay alanı
                      TextFormField(
                        controller: _confirmPasswordController,
                        validator: passwordValidator,
                        obscureText: !_isConfirmPasswordVisible,
                        decoration: InputDecoration(
                          labelText: AppStrings.confirmPassword,
                          prefixIcon: const Icon(Icons.lock_outlined),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _isConfirmPasswordVisible
                                  ? Icons.visibility_off
                                  : Icons.visibility,
                            ),
                            onPressed: () {
                              setState(() {
                                _isConfirmPasswordVisible =
                                    !_isConfirmPasswordVisible;
                              });
                            },
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      // Yaş grubu seçimi
                      DropdownButtonFormField<String>(
                        value: _selectedAgeGroup,
                        decoration: const InputDecoration(
                          labelText: AppStrings.ageGroup,
                          prefixIcon: Icon(Icons.person_outline),
                        ),
                        items: const [
                          DropdownMenuItem(
                            value: 'child',
                            child: Text(AppStrings.child),
                          ),
                          DropdownMenuItem(
                            value: 'teenager',
                            child: Text(AppStrings.teenager),
                          ),
                          DropdownMenuItem(
                            value: 'adult',
                            child: Text(AppStrings.adult),
                          ),
                        ],
                        onChanged: (value) {
                          setState(() {
                            _selectedAgeGroup = value;
                          });
                        },
                      ),
                      const SizedBox(height: 32),
                      // Kayıt butonu
                      ElevatedButton(
                        onPressed: _register,
                        child: const Text(AppStrings.register),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                // Veya çizgisi
                Row(
                  children: [
                    const Expanded(child: Divider(thickness: 1)),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        'veya',
                        style: textTheme.bodyMedium?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                    const Expanded(child: Divider(thickness: 1)),
                  ],
                ),
                const SizedBox(height: 24),
                // Google ile giriş
                SocialLoginButton(
                  text: AppStrings.loginWithGoogle,
                  icon: 'assets/images/google_logo.png',
                  onPressed: _loginWithGoogle,
                ),
                const SizedBox(height: 24),
                // Giriş yönlendirmesi
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      AppStrings.alreadyHaveAccount,
                      style: textTheme.bodyMedium,
                    ),
                    TextButton(
                      onPressed: () {
                        // Giriş ekranına dön
                        Navigator.pop(context);
                      },
                      child: const Text(AppStrings.login),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
