import 'package:flutter/material.dart';

/// A reusable logo widget that can be used throughout the application
class AppLogo extends StatelessWidget {
  final double? width;
  final double? height;
  final BoxFit fit;
  final BorderRadius? borderRadius;
  final Color? backgroundColor;
  final EdgeInsets? padding;
  final List<BoxShadow>? boxShadow;

  const AppLogo({
    super.key,
    this.width,
    this.height,
    this.fit = BoxFit.contain,
    this.borderRadius,
    this.backgroundColor,
    this.padding,
    this.boxShadow,
  });

  /// Small logo (24x24)
  const AppLogo.small({
    super.key,
    this.fit = BoxFit.contain,
    this.borderRadius,
    this.backgroundColor,
    this.padding,
    this.boxShadow,
  })  : width = 24,
        height = 24;

  /// Medium logo (48x48)
  const AppLogo.medium({
    super.key,
    this.fit = BoxFit.contain,
    this.borderRadius,
    this.backgroundColor,
    this.padding,
    this.boxShadow,
  })  : width = 48,
        height = 48;

  /// Large logo (80x80)
  const AppLogo.large({
    super.key,
    this.fit = BoxFit.contain,
    this.borderRadius,
    this.backgroundColor,
    this.padding,
    this.boxShadow,
  })  : width = 80,
        height = 80;

  /// Extra large logo (120x120)
  const AppLogo.extraLarge({
    super.key,
    this.fit = BoxFit.contain,
    this.borderRadius,
    this.backgroundColor,
    this.padding,
    this.boxShadow,
  })  : width = 120,
        height = 120;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      padding: padding,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: borderRadius,
        boxShadow: boxShadow,
      ),
      child: ClipRRect(
        borderRadius: borderRadius ?? BorderRadius.zero,
        child: Image.asset(
          'assets/images/logo.png',
          fit: fit,
          errorBuilder: (context, error, stackTrace) {
            // Fallback to a simple icon if logo fails to load
            return Container(
              width: width,
              height: height,
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
                borderRadius: borderRadius,
              ),
              child: Icon(
                Icons.pets,
                color: Theme.of(context).primaryColor,
                size: (width != null && height != null)
                    ? (width! < height! ? width! * 0.6 : height! * 0.6)
                    : 24,
              ),
            );
          },
        ),
      ),
    );
  }
}

/// A logo with premium card styling
class PremiumAppLogo extends StatelessWidget {
  final double? width;
  final double? height;
  final BoxFit fit;
  final BorderRadius? borderRadius;
  final EdgeInsets? padding;
  final bool hasElevation;
  final List<BoxShadow>? customShadows;
  final Gradient? gradient;

  const PremiumAppLogo({
    super.key,
    this.width,
    this.height,
    this.fit = BoxFit.contain,
    this.borderRadius,
    this.padding,
    this.hasElevation = true,
    this.customShadows,
    this.gradient,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      padding: padding ?? const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: borderRadius ?? BorderRadius.circular(16),
        boxShadow: hasElevation
            ? (customShadows ??
                [
                  BoxShadow(
                    color:
                        Theme.of(context).primaryColor.withValues(alpha: 0.3),
                    blurRadius: 10,
                    spreadRadius: 2,
                  ),
                ])
            : null,
      ),
      child: ClipRRect(
        borderRadius: borderRadius ?? BorderRadius.circular(16),
        child: Image.asset(
          'assets/images/logo.png',
          fit: fit,
          errorBuilder: (context, error, stackTrace) {
            return Icon(
              Icons.pets,
              color: Colors.white,
              size: (width != null && height != null)
                  ? (width! < height! ? width! * 0.6 : height! * 0.6)
                  : 32,
            );
          },
        ),
      ),
    );
  }
}
