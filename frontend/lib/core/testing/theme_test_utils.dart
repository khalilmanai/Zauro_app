import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class ThemeTestUtils {
  static Widget pumpWithThemes(Widget child, {Brightness brightness = Brightness.light}) {
    final theme = brightness == Brightness.dark ? AppTheme.darkTheme : AppTheme.lightTheme;
    return MaterialApp(theme: theme, home: Scaffold(body: child));
  }
}

