import 'package:flutter/material.dart';

/// Sosyal medya giriş butonu widget'ı
class SocialLoginButton extends StatelessWidget {
  final String text;
  final String icon;
  final VoidCallback onPressed;

  const SocialLoginButton({
    super.key,
    required this.text,
    required this.icon,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        side: BorderSide(color: Theme.of(context).dividerColor),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Google logosu için özel widget
          Container(
            width: 24,
            height: 24,
            margin: const EdgeInsets.only(right: 12),
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/google_logo.png'),
                fit: BoxFit.contain,
              ),
            ),
            // Fallback olarak icon kullan (resim bulunamazsa)
            child: const Icon(
              Icons.g_translate,
              size: 24,
              color: Colors.transparent,
            ),
          ),
          Text(text),
        ],
      ),
    );
  }
}
