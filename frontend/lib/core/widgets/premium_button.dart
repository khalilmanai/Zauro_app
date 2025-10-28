import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../theme/app_theme.dart';
import '../theme/app_colors.dart';

enum ButtonVariant {
  primary,
  secondary,
  outlined,
  ghost,
  glow,
  gradient,
  glass,
  neon,
}

enum ButtonSize {
  small,
  medium,
  large,
  extraLarge,
}

class PremiumButton extends StatefulWidget {
  final String text;
  final VoidCallback? onPressed;
  final Widget? icon;
  final Widget? trailingIcon;
  final bool isLoading;
  final ButtonVariant variant;
  final ButtonSize size;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final Gradient? gradient;
  final double borderRadius;
  final EdgeInsetsGeometry? padding;
  final double? width;
  final double? height;
  final bool hasShadow;
  final bool hasHoverAnimation;
  final Duration animationDuration;
  final Curve animationCurve;
  final String? tooltip;
  final bool enableAnimations;

  const PremiumButton({
    super.key,
    required this.text,
    this.onPressed,
    this.icon,
    this.trailingIcon,
    this.isLoading = false,
    this.variant = ButtonVariant.primary,
    this.size = ButtonSize.medium,
    this.backgroundColor,
    this.foregroundColor,
    this.gradient,
    this.borderRadius = 12,
    this.padding,
    this.width,
    this.height,
    this.hasShadow = true,
    this.hasHoverAnimation = true,
    this.animationDuration = AppTheme.fastAnimation,
    this.animationCurve = AppTheme.quickTransition,
    this.tooltip,
    this.enableAnimations = true,
  });

  @override
  State<PremiumButton> createState() => _PremiumButtonState();
}

class _PremiumButtonState extends State<PremiumButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );

    _animationController.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _handleTapDown(TapDownDetails details) {
    if (widget.onPressed != null && widget.hasHoverAnimation) {
      setState(() {
        _isPressed = true;
      });
      _animationController.forward();
    }
  }

  void _handleTapUp(TapUpDetails details) {
    _handleTapEnd();
  }

  void _handleTapCancel() {
    _handleTapEnd();
  }

  void _handleTapEnd() {
    if (widget.onPressed != null && widget.hasHoverAnimation) {
      setState(() {
        _isPressed = false;
      });
      _animationController.reverse();

      // Add haptic feedback
      if (widget.onPressed != null) {
        HapticFeedback.lightImpact();
        widget.onPressed!();
      }
    }
  }

  void _handleHover(bool isHovered) {
    // Hover state handling removed
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final buttonConfig = _getButtonConfig(context, theme, isDark);
    final sizeConfig = _getSizeConfig();

    Widget button = Container(
      width: widget.width,
      height: widget.height ?? sizeConfig.height,
      decoration: _getBoxDecoration(context, theme, isDark, buttonConfig),
      child: Material(
        color: AppColors.transparent,
        child: InkWell(
          onTap: widget.onPressed,
          onTapDown: _handleTapDown,
          onTapUp: _handleTapUp,
          onTapCancel: _handleTapCancel,
          borderRadius: BorderRadius.circular(widget.borderRadius),
          child: Padding(
            padding: widget.padding ?? sizeConfig.padding,
            child: _buildButtonContent(context, buttonConfig, sizeConfig),
          ),
        ),
      ),
    ).animate(target: widget.enableAnimations && _isPressed ? 1 : 0).scaleXY(
          begin: 1.0,
          end: 0.98,
        );

    Widget result = MouseRegion(
      onEnter: (_) => _handleHover(true),
      onExit: (_) => _handleHover(false),
      child: button,
    );

    if (widget.tooltip != null && widget.onPressed != null) {
      result = Tooltip(
        message: widget.tooltip!,
        child: result,
      );
    }

    return result;
  }

  ButtonConfig _getButtonConfig(
      BuildContext context, ThemeData theme, bool isDark) {
    Color backgroundColor;
    Color foregroundColor;
    List<BoxShadow> shadows = [];

    switch (widget.variant) {
      case ButtonVariant.primary:
        backgroundColor =
            widget.backgroundColor ?? AppTheme.getPrimaryColor(context);
        foregroundColor = widget.foregroundColor ?? AppColors.white;
        if (widget.hasShadow) {
          shadows = AppTheme.getLightShadow();
        }
        break;

      case ButtonVariant.secondary:
        backgroundColor =
            widget.backgroundColor ?? AppTheme.getSecondaryColor(context);
        foregroundColor =
            widget.foregroundColor ?? AppTheme.getForegroundColor(context);
        break;

      case ButtonVariant.outlined:
        backgroundColor = AppColors.transparent;
        foregroundColor =
            widget.foregroundColor ?? AppTheme.getPrimaryColor(context);
        break;

      case ButtonVariant.ghost:
        backgroundColor = widget.backgroundColor?.withValues(alpha: 0.1) ??
            AppTheme.getPrimaryColor(context).withValues(alpha: 0.1);
        foregroundColor =
            widget.foregroundColor ?? AppTheme.getPrimaryColor(context);
        break;

      case ButtonVariant.glow:
        backgroundColor =
            widget.backgroundColor ?? AppTheme.getPrimaryColor(context);
        foregroundColor = widget.foregroundColor ?? AppColors.white;
        if (widget.hasShadow) {
          shadows = AppTheme.getPrimaryNeonGlow(isDark: isDark);
        }
        break;

      case ButtonVariant.gradient:
        backgroundColor = AppColors.transparent;
        foregroundColor = widget.foregroundColor ?? AppColors.white;
        if (widget.hasShadow) {
          shadows = AppTheme.getLightShadow();
        }
        break;

      case ButtonVariant.glass:
        backgroundColor = AppColors.transparent;
        foregroundColor =
            widget.foregroundColor ?? AppTheme.getForegroundColor(context);
        break;

      case ButtonVariant.neon:
        backgroundColor =
            widget.backgroundColor ?? AppTheme.getPrimaryColor(context);
        foregroundColor = widget.foregroundColor ?? Colors.white;
        if (widget.hasShadow) {
          shadows = AppTheme.getPrimaryNeonGlow(isDark: isDark);
        }
        break;
    }

    return ButtonConfig(
      backgroundColor: backgroundColor,
      foregroundColor: foregroundColor,
      shadows: shadows,
    );
  }

  SizeConfig _getSizeConfig() {
    switch (widget.size) {
      case ButtonSize.small:
        return const SizeConfig(
          height: 36,
          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          iconSize: 16,
          fontSize: 14,
        );
      case ButtonSize.medium:
        return const SizeConfig(
          height: 48,
          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          iconSize: 20,
          fontSize: 16,
        );
      case ButtonSize.large:
        return const SizeConfig(
          height: 56,
          padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          iconSize: 22,
          fontSize: 18,
        );
      case ButtonSize.extraLarge:
        return const SizeConfig(
          height: 64,
          padding: EdgeInsets.symmetric(horizontal: 32, vertical: 20),
          iconSize: 24,
          fontSize: 20,
        );
    }
  }

  BoxDecoration _getBoxDecoration(
      BuildContext context, ThemeData theme, bool isDark, ButtonConfig config) {
    BoxDecoration decoration = BoxDecoration(
      borderRadius: BorderRadius.circular(widget.borderRadius),
      boxShadow: config.shadows.isEmpty ? null : config.shadows,
      border: widget.variant == ButtonVariant.outlined
          ? Border.all(
              color: config.foregroundColor,
              width: 1.5,
            )
          : null,
    );

    if (widget.variant == ButtonVariant.glass) {
      decoration = decoration.copyWith(
        gradient: LinearGradient(
          colors: [
            AppColors.white.withValues(alpha: 0.2),
            AppColors.white.withValues(alpha: 0.1),
          ],
        ),
        border: Border.all(
          color: AppColors.white.withValues(alpha: 0.2),
          width: 1,
        ),
      );
    } else if (widget.gradient != null ||
        widget.variant == ButtonVariant.gradient) {
      decoration = decoration.copyWith(
        gradient:
            widget.gradient ?? AppTheme.getNeonPrimaryGradient(isDark: isDark),
      );
    } else if (widget.variant != ButtonVariant.outlined &&
        widget.variant != ButtonVariant.glass) {
      decoration = decoration.copyWith(color: config.backgroundColor);
    }

    return decoration;
  }

  Widget _buildButtonContent(
      BuildContext context, ButtonConfig config, SizeConfig sizeConfig) {
    final children = <Widget>[];

    if (widget.isLoading) {
      children.add(
        SizedBox(
          height: sizeConfig.iconSize,
          width: sizeConfig.iconSize,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            color: config.foregroundColor,
          ),
        ),
      );
      children.add(const SizedBox(width: 8));
    } else {
      if (widget.icon != null) {
        children.add(
          SizedBox(
            width: sizeConfig.iconSize,
            height: sizeConfig.iconSize,
            child: widget.icon!,
          ),
        );
        children.add(const SizedBox(width: 8));
      }

      children.add(
        Flexible(
          child: Text(
            widget.text,
            style: TextStyle(
              fontSize: sizeConfig.fontSize,
              fontWeight: FontWeight.w600,
              color: config.foregroundColor,
            ),
            textAlign: TextAlign.center,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      );

      if (widget.trailingIcon != null) {
        children.add(const SizedBox(width: 8));
        children.add(
          SizedBox(
            width: sizeConfig.iconSize,
            height: sizeConfig.iconSize,
            child: widget.trailingIcon!,
          ),
        );
      }
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: children,
    );
  }
}

class ButtonConfig {
  final Color backgroundColor;
  final Color foregroundColor;
  final List<BoxShadow> shadows;

  const ButtonConfig({
    required this.backgroundColor,
    required this.foregroundColor,
    required this.shadows,
  });
}

class SizeConfig {
  final double height;
  final EdgeInsetsGeometry padding;
  final double iconSize;
  final double fontSize;

  const SizeConfig({
    required this.height,
    required this.padding,
    required this.iconSize,
    required this.fontSize,
  });
}

// Convenience constructors for common button variants
class PrimaryButton extends PremiumButton {
  const PrimaryButton({
    super.key,
    required super.text,
    super.onPressed,
    super.icon,
    super.trailingIcon,
    super.isLoading,
    super.size = ButtonSize.medium,
  }) : super(variant: ButtonVariant.primary);
}

class SecondaryButton extends PremiumButton {
  const SecondaryButton({
    super.key,
    required super.text,
    super.onPressed,
    super.icon,
    super.trailingIcon,
    super.isLoading,
    super.size = ButtonSize.medium,
  }) : super(variant: ButtonVariant.secondary);
}

class OutlinedButton extends PremiumButton {
  const OutlinedButton({
    super.key,
    required super.text,
    super.onPressed,
    super.icon,
    super.trailingIcon,
    super.isLoading,
    super.size = ButtonSize.medium,
    super.foregroundColor,
  }) : super(variant: ButtonVariant.outlined);
}

class GradientButton extends PremiumButton {
  const GradientButton({
    super.key,
    required super.text,
    super.onPressed,
    super.icon,
    super.trailingIcon,
    super.isLoading,
    super.size = ButtonSize.medium,
    super.gradient,
  }) : super(variant: ButtonVariant.gradient);
}

class GlowButton extends PremiumButton {
  const GlowButton({
    super.key,
    required super.text,
    super.onPressed,
    super.icon,
    super.trailingIcon,
    super.isLoading,
    super.size = ButtonSize.medium,
  }) : super(variant: ButtonVariant.glow);
}

class GlassButton extends PremiumButton {
  const GlassButton({
    super.key,
    required super.text,
    super.onPressed,
    super.icon,
    super.trailingIcon,
    super.isLoading,
    super.size = ButtonSize.medium,
  }) : super(variant: ButtonVariant.glass);
}
