import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// A widget that provides neon glow effects
class NeonGlowWidget extends StatefulWidget {
  final Widget child;
  final Color glowColor;
  final double glowRadius;
  final double glowOpacity;
  final bool isAnimated;
  final Duration animationDuration;
  final bool isDark;

  const NeonGlowWidget({
    super.key,
    required this.child,
    required this.glowColor,
    this.glowRadius = 20,
    this.glowOpacity = 0.3,
    this.isAnimated = false,
    this.animationDuration = const Duration(milliseconds: 2000),
    this.isDark = false,
  });

  @override
  State<NeonGlowWidget> createState() => _NeonGlowWidgetState();
}

class _NeonGlowWidgetState extends State<NeonGlowWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _glowAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: widget.animationDuration,
      vsync: this,
    );
    _glowAnimation = Tween<double>(
      begin: 0.2,
      end: 0.6,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    if (widget.isAnimated) {
      _animationController.repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.isAnimated) {
      return AnimatedBuilder(
        animation: _glowAnimation,
        builder: (context, child) {
          return Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              boxShadow: AppTheme.getNeonGlow(
                color: widget.glowColor,
                blurRadius: widget.glowRadius,
                spreadRadius: 2,
                opacity: widget.glowOpacity * _glowAnimation.value,
              ),
            ),
            child: widget.child,
          );
        },
      );
    }

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        boxShadow: AppTheme.getNeonGlow(
          color: widget.glowColor,
          blurRadius: widget.glowRadius,
          spreadRadius: 2,
          opacity: widget.glowOpacity,
        ),
      ),
      child: widget.child,
    );
  }
}

/// A neon button with glow effects
class NeonButton extends StatefulWidget {
  final Widget child;
  final VoidCallback? onPressed;
  final Color color;
  final double borderRadius;
  final EdgeInsets padding;
  final bool isDark;

  const NeonButton({
    super.key,
    required this.child,
    this.onPressed,
    required this.color,
    this.borderRadius = 12,
    this.padding = const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
    this.isDark = false,
  });

  @override
  State<NeonButton> createState() => _NeonButtonState();
}

class _NeonButtonState extends State<NeonButton>
    with SingleTickerProviderStateMixin {
  bool _isPressed = false;
  late AnimationController _pressController;
  late Animation<double> _pressAnimation;

  @override
  void initState() {
    super.initState();
    _pressController = AnimationController(
      duration: const Duration(milliseconds: 100),
      vsync: this,
    );
    _pressAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(
      parent: _pressController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _pressController.dispose();
    super.dispose();
  }

  void _handleTapDown(TapDownDetails details) {
    setState(() {
      _isPressed = true;
    });
    _pressController.forward();
  }

  void _handleTapUp(TapUpDetails details) {
    setState(() {
      _isPressed = false;
    });
    _pressController.reverse();
  }

  void _handleTapCancel() {
    setState(() {
      _isPressed = false;
    });
    _pressController.reverse();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: widget.onPressed != null ? _handleTapDown : null,
      onTapUp: widget.onPressed != null ? _handleTapUp : null,
      onTapCancel: widget.onPressed != null ? _handleTapCancel : null,
      onTap: widget.onPressed,
      child: AnimatedBuilder(
        animation: _pressAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _pressAnimation.value,
            child: Container(
              padding: widget.padding,
              decoration: AppTheme.getNeonButtonDecoration(
                color: widget.color,
                borderRadius: widget.borderRadius,
                isDark: widget.isDark,
                isPressed: _isPressed,
              ),
              child: widget.child,
            ),
          );
        },
      ),
    );
  }
}

/// A neon card with glow effects
class NeonCard extends StatelessWidget {
  final Widget child;
  final Color glowColor;
  final double borderRadius;
  final EdgeInsets padding;
  final EdgeInsets margin;
  final bool isDark;

  const NeonCard({
    super.key,
    required this.child,
    required this.glowColor,
    this.borderRadius = 16,
    this.padding = const EdgeInsets.all(20),
    this.margin = const EdgeInsets.all(8),
    this.isDark = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin,
      decoration: BoxDecoration(
        color: isDark ? AppTheme.darkMuted : AppTheme.lightMuted,
        borderRadius: BorderRadius.circular(borderRadius),
        boxShadow: AppTheme.getNeonGlow(
          color: glowColor,
          blurRadius: 20,
          spreadRadius: 1,
          opacity: 0.2,
        ),
      ),
      child: Padding(
        padding: padding,
        child: child,
      ),
    );
  }
}

/// A neon input field with glow effects
class NeonInputField extends StatefulWidget {
  final TextEditingController controller;
  final String hintText;
  final IconData? prefixIcon;
  final bool obscureText;
  final TextInputType keyboardType;
  final Color glowColor;
  final bool isDark;

  const NeonInputField({
    super.key,
    required this.controller,
    required this.hintText,
    this.prefixIcon,
    this.obscureText = false,
    this.keyboardType = TextInputType.text,
    required this.glowColor,
    this.isDark = false,
  });

  @override
  State<NeonInputField> createState() => _NeonInputFieldState();
}

class _NeonInputFieldState extends State<NeonInputField> {
  bool _isFocused = false;

  @override
  Widget build(BuildContext context) {
    return Focus(
      onFocusChange: (hasFocus) {
        setState(() {
          _isFocused = hasFocus;
        });
      },
      child: Container(
        decoration: BoxDecoration(
          color: widget.isDark ? AppTheme.darkInput : AppTheme.lightInput,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: _isFocused ? widget.glowColor : AppTheme.lightBorder,
            width: _isFocused ? 2 : 1,
          ),
          boxShadow: _isFocused
              ? AppTheme.getNeonGlow(
                  color: widget.glowColor,
                  blurRadius: 15,
                  spreadRadius: 1,
                  opacity: 0.3,
                )
              : [],
        ),
        child: TextField(
          controller: widget.controller,
          obscureText: widget.obscureText,
          keyboardType: widget.keyboardType,
          style: TextStyle(
            color: widget.isDark
                ? AppTheme.darkForeground
                : AppTheme.lightForeground,
            fontSize: 16,
          ),
          decoration: InputDecoration(
            hintText: widget.hintText,
            hintStyle: TextStyle(
              color: widget.isDark
                  ? AppTheme.darkMutedForeground
                  : AppTheme.lightMutedForeground,
            ),
            prefixIcon: widget.prefixIcon != null
                ? Icon(
                    widget.prefixIcon,
                    color: _isFocused
                        ? widget.glowColor
                        : AppTheme.lightMutedForeground,
                  )
                : null,
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 16,
            ),
          ),
        ),
      ),
    );
  }
}
