import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:url_launcher/url_launcher.dart';

/// Markdown formatındaki metinleri düzgün şekilde gösteren widget
class MarkdownTextWidget extends StatelessWidget {
  final String text;
  final TextStyle? style;

  const MarkdownTextWidget({Key? key, required this.text, this.style})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final defaultStyle =
        style ?? Theme.of(context).textTheme.bodyLarge?.copyWith(height: 1.6);

    // Metin boş veya null ise boş bir Container döndür
    if (text.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(16),
        alignment: Alignment.center,
        child: const Text(
          'İçerik yüklenemedi',
          style: TextStyle(fontStyle: FontStyle.italic, color: Colors.grey),
        ),
      );
    }

    // Debug için metni yazdır
    debugPrint(
      'Markdown text: ${text.length > 100 ? "${text.substring(0, 100)}..." : text}',
    );

    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(
        minHeight: 100,
      ),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Markdown(
        data: text,
        styleSheet: MarkdownStyleSheet(
          p: defaultStyle,
          h1: defaultStyle?.copyWith(
            fontSize: defaultStyle.fontSize! * 1.8,
            fontWeight: FontWeight.bold,
          ),
          h2: defaultStyle?.copyWith(
            fontSize: defaultStyle.fontSize! * 1.5,
            fontWeight: FontWeight.bold,
          ),
          h3: defaultStyle?.copyWith(
            fontSize: defaultStyle.fontSize! * 1.3,
            fontWeight: FontWeight.bold,
          ),
          h4: defaultStyle?.copyWith(
            fontSize: defaultStyle.fontSize! * 1.2,
            fontWeight: FontWeight.bold,
          ),
          h5: defaultStyle?.copyWith(
            fontSize: defaultStyle.fontSize! * 1.1,
            fontWeight: FontWeight.bold,
          ),
          h6: defaultStyle?.copyWith(fontWeight: FontWeight.bold),
          em: defaultStyle?.copyWith(fontStyle: FontStyle.italic),
          strong: defaultStyle?.copyWith(fontWeight: FontWeight.bold),
          blockquote: defaultStyle?.copyWith(
            color: Colors.grey.shade700,
            fontStyle: FontStyle.italic,
          ),
          code: defaultStyle?.copyWith(
            fontFamily: 'monospace',
            backgroundColor: Colors.grey.shade200,
          ),
          codeblockPadding: const EdgeInsets.all(8),
          codeblockDecoration: BoxDecoration(
            color: Colors.grey.shade200,
            borderRadius: BorderRadius.circular(8),
          ),
          blockSpacing: 16.0,
          listIndent: 24.0,
        ),
        onTapLink: (text, href, title) {
          if (href != null) {
            _launchUrl(href);
          }
        },
        selectable: true,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
      ),
    );
  }

  Future<void> _launchUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }
}
