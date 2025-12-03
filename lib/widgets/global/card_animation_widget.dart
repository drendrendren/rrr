import 'package:flutter/material.dart';

// opacity 밝아지면서 slide로 등장하도록 도와주는 animation widget
class FadeSlideAnimationWidget extends StatefulWidget {
  final Widget child;
  final Duration duration;
  final Offset offset; // 등장 방향 (아래→위, 왼쪽→오른쪽 등)

  const FadeSlideAnimationWidget({
    super.key,
    required this.child,
    this.duration = const Duration(milliseconds: 1400),
    this.offset = const Offset(0, 5), // 아래에서 위로 등장
  });

  @override
  State<FadeSlideAnimationWidget> createState() => _FadeSlideAnimationWidgetState();
}

class _FadeSlideAnimationWidgetState extends State<FadeSlideAnimationWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(vsync: this, duration: widget.duration);

    _slideAnimation = Tween<Offset>(
      begin: widget.offset / 100, // 예: Offset(0, 0.3)
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    _fadeAnimation = CurvedAnimation(parent: _controller, curve: Curves.easeIn);

    // 자동 재생
    _controller.forward();
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
      child: SlideTransition(position: _slideAnimation, child: widget.child),
    );
  }
}
