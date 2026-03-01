import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/router/app_router.dart';

/// Splash Screen — "Kahu Ola - Guardian of Life"
/// Displays brand logo placeholder + tagline, then navigates to Dashboard.
class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnim;
  late Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    );

    _fadeAnim = CurvedAnimation(parent: _controller, curve: Curves.easeIn);
    _scaleAnim = Tween<double>(begin: 0.75, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutBack),
    );

    _controller.forward();

    // Navigate to dashboard after 3 seconds
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) context.go(AppRoutes.dashboard);
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: cs.primary,
      body: SafeArea(
        child: Center(
          child: FadeTransition(
            opacity: _fadeAnim,
            child: ScaleTransition(
              scale: _scaleAnim,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // ── Logo placeholder ─────────────────────────────────────
                  _LogoPlaceholder(color: cs.onPrimary),
                  const SizedBox(height: 32),

                  // ── App name ─────────────────────────────────────────────
                  Text(
                    AppConstants.appName,
                    style: Theme.of(context).textTheme.displayLarge?.copyWith(
                          color: cs.onPrimary,
                          fontWeight: FontWeight.w900,
                          fontSize: 48,
                          letterSpacing: 1.5,
                        ),
                  ),
                  const SizedBox(height: 8),

                  // ── Tagline ───────────────────────────────────────────────
                  Text(
                    AppConstants.appTagline,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: cs.onPrimary.withValues(alpha: 0.85),
                          letterSpacing: 2,
                          fontWeight: FontWeight.w400,
                        ),
                  ),
                  const SizedBox(height: 64),

                  // ── Loading indicator ─────────────────────────────────────
                  SizedBox(
                    width: 36,
                    height: 36,
                    child: CircularProgressIndicator(
                      strokeWidth: 3,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        cs.onPrimary.withValues(alpha: 0.7),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Space to Abyss · 12 Data Streams',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: cs.onPrimary.withValues(alpha: 0.6),
                          fontSize: 13,
                          letterSpacing: 1,
                        ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ── Logo Placeholder Widget ────────────────────────────────────────────────────
class _LogoPlaceholder extends StatelessWidget {
  final Color color;
  const _LogoPlaceholder({required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 130,
      height: 130,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
            color: color.withValues(alpha: 0.6), width: 3),
        color: color.withValues(alpha: 0.08),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Outer ring (represents the ocean / Earth)
          Container(
            width: 110,
            height: 110,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                  color: color.withValues(alpha: 0.3), width: 1.5),
            ),
          ),
          // Shield icon (guardian)
          Icon(
            Icons.shield_rounded,
            color: color,
            size: 64,
          ),
          // Small satellite symbol (Space layer)
          Positioned(
            top: 14,
            right: 14,
            child: Icon(Icons.satellite_alt_rounded, color: color, size: 20),
          ),
          // Wave at bottom (Abyss layer)
          Positioned(
            bottom: 16,
            child: Icon(Icons.waves_rounded, color: color, size: 20),
          ),
        ],
      ),
    );
  }
}
