import 'package:flutter/material.dart';
import 'animation_constants.dart';

class HoverScale extends StatefulWidget {
  final Widget child;
  final double scale;
  const HoverScale({super.key, required this.child, this.scale = 1.02});

  @override
  State<HoverScale> createState() => _HoverScaleState();
}

class _HoverScaleState extends State<HoverScale> {
  bool _hovered = false;
  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: AnimatedScale(
        duration: Anim.micro,
        curve: Anim.emphasis,
        scale: _hovered ? widget.scale : 1,
        child: widget.child,
      ),
    );
  }
}

class Pressable extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  const Pressable({super.key, required this.child, this.onTap});

  @override
  State<Pressable> createState() => _PressableState();
}

class _PressableState extends State<Pressable> {
  bool _down = false;
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _down = true),
      onTapCancel: () => setState(() => _down = false),
      onTapUp: (_) => setState(() => _down = false),
      onTap: widget.onTap,
      child: AnimatedScale(
        duration: Anim.microFast,
        scale: _down ? 0.98 : 1,
        child: AnimatedOpacity(
          duration: Anim.microFast,
          opacity: _down ? 0.9 : 1,
          child: widget.child,
        ),
      ),
    );
  }
}

class Shimmer extends StatefulWidget {
  final Widget Function(BuildContext, double) builder;
  const Shimmer({super.key, required this.builder});

  @override
  State<Shimmer> createState() => _ShimmerState();
}

class _ShimmerState extends State<Shimmer> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: Anim.shimmerLoop)..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) => widget.builder(context, _controller.value),
    );
  }
}

