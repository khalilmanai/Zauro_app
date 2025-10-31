import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../utils/storage_service.dart';
import '../theme/app_theme.dart';

enum AppThemeMode {
  system,
  light,
  dark,
}

extension AppThemeModeExtension on AppThemeMode {
  ThemeMode get themeMode {
    switch (this) {
      case AppThemeMode.system:
        return ThemeMode.system;
      case AppThemeMode.light:
        return ThemeMode.light;
      case AppThemeMode.dark:
        return ThemeMode.dark;
    }
  }

  String get displayName {
    switch (this) {
      case AppThemeMode.system:
        return 'System';
      case AppThemeMode.light:
        return 'Light';
      case AppThemeMode.dark:
        return 'Dark';
    }
  }

  IconData get icon {
    switch (this) {
      case AppThemeMode.system:
        return Icons.brightness_auto;
      case AppThemeMode.light:
        return Icons.light_mode;
      case AppThemeMode.dark:
        return Icons.dark_mode;
    }
  }
}

class ThemePreferences {
  final AppThemeMode mode;
  final Color? seedColor;
  final bool dynamicSeedEnabled;

  const ThemePreferences({
    required this.mode,
    required this.seedColor,
    required this.dynamicSeedEnabled,
  });

  ThemePreferences copyWith({
    AppThemeMode? mode,
    Color? seedColor,
    bool? dynamicSeedEnabled,
  }) => ThemePreferences(
        mode: mode ?? this.mode,
        seedColor: seedColor ?? this.seedColor,
        dynamicSeedEnabled: dynamicSeedEnabled ?? this.dynamicSeedEnabled,
      );
}

class ThemeNotifier extends StateNotifier<ThemePreferences> {
  static const String _themeKey = 'app_theme_mode';
  static const String _seedKey = 'app_theme_seed';
  static const String _dynamicSeedKey = 'app_theme_dynamic_seed';

  ThemeNotifier()
      : super(const ThemePreferences(
          mode: AppThemeMode.system,
          seedColor: null,
          dynamicSeedEnabled: false,
        )) {
    _load();
  }

  Future<void> _load() async {
    final themeIndex = StorageService.getInt(_themeKey) ?? 0;
    final seedHex = StorageService.getString(_seedKey);
    final dynamicEnabled = StorageService.getBool(_dynamicSeedKey) ?? false;
    state = state.copyWith(
      mode: AppThemeMode.values[themeIndex],
      seedColor: _parseColor(seedHex),
      dynamicSeedEnabled: dynamicEnabled,
    );
  }

  Future<void> setTheme(AppThemeMode themeMode) async {
    state = state.copyWith(mode: themeMode);
    await StorageService.setInt(_themeKey, themeMode.index);
  }

  Future<void> toggleTheme() async {
    switch (state.mode) {
      case AppThemeMode.system:
        await setTheme(AppThemeMode.light);
        break;
      case AppThemeMode.light:
        await setTheme(AppThemeMode.dark);
        break;
      case AppThemeMode.dark:
        await setTheme(AppThemeMode.system);
        break;
    }
  }

  Future<void> setSeedColor(Color? color) async {
    state = state.copyWith(seedColor: color);
    if (color == null) {
      await StorageService.remove(_seedKey);
    } else {
      await StorageService.setString(_seedKey, _colorToHex(color));
    }
  }

  Future<void> setDynamicSeedEnabled(bool enabled) async {
    state = state.copyWith(dynamicSeedEnabled: enabled);
    await StorageService.setBool(_dynamicSeedKey, enabled);
  }

  static String _colorToHex(Color color) =>
      '#${color.value.toRadixString(16).padLeft(8, '0')}';
  static Color? _parseColor(String? hex) {
    if (hex == null || hex.isEmpty) return null;
    final clean = hex.replaceAll('#', '');
    final value = int.tryParse(clean, radix: 16);
    if (value == null) return null;
    return Color(value);
  }
}

final themeProvider = StateNotifierProvider<ThemeNotifier, ThemePreferences>(
    (ref) => ThemeNotifier());

// Helper provider to get the current brightness based on theme mode and system
final currentBrightnessProvider = Provider<Brightness>((ref) {
  final prefs = ref.watch(themeProvider);

  switch (prefs.mode) {
    case AppThemeMode.light:
      return Brightness.light;
    case AppThemeMode.dark:
      return Brightness.dark;
    case AppThemeMode.system:
      // In a real app, you'd get this from MediaQuery or platform
      // For now, default to light
      return Brightness.light;
  }
});

// Helper provider to check if current theme is dark
final isDarkModeProvider = Provider<bool>((ref) {
  final brightness = ref.watch(currentBrightnessProvider);
  return brightness == Brightness.dark;
});

// Expose current ThemeData with optional seed color applied
final appThemeDataProvider = Provider<ThemeData>((ref) {
  final prefs = ref.watch(themeProvider);
  final isDark = ref.watch(isDarkModeProvider);
  final theme = AppTheme.themed(isDark: isDark, seedColor: prefs.seedColor);
  return theme;
});
