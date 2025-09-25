import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/storage_service.dart';
import '../../../shared/presentation/widgets/custom_button.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<OnboardingItem> _items = [
    OnboardingItem(
      title: 'Welcome to Zauro Marketplace',
      description:
          'Trade animals as NFTs on the blockchain with complete security and transparency.',
      icon: Icons.pets,
      color: AppTheme.primaryColor,
    ),
    OnboardingItem(
      title: 'Secure Blockchain Trading',
      description:
          'All animals are minted as NFTs on Hedera Hashgraph, ensuring immutable ownership records.',
      icon: Icons.security,
      color: AppTheme.successColor,
    ),
    OnboardingItem(
      title: 'AI-Powered Valuations',
      description:
          'Get intelligent price predictions for your animals using advanced AI algorithms.',
      icon: Icons.psychology,
      color: AppTheme.accentColor,
    ),
    OnboardingItem(
      title: 'Atomic Swap Execution',
      description:
          'Trade with confidence using atomic swaps that ensure fair and secure transactions.',
      icon: Icons.swap_horiz,
      color: AppTheme.primaryColor,
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.white,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (index) {
                  setState(() {
                    _currentPage = index;
                  });
                },
                itemCount: _items.length,
                itemBuilder: (context, index) {
                  return _buildOnboardingPage(_items[index]);
                },
              ),
            ),
            _buildBottomSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildOnboardingPage(OnboardingItem item) {
    return Padding(
      padding: const EdgeInsets.all(40),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: item.color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(60),
            ),
            child: Icon(item.icon, size: 60, color: item.color),
          ),
          const SizedBox(height: 48),
          Text(
            item.title,
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: AppTheme.grey900,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            item.description,
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              fontSize: 16,
              color: AppTheme.grey600,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomSection() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          // Page Indicators
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              _items.length,
              (index) => _buildPageIndicator(index),
            ),
          ),
          const SizedBox(height: 32),

          // Navigation Buttons
          Row(
            children: [
              if (_currentPage > 0)
                Expanded(
                  child: CustomButton(
                    text: 'Previous',
                    isOutlined: true,
                    onPressed: _previousPage,
                  ),
                )
              else
                const Spacer(),

              const SizedBox(width: 16),

              Expanded(
                child: CustomButton(
                  text: _currentPage == _items.length - 1
                      ? 'Get Started'
                      : 'Next',
                  onPressed: _currentPage == _items.length - 1
                      ? _completeOnboarding
                      : _nextPage,
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Skip Button
          if (_currentPage < _items.length - 1)
            TextButton(
              onPressed: _completeOnboarding,
              child: Text(
                'Skip',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  color: AppTheme.grey600,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildPageIndicator(int index) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4),
      width: _currentPage == index ? 24 : 8,
      height: 8,
      decoration: BoxDecoration(
        color: _currentPage == index ? AppTheme.primaryColor : AppTheme.grey300,
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }

  void _nextPage() {
    _pageController.nextPage(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  void _previousPage() {
    _pageController.previousPage(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  void _completeOnboarding() async {
    await StorageService.setOnboardingCompleted(true);
    if (mounted) {
      context.go('/login');
    }
  }
}

class OnboardingItem {
  final String title;
  final String description;
  final IconData icon;
  final Color color;

  OnboardingItem({
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
  });
}
