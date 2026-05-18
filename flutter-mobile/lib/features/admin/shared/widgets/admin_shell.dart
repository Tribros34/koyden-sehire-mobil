import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../features/auth/providers/auth_provider.dart';

class AdminShell extends ConsumerWidget {
  final Widget child;
  final String currentLocation;

  const AdminShell({
    super.key,
    required this.child,
    required this.currentLocation,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Yönetim Paneli'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Çıkış',
            onPressed: () async {
              await ref.read(authProvider.notifier).logout();
            },
          ),
        ],
      ),
      drawer: _AdminDrawer(currentLocation: currentLocation),
      body: child,
    );
  }
}

class _AdminDrawer extends StatelessWidget {
  final String currentLocation;
  const _AdminDrawer({required this.currentLocation});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: [
          DrawerHeader(
            decoration: const BoxDecoration(
              color: Color(0xFF2D6A4F),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                const Icon(Icons.admin_panel_settings,
                    color: Colors.white, size: 36),
                const SizedBox(height: 8),
                Text(
                  'Köyden Şehre',
                  style: Theme.of(context)
                      .textTheme
                      .titleLarge
                      ?.copyWith(color: Colors.white),
                ),
                Text(
                  'Admin Paneli',
                  style: Theme.of(context)
                      .textTheme
                      .bodySmall
                      ?.copyWith(color: Colors.white70),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                _NavItem(
                  icon: Icons.dashboard_outlined,
                  label: 'Dashboard',
                  route: '/admin/dashboard',
                  currentLocation: currentLocation,
                ),
                _NavItem(
                  icon: Icons.assignment_outlined,
                  label: 'Başvurular',
                  route: '/admin/applications',
                  currentLocation: currentLocation,
                ),
                _NavItem(
                  icon: Icons.inventory_2_outlined,
                  label: 'Ürün Moderasyonu',
                  route: '/admin/products',
                  currentLocation: currentLocation,
                ),
                _NavItem(
                  icon: Icons.category_outlined,
                  label: 'Kategoriler',
                  route: '/admin/categories',
                  currentLocation: currentLocation,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String route;
  final String currentLocation;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.route,
    required this.currentLocation,
  });

  @override
  Widget build(BuildContext context) {
    final isActive = currentLocation.startsWith(route);
    return ListTile(
      leading: Icon(
        icon,
        color: isActive ? const Color(0xFF2D6A4F) : null,
      ),
      title: Text(
        label,
        style: TextStyle(
          fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
          color: isActive ? const Color(0xFF2D6A4F) : null,
        ),
      ),
      selected: isActive,
      selectedTileColor: const Color(0xFF2D6A4F).withOpacity(0.08),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      onTap: () {
        context.go(route);
        Navigator.of(context).pop();
      },
    );
  }
}
