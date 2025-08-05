import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../data/models/audio_sync_model.dart';

/// Basit metin widget'ı - Flutter HTML kullanmadan sade metin gösterir
class SimpleTextWidget extends StatelessWidget {
  final String text;
  final List<String>? keywords;
  final int currentPosition;
  final AudioSyncModel? audioSync;
  final bool isPlaying;

  const SimpleTextWidget({
    super.key,
    required this.text,
    this.keywords,
    this.currentPosition = 0,
    this.audioSync,
    this.isPlaying = false,
  });

  @override
  Widget build(BuildContext context) {
    // Basit metin gösterimi - HTML veya karmaşık işleme olmadan
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Text(
          text,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                height: 1.6,
                fontSize: 16,
                color: AppColors.textPrimary,
              ),
        ),
      ),
    );
  }
}

/// Anahtar kelimeleri vurgulayan basit metin widget'ı
class SimpleHighlightedText extends StatelessWidget {
  final String text;
  final List<String>? keywords;
  final Color keywordColor;

  const SimpleHighlightedText({
    super.key,
    required this.text,
    this.keywords,
    this.keywordColor = Colors.deepOrange,
  });

  @override
  Widget build(BuildContext context) {
    // Anahtar kelime vurgulaması olmadan basit metin gösterimi
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Text(
          text,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                height: 1.6,
                fontSize: 16,
                color: AppColors.textPrimary,
              ),
        ),
      ),
    );
  }
}
