import 'package:flutter/material.dart';

import '../../../../core/constants/app_constants.dart';
import '../widgets/home_tab.dart';
import '../widgets/map_tab.dart';
import '../widgets/profile_tab.dart';
import '../widgets/resources_tab.dart';

/// Main Dashboard with M3 NavigationBar (4 tabs)
/// Tabs: Home (Alerts) | Map | Profile | Resources
class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  int _selectedIndex = AppConstants.navHome;

  final List<Widget> _pages = const [
    HomeTab(),
    MapTab(),
    ProfileTab(),
    ResourcesTab(),
  ];

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isMapTabSelected = _selectedIndex == AppConstants.navMap;

    return Scaffold(
      appBar: isMapTabSelected
          ? null
          : AppBar(
              title: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.shield_rounded, color: cs.primary, size: 26),
                  const SizedBox(width: 8),
                  Text(
                    AppConstants.appName,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: cs.primary,
                          fontWeight: FontWeight.w800,
                        ),
                  ),
                ],
              ),
              actions: [
                // Stale data indicator placeholder
                IconButton(
                  icon: Icon(Icons.wifi_tethering_rounded, color: cs.secondary),
                  tooltip: 'Live: 12 streams active',
                  onPressed: () {},
                ),
                // Settings
                IconButton(
                  icon: const Icon(Icons.tune_rounded),
                  tooltip: 'Settings',
                  onPressed: () {},
                ),
              ],
            ),
      body: IndexedStack(
        index: _selectedIndex,
        children: _pages,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) =>
            setState(() => _selectedIndex = index),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.notifications_outlined),
            selectedIcon: Icon(Icons.notifications_rounded),
            label: 'Alerts',
          ),
          NavigationDestination(
            icon: Icon(Icons.map_outlined),
            selectedIcon: Icon(Icons.map_rounded),
            label: 'Map',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outlined),
            selectedIcon: Icon(Icons.person_rounded),
            label: 'Profile',
          ),
          NavigationDestination(
            icon: Icon(Icons.library_books_outlined),
            selectedIcon: Icon(Icons.library_books_rounded),
            label: 'Resources',
          ),
        ],
      ),
    );
  }
}
