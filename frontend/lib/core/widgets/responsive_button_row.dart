import 'package:flutter/material.dart';
import '../utils/responsive_utils.dart';
import '../theme/app_theme.dart';

class ResponsiveButtonRow extends StatelessWidget {
  final List<ResponsiveButtonData> buttons;
  final MainAxisAlignment mainAxisAlignment;
  final bool forceVerticalOnMobile;
  final double spacing;
  final EdgeInsets? padding;

  const ResponsiveButtonRow({
    super.key,
    required this.buttons,
    this.mainAxisAlignment = MainAxisAlignment.center,
    this.forceVerticalOnMobile = true,
    this.spacing = 12.0,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    final isMobile = context.isMobile;

    if (forceVerticalOnMobile && isMobile) {
      return Padding(
        padding: padding ?? EdgeInsets.zero,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: buttons.asMap().entries.map((entry) {
            final index = entry.key;
            final button = entry.value;
            return Column(
              children: [
                if (index > 0) SizedBox(height: spacing),
                _buildButton(context, button, isFullWidth: true),
              ],
            );
          }).toList(),
        ),
      );
    }

    return Padding(
      padding: padding ?? EdgeInsets.zero,
      child: Row(
        mainAxisAlignment: mainAxisAlignment,
        children: buttons.asMap().entries.map((entry) {
          final index = entry.key;
          final button = entry.value;
          return Row(
            children: [
              if (index > 0) SizedBox(width: spacing),
              Flexible(child: _buildButton(context, button)),
            ],
          );
        }).toList(),
      ),
    );
  }

  Widget _buildButton(BuildContext context, ResponsiveButtonData button,
      {bool isFullWidth = false}) {
    final baseStyle = button.isOutlined
        ? OutlinedButton.styleFrom(
            padding: EdgeInsets.symmetric(
              horizontal: isFullWidth
                  ? 16
                  : context.responsive(mobile: 12.0, desktop: 16.0),
              vertical: 12,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            side: BorderSide(
              color: button.color ?? AppTheme.getPrimaryColor(context),
              width: 1.5,
            ),
          )
        : ElevatedButton.styleFrom(
            backgroundColor: button.color ?? AppTheme.getPrimaryColor(context),
            foregroundColor: button.textColor ?? Colors.white,
            padding: EdgeInsets.symmetric(
              horizontal: isFullWidth
                  ? 16
                  : context.responsive(mobile: 12.0, desktop: 16.0),
              vertical: 12,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            elevation: button.hasGlow ? 4 : 0,
            shadowColor: button.hasGlow
                ? (button.color ?? AppTheme.getPrimaryColor(context))
                    .withValues(alpha: 0.3)
                : null,
          );

    Widget buttonChild = Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (button.icon != null) ...[
          Icon(button.icon, size: 18),
          const SizedBox(width: 8),
        ],
        Flexible(
          child: Text(
            button.text,
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: button.isOutlined
                      ? (button.color ?? AppTheme.getPrimaryColor(context))
                      : (button.textColor ?? Colors.white),
                  fontWeight: FontWeight.w600,
                ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );

    Widget finalButton = SizedBox(
      width: isFullWidth ? double.infinity : null,
      child: button.isOutlined
          ? OutlinedButton(
              onPressed: button.onPressed,
              style: baseStyle,
              child: buttonChild,
            )
          : ElevatedButton(
              onPressed: button.onPressed,
              style: baseStyle,
              child: buttonChild,
            ),
    );

    // Add AI glow effect if enabled
    if (button.hasGlow) {
      return AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: (button.color ?? AppTheme.getPrimaryColor(context))
                  .withValues(alpha: 0.3),
              blurRadius: 8,
              spreadRadius: 0,
              offset: const Offset(0, 2),
            ),
            if (button.hasGlow)
              BoxShadow(
                color: (button.color ?? AppTheme.getPrimaryColor(context))
                    .withValues(alpha: 0.1),
                blurRadius: 16,
                spreadRadius: 2,
                offset: const Offset(0, 4),
              ),
          ],
        ),
        child: finalButton,
      );
    }

    return finalButton;
  }
}

class ResponsiveButtonData {
  final String text;
  final VoidCallback? onPressed;
  final IconData? icon;
  final Color? color;
  final Color? textColor;
  final bool isOutlined;
  final bool hasGlow;

  const ResponsiveButtonData({
    required this.text,
    this.onPressed,
    this.icon,
    this.color,
    this.textColor,
    this.isOutlined = false,
    this.hasGlow = false,
  });
}

// AI-Enhanced Glowing Button Widget
class AIGlowButton extends StatefulWidget {
  final String text;
  final VoidCallback? onPressed;
  final IconData? icon;
  final Color? color;
  final bool isLoading;
  final bool isPrimary;

  const AIGlowButton({
    super.key,
    required this.text,
    this.onPressed,
    this.icon,
    this.color,
    this.isLoading = false,
    this.isPrimary = true,
  });

  @override
  State<AIGlowButton> createState() => _AIGlowButtonState();
}

class _AIGlowButtonState extends State<AIGlowButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _glowAnimation;
  bool _isHovered = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );
    _glowAnimation = Tween<double>(
      begin: 0.3,
      end: 0.8,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    if (widget.isPrimary) {
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
    final primaryColor = widget.color ?? AppTheme.getPrimaryColor(context);

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedBuilder(
        animation: _glowAnimation,
        builder: (context, child) {
          return Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                // Base shadow
                BoxShadow(
                  color: primaryColor.withValues(alpha: 0.2),
                  blurRadius: 8,
                  spreadRadius: 0,
                  offset: const Offset(0, 2),
                ),
                // AI glow effect
                if (widget.isPrimary)
                  BoxShadow(
                    color: primaryColor.withValues(
                        alpha: _glowAnimation.value * 0.4),
                    blurRadius: _isHovered ? 20 : 16,
                    spreadRadius: _isHovered ? 4 : 2,
                    offset: const Offset(0, 4),
                  ),
                // Hover enhancement
                if (_isHovered)
                  BoxShadow(
                    color: primaryColor.withValues(alpha: 0.6),
                    blurRadius: 24,
                    spreadRadius: 6,
                    offset: const Offset(0, 6),
                  ),
              ],
            ),
            child: ElevatedButton(
              onPressed: widget.isLoading ? null : widget.onPressed,
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                foregroundColor: Colors.white,
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
                shadowColor: Colors.transparent,
              ),
              child: widget.isLoading
                  ? SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (widget.icon != null) ...[
                          Icon(widget.icon, size: 18),
                          const SizedBox(width: 8),
                        ],
                        Text(
                          widget.text,
                          style:
                              Theme.of(context).textTheme.labelLarge?.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600,
                                  ),
                        ),
                      ],
                    ),
            ),
          );
        },
      ),
    );
  }
}
