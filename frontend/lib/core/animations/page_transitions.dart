import 'package:flutter/material.dart';
import 'animation_constants.dart';

typedef PageBuilder = Widget Function(BuildContext context);

class PageTransitions {
  static PageRouteBuilder<T> fade<T>(Widget page) => PageRouteBuilder<T>(
        transitionDuration: Anim.page,
        reverseTransitionDuration: Anim.page,
        pageBuilder: (_, __, ___) => page,
        transitionsBuilder: (context, animation, secondary, child) {
          final curved = CurvedAnimation(parent: animation, curve: Anim.pageCurve);
          return FadeTransition(opacity: curved, child: child);
        },
      );

  static PageRouteBuilder<T> slideUp<T>(Widget page) => PageRouteBuilder<T>(
        transitionDuration: Anim.page,
        reverseTransitionDuration: Anim.page,
        pageBuilder: (_, __, ___) => page,
        transitionsBuilder: (context, animation, secondary, child) {
          final curved = CurvedAnimation(parent: animation, curve: Anim.pageCurve);
          final offset = Tween<Offset>(begin: const Offset(0, 0.08), end: Offset.zero).animate(curved);
          final fade = Tween<double>(begin: 0.0, end: 1.0).animate(curved);
          return SlideTransition(position: offset, child: FadeTransition(opacity: fade, child: child));
        },
      );

  static PageRouteBuilder<T> scale<T>(Widget page) => PageRouteBuilder<T>(
        transitionDuration: Anim.page,
        reverseTransitionDuration: Anim.page,
        pageBuilder: (_, __, ___) => page,
        transitionsBuilder: (context, animation, secondary, child) {
          final curved = CurvedAnimation(parent: animation, curve: Anim.pageCurve);
          return ScaleTransition(scale: Tween<double>(begin: 0.98, end: 1).animate(curved), child: child);
        },
      );
}

