import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../auth/providers/auth_provider.dart';

class AdminShell extends StatelessWidget {
  final String title;
  final Widget child;
  final Widget? actions;
  const AdminShell({super.key, required this.title, required this.child, this.actions});

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width >= 1000;
    final sidebar = _AdminSidebar(currentRoute: GoRouterState.of(context).uri.toString());
    final topbar = _AdminTopbar(title: title, actions: actions);

    if (isWide) {
      return Scaffold(
        body: Row(
          children: [
            SizedBox(width: 260, child: sidebar),
            const VerticalDivider(width: 1),
            Expanded(
              child: Column(
                children: [
                  SizedBox(height: 64, child: topbar),
                  const Divider(height: 1),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: child,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(title, style: GoogleFonts.poppins(fontWeight: FontWeight.w700)),
        actions: actions != null ? [actions!] : null,
      ),
      drawer: Drawer(child: sidebar),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: child,
      ),
    );
  }
}

class _AdminTopbar extends StatelessWidget {
  final String title;
  final Widget? actions;
  const _AdminTopbar({required this.title, this.actions});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      color: scheme.surface,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Text(title, style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w700)),
          const SizedBox(width: 24),
          const _GlobalSearchField(),
          const Spacer(),
          if (actions != null) actions!,
          const SizedBox(width: 8),
          const _AvatarMenu(),
        ],
      ),
    );
  }
}

class _GlobalSearchField extends StatefulWidget {
  const _GlobalSearchField();
  @override
  State<_GlobalSearchField> createState() => _GlobalSearchFieldState();
}

class _GlobalSearchFieldState extends State<_GlobalSearchField> {
  final controller = TextEditingController();
  @override
  Widget build(BuildContext context) {
    final isNarrow = MediaQuery.of(context).size.width < 1200;
    if (isNarrow) return const SizedBox.shrink();
    return SizedBox(
      width: 360,
      child: TextField(
        controller: controller,
        decoration: const InputDecoration(
          hintText: 'Search animal, trade, or user',
          prefixIcon: Icon(Icons.search),
          isDense: true,
          border: OutlineInputBorder(),
        ),
        onSubmitted: (q) {
          if (q.trim().isEmpty) return;
          if (RegExp(r'^TRADE', caseSensitive: false).hasMatch(q)) {
            context.go('/admin/trades');
          } else if (RegExp(r'^[A-Z0-9\-]{6,}$').hasMatch(q)) {
            context.go('/admin/animals');
          } else {
            context.go('/admin/dashboard');
          }
        },
      ),
    );
  }
}

class _AvatarMenu extends ConsumerWidget {
  const _AvatarMenu();
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return PopupMenuButton(
      icon: const CircleAvatar(child: Icon(Icons.person)),
      itemBuilder: (context) => [
        const PopupMenuItem(value: 'profile', child: Text('Profile')),
        const PopupMenuItem(value: 'logout', child: Text('Logout')),
      ],
      onSelected: (value) {
        if (value == 'logout') {
          ref.read(authNotifierProvider.notifier).logout();
          context.go('/login');
        } else if (value == 'profile') {
          context.go('/profile');
        }
      },
    );
  }
}

class _AdminSidebar extends ConsumerWidget {
  final String currentRoute;
  const _AdminSidebar({required this.currentRoute});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final items = <_NavItem>[
      _NavItem(label: 'Dashboard', icon: Icons.dashboard, route: '/admin/dashboard'),
      _NavItem(label: 'Animals', icon: Icons.pets, route: '/admin/animals'),
      _NavItem(label: 'Trades', icon: Icons.swap_horiz, route: '/admin/trades'),
      _NavItem(label: 'Collections', icon: Icons.collections_bookmark, route: '/admin/collections'),
      _NavItem(label: 'DIDs', icon: Icons.verified_user, route: '/admin/dids'),
      _NavItem(label: 'Settings', icon: Icons.settings, route: '/settings'),
    ];
    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text('Admin', style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.w700)),
          ),
          const Divider(height: 1),
          Expanded(
            child: ListView(
              children: [
                for (final it in items)
                  ListTile(
                    leading: Icon(it.icon),
                    title: Text(it.label),
                    selected: currentRoute.startsWith(it.route),
                    onTap: () => context.go(it.route),
                  ),
              ],
            ),
          ),
          const Divider(height: 1),
          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text('Logout'),
            onTap: () {
              ref.read(authNotifierProvider.notifier).logout();
              context.go('/login');
            },
          ),
        ],
      ),
    );
  }
}

class _NavItem {
  final String label;
  final IconData icon;
  final String route;
  _NavItem({required this.label, required this.icon, required this.route});
}


