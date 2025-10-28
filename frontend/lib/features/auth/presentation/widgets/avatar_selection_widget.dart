import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_carousel_widget/flutter_carousel_widget.dart'
    as carousel;
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shimmer/shimmer.dart';

import '../../../../core/theme/app_theme.dart';
import '../../data/models/auth_models.dart';
import '../../data/services/avatar_service.dart';
import '../../data/models/avatar_api_models.dart';

class AvatarSelectionWidget extends StatefulWidget {
  final Avatar? selectedAvatar;
  final Function(Avatar) onAvatarSelected;
  final List<Avatar> avatars;

  const AvatarSelectionWidget({
    super.key,
    this.selectedAvatar,
    required this.onAvatarSelected,
    required this.avatars,
  });

  @override
  State<AvatarSelectionWidget> createState() => _AvatarSelectionWidgetState();
}

class _AvatarSelectionWidgetState extends State<AvatarSelectionWidget>
    with TickerProviderStateMixin {
  int _currentIndex = 0;

  final AvatarService _avatarService = AvatarService();
  List<Avatar> _avatars = [];
  bool _isLoading = true;
  bool _isLoadingMore = false;
  String? _error;
  bool _isInitialized = false;
  static const int _initialBatchSize = 20; // Load more avatars initially
  static const int _moreBatchSize = 10; // Increased from 3 to 10
  int _loadedCount = 0;

  late AnimationController _fadeController;
  late AnimationController _slideController;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    _loadInitialAvatars();

    if (widget.selectedAvatar != null) {
      final index = widget.avatars.indexWhere(
        (avatar) => avatar.id == widget.selectedAvatar!.id,
      );
      if (index != -1) {
        _currentIndex = index;
      }
    }
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  Future<void> _loadInitialAvatars() async {
    if (_isInitialized) return;

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      List<AvatarData> avatarDataList = [];

      try {
        // Try to fetch predefined avatars first (now loads in parallel - MUCH faster!)
        avatarDataList = await _avatarService.fetchPredefinedAvatars();
      } catch (e) {
        // Fallback to random avatars with larger batch size
        avatarDataList = await _avatarService.fetchRandomAvatars(
          count: _initialBatchSize,
        );
      }

      if (!mounted) return;

      setState(() {
        _avatars = avatarDataList.map((data) => data.toAvatar()).toList();
        _loadedCount = _avatars.length;
        _isLoading = false;
        _isInitialized = true;
      });

      _fadeController.forward();

      // Pre-cache images in background (optimized - don't block UI)
      _precacheAvatarImages(_avatars.take(6).toList());
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _error = 'Failed to load avatars. Please check your connection.';
        _isLoading = false;
        _avatars = _getFallbackAvatars();
        _loadedCount = _avatars.length;
        _isInitialized = true;
      });
    }
  }

  /// Optimized image precaching - runs in background without blocking UI
  void _precacheAvatarImages(List<Avatar> avatars) {
    if (!mounted) return;

    final toPrecache =
        avatars.where((a) => a.imageUrl.startsWith('http')).toList();
    if (toPrecache.isEmpty) return;

    // Schedule precaching in next frame to avoid blocking current build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      for (final avatar in toPrecache) {
        precacheImage(
          CachedNetworkImageProvider(avatar.imageUrl),
          context,
        ).catchError((_) {
          // Silently ignore precache errors
        });
      }
    });
  }

  Future<void> _loadMoreAvatars() async {
    if (_isLoadingMore || !_isInitialized) return;

    setState(() {
      _isLoadingMore = true;
    });

    try {
      final newAvatars = await _avatarService.fetchMoreAvatars(
        count: _moreBatchSize, // Increased batch size for faster loading
        offset: _loadedCount,
      );

      if (!mounted) return;

      final newAvatarsList = newAvatars.map((data) => data.toAvatar()).toList();

      setState(() {
        _avatars.addAll(newAvatarsList);
        _loadedCount = _avatars.length;
        _isLoadingMore = false;
      });

      // Pre-cache newly loaded avatars (optimized)
      _precacheAvatarImages(newAvatarsList.take(6).toList());
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isLoadingMore = false;
      });
    }
  }

  List<Avatar> _getFallbackAvatars() {
    return [
      const Avatar(
        id: 'fallback_1',
        name: 'Default Avatar 1',
        imageUrl: 'https://avatar.iran.liara.run/public/4',
        category: 'avatar',
      ),
      const Avatar(
        id: 'fallback_2',
        name: 'Default Avatar 2',
        imageUrl: 'https://avatar.iran.liara.run/public/12',
        category: 'avatar',
      ),
      const Avatar(
        id: 'fallback_3',
        name: 'Default Avatar 3',
        imageUrl: 'https://avatar.iran.liara.run/public/23',
        category: 'avatar',
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          const SizedBox(height: 32),
          _isLoading ? _buildLoadingView() : _buildAvatarCarousel(),
          const SizedBox(height: 24),
          _isLoading ? const SizedBox.shrink() : _buildAvatarInfo(),
          const SizedBox(height: 12),
          _isLoading ? const SizedBox.shrink() : _buildLoadingStatus(),
          if (_error != null && !_isLoading) ...[
            const SizedBox(height: 20),
            _buildErrorView(),
          ],
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ShaderMask(
            shaderCallback: (bounds) => LinearGradient(
              colors: [AppTheme.primaryColor, AppTheme.accentColor],
            ).createShader(bounds),
            child: Text(
              'Choose Your Avatar',
              style: GoogleFonts.poppins(
                fontSize: 32,
                fontWeight: FontWeight.w800,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Select an avatar that represents you in the marketplace',
            style: GoogleFonts.poppins(
              fontSize: 15,
              color: AppTheme.grey600,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAvatarCarousel() {
    return FadeTransition(
      opacity: _fadeController,
      child: Column(
        children: [
          carousel.FlutterCarousel(
            options: carousel.CarouselOptions(
              height: 280,
              enlargeCenterPage: true,
              enableInfiniteScroll: false,
              autoPlay: false,
              viewportFraction: 0.62,
              onPageChanged: (index, reason) {
                setState(() {
                  _currentIndex = index;
                  // Load more when user is 5 avatars away from the end (proactive loading)
                  if (index >= _avatars.length - 5 && !_isLoadingMore) {
                    _loadMoreAvatars();
                  }
                });
              },
            ),
            items: [
              ..._avatars.map((avatar) {
                final isSelected = widget.selectedAvatar?.id == avatar.id;
                final currentId =
                    (_avatars.isNotEmpty && _currentIndex < _avatars.length)
                        ? _avatars[_currentIndex].id
                        : null;
                final isCurrent = currentId != null && currentId == avatar.id;

                return Builder(
                  builder: (BuildContext context) {
                    return GestureDetector(
                      onTap: () {
                        widget.onAvatarSelected(avatar);
                        setState(() {
                          _currentIndex = _avatars.indexOf(avatar);
                        });
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeOutCubic,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(
                                  isSelected || isCurrent ? 0.15 : 0.08),
                              blurRadius: isSelected || isCurrent ? 24 : 12,
                              offset:
                                  Offset(0, isSelected || isCurrent ? 8 : 4),
                              spreadRadius: 0,
                            ),
                          ],
                        ),
                        child: Stack(
                          children: [
                            // Main avatar image with improved styling
                            ClipRRect(
                              borderRadius: BorderRadius.circular(24),
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(24),
                                ),
                                child: Stack(
                                  children: [
                                    avatar.imageUrl.startsWith('http')
                                        ? CachedNetworkImage(
                                            imageUrl: avatar.imageUrl,
                                            fit: BoxFit.cover,
                                            placeholder: (context, url) =>
                                                Shimmer.fromColors(
                                              baseColor: AppTheme.grey100,
                                              highlightColor: AppTheme.grey50,
                                              child: Container(
                                                color: AppTheme.grey50,
                                              ),
                                            ),
                                            errorWidget:
                                                (context, url, error) =>
                                                    _buildPlaceholderAvatar(
                                                        avatar.name),
                                            fadeInDuration: const Duration(
                                                milliseconds: 200),
                                            useOldImageOnUrlChange: true,
                                            cacheKey: avatar.id,
                                            maxHeightDiskCache: 400,
                                            maxWidthDiskCache: 400,
                                            memCacheHeight: 300,
                                            memCacheWidth: 300,
                                          )
                                        : _buildPlaceholderAvatar(avatar.name),
                                    // Subtle gradient overlay for depth
                                    Positioned(
                                      bottom: 0,
                                      left: 0,
                                      right: 0,
                                      child: Container(
                                        height: 80,
                                        decoration: BoxDecoration(
                                          gradient: LinearGradient(
                                            begin: Alignment.topCenter,
                                            end: Alignment.bottomCenter,
                                            colors: [
                                              Colors.transparent,
                                              Colors.black.withOpacity(
                                                  isSelected || isCurrent
                                                      ? 0.25
                                                      : 0.15),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            // Selection indicator with modern design
                            if (isSelected || isCurrent)
                              Positioned(
                                top: 16,
                                right: 16,
                                child: ScaleTransition(
                                  scale: Tween<double>(begin: 0.0, end: 1.0)
                                      .animate(CurvedAnimation(
                                    parent: _fadeController,
                                    curve: Curves.elasticOut,
                                  )),
                                  child: Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        colors: [
                                          Colors.white,
                                          Colors.white.withOpacity(0.95),
                                        ],
                                      ),
                                      shape: BoxShape.circle,
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.2),
                                          blurRadius: 12,
                                          offset: const Offset(0, 4),
                                        ),
                                      ],
                                    ),
                                    child: Icon(
                                      Icons.check_circle_rounded,
                                      color: AppTheme.primaryColor,
                                      size: 24,
                                    ),
                                  ),
                                ),
                              ),
                            // Active indicator ring (subtle)
                            if (isSelected || isCurrent)
                              Positioned.fill(
                                child: Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(24),
                                    border: Border.all(
                                      color: Colors.white.withOpacity(0.3),
                                      width: 2,
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              }).toList(),
              if (_isLoadingMore)
                Builder(
                  builder: (BuildContext context) {
                    return Container(
                      margin: const EdgeInsets.symmetric(horizontal: 8),
                      width: MediaQuery.of(context).size.width * 0.65,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(24),
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Colors.white,
                            AppTheme.grey50.withOpacity(0.5),
                          ],
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.08),
                            blurRadius: 16,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(
                              width: 44,
                              height: 44,
                              child: CircularProgressIndicator(
                                strokeWidth: 3,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                    AppTheme.primaryColor),
                              ),
                            ),
                            const SizedBox(height: 20),
                            Text(
                              'Loading more avatars',
                              style: GoogleFonts.poppins(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: AppTheme.grey800,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              'Discovering new faces',
                              style: GoogleFonts.poppins(
                                fontSize: 12,
                                color: AppTheme.grey600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
            ],
          ),
          const SizedBox(height: 20),
          _buildEnhancedIndicators(),
        ],
      ),
    );
  }

  Widget _buildEnhancedIndicators() {
    // If we have many avatars, show a compact indicator (current/total + progress bar)
    if (_avatars.length > 8) {
      final progress =
          _avatars.isEmpty ? 0.0 : ((_currentIndex + 1) / _avatars.length);
      return Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${_currentIndex + 1}/${_avatars.length}',
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.grey700,
                  ),
                ),
                Text(
                  'Swipe to explore',
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: AppTheme.grey500,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: LinearProgressIndicator(
              value: progress,
              color: AppTheme.primaryColor,
              backgroundColor: AppTheme.grey100,
              minHeight: 6,
            ),
          ),
        ],
      );
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: _avatars.asMap().entries.map((entry) {
        final isActive = _currentIndex == entry.key;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 350),
          curve: Curves.easeOutCubic,
          width: isActive ? 32 : 8,
          height: 8,
          margin: const EdgeInsets.symmetric(horizontal: 5),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(4),
            color: isActive ? AppTheme.primaryColor : AppTheme.grey300,
            boxShadow: isActive
                ? [
                    BoxShadow(
                      color: AppTheme.primaryColor.withOpacity(0.3),
                      blurRadius: 8,
                      spreadRadius: 0,
                    ),
                  ]
                : null,
          ),
        );
      }).toList(),
    );
  }

  Widget _buildPlaceholderAvatar(String name) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppTheme.grey50,
            AppTheme.grey100.withOpacity(0.5),
          ],
        ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.8),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.person_outline_rounded,
                size: 48,
                color: AppTheme.grey600,
              ),
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                name,
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.grey700,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAvatarInfo() {
    if (_currentIndex >= _avatars.length) return const SizedBox.shrink();

    final currentAvatar = _avatars[_currentIndex];

    return SlideTransition(
      position: Tween<Offset>(begin: const Offset(0, 0.2), end: Offset.zero)
          .animate(_slideController),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: Row(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                color: AppTheme.grey100,
              ),
              child: currentAvatar.imageUrl.startsWith('http')
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: CachedNetworkImage(
                        imageUrl: currentAvatar.imageUrl,
                        fit: BoxFit.cover,
                        placeholder: (context, url) => Shimmer.fromColors(
                          baseColor: AppTheme.grey100,
                          highlightColor: AppTheme.grey50,
                          child: Container(
                            color: AppTheme.grey50,
                          ),
                        ),
                        errorWidget: (context, url, error) => Icon(
                          Icons.person_rounded,
                          color: AppTheme.grey600,
                          size: 28,
                        ),
                        fadeInDuration: const Duration(milliseconds: 150),
                        useOldImageOnUrlChange: true,
                        cacheKey: currentAvatar.id,
                        maxHeightDiskCache: 100,
                        maxWidthDiskCache: 100,
                        memCacheHeight: 80,
                        memCacheWidth: 80,
                      ),
                    )
                  : Icon(
                      Icons.person_rounded,
                      color: AppTheme.grey600,
                      size: 28,
                    ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    currentAvatar.name,
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.grey900,
                      letterSpacing: -0.2,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      currentAvatar.category,
                      style: GoogleFonts.poppins(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.primaryColor,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingView() {
    return Container(
      height: 240,
      decoration: BoxDecoration(
        color: AppTheme.grey50,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppTheme.grey100),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 50,
              height: 50,
              child: CircularProgressIndicator(
                strokeWidth: 2.5,
                valueColor:
                    AlwaysStoppedAnimation<Color>(AppTheme.primaryColor),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Loading avatars...',
              style: GoogleFonts.poppins(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: AppTheme.grey700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Finding the perfect match for you',
              style: GoogleFonts.poppins(
                fontSize: 12,
                color: AppTheme.grey500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingStatus() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.check_circle_rounded,
            size: 18,
            color: AppTheme.primaryColor,
          ),
          const SizedBox(width: 8),
          Text(
            '$_loadedCount avatars loaded',
            style: GoogleFonts.poppins(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: AppTheme.grey600,
            ),
          ),
          if (_isLoadingMore) ...[
            const SizedBox(width: 12),
            SizedBox(
              width: 14,
              height: 14,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor:
                    AlwaysStoppedAnimation<Color>(AppTheme.primaryColor),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildErrorView() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.errorColor.withOpacity(0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppTheme.errorColor.withOpacity(0.2),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.error_rounded,
            color: AppTheme.errorColor,
            size: 24,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Connection Error',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.errorColor,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _error ?? 'Failed to load avatars',
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: AppTheme.errorColor.withOpacity(0.8),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          TextButton(
            onPressed: _loadInitialAvatars,
            style: TextButton.styleFrom(
              backgroundColor: AppTheme.primaryColor,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text(
              'Retry',
              style: GoogleFonts.poppins(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
