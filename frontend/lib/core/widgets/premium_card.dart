import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../theme/app_theme.dart';

class PremiumCard extends StatefulWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double borderRadius;
  final Color? backgroundColor;
  final bool hasElevation;
  final bool isGlowing;
  final bool isGlass;
  final Gradient? gradient;
  final List<BoxShadow>? customShadows;
  final VoidCallback? onTap;
  final bool enableHoverAnimation;
  final Duration animationDuration;
  final Curve animationCurve;

  const PremiumCard({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.borderRadius = 20,
    this.backgroundColor,
    this.hasElevation = true,
    this.isGlowing = false,
    this.isGlass = false,
    this.gradient,
    this.customShadows,
    this.onTap,
    this.enableHoverAnimation = true,
    this.animationDuration = AppTheme.mediumAnimation,
    this.animationCurve = AppTheme.smoothTransition,
  });

  @override
  State<PremiumCard> createState() => _PremiumCardState();
}

class _PremiumCardState extends State<PremiumCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _glowAnimation;

  bool _isHovered = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: widget.animationDuration,
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.02,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: widget.animationCurve,
    ));

    _glowAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: widget.animationCurve,
    ));
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _handleHover(bool isHovered) {
    if (widget.enableHoverAnimation) {
      setState(() {
        _isHovered = isHovered;
      });

      if (isHovered) {
        _animationController.forward();
      } else {
        _animationController.reverse();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    BoxDecoration decoration;

    if (widget.isGlass) {
      decoration = AppTheme.getGlassMorphismDecoration(
        color: widget.backgroundColor,
        borderRadius: widget.borderRadius,
        isDark: isDark,
      );
    } else {
      decoration = BoxDecoration(
        color: widget.backgroundColor ?? Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(widget.borderRadius),
        gradient: widget.gradient,
        border: Border.all(
          color: isDark ? AppTheme.darkBorder : AppTheme.lightBorder,
          width: 0.5,
        ),
        boxShadow: widget.customShadows ??
            (widget.hasElevation
                ? (widget.isGlowing
                    ? AppTheme.getPrimaryNeonGlow(isDark: isDark)
                    : AppTheme.getLightShadow())
                : []),
      );
    }

    Widget cardChild = Container(
      decoration: decoration,
      child: Padding(
        padding: widget.padding ?? const EdgeInsets.all(20),
        child: widget.child,
      ),
    ).animate(target: _isHovered ? 1 : 0).scaleXY(
          begin: 1.0,
          end: 1.02,
        );

    if (widget.onTap != null) {
      return MouseRegion(
        onEnter: (_) => _handleHover(true),
        onExit: (_) => _handleHover(false),
        child: GestureDetector(
          onTap: widget.onTap,
          child: AnimatedBuilder(
            animation: _animationController,
            builder: (context, child) {
              return Transform.scale(
                scale: _scaleAnimation.value,
                child: cardChild,
              );
            },
          ),
        ),
      );
    }

    return cardChild;
  }
}

class GlowingCard extends PremiumCard {
  GlowingCard({
    super.key,
    required super.child,
    Color? glowColor,
    bool isDark = false,
    super.hasElevation = true,
    super.borderRadius = 20,
    super.onTap,
    super.padding,
    super.margin,
  }) : super(
          isGlowing: true,
          customShadows: glowColor != null
              ? [
                  BoxShadow(
                    color: glowColor.withOpacity(0.6),
                    blurRadius: 20,
                    spreadRadius: 2,
                  )
                ]
              : AppTheme.getPrimaryNeonGlow(isDark: isDark),
        );
}

class GlassCard extends PremiumCard {
  const GlassCard({
    super.key,
    required super.child,
    super.padding,
    super.margin,
    super.borderRadius = 20,
    super.onTap,
  }) : super(
          isGlass: true,
          hasElevation: false,
        );
}

class GradientCard extends PremiumCard {
  const GradientCard({
    super.key,
    required super.child,
    required Gradient gradient,
    super.padding,
    super.margin,
    super.borderRadius = 20,
    super.onTap,
    super.hasElevation = true,
  }) : super(gradient: gradient);
}

class AnimatedCard extends PremiumCard {
  const AnimatedCard({
    super.key,
    required super.child,
    super.padding,
    super.margin,
    super.borderRadius = 20,
    super.onTap,
    super.hasElevation = true,
    Duration? animationDuration,
    Curve? animationCurve,
  }) : super(
          enableHoverAnimation: true,
          animationDuration: animationDuration ?? AppTheme.fastAnimation,
          animationCurve: animationCurve ?? AppTheme.quickTransition,
        );
}

class CompactCard extends PremiumCard {
  const CompactCard({
    super.key,
    required super.child,
    super.margin,
    super.borderRadius = 12,
    super.onTap,
    super.hasElevation = true,
  }) : super(
          padding: const EdgeInsets.all(12),
          enableHoverAnimation: false,
        );
}

class StatusCard extends PremiumCard {
  StatusCard({
    super.key,
    required super.child,
    required CardStatus status,
    super.padding,
    super.margin,
    super.borderRadius = 16,
    super.onTap,
  }) : super(
          hasElevation: true,
          customShadows: _getStatusShadows(status),
          backgroundColor: _getStatusColor(status),
        );

  static Color _getStatusColor(CardStatus status) {
    switch (status) {
      case CardStatus.success:
        return AppTheme.success.withOpacity(0.1);
      case CardStatus.warning:
        return AppTheme.warning.withOpacity(0.1);
      case CardStatus.error:
        return AppTheme.error.withOpacity(0.1);
      case CardStatus.info:
        return AppTheme.info.withOpacity(0.1);
      case CardStatus.neutral:
        return Colors.grey.withOpacity(0.05);
    }
  }

  static List<BoxShadow> _getStatusShadows(CardStatus status) {
    Color statusColor;
    switch (status) {
      case CardStatus.success:
        statusColor = AppTheme.success;
        break;
      case CardStatus.warning:
        statusColor = AppTheme.warning;
        break;
      case CardStatus.error:
        statusColor = AppTheme.error;
        break;
      case CardStatus.info:
        statusColor = AppTheme.info;
        break;
      case CardStatus.neutral:
        statusColor = Colors.grey;
        break;
    }

    return [
      BoxShadow(
        color: statusColor.withOpacity(0.2),
        blurRadius: 8,
        offset: const Offset(0, 2),
      ),
    ];
  }
}

enum CardStatus {
  success,
  warning,
  error,
  info,
  neutral,
}
