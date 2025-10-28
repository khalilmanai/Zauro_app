import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class ShimmerLoader extends StatefulWidget {
  final Widget child;
  final Color? baseColor;
  final Color? highlightColor;
  final Duration duration;
  final double animationStrength;

  const ShimmerLoader({
    super.key,
    required this.child,
    this.baseColor,
    this.highlightColor,
    this.duration = const Duration(milliseconds: 1500),
    this.animationStrength = 0.3,
  });

  @override
  State<ShimmerLoader> createState() => _ShimmerLoaderState();
}

class _ShimmerLoaderState extends State<ShimmerLoader>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _shimmerAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );
    _shimmerAnimation = Tween<double>(
      begin: -1.0,
      end: 2.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));

    _controller.repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _shimmerAnimation,
      builder: (context, child) {
        return ShaderMask(
          shaderCallback: (bounds) {
            return LinearGradient(
              colors: [
                widget.baseColor ?? Colors.grey.withValues(alpha: 0.1),
                widget.highlightColor ??
                    Colors.white.withValues(alpha: widget.animationStrength),
                widget.baseColor ?? Colors.grey.withValues(alpha: 0.1),
              ],
              stops: [
                _shimmerAnimation.value - 0.3,
                _shimmerAnimation.value,
                _shimmerAnimation.value + 0.3,
              ].map((e) => e.clamp(0.0, 1.0)).toList(),
            ).createShader(bounds);
          },
          child: widget.child,
        );
      },
    );
  }
}

class PulseLoader extends StatefulWidget {
  final Widget child;
  final Color? pulseColor;
  final Duration duration;
  final double scaleFactor;

  const PulseLoader({
    super.key,
    required this.child,
    this.pulseColor,
    this.duration = const Duration(milliseconds: 1000),
    this.scaleFactor = 1.1,
  });

  @override
  State<PulseLoader> createState() => _PulseLoaderState();
}

class _PulseLoaderState extends State<PulseLoader>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: widget.scaleFactor,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));

    _opacityAnimation = Tween<double>(
      begin: 0.5,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));

    _controller.repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Opacity(
            opacity: _opacityAnimation.value,
            child: widget.child,
          ),
        );
      },
    );
  }
}

class BouncingLoader extends StatefulWidget {
  final Widget child;
  final Duration duration;
  final double bounceHeight;

  const BouncingLoader({
    super.key,
    required this.child,
    this.duration = const Duration(milliseconds: 600),
    this.bounceHeight = 20,
  });

  @override
  State<BouncingLoader> createState() => _BouncingLoaderState();
}

class _BouncingLoaderState extends State<BouncingLoader>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _bounceAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    _bounceAnimation = Tween<double>(
      begin: 0.0,
      end: widget.bounceHeight,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.elasticOut,
    ));

    _controller.repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, -_bounceAnimation.value),
          child: widget.child,
        );
      },
    );
  }
}

class ShimmerCard extends StatelessWidget {
  final double? width;
  final double? height;
  final double borderRadius;
  final EdgeInsetsGeometry? padding;

  const ShimmerCard({
    super.key,
    this.width,
    this.height,
    this.borderRadius = 16,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return ShimmerLoader(
      child: Container(
        width: width,
        height: height,
        padding: padding ?? const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.grey.withValues(alpha: 0.3),
          borderRadius: BorderRadius.circular(borderRadius),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 20,
              decoration: BoxDecoration(
                color: Colors.grey,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            const SizedBox(height: 12),
            Container(
              height: 16,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.grey,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            const SizedBox(height: 8),
            Container(
              height: 16,
              width: MediaQuery.of(context).size.width * 0.6,
              decoration: BoxDecoration(
                color: Colors.grey,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class LoadingOverlay extends StatefulWidget {
  final Widget child;
  final bool isLoading;
  final String? loadingText;
  final Widget? loadingWidget;
  final Color? overlayColor;
  final bool isDimmed;

  const LoadingOverlay({
    super.key,
    required this.child,
    required this.isLoading,
    this.loadingText,
    this.loadingWidget,
    this.overlayColor,
    this.isDimmed = true,
  });

  @override
  State<LoadingOverlay> createState() => _LoadingOverlayState();
}

class _LoadingOverlayState extends State<LoadingOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: AppTheme.fastAnimation,
      vsync: this,
    );
    _opacityAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void didUpdateWidget(LoadingOverlay oldwidget) {
    super.didUpdateWidget(oldwidget);
    if (widget.isLoading != oldwidget.isLoading) {
      if (widget.isLoading) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        widget.child,
        if (widget.isLoading)
          AnimatedBuilder(
            animation: _opacityAnimation,
            builder: (context, child) {
              return Opacity(
                opacity: _opacityAnimation.value,
                child: Container(
                  color: widget.isDimmed
                      ? (widget.overlayColor ??
                          Colors.black.withValues(alpha: 0.3))
                      : Colors.transparent,
                  child: Center(
                    child: PremiumLoadingIndicator(
                      text: widget.loadingText,
                      customLoadingWidget: widget.loadingWidget,
                    ),
                  ),
                ),
              );
            },
          ),
      ],
    );
  }
}

class PremiumLoadingIndicator extends StatelessWidget {
  final String? text;
  final Widget? customLoadingWidget;
  final double size;
  final Color? color;

  const PremiumLoadingIndicator({
    super.key,
    this.text,
    this.customLoadingWidget,
    this.size = 50,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (customLoadingWidget != null) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          customLoadingWidget!,
          if (text != null) ...[
            const SizedBox(height: 16),
            Text(
              text!,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: color ?? theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ],
      );
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        PulseLoader(
          child: Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              color: color ?? theme.colorScheme.primary,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.pets,
              color: theme.colorScheme.onPrimary,
              size: size * 0.6,
            ),
          ),
        ),
        if (text != null) ...[
          const SizedBox(height: 16),
          Text(
            text!,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: color ?? theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ],
    );
  }
}

class SkeletonLoader extends StatefulWidget {
  final int itemCount;
  final Widget Function(BuildContext context, int index)? itemBuilder;
  final Duration shimmerDuration;

  const SkeletonLoader({
    super.key,
    this.itemCount = 3,
    this.itemBuilder,
    this.shimmerDuration = const Duration(milliseconds: 1500),
  }) : assert(itemCount > 0, 'itemCount must be greater than 0');

  @override
  State<SkeletonLoader> createState() => _SkeletonLoaderState();
}

class _SkeletonLoaderState extends State<SkeletonLoader> {
  @override
  Widget build(BuildContext context) {
    return ShimmerLoader(
      duration: widget.shimmerDuration,
      child: ListView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: widget.itemCount,
        itemBuilder: widget.itemBuilder ?? _defaultItemBuilder,
      ),
    );
  }

  Widget _defaultItemBuilder(BuildContext context, int index) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ShimmerCard(height: 80),
    );
  }
}
