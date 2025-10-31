import 'package:flutter/material.dart';
import 'animation_constants.dart';

class SharedAnimations {
  // Simple shared element using Hero
  static Widget hero({required String tag, required Widget child, RectTween? rectTween}) {
    return Hero(
      tag: tag,
      createRectTween: (begin, end) => rectTween ?? MaterialRectArcTween(begin: begin, end: end),
      flightShuttleBuilder: (context, animation, direction, from, to) {
        return FadeTransition(
          opacity: CurvedAnimation(parent: animation, curve: Anim.enterCurve),
          child: to.widget,
        );
      },
      child: child,
    );
  }

  // Fade + slide preset
  static Widget fadeInUp({required Animation<double> animation, required Widget child}) {
    final curved = CurvedAnimation(parent: animation, curve: Anim.enterCurve);
    return FadeTransition(
      opacity: curved,
      child: SlideTransition(position: Tween<Offset>(begin: const Offset(0, 0.05), end: Offset.zero).animate(curved), child: child),
    );
  }

  static Widget slideInLeft({required Animation<double> animation, required Widget child}) {
    final curved = CurvedAnimation(parent: animation, curve: Anim.enterCurve);
    return SlideTransition(position: Tween<Offset>(begin: const Offset(-0.08, 0), end: Offset.zero).animate(curved), child: child);
  }
}

class StaggeredList extends StatelessWidget {
  final IndexedWidgetBuilder itemBuilder;
  final int itemCount;
  final Duration initialDelay;

  const StaggeredList({super.key, required this.itemBuilder, required this.itemCount, this.initialDelay = Duration.zero});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: itemCount,
      itemBuilder: (context, index) {
        return _StaggeredItem(
          delay: initialDelay + Anim.listStaggerStep * index,
          child: itemBuilder(context, index),
        );
      },
    );
  }
}

class _StaggeredItem extends StatefulWidget {
  final Duration delay;
  final Widget child;
  const _StaggeredItem({required this.delay, required this.child});

  @override
  State<_StaggeredItem> createState() => _StaggeredItemState();
}

class _StaggeredItemState extends State<_StaggeredItem> {
  bool _visible = false;

  @override
  void initState() {
    super.initState();
    Future.delayed(widget.delay, () {
      if (mounted) setState(() => _visible = true);
    });
  }

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: _visible ? 1 : 0),
      duration: Anim.microSlow,
      curve: Anim.enterCurve,
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, (1 - value) * 12),
            child: child,
          ),
        );
      },
      child: widget.child,
    );
  }
}

