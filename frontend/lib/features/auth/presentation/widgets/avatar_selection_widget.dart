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
  final carousel.CarouselController _carouselController =
      carousel.CarouselController();

  final AvatarService _avatarService = AvatarService();
  List<Avatar> _avatars = [];
  bool _isLoading = true;
  bool _isLoadingMore = false;
  String? _error;
  bool _isInitialized = false;
  static const int _batchSize = 5;
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
        avatarDataList = await _avatarService.fetchPredefinedAvatars();
      } catch (e) {
        avatarDataList =
            await _avatarService.fetchRandomAvatars(count: _batchSize);
      }

      setState(() {
        _avatars = avatarDataList.map((data) => data.toAvatar()).toList();
        _loadedCount = _avatars.length;
        _isLoading = false;
        _isInitialized = true;
      });

      // Pre-cache a small batch of images to reduce jank on first view
      final toPrecache = _avatars
          .take(10)
          .where((a) => a.imageUrl.startsWith('http'))
          .toList();
      if (toPrecache.isNotEmpty) {
        // run in background so UI isn't blocked
        Future(() async {
          for (final a in toPrecache) {
            try {
              await precacheImage(
                  CachedNetworkImageProvider(a.imageUrl), context);
            } catch (_) {
              // ignore individual precache errors
            }
          }
        });
      }

      _fadeController.forward();
    } catch (e) {
      setState(() {
        _error = 'Failed to load avatars. Please check your connection.';
        _isLoading = false;
        _avatars = _getFallbackAvatars();
        _loadedCount = _avatars.length;
        _isInitialized = true;
      });
    }
  }

  Future<void> _loadMoreAvatars() async {
    if (_isLoadingMore || !_isInitialized) return;

    setState(() {
      _isLoadingMore = true;
    });

    try {
      final newAvatars = await _avatarService.fetchMoreAvatars(
        count: _batchSize,
        offset: _loadedCount,
      );

      setState(() {
        _avatars.addAll(newAvatars.map((data) => data.toAvatar()));
        _loadedCount = _avatars.length;
        _isLoadingMore = false;
      });

      // Pre-cache newly loaded avatars (small batch)
      final newly = newAvatars
          .map((d) => d.toAvatar())
          .take(10)
          .where((a) => a.imageUrl.startsWith('http'))
          .toList();
      if (newly.isNotEmpty) {
        Future(() async {
          for (final a in newly) {
            try {
              await precacheImage(
                  CachedNetworkImageProvider(a.imageUrl), context);
            } catch (_) {}
          }
        });
      }
    } catch (e) {
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
          const SizedBox(height: 24),
          _isLoading ? const SizedBox.shrink() : _buildNavigationButtons(),
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
                  if (index >= _avatars.length - 2) {
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
                      child: Stack(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(28),
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
                                        errorWidget: (context, url, error) =>
                                            _buildPlaceholderAvatar(
                                                avatar.name),
                                        fadeInDuration:
                                            const Duration(milliseconds: 260),
                                        useOldImageOnUrlChange: true,
                                        cacheKey: avatar.id,
                                      )
                                    : _buildPlaceholderAvatar(avatar.name),
                                // Gradient overlay
                                Positioned(
                                  bottom: 0,
                                  left: 0,
                                  right: 0,
                                  child: Container(
                                    height: 60,
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        begin: Alignment.topCenter,
                                        end: Alignment.bottomCenter,
                                        colors: [
                                          Colors.transparent,
                                          Colors.black.withOpacity(0.3),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          // Animated border overlay
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 400),
                            curve: Curves.easeOutCubic,
                            margin: const EdgeInsets.symmetric(horizontal: 8),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(28),
                              border: Border.all(
                                color: isSelected || isCurrent
                                    ? AppTheme.primaryColor
                                    : Colors.transparent,
                                width: isSelected || isCurrent ? 3 : 0,
                              ),
                              boxShadow: [
                                if (isSelected || isCurrent)
                                  BoxShadow(
                                    color:
                                        AppTheme.primaryColor.withOpacity(0.25),
                                    blurRadius: 20,
                                    spreadRadius: 2,
                                  ),
                              ],
                            ),
                          ),
                          if (isSelected || isCurrent)
                            Positioned(
                              top: 12,
                              right: 20,
                              child: ScaleTransition(
                                scale: Tween<double>(begin: 0.8, end: 1.0)
                                    .animate(_fadeController),
                                child: Container(
                                  padding: const EdgeInsets.all(6),
                                  decoration: BoxDecoration(
                                    color: AppTheme.primaryColor,
                                    borderRadius: BorderRadius.circular(16),
                                    boxShadow: [
                                      BoxShadow(
                                        color: AppTheme.primaryColor
                                            .withOpacity(0.4),
                                        blurRadius: 8,
                                        spreadRadius: 1,
                                      ),
                                    ],
                                  ),
                                  child: const Icon(
                                    Icons.check_rounded,
                                    color: Colors.white,
                                    size: 18,
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    );
                  },
                );
              }).toList(),
              if (_isLoadingMore)
                Builder(
                  builder: (BuildContext context) {
                    return AnimatedContainer(
                      duration: const Duration(milliseconds: 400),
                      curve: Curves.easeInOut,
                      margin: const EdgeInsets.symmetric(horizontal: 8),
                      width: MediaQuery.of(context).size.width * 0.65,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(32),
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            AppTheme.primaryColor.withOpacity(0.08),
                            AppTheme.accentColor.withOpacity(0.08),
                          ],
                        ),
                        border: Border.all(
                          color: AppTheme.primaryColor.withOpacity(0.2),
                          width: 1.5,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: AppTheme.primaryColor.withOpacity(0.05),
                            blurRadius: 12,
                            spreadRadius: 0,
                          ),
                        ],
                      ),
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(
                              width: 40,
                              height: 40,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.5,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                    AppTheme.primaryColor),
                              ),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Loading more avatars',
                              style: GoogleFonts.poppins(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: AppTheme.grey700,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              'Discovering new faces',
                              style: GoogleFonts.poppins(
                                fontSize: 11,
                                color: AppTheme.grey500,
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
        return GestureDetector(
          onTap: () {
            _carouselController.jumpToPage(entry.key);
          },
          child: AnimatedContainer(
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
            AppTheme.primaryColor.withOpacity(0.15),
            AppTheme.accentColor.withOpacity(0.15),
          ],
        ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.person_outline_rounded,
              size: 48,
              color: AppTheme.primaryColor,
            ),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                name,
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.primaryColor,
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
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppTheme.grey100),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 12,
              spreadRadius: 0,
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                color: AppTheme.primaryColor.withOpacity(0.1),
                border: Border.all(
                  color: AppTheme.primaryColor.withOpacity(0.2),
                ),
              ),
              child: currentAvatar.imageUrl.startsWith('http')
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(13),
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
                          color: AppTheme.primaryColor,
                        ),
                        fadeInDuration: const Duration(milliseconds: 220),
                        useOldImageOnUrlChange: true,
                        cacheKey: currentAvatar.id,
                      ),
                    )
                  : Icon(
                      Icons.person_rounded,
                      color: AppTheme.primaryColor,
                    ),
            ),
            const SizedBox(width: 16),
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
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
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

  Widget _buildNavigationButtons() {
    return Row(
      children: [
        _buildNavButton(
          label: 'Previous',
          isEnabled: _currentIndex > 0,
          onPressed: () {
            if (_currentIndex > 0) {
              _carouselController.previousPage();
            }
          },
          isPrimary: false,
        ),
        const SizedBox(width: 12),
        _buildNavButton(
          label: 'Next',
          isEnabled: _currentIndex < _avatars.length - 1,
          onPressed: () {
            if (_currentIndex < _avatars.length - 1) {
              _carouselController.nextPage();
            }
          },
          isPrimary: true,
        ),
      ],
    );
  }

  Widget _buildNavButton({
    required String label,
    required bool isEnabled,
    required VoidCallback onPressed,
    required bool isPrimary,
  }) {
    return Expanded(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: isEnabled ? onPressed : null,
          borderRadius: BorderRadius.circular(12),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            padding: const EdgeInsets.symmetric(vertical: 14),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: isPrimary
                  ? (isEnabled ? AppTheme.primaryColor : AppTheme.grey200)
                  : Colors.transparent,
              border: Border.all(
                color: isPrimary ? Colors.transparent : AppTheme.grey300,
              ),
              boxShadow: isPrimary && isEnabled
                  ? [
                      BoxShadow(
                        color: AppTheme.primaryColor.withOpacity(0.2),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ]
                  : null,
            ),
            child: Center(
              child: Text(
                label,
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: isPrimary
                      ? (isEnabled ? Colors.white : AppTheme.grey500)
                      : (isEnabled ? AppTheme.grey700 : AppTheme.grey400),
                ),
              ),
            ),
          ),
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
