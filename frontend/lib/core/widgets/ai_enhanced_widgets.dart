import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../utils/responsive_utils.dart';

// AI-Enhanced Card with Glowing Effects
class AIEnhancedCard extends StatefulWidget {
  final Widget child;
  final EdgeInsets? padding;
  final EdgeInsets? margin;
  final double? elevation;
  final Color? color;
  final BorderRadius? borderRadius;
  final bool hasAIGlow;
  final Color? glowColor;
  final VoidCallback? onTap;

  const AIEnhancedCard({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.elevation,
    this.color,
    this.borderRadius,
    this.hasAIGlow = false,
    this.glowColor,
    this.onTap,
  });

  @override
  State<AIEnhancedCard> createState() => _AIEnhancedCardState();
}

class _AIEnhancedCardState extends State<AIEnhancedCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _glowAnimation;
  bool _isHovered = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 3000),
      vsync: this,
    );
    _glowAnimation = Tween<double>(
      begin: 0.2,
      end: 0.6,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    if (widget.hasAIGlow) {
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
    final glowColor = widget.glowColor ?? AppTheme.getPrimaryColor(context);

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedBuilder(
        animation: _glowAnimation,
        builder: (context, child) {
          return Container(
            margin: widget.margin ?? ResponsiveUtils.responsiveMargin(context),
            decoration: BoxDecoration(
              borderRadius: widget.borderRadius ?? BorderRadius.circular(20),
              boxShadow: [
                // Base shadow
                BoxShadow(
                  color: Theme.of(context).shadowColor.withValues(alpha: 0.1),
                  offset: const Offset(0, 2),
                  blurRadius: widget.elevation ?? 8,
                ),
                // AI glow effect
                if (widget.hasAIGlow)
                  BoxShadow(
                    color:
                        glowColor.withValues(alpha: _glowAnimation.value * 0.3),
                    blurRadius: _isHovered ? 24 : 16,
                    spreadRadius: _isHovered ? 4 : 2,
                    offset: const Offset(0, 4),
                  ),
                // Hover enhancement
                if (_isHovered && !widget.hasAIGlow)
                  BoxShadow(
                    color: glowColor.withValues(alpha: 0.2),
                    blurRadius: 16,
                    spreadRadius: 2,
                    offset: const Offset(0, 4),
                  ),
              ],
            ),
            child: Material(
              color: widget.color ?? Theme.of(context).cardColor,
              borderRadius: widget.borderRadius ?? BorderRadius.circular(20),
              child: InkWell(
                onTap: widget.onTap,
                borderRadius: widget.borderRadius ?? BorderRadius.circular(20),
                child: Container(
                  padding: widget.padding ??
                      ResponsiveUtils.responsivePadding(context),
                  decoration: BoxDecoration(
                    borderRadius:
                        widget.borderRadius ?? BorderRadius.circular(20),
                    border: Border.all(
                      color: AppTheme.getBorderColor(context),
                      width: 1,
                    ),
                  ),
                  child: widget.child,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

// AI-Enhanced Stats Card
class AIStatsCard extends StatefulWidget {
  final String title;
  final String value;
  final String subtitle;
  final IconData icon;
  final Color color;
  final String trend;
  final bool isPositive;
  final bool isLarge;
  final bool hasAIGlow;

  const AIStatsCard({
    super.key,
    required this.title,
    required this.value,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.trend,
    required this.isPositive,
    this.isLarge = false,
    this.hasAIGlow = false,
  });

  @override
  State<AIStatsCard> createState() => _AIStatsCardState();
}

class _AIStatsCardState extends State<AIStatsCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );
    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.05,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));

    if (widget.hasAIGlow) {
      _pulseController.repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _pulseAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: widget.hasAIGlow ? _pulseAnimation.value : 1.0,
          child: AIEnhancedCard(
            hasAIGlow: widget.hasAIGlow,
            glowColor: widget.color,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      width: widget.isLarge ? 56 : 48,
                      height: widget.isLarge ? 56 : 48,
                      decoration: BoxDecoration(
                        color: widget.color.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Icon(
                        widget.icon,
                        color: widget.color,
                        size: widget.isLarge ? 28 : 24,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: (widget.isPositive
                                ? AppTheme.getSuccessColor(context)
                                : AppTheme.errorColor)
                            .withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            widget.isPositive
                                ? Icons.trending_up
                                : Icons.trending_down,
                            size: 14,
                            color: widget.isPositive
                                ? AppTheme.getSuccessColor(context)
                                : AppTheme.errorColor,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            widget.trend,
                            style: Theme.of(context)
                                .textTheme
                                .labelSmall
                                ?.copyWith(
                                  color: widget.isPositive
                                      ? AppTheme.getSuccessColor(context)
                                      : AppTheme.errorColor,
                                  fontWeight: FontWeight.w600,
                                ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: widget.isLarge ? 20 : 16),
                Text(
                  widget.value,
                  style: (widget.isLarge
                          ? Theme.of(context).textTheme.headlineLarge
                          : Theme.of(context).textTheme.headlineMedium)
                      ?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  widget.title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onSurface,
                        fontWeight: FontWeight.w600,
                      ),
                ),
                const SizedBox(height: 2),
                Text(
                  widget.subtitle,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

// AI-Enhanced Action Card
class AIActionCard extends StatefulWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  final bool hasAIGlow;

  const AIActionCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.onTap,
    this.hasAIGlow = false,
  });

  @override
  State<AIActionCard> createState() => _AIActionCardState();
}

class _AIActionCardState extends State<AIActionCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _hoverController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _hoverController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.02,
    ).animate(CurvedAnimation(
      parent: _hoverController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _hoverController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) {
        _hoverController.forward();
      },
      onExit: (_) {
        _hoverController.reverse();
      },
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: AIEnhancedCard(
              hasAIGlow: widget.hasAIGlow,
              glowColor: widget.color,
              onTap: widget.onTap,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: widget.color.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Icon(
                      widget.icon,
                      color: widget.color,
                      size: 30,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    widget.title,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    widget.subtitle,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
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

// AI-Enhanced Header with Particle Effects
class AIEnhancedHeader extends StatefulWidget {
  final String greeting;
  final String userName;
  final Widget? trailing;
  final bool showParticles;

  const AIEnhancedHeader({
    super.key,
    required this.greeting,
    required this.userName,
    this.trailing,
    this.showParticles = true,
  });

  @override
  State<AIEnhancedHeader> createState() => _AIEnhancedHeaderState();
}

class _AIEnhancedHeaderState extends State<AIEnhancedHeader>
    with TickerProviderStateMixin {
  late AnimationController _particleController;
  late List<Particle> _particles;

  @override
  void initState() {
    super.initState();
    _particleController = AnimationController(
      duration: const Duration(seconds: 10),
      vsync: this,
    );

    _particles = List.generate(20, (index) => Particle());

    if (widget.showParticles) {
      _particleController.repeat();
    }
  }

  @override
  void dispose() {
    _particleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppTheme.getPrimaryColor(context),
            AppTheme.getPrimaryColor(context).withValues(alpha: 0.8),
            AppTheme.getAccentColor(context).withValues(alpha: 0.6),
          ],
        ),
      ),
      child: Stack(
        children: [
          // Particle background
          if (widget.showParticles)
            AnimatedBuilder(
              animation: _particleController,
              builder: (context, child) {
                return CustomPaint(
                  painter:
                      ParticlePainter(_particles, _particleController.value),
                  size: Size.infinite,
                );
              },
            ),
          // Content
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 40, 20, 20),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.greeting,
                          style:
                              Theme.of(context).textTheme.bodyLarge?.copyWith(
                                    color: Colors.white.withValues(alpha: 0.9),
                                    fontWeight: FontWeight.w500,
                                  ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          widget.userName,
                          style: Theme.of(context)
                              .textTheme
                              .headlineMedium
                              ?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                      ],
                    ),
                  ),
                  if (widget.trailing != null) widget.trailing!,
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class Particle {
  late double x;
  late double y;
  late double speed;
  late double size;
  late double opacity;

  Particle() {
    reset();
  }

  void reset() {
    x = (DateTime.now().millisecondsSinceEpoch % 1000) / 1000.0;
    y = (DateTime.now().microsecondsSinceEpoch % 1000) / 1000.0;
    speed = 0.1 + (DateTime.now().millisecondsSinceEpoch % 100) / 1000.0;
    size = 2 + (DateTime.now().microsecondsSinceEpoch % 4);
    opacity = 0.1 + (DateTime.now().millisecondsSinceEpoch % 40) / 100.0;
  }

  void update(double progress) {
    y -= speed * progress;
    if (y < 0) {
      reset();
      y = 1.0;
    }
  }
}

class ParticlePainter extends CustomPainter {
  final List<Particle> particles;
  final double progress;

  ParticlePainter(this.particles, this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.3)
      ..style = PaintingStyle.fill;

    for (final particle in particles) {
      particle.update(progress);
      canvas.drawCircle(
        Offset(
          particle.x * size.width,
          particle.y * size.height,
        ),
        particle.size,
        paint..color = Colors.white.withValues(alpha: particle.opacity),
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
