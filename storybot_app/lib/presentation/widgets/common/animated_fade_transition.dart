import 'package:flutter/material.dart';

/// Solma animasyonu ile geçiş efekti sağlayan widget
class AnimatedFadeTransition extends StatefulWidget {
  final Widget child;
  final Duration duration;
  final Duration delay;
  final Curve curve;
  final double beginOpacity;
  final double endOpacity;

  const AnimatedFadeTransition({
    super.key,
    required this.child,
    this.duration = const Duration(milliseconds: 300),
    this.delay = Duration.zero,
    this.curve = Curves.easeInOut,
    this.beginOpacity = 0.0,
    this.endOpacity = 1.0,
  });

  @override
  State<AnimatedFadeTransition> createState() => _AnimatedFadeTransitionState();
}

class _AnimatedFadeTransitionState extends State<AnimatedFadeTransition>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    );
    _fadeAnimation = Tween<double>(
      begin: widget.beginOpacity,
      end: widget.endOpacity,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: widget.curve,
      ),
    );

    if (widget.delay == Duration.zero) {
      _controller.forward();
    } else {
      Future.delayed(widget.delay, () {
        if (mounted) {
          _controller.forward();
        }
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: widget.child,
    );
  }
}
