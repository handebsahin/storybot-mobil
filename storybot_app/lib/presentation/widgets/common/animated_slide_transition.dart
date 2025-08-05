import 'package:flutter/material.dart';

/// Kaydırma animasyonu ile geçiş efekti sağlayan widget
class AnimatedSlideTransition extends StatefulWidget {
  final Widget child;
  final Duration duration;
  final Duration delay;
  final Curve curve;
  final Offset beginOffset;
  final Offset endOffset;

  const AnimatedSlideTransition({
    super.key,
    required this.child,
    this.duration = const Duration(milliseconds: 300),
    this.delay = Duration.zero,
    this.curve = Curves.easeInOut,
    this.beginOffset = const Offset(0, 0.1),
    this.endOffset = Offset.zero,
  });

  @override
  State<AnimatedSlideTransition> createState() =>
      _AnimatedSlideTransitionState();
}

class _AnimatedSlideTransitionState extends State<AnimatedSlideTransition>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    );
    _slideAnimation = Tween<Offset>(
      begin: widget.beginOffset,
      end: widget.endOffset,
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
    return SlideTransition(
      position: _slideAnimation,
      child: widget.child,
    );
  }
}
