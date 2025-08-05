import 'package:flutter/material.dart';

/// Ölçek animasyonu ile geçiş efekti sağlayan widget
class AnimatedScaleTransition extends StatefulWidget {
  final Widget child;
  final Duration duration;
  final Duration delay;
  final Curve curve;
  final double beginScale;
  final double endScale;

  const AnimatedScaleTransition({
    super.key,
    required this.child,
    this.duration = const Duration(milliseconds: 300),
    this.delay = Duration.zero,
    this.curve = Curves.easeInOut,
    this.beginScale = 0.95,
    this.endScale = 1.0,
  });

  @override
  State<AnimatedScaleTransition> createState() =>
      _AnimatedScaleTransitionState();
}

class _AnimatedScaleTransitionState extends State<AnimatedScaleTransition>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    );
    _scaleAnimation = Tween<double>(
      begin: widget.beginScale,
      end: widget.endScale,
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
    return ScaleTransition(
      scale: _scaleAnimation,
      child: widget.child,
    );
  }
}
