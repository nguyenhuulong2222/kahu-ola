import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'app/app_shell.dart';
import 'core/config/env.dart';
import 'core/diagnostics/diagnostics_store.dart';
import 'core/utils/logger.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  Env.initialize();

  final DiagnosticsStore diagnostics = DiagnosticsStore.instance;

  try {
    await Firebase.initializeApp();
    diagnostics.setFirebaseStatus(ready: true);
  } catch (error, stack) {
    diagnostics.setFirebaseStatus(ready: false, error: error.toString());
    AppLogger.warn(
      'Firebase initialization skipped',
      meta: const {'domain': 'firebase'},
    );
    AppLogger.debug(
      'Firebase initialization detail',
      meta: {'error': error.toString(), 'stack': '$stack'},
    );
  }

  FlutterError.onError = (FlutterErrorDetails details) {
    diagnostics.recordError(
      details.exception,
      details.stack,
      domain: FailureDomain.runtime,
    );
    AppLogger.error(
      'Flutter framework error',
      err: details.exception,
      stack: details.stack,
      meta: const {'domain': 'runtime'},
    );
  };

  runZonedGuarded(() => runApp(const AppShell()), (
    Object error,
    StackTrace stack,
  ) {
    diagnostics.recordError(error, stack, domain: FailureDomain.runtime);
    AppLogger.fatal('Uncaught zone error', err: error, stack: stack);
  });
}
