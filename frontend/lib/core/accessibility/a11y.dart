import 'package:flutter/material.dart';
import 'dart:math' as math;

class A11y {
  // Checks contrast between two colors (approx WCAG luminance ratio)
  static double contrastRatio(Color a, Color b) {
    double l(Color c) {
      final r = _srgbToLin(c.red / 255);
      final g = _srgbToLin(c.green / 255);
      final bl = _srgbToLin(c.blue / 255);
      return 0.2126 * r + 0.7152 * g + 0.0722 * bl;
    }

    final l1 = l(a) + 0.05;
    final l2 = l(b) + 0.05;
    final high = l1 > l2 ? l1 : l2;
    final low = l1 > l2 ? l2 : l1;
    return high / low;
  }

  static double _srgbToLin(double c) => c <= 0.03928 ? c / 12.92 : math.pow((c + 0.055) / 1.055, 2.4).toDouble();

  // Wraps child with semantics label and role
  static Widget semantic({required Widget child, String? label, String? hint, bool enabled = true}) {
    return Semantics(
      label: label,
      hint: hint,
      enabled: enabled,
      child: child,
    );
  }

  // Focus decoration helper
  static BoxDecoration focusRing(BuildContext context, {double radius = 12}) {
    final primary = Theme.of(context).colorScheme.primary;
    return BoxDecoration(
      borderRadius: BorderRadius.circular(radius),
      boxShadow: [
        BoxShadow(color: primary.withOpacity(0.3), blurRadius: 8, spreadRadius: 1),
      ],
    );
  }
}

