import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../utils/storage_service.dart';
import '../../features/auth/providers/auth_provider.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/screens/register_screen.dart';
import '../../features/auth/presentation/screens/forgot_password_screen.dart';
import '../../features/onboarding/presentation/screens/onboarding_screen.dart';
import '../../features/home/presentation/screens/main_screen.dart';
import '../../features/animals/presentation/screens/animals_list_screen.dart';
import '../../features/animals/presentation/screens/animal_detail_screen.dart';
import '../../features/animals/presentation/screens/add_animal_screen.dart';
import '../../features/trading/presentation/screens/marketplace_screen.dart';
import '../../features/trading/presentation/screens/trade_detail_screen.dart';
import '../../features/wallet/presentation/screens/wallet_screen.dart';
import '../../features/profile/presentation/screens/profile_screen.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  // Watch auth state to make router reactive
  ref.watch(authNotifierProvider);

  return GoRouter(
    initialLocation: _getInitialRoute(),
    routes: [
      // Onboarding
      GoRoute(
        path: '/onboarding',
        builder: (context, state) => const OnboardingScreen(),
      ),

      // Authentication Routes
      GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
      GoRoute(
        path: '/register',
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
        path: '/forgot-password',
        builder: (context, state) => const ForgotPasswordScreen(),
      ),

      // Main App Routes
      GoRoute(path: '/home', builder: (context, state) => const MainScreen()),

      // Animals Routes
      GoRoute(
        path: '/animals',
        builder: (context, state) => const AnimalsListScreen(),
        routes: [
          GoRoute(
            path: 'add',
            builder: (context, state) => const AddAnimalScreen(),
          ),
          GoRoute(
            path: ':id',
            builder: (context, state) =>
                AnimalDetailScreen(animalId: state.pathParameters['id']!),
          ),
        ],
      ),

      // Trading Routes
      GoRoute(
        path: '/marketplace',
        builder: (context, state) => const MarketplaceScreen(),
        routes: [
          GoRoute(
            path: 'trade/:id',
            builder: (context, state) =>
                TradeDetailScreen(tradeId: state.pathParameters['id']!),
          ),
        ],
      ),

      // Wallet Routes
      GoRoute(
        path: '/wallet',
        builder: (context, state) => const WalletScreen(),
      ),

      // Profile Routes
      GoRoute(
        path: '/profile',
        builder: (context, state) => const ProfileScreen(),
      ),
    ],
    redirect: (context, state) {
      return _handleRedirect(ref, state.fullPath ?? '/');
    },
  );
});

String _getInitialRoute() {
  final isOnboardingCompleted = StorageService.isOnboardingCompleted();
  if (!isOnboardingCompleted) {
    return '/onboarding';
  }

  final user = StorageService.getUserData();
  if (user != null) {
    return '/home';
  }

  return '/login';
}

String? _handleRedirect(Ref ref, String location) {
  final isOnboardingCompleted = StorageService.isOnboardingCompleted();
  final authState = ref.read(authNotifierProvider);

  // If onboarding not completed, redirect to onboarding
  if (!isOnboardingCompleted && location != '/onboarding') {
    return '/onboarding';
  }

  // If user is not authenticated and trying to access protected routes
  if (!authState.isAuthenticated && _isProtectedRoute(location)) {
    return '/login';
  }

  // If user is authenticated and trying to access auth routes
  if (authState.isAuthenticated && _isAuthRoute(location)) {
    return '/home';
  }

  return null;
}

bool _isProtectedRoute(String location) {
  const protectedRoutes = [
    '/home',
    '/animals',
    '/marketplace',
    '/wallet',
    '/profile',
  ];

  return protectedRoutes.any((route) => location.startsWith(route));
}

bool _isAuthRoute(String location) {
  const authRoutes = ['/login', '/register', '/forgot-password'];

  return authRoutes.contains(location);
}
