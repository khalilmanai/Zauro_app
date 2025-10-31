import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../utils/storage_service.dart';
import '../utils/role_guard.dart';
import '../../features/auth/providers/auth_provider.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/screens/register_screen.dart';
import '../../features/auth/presentation/screens/registration_carousel_screen.dart';
import '../../features/auth/presentation/screens/forgot_password_screen.dart';
import '../../features/onboarding/presentation/screens/onboarding_screen.dart';
import '../../features/home/presentation/screens/main_screen.dart';
import '../../features/animals/presentation/screens/animals_list_screen.dart';
import '../../features/animals/presentation/screens/animal_detail_screen.dart';
import '../../features/animals/presentation/screens/add_animal_screen.dart';
import '../../features/animals/presentation/screens/edit_animal_screen.dart';
import '../../features/trading/presentation/screens/marketplace_screen.dart';
import '../../features/trading/presentation/screens/trade_detail_screen.dart';
import '../../features/trading/presentation/screens/my_listings_screen.dart';
import '../../features/wallet/presentation/screens/wallet_screen.dart';
import '../../features/wallet/presentation/screens/transaction_history_screen.dart';
import '../../features/profile/presentation/screens/profile_screen.dart';
import '../../features/profile/presentation/screens/edit_profile_screen.dart';
import '../../features/profile/presentation/screens/settings_screen.dart';
import '../../features/profile/presentation/screens/help_support_screen.dart';
import '../../features/profile/presentation/screens/security_settings_screen.dart';
import '../../features/profile/presentation/screens/notification_settings_screen.dart';
import '../../features/did/presentation/screens/did_screen.dart';
import '../../features/admin/presentation/screens/collections_screen.dart';
import '../../features/admin/presentation/screens/admin_dashboard_screen.dart';
import '../../features/admin/presentation/screens/admin_animals_screen.dart';
import '../../features/admin/presentation/screens/admin_trades_screen.dart';
import '../../features/admin/presentation/screens/admin_dids_screen.dart';
import '../../features/admin/presentation/screens/access_denied_screen.dart';
import '../../features/animals/presentation/screens/upload_animal_image_screen.dart';

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
        path: '/register-carousel',
        builder: (context, state) => const RegistrationCarouselScreen(),
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
          GoRoute(
            path: ':id/upload',
            builder: (context, state) => UploadAnimalImageScreen(
              animalId: state.pathParameters['id']!,
            ),
          ),
          GoRoute(
            path: ':id/edit',
            builder: (context, state) => EditAnimalScreen(
              animalId: state.pathParameters['id']!,
            ),
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
          GoRoute(
            path: 'my-listings',
            builder: (context, state) => const MyListingsScreen(),
          ),
        ],
      ),

      // Wallet Routes
      GoRoute(
        path: '/wallet',
        builder: (context, state) => const WalletScreen(),
        routes: [
          GoRoute(
            path: 'history',
            builder: (context, state) => const TransactionHistoryScreen(),
          ),
        ],
      ),

      // DID and Admin
      GoRoute(
        path: '/did',
        builder: (context, state) => const DidScreen(),
      ),
      GoRoute(
        path: '/admin',
        builder: (context, state) => const AdminDashboardScreen(),
        routes: [
          GoRoute(
            path: 'dashboard',
            builder: (context, state) => const AdminDashboardScreen(),
          ),
          GoRoute(
            path: 'animals',
            builder: (context, state) => const AdminAnimalsScreen(),
          ),
          GoRoute(
            path: 'trades',
            builder: (context, state) => const AdminTradesScreen(),
          ),
          GoRoute(
            path: 'collections',
            builder: (context, state) => const CollectionsScreen(),
          ),
          GoRoute(
            path: 'dids',
            builder: (context, state) => const AdminDidsScreen(),
          ),
        ],
      ),
      GoRoute(path: '/403', builder: (context, state) => const AccessDeniedScreen()),

      // Profile Routes
      GoRoute(
        path: '/profile',
        builder: (context, state) => const ProfileScreen(),
      ),
      GoRoute(
        path: '/profile/edit',
        builder: (context, state) => const EditProfileScreen(),
      ),
      GoRoute(
        path: '/settings',
        builder: (context, state) => const SettingsScreen(),
      ),
      GoRoute(
        path: '/help',
        builder: (context, state) => const HelpSupportScreen(),
      ),
      GoRoute(
        path: '/profile/security',
        builder: (context, state) => const SecuritySettingsScreen(),
      ),
      GoRoute(
        path: '/profile/notifications',
        builder: (context, state) => const NotificationSettingsScreen(),
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
    // Route based on persisted role
    if (user.role == 'ADMIN') {
      return '/admin/dashboard';
    }
    // Default for employees/other roles
    return '/marketplace';
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

  // Role-based redirects
  if (authState.isAuthenticated && _isAuthRoute(location)) {
    final role = authState.user?.role;
    if (RoleGuard.canAccess(role, RoleGuard.admin)) return '/admin/dashboard';
    return '/marketplace';
  }

  // Admin route guard
  if (location.startsWith('/admin')) {
    if (!authState.isAuthenticated) return '/login';
    final role = authState.user?.role;
    final isAllowed = RoleGuard.canAccess(role, RoleGuard.admin);
    if (!isAllowed) return '/403';
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
    '/admin',
  ];

  return protectedRoutes.any((route) => location.startsWith(route));
}

bool _isAuthRoute(String location) {
  const authRoutes = [
    '/login',
    '/register',
    '/register-carousel',
    '/forgot-password'
  ];

  return authRoutes.contains(location);
}
