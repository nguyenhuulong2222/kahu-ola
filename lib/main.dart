import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/services/push_notification_service.dart';
import 'core/theme/app_theme.dart';
import 'features/dashboard/presentation/pages/dashboard_page.dart';

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  if (kDebugMode) {
    debugPrint('Background FCM message: ${message.messageId}');
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  if (kIsWeb) {
    await Firebase.initializeApp(
      options: const FirebaseOptions(
        apiKey: 'AIzaSyBENF3y1EKgzKsAj478WlewxVPoRsSEfaE',
        authDomain: 'kahu-ola.firebaseapp.com',
        projectId: 'kahu-ola',
        storageBucket: 'kahu-ola.firebasestorage.app',
        messagingSenderId: '609159204886',
        appId: '1:609159204886:web:ff74a6ceb092aab12ca537',
        measurementId: 'G-7B7XTCCSE9',
      ),
    );
  } else {
    await Firebase.initializeApp();
  }
  try {
    await PushNotificationService.initialize();
  } catch (error) {
    if (kDebugMode) {
      debugPrint('Push notification setup skipped: $error');
    }
  }
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const ProviderScope(
      child: _AppRoot(),
    );
  }
}

class _AppRoot extends ConsumerWidget {
  const _AppRoot();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp(
      title: 'Kahu Ola',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: ThemeMode.system,
      home: const SplashScreen(),
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const DashboardPage();
  }
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer(const Duration(seconds: 3), () {
      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute<void>(
          builder: (_) => const HomeScreen(),
        ),
      );
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ColoredBox(
        color: const Color(0xFF081A2B),
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.asset(
              'assets/images/logo.png',
              fit: BoxFit.fitWidth,
              alignment: Alignment.center,
            ),
            ColoredBox(
              color: Colors.black.withValues(alpha: 0.3),
            ),
          ],
        ),
      ),
    );
  }
}
