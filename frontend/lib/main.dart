import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'core/config/app_config.dart';
import 'core/config/environment.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/app_colors.dart';
import 'core/utils/storage_service.dart';
import 'core/providers/theme_provider.dart';
import 'core/services/performance_service.dart';
import 'core/widgets/splash_screen.dart';
import 'features/auth/data/models/user_model.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    // Validate environment configuration
    EnvironmentConfig.validateConfiguration();

    // Initialize Hive
    await Hive.initFlutter();
    Hive.registerAdapter(UserModelAdapter());

    // Initialize Storage Service
    await StorageService.init();

    // Initialize Performance Service
    PerformanceService().initialize();

    // Set preferred orientations
    await SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);

    // Set system UI overlay style
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: AppColors.transparent,
        statusBarIconBrightness: Brightness.dark,
        systemNavigationBarColor: AppColors.white,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
    );

    // Set up global error handling
    FlutterError.onError = (FlutterErrorDetails details) {
      FlutterError.presentError(details);
      // In production, you would send this to your crash reporting service
      debugPrint('Flutter Error: ${details.exception}');
    };

    runApp(const ProviderScope(child: ZauroApp()));
  } catch (error, stackTrace) {
    // Handle initialization errors
    debugPrint('App initialization failed: $error');
    debugPrint('Stack trace: $stackTrace');

    // Show a basic error screen
    runApp(
      MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Scaffold(
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error, size: 64, color: AppColors.red500),
                const SizedBox(height: 16),
                const Text(
                  'App initialization failed',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  'Error: $error',
                  style: const TextStyle(fontSize: 14),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class ZauroApp extends ConsumerWidget {
  const ZauroApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);
    final themeMode = ref.watch(themeProvider);

    return MaterialApp.router(
      title: AppConfig.appName,
      debugShowCheckedModeBanner: EnvironmentConfig.showDebugBanner,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeMode.themeMode,
      routerConfig: router,
      showPerformanceOverlay: EnvironmentConfig.showPerformanceOverlay,
      builder: (context, child) {
        // Preload critical resources
        PerformanceService.preloadCriticalResources(context);

        return MediaQuery(
          data: MediaQuery.of(
            context,
          ).copyWith(textScaler: TextScaler.noScaling),
          child: AnimatedSplashScreen(
            duration: const Duration(seconds: 3),
            child: child!,
          ),
        );
      },
    );
  }
}
