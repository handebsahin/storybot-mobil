import 'package:flutter/material.dart';

/// Yükleme durumunda ekranı kaplayan overlay widget'ı
class LoadingOverlay extends StatelessWidget {
  final bool isLoading;
  final Widget child;
  final Color? color;
  final double opacity;

  const LoadingOverlay({
    super.key,
    required this.isLoading,
    required this.child,
    this.color,
    this.opacity = 0.5,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        child,
        if (isLoading)
          Positioned.fill(
            child: Container(
              // Deprecated API kullanımı düzeltildi
              color: color != null
                  ? Color.fromRGBO(
                      (color!.value >> 16) & 0xFF,
                      (color!.value >> 8) & 0xFF,
                      color!.value & 0xFF,
                      opacity,
                    )
                  : Color.fromRGBO(0, 0, 0, opacity),
              child: const Center(child: CircularProgressIndicator()),
            ),
          ),
      ],
    );
  }
}
