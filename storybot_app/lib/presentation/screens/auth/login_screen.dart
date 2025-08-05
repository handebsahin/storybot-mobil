import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:form_field_validator/form_field_validator.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../state/auth_state.dart';
import '../../widgets/auth/social_login_button.dart';
import '../../widgets/common/loading_overlay.dart';

/// Giriş ekranı
class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isPasswordVisible = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

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

  /// E-posta ile giriş işlemi
  void _login() {
    if (_formKey.currentState!.validate()) {
      FocusScope.of(context).unfocus();
      ref
          .read(authStateProvider.notifier)
          .loginWithEmail(
            email: _emailController.text.trim(),
            password: _passwordController.text,
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
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 40),
                // Logo ve başlık
                Center(
                  child: Text(
                    AppStrings.appName,
                    style: textTheme.displaySmall?.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                // Karşılama mesajı
                Text(
                  AppStrings.welcomeBack,
                  style: textTheme.headlineMedium,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  AppStrings.welcomeMessage,
                  style: textTheme.bodyMedium?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 40),
                // Giriş formu
                Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // E-posta alanı
                      TextFormField(
                        controller: _emailController,
                        validator: emailValidator,
                        keyboardType: TextInputType.emailAddress,
                        decoration: InputDecoration(
                          labelText: AppStrings.email,
                          prefixIcon: const Icon(Icons.email_outlined),
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
                      const SizedBox(height: 8),
                      // Şifremi unuttum
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: () {
                            // Şifremi unuttum ekranına yönlendir
                          },
                          child: Text(AppStrings.forgotPassword),
                        ),
                      ),
                      const SizedBox(height: 24),
                      // Giriş butonu
                      ElevatedButton(
                        onPressed: _login,
                        child: Text(AppStrings.login),
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
                // Kayıt ol yönlendirmesi
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      AppStrings.dontHaveAccount,
                      style: textTheme.bodyMedium,
                    ),
                    TextButton(
                      onPressed: () {
                        // Kayıt ekranına go_router ile yönlendir
                        context.push('/register');
                      },
                      child: Text(AppStrings.register),
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
