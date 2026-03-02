import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:maui_alert_buddy/app_shell.dart';
import 'package:maui_alert_buddy/config.dart';

void main() {
  testWidgets(
    'AppShell renders loading first and then the main UI after bootstrap',
    (WidgetTester tester) async {
      final completer = Completer<AppConfig>();

      await tester.pumpWidget(
        MaterialApp(
          home: AppShell(
            bootstrapper: (_) => completer.future,
            builder: (context, config) => const Text('Main UI Ready'),
          ),
        ),
      );

      await tester.pump();

      expect(
        find.text('Preparing configuration and diagnostics...'),
        findsOneWidget,
      );

      completer.complete(
        const AppConfig(
          environmentName: 'test',
          apiBaseUrl: 'https://example.com',
          appVersion: '1.0.0',
          buildNumber: '99',
          useFirebase: false,
          googleServiceInfoPresent: false,
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Main UI Ready'), findsOneWidget);
    },
  );

  testWidgets(
    'AppShell renders an error screen when bootstrap fails',
    (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: AppShell(
            bootstrapper: (_) async {
              throw const ConfigException('Missing configuration');
            },
            builder: (context, config) => const Text('Main UI Ready'),
          ),
        ),
      );

      await tester.pump();
      await tester.pump();

      expect(find.text('We could not finish startup.'), findsOneWidget);
      expect(find.text('Missing configuration'), findsOneWidget);
      expect(find.text('Retry'), findsOneWidget);
    },
  );
}
