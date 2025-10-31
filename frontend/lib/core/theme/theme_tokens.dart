import 'package:flutter/material.dart';
import 'dart:ui' show lerpDouble;

class AppTokens extends ThemeExtension<AppTokens> {
  final double radiusXs;
  final double radiusSm;
  final double radiusMd;
  final double radiusLg;
  final double radiusXl;

  final double spaceXs;
  final double spaceSm;
  final double spaceMd;
  final double spaceLg;
  final double spaceXl;

  final Duration animFast;
  final Duration animNormal;
  final Duration animSlow;

  final double elevationSm;
  final double elevationMd;
  final double elevationLg;

  const AppTokens({
    required this.radiusXs,
    required this.radiusSm,
    required this.radiusMd,
    required this.radiusLg,
    required this.radiusXl,
    required this.spaceXs,
    required this.spaceSm,
    required this.spaceMd,
    required this.spaceLg,
    required this.spaceXl,
    required this.animFast,
    required this.animNormal,
    required this.animSlow,
    required this.elevationSm,
    required this.elevationMd,
    required this.elevationLg,
  });

  static const AppTokens defaultLight = AppTokens(
    radiusXs: 6,
    radiusSm: 8,
    radiusMd: 12,
    radiusLg: 16,
    radiusXl: 20,
    spaceXs: 6,
    spaceSm: 8,
    spaceMd: 12,
    spaceLg: 16,
    spaceXl: 24,
    animFast: Duration(milliseconds: 200),
    animNormal: Duration(milliseconds: 300),
    animSlow: Duration(milliseconds: 500),
    elevationSm: 1,
    elevationMd: 2,
    elevationLg: 4,
  );

  static const AppTokens defaultDark = defaultLight;

  @override
  AppTokens copyWith({
    double? radiusXs,
    double? radiusSm,
    double? radiusMd,
    double? radiusLg,
    double? radiusXl,
    double? spaceXs,
    double? spaceSm,
    double? spaceMd,
    double? spaceLg,
    double? spaceXl,
    Duration? animFast,
    Duration? animNormal,
    Duration? animSlow,
    double? elevationSm,
    double? elevationMd,
    double? elevationLg,
  }) {
    return AppTokens(
      radiusXs: radiusXs ?? this.radiusXs,
      radiusSm: radiusSm ?? this.radiusSm,
      radiusMd: radiusMd ?? this.radiusMd,
      radiusLg: radiusLg ?? this.radiusLg,
      radiusXl: radiusXl ?? this.radiusXl,
      spaceXs: spaceXs ?? this.spaceXs,
      spaceSm: spaceSm ?? this.spaceSm,
      spaceMd: spaceMd ?? this.spaceMd,
      spaceLg: spaceLg ?? this.spaceLg,
      spaceXl: spaceXl ?? this.spaceXl,
      animFast: animFast ?? this.animFast,
      animNormal: animNormal ?? this.animNormal,
      animSlow: animSlow ?? this.animSlow,
      elevationSm: elevationSm ?? this.elevationSm,
      elevationMd: elevationMd ?? this.elevationMd,
      elevationLg: elevationLg ?? this.elevationLg,
    );
  }

  @override
  AppTokens lerp(ThemeExtension<AppTokens>? other, double t) {
    if (other is! AppTokens) return this;
    return AppTokens(
      radiusXs: lerpDouble(radiusXs, other.radiusXs, t)!,
      radiusSm: lerpDouble(radiusSm, other.radiusSm, t)!,
      radiusMd: lerpDouble(radiusMd, other.radiusMd, t)!,
      radiusLg: lerpDouble(radiusLg, other.radiusLg, t)!,
      radiusXl: lerpDouble(radiusXl, other.radiusXl, t)!,
      spaceXs: lerpDouble(spaceXs, other.spaceXs, t)!,
      spaceSm: lerpDouble(spaceSm, other.spaceSm, t)!,
      spaceMd: lerpDouble(spaceMd, other.spaceMd, t)!,
      spaceLg: lerpDouble(spaceLg, other.spaceLg, t)!,
      spaceXl: lerpDouble(spaceXl, other.spaceXl, t)!,
      animFast: Duration(milliseconds: _lerpDuration(animFast, other.animFast, t)),
      animNormal: Duration(milliseconds: _lerpDuration(animNormal, other.animNormal, t)),
      animSlow: Duration(milliseconds: _lerpDuration(animSlow, other.animSlow, t)),
      elevationSm: lerpDouble(elevationSm, other.elevationSm, t)!,
      elevationMd: lerpDouble(elevationMd, other.elevationMd, t)!,
      elevationLg: lerpDouble(elevationLg, other.elevationLg, t)!,
    );
  }

  static int _lerpDuration(Duration a, Duration b, double t) {
    return (a.inMilliseconds + (b.inMilliseconds - a.inMilliseconds) * t).round();
  }
}

extension AppTokensOf on BuildContext {
  AppTokens get tokens => Theme.of(this).extension<AppTokens>() ?? AppTokens.defaultLight;
}

