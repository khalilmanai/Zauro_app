import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/providers/theme_provider.dart';
import '../widgets/theme_switcher.dart';

class ThemeDemoScreen extends ConsumerWidget {
  const ThemeDemoScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Zauro Theme Demo'),
        actions: const [
          ThemeSwitcher(),
          SizedBox(width: 16),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Text(
              'Nature-Inspired Theme',
              style: Theme.of(context).textTheme.displayMedium,
            ),
            const SizedBox(height: 8),
            Text(
              'Beautiful colors inspired by nature for the Zauro marketplace',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: AppTheme.getForegroundColor(context)
                        .withValues(alpha: 0.7),
                  ),
            ),
            const SizedBox(height: 32),

            // Color Palette
            _buildSection(
              context,
              'Color Palette',
              [
                _buildColorCard(
                  context,
                  'Primary',
                  'Forest Green',
                  AppTheme.getPrimaryColor(context),
                  AppTheme.lightPrimaryForeground,
                ),
                _buildColorCard(
                  context,
                  'Secondary',
                  'Light Green',
                  Theme.of(context).colorScheme.secondary,
                  Theme.of(context).colorScheme.onSecondary,
                ),
                _buildColorCard(
                  context,
                  'Accent',
                  'Warm Earthy',
                  AppTheme.getAccentColor(context),
                  Theme.of(context).colorScheme.onTertiary,
                ),
                _buildColorCard(
                  context,
                  'Success',
                  'Nature Green',
                  AppTheme.getSuccessColor(context),
                  Colors.white,
                ),
                _buildColorCard(
                  context,
                  'Error',
                  'Terracotta Red',
                  AppTheme.getErrorColor(context),
                  Colors.white,
                ),
              ],
            ),

            const SizedBox(height: 32),

            // Buttons Demo
            _buildSection(
              context,
              'Buttons',
              [
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {},
                        child: const Text('Primary Button'),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {},
                        child: const Text('Outlined Button'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: TextButton(
                        onPressed: () {},
                        child: const Text('Text Button'),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {},
                        icon: const Icon(Icons.eco),
                        label: const Text('Eco Friendly'),
                      ),
                    ),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 32),

            // Form Elements
            _buildSection(
              context,
              'Form Elements',
              [
                TextField(
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    hintText: 'Enter your email',
                    prefixIcon: Icon(Icons.email),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  decoration: const InputDecoration(
                    labelText: 'Password',
                    hintText: 'Enter your password',
                    prefixIcon: Icon(Icons.lock),
                    suffixIcon: Icon(Icons.visibility),
                  ),
                  obscureText: true,
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  decoration: const InputDecoration(
                    labelText: 'Animal Type',
                    prefixIcon: Icon(Icons.pets),
                  ),
                  items: ['Cattle', 'Goats', 'Sheep', 'Chickens']
                      .map((type) => DropdownMenuItem(
                            value: type,
                            child: Text(type),
                          ))
                      .toList(),
                  onChanged: (value) {},
                ),
              ],
            ),

            const SizedBox(height: 32),

            // Cards Demo
            _buildSection(
              context,
              'Cards & Components',
              [
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            CircleAvatar(
                              backgroundColor:
                                  AppTheme.getPrimaryColor(context),
                              child: const Icon(
                                Icons.agriculture,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Premium Cattle',
                                    style:
                                        Theme.of(context).textTheme.titleMedium,
                                  ),
                                  Text(
                                    'High-quality livestock for sale',
                                    style:
                                        Theme.of(context).textTheme.bodySmall,
                                  ),
                                ],
                              ),
                            ),
                            Chip(
                              label: const Text('Available'),
                              backgroundColor: AppTheme.getSuccessColor(context)
                                  .withValues(alpha: 0.1),
                              labelStyle: TextStyle(
                                color: AppTheme.getSuccessColor(context),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Experience sustainable farming with our premium livestock. Each animal is carefully selected and health-certified.',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '\$2,500',
                              style: Theme.of(context)
                                  .textTheme
                                  .titleLarge
                                  ?.copyWith(
                                    color: AppTheme.getPrimaryColor(context),
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                            ElevatedButton.icon(
                              onPressed: () {},
                              icon: const Icon(Icons.shopping_cart, size: 16),
                              label: const Text('Buy Now'),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 32),

            // Theme Switcher Demo
            _buildSection(
              context,
              'Theme Controls',
              [
                const ThemeSwitcherTile(),
                const SizedBox(height: 16),
                Text(
                  'Try switching between light, dark, and system themes to see how the colors adapt beautifully to different modes.',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontStyle: FontStyle.italic,
                      ),
                ),
              ],
            ),

            const SizedBox(height: 32),

            // Preview Cards
            _buildSection(
              context,
              'Theme Preview',
              [
                SizedBox(
                  height: 200,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: [
                      ThemePreviewCard(
                        themeMode: AppThemeMode.light,
                        isSelected:
                            Theme.of(context).brightness == Brightness.light,
                        onTap: () => ref
                            .read(themeProvider.notifier)
                            .setTheme(AppThemeMode.light),
                      ),
                      const SizedBox(width: 16),
                      ThemePreviewCard(
                        themeMode: AppThemeMode.dark,
                        isSelected:
                            Theme.of(context).brightness == Brightness.dark,
                        onTap: () => ref
                            .read(themeProvider.notifier)
                            .setTheme(AppThemeMode.dark),
                      ),
                      const SizedBox(width: 16),
                      ThemePreviewCard(
                        themeMode: AppThemeMode.system,
                        isSelected:
                            ref.watch(themeProvider) == AppThemeMode.system,
                        onTap: () => ref
                            .read(themeProvider.notifier)
                            .setTheme(AppThemeMode.system),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => ref.read(themeProvider.notifier).toggleTheme(),
        tooltip: 'Toggle Theme',
        child: const Icon(Icons.palette),
      ),
    );
  }

  Widget _buildSection(
      BuildContext context, String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        const SizedBox(height: 16),
        ...children,
      ],
    );
  }

  Widget _buildColorCard(
    BuildContext context,
    String name,
    String description,
    Color color,
    Color textColor,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Card(
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: textColor,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    Text(
                      description,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: textColor.withValues(alpha: 0.8),
                          ),
                    ),
                  ],
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: textColor.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '#${color.toARGB32().toRadixString(16).padLeft(8, '0').substring(2).toUpperCase()}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: textColor,
                        fontFamily: 'monospace',
                        fontWeight: FontWeight.w500,
                      ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Add this to your router configuration
class ThemeDemoRoute {
  static const String path = '/theme-demo';
  static const String name = 'theme-demo';
}
