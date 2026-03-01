import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../features/splash/presentation/pages/splash_page.dart';
import '../../features/dashboard/presentation/pages/dashboard_page.dart';
import '../../features/alert_buddy/presentation/pages/alert_buddy_page.dart';
import '../../features/wildfire_air/presentation/pages/wildfire_air_page.dart';
import '../../features/ocean_safety/presentation/pages/ocean_safety_page.dart';

/// Route name constants
class AppRoutes {
  AppRoutes._();
  static const String splash = '/';
  static const String dashboard = '/dashboard';
  static const String alertBuddy = '/alerts';
  static const String wildfireAir = '/wildfire';
  static const String oceanSafety = '/ocean';
  static const String map = '/map';
  static const String profile = '/profile';
  static const String resources = '/resources';
}

final GoRouter appRouter = GoRouter(
  initialLocation: AppRoutes.splash,
  debugLogDiagnostics: true,
  routes: [
    GoRoute(
      path: AppRoutes.splash,
      name: 'splash',
      builder: (context, state) => const SplashPage(),
    ),
    GoRoute(
      path: AppRoutes.dashboard,
      name: 'dashboard',
      builder: (context, state) => const DashboardPage(),
      routes: [
        GoRoute(
          path: 'alerts',
          name: 'alertBuddy',
          builder: (context, state) => const AlertBuddyPage(),
        ),
        GoRoute(
          path: 'wildfire',
          name: 'wildfireAir',
          builder: (context, state) => const WildfireAirPage(),
        ),
        GoRoute(
          path: 'ocean',
          name: 'oceanSafety',
          builder: (context, state) => const OceanSafetyPage(),
        ),
      ],
    ),
  ],
  errorBuilder: (context, state) => Scaffold(
    body: Center(
      child: Text('Page not found: ${state.error}'),
    ),
  ),
);
