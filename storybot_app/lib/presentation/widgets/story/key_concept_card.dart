import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../data/models/story_model.dart';

/// Anahtar kavram kartı
class KeyConceptCard extends StatelessWidget {
  final KeyConceptModel concept;

  const KeyConceptCard({
    super.key,
    required this.concept,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Card(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        color: Colors.white,
        child: ExpansionTile(
          tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          expandedCrossAxisAlignment: CrossAxisAlignment.start,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Row(
            children: [
              // Anahtar kelime ikonu
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  _getConceptIcon(concept.keyword),
                  color: AppColors.primary,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              // Anahtar kelime metni
              Expanded(
                child: Text(
                  concept.keyword,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ],
          ),
          children: [
            // Açıklama metni
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.lightBackground,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                concept.explanation,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      height: 1.5,
                      color: AppColors.textPrimary,
                    ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Kavram için uygun ikon seçer
  IconData _getConceptIcon(String keyword) {
    final lowerKeyword = keyword.toLowerCase();

    if (lowerKeyword.contains('matematik') ||
        lowerKeyword.contains('sayı') ||
        lowerKeyword.contains('formül')) {
      return Icons.functions;
    } else if (lowerKeyword.contains('bilim') ||
        lowerKeyword.contains('deney') ||
        lowerKeyword.contains('kimya')) {
      return Icons.science;
    } else if (lowerKeyword.contains('tarih') ||
        lowerKeyword.contains('geçmiş')) {
      return Icons.history_edu;
    } else if (lowerKeyword.contains('teknoloji') ||
        lowerKeyword.contains('bilgisayar') ||
        lowerKeyword.contains('yazılım')) {
      return Icons.computer;
    } else if (lowerKeyword.contains('sanat') ||
        lowerKeyword.contains('resim')) {
      return Icons.palette;
    } else if (lowerKeyword.contains('müzik') ||
        lowerKeyword.contains('nota')) {
      return Icons.music_note;
    } else if (lowerKeyword.contains('edebiyat') ||
        lowerKeyword.contains('kitap') ||
        lowerKeyword.contains('yazar')) {
      return Icons.menu_book;
    } else if (lowerKeyword.contains('coğrafya') ||
        lowerKeyword.contains('dünya') ||
        lowerKeyword.contains('harita')) {
      return Icons.public;
    } else if (lowerKeyword.contains('biyoloji') ||
        lowerKeyword.contains('canlı') ||
        lowerKeyword.contains('hücre')) {
      return Icons.biotech;
    } else {
      return Icons.lightbulb_outline;
    }
  }
}
