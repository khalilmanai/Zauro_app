import 'package:flutter/animation.dart';

class Anim {
  // Durations
  static const Duration page = Duration(milliseconds: 400);
  static const Duration microFast = Duration(milliseconds: 200);
  static const Duration micro = Duration(milliseconds: 250);
  static const Duration microSlow = Duration(milliseconds: 300);
  static const Duration shimmerLoop = Duration(milliseconds: 1000);
  static const Duration listStaggerStep = Duration(milliseconds: 100);

  // Curves
  static const Curve pageCurve = Curves.easeInOutCubic;
  static const Curve enterCurve = Curves.easeOutCubic;
  static const Curve exitCurve = Curves.easeInCubic;
  static const Curve emphasis = Curves.easeOutBack;
}

