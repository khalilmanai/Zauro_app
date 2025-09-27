import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/providers/theme_provider.dart';
import '../../../../core/theme/app_theme.dart';

class ThemeSwitcher extends ConsumerWidget {
  const ThemeSwitcher({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentTheme = ref.watch(themeProvider);

    return PopupMenuButton<AppThemeMode>(
      icon: Icon(
        currentTheme.icon,
        color: AppTheme.getForegroundColor(context),
      ),
      tooltip: 'Change theme',
      onSelected: (AppThemeMode themeMode) {
        ref.read(themeProvider.notifier).setTheme(themeMode);
      },
      itemBuilder: (BuildContext context) =>
          AppThemeMode.values.map((themeMode) {
        return PopupMenuItem<AppThemeMode>(
          value: themeMode,
          child: Row(
            children: [
              Icon(
                themeMode.icon,
                color: currentTheme == themeMode
                    ? AppTheme.getPrimaryColor(context)
                    : AppTheme.getForegroundColor(context),
              ),
              const SizedBox(width: 12),
              Text(
                themeMode.displayName,
                style: TextStyle(
                  color: currentTheme == themeMode
                      ? AppTheme.getPrimaryColor(context)
                      : AppTheme.getForegroundColor(context),
                  fontWeight: currentTheme == themeMode
                      ? FontWeight.w600
                      : FontWeight.normal,
                ),
              ),
              if (currentTheme == themeMode) ...[
                const Spacer(),
                Icon(
                  Icons.check,
                  color: AppTheme.getPrimaryColor(context),
                  size: 20,
                ),
              ],
            ],
          ),
        );
      }).toList(),
    );
  }
}

class ThemeSwitcherTile extends ConsumerWidget {
  const ThemeSwitcherTile({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentTheme = ref.watch(themeProvider);

    return ListTile(
      leading: Icon(
        Icons.palette_outlined,
        color: AppTheme.getPrimaryColor(context),
      ),
      title: const Text('Theme'),
      subtitle: Text('Current: ${currentTheme.displayName}'),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: AppThemeMode.values.map((themeMode) {
          final isSelected = currentTheme == themeMode;
          return Padding(
            padding: const EdgeInsets.only(left: 8),
            child: InkWell(
              onTap: () => ref.read(themeProvider.notifier).setTheme(themeMode),
              borderRadius: BorderRadius.circular(8),
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppTheme.getPrimaryColor(context).withValues(alpha: 0.1)
                      : null,
                  borderRadius: BorderRadius.circular(8),
                  border: isSelected
                      ? Border.all(color: AppTheme.getPrimaryColor(context))
                      : Border.all(color: AppTheme.getBorderColor(context)),
                ),
                child: Icon(
                  themeMode.icon,
                  size: 20,
                  color: isSelected
                      ? AppTheme.getPrimaryColor(context)
                      : AppTheme.getForegroundColor(context),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class QuickThemeToggle extends ConsumerWidget {
  const QuickThemeToggle({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentTheme = ref.watch(themeProvider);

    return IconButton(
      onPressed: () => ref.read(themeProvider.notifier).toggleTheme(),
      icon: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        child: Icon(
          currentTheme.icon,
          key: ValueKey(currentTheme),
          color: AppTheme.getPrimaryColor(context),
        ),
      ),
      tooltip: 'Toggle theme (${currentTheme.displayName})',
    );
  }
}

class ThemePreviewCard extends StatelessWidget {
  final AppThemeMode themeMode;
  final bool isSelected;
  final VoidCallback onTap;

  const ThemePreviewCard({
    super.key,
    required this.themeMode,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = themeMode == AppThemeMode.dark;
    final backgroundColor =
        isDark ? AppTheme.darkBackground : AppTheme.lightBackground;
    final foregroundColor =
        isDark ? AppTheme.darkForeground : AppTheme.lightForeground;
    final primaryColor = isDark ? AppTheme.darkPrimary : AppTheme.lightPrimary;
    final borderColor = isDark ? AppTheme.darkBorder : AppTheme.lightBorder;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: 120,
        height: 160,
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? primaryColor : borderColor,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          children: [
            // Header
            Container(
              height: 40,
              decoration: BoxDecoration(
                color: primaryColor.withValues(alpha: 0.1),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(11),
                  topRight: Radius.circular(11),
                ),
              ),
              child: Row(
                children: [
                  const SizedBox(width: 8),
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: primaryColor,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: foregroundColor.withValues(alpha: 0.3),
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: foregroundColor.withValues(alpha: 0.3),
                      shape: BoxShape.circle,
                    ),
                  ),
                ],
              ),
            ),
            // Content
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: double.infinity,
                      height: 12,
                      decoration: BoxDecoration(
                        color: foregroundColor.withValues(alpha: 0.8),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      width: 60,
                      height: 8,
                      decoration: BoxDecoration(
                        color: foregroundColor.withValues(alpha: 0.5),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      width: double.infinity,
                      height: 20,
                      decoration: BoxDecoration(
                        color: primaryColor,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      width: double.infinity,
                      height: 16,
                      decoration: BoxDecoration(
                        color: foregroundColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(color: borderColor),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // Footer
            Container(
              padding: const EdgeInsets.all(8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    themeMode.icon,
                    size: 16,
                    color: foregroundColor,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    themeMode.displayName,
                    style: TextStyle(
                      fontSize: 12,
                      color: foregroundColor,
                      fontWeight: FontWeight.w500,
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
}
