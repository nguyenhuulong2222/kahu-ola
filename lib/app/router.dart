import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../features/hazards/presentation/dashboard_screen.dart';
import '../features/settings/presentation/data_integrity_screen.dart';

final GoRouter appRouter = GoRouter(
  initialLocation: '/dashboard',
  routes: <RouteBase>[
    GoRoute(
      path: '/dashboard',
      builder: (BuildContext context, GoRouterState state) {
        return const DashboardScreen();
      },
    ),
    GoRoute(
      path: '/data-integrity',
      builder: (BuildContext context, GoRouterState state) {
        return const DataIntegrityScreen();
      },
    ),
  ],
  errorBuilder: (BuildContext context, GoRouterState state) {
    return const DashboardScreen();
  },
);
