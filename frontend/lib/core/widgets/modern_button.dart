import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../theme/app_theme.dart';

class ModernButton extends StatefulWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool isFullWidth;
  final IconData? icon;
  final Color? color;
  final Color? textColor;
  final double height;
  final double borderRadius;
  final bool hasGradient;
  final List<Color>? gradientColors;
  final bool isOutlined;

  const ModernButton({
    super.key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.isFullWidth = true,
    this.icon,
    this.color,
    this.textColor,
    this.height = 56,
    this.borderRadius = 16,
    this.hasGradient = false,
    this.gradientColors,
    this.isOutlined = false,
  });

  @override
  State<ModernButton> createState() => _ModernButtonState();
}

class _ModernButtonState extends State<ModernButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final buttonColor = widget.color ?? AppTheme.lightPrimary;
    final foregroundColor = widget.textColor ?? AppTheme.lightPrimaryForeground;

    if (widget.isOutlined) {
      return _buildOutlinedButton(context, buttonColor, foregroundColor);
    }

    return _buildFilledButton(context, buttonColor, foregroundColor);
  }

  Widget _buildFilledButton(
      BuildContext context, Color buttonColor, Color foregroundColor) {
    return SizedBox(
      width: widget.isFullWidth ? double.infinity : null,
      height: widget.height,
      child: GestureDetector(
        onTapDown: (_) => setState(() => _isPressed = true),
        onTapUp: (_) => setState(() => _isPressed = false),
        onTapCancel: () => setState(() => _isPressed = false),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          transform: Matrix4.identity()..scale(_isPressed ? 0.98 : 1.0),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: widget.isLoading ? null : widget.onPressed,
              borderRadius: BorderRadius.circular(widget.borderRadius),
              child: Container(
                decoration: BoxDecoration(
                  gradient: widget.hasGradient
                      ? LinearGradient(
                          colors: widget.gradientColors ??
                              [
                                buttonColor,
                                buttonColor.withValues(alpha: 0.8),
                              ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        )
                      : null,
                  color: widget.hasGradient ? null : buttonColor,
                  borderRadius: BorderRadius.circular(widget.borderRadius),
                  boxShadow: _isPressed
                      ? []
                      : [
                          BoxShadow(
                            color: buttonColor.withValues(alpha: 0.3),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                ),
                child: Center(
                  child: widget.isLoading
                      ? SizedBox(
                          height: 24,
                          width: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            valueColor:
                                AlwaysStoppedAnimation<Color>(foregroundColor),
                          ),
                        )
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (widget.icon != null) ...[
                              Icon(
                                widget.icon,
                                color: foregroundColor,
                                size: 20,
                              ),
                              const SizedBox(width: 12),
                            ],
                            Text(
                              widget.text,
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium
                                  ?.copyWith(
                                    color: foregroundColor,
                                    fontWeight: FontWeight.w600,
                                  ),
                            ),
                          ],
                        ),
                ),
              ),
            ),
          ),
        ),
      ),
    ).animate(key: ValueKey(widget.isLoading)).fadeIn();
  }

  Widget _buildOutlinedButton(
      BuildContext context, Color buttonColor, Color foregroundColor) {
    return SizedBox(
      width: widget.isFullWidth ? double.infinity : null,
      height: widget.height,
      child: OutlinedButton(
        onPressed: widget.isLoading ? null : widget.onPressed,
        style: OutlinedButton.styleFrom(
          foregroundColor: buttonColor,
          side: BorderSide(color: buttonColor, width: 2),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(widget.borderRadius),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        ),
        child: widget.isLoading
            ? SizedBox(
                height: 24,
                width: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  valueColor: AlwaysStoppedAnimation<Color>(buttonColor),
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (widget.icon != null) ...[
                    Icon(widget.icon, size: 20),
                    const SizedBox(width: 12),
                  ],
                  Text(widget.text),
                ],
              ),
      ),
    );
  }
}

class IconTextButton extends StatelessWidget {
  final String text;
  final IconData icon;
  final VoidCallback? onPressed;
  final Color? color;

  const IconTextButton({
    super.key,
    required this.text,
    required this.icon,
    this.onPressed,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final buttonColor = color ?? AppTheme.lightPrimary;

    return TextButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 20),
      label: Text(text),
      style: TextButton.styleFrom(
        foregroundColor: buttonColor,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
    );
  }
}

class FloatingButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onPressed;
  final Color? color;
  final String? tooltip;

  const FloatingButton({
    super.key,
    required this.icon,
    this.onPressed,
    this.color,
    this.tooltip,
  });

  @override
  Widget build(BuildContext context) {
    final buttonColor = color ?? AppTheme.lightPrimary;

    return FloatingActionButton(
      onPressed: onPressed,
      backgroundColor: buttonColor,
      tooltip: tooltip,
      child: Icon(icon, color: Colors.white),
    );
  }
}

class ModernIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onPressed;
  final Color? color;
  final double size;
  final String? tooltip;

  const ModernIconButton({
    super.key,
    required this.icon,
    this.onPressed,
    this.color,
    this.size = 24,
    this.tooltip,
  });

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: onPressed,
      icon: Icon(icon, size: size),
      color: color,
      tooltip: tooltip,
    );
  }
}

