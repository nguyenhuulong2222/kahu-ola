# kahu_ola

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Learn Flutter](https://docs.flutter.dev/get-started/learn-flutter)
- [Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Flutter learning resources](https://docs.flutter.dev/reference/learning-resources)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.

## If TestFlight Shows A Blank Screen

This build now starts with an `AppShell` that always renders a loading,
error, or main UI state instead of a blank screen.

If a TestFlight build still fails to become ready:

1. Long-press the top-left corner for 2 seconds, or tap the app title 7 times.
2. Open the hidden `Runtime Diagnostics` panel.
3. Tap `Copy diagnostics`.
4. Send the copied report with the visible startup error and bootstrap step.

If your CI injects Firebase at build time, make sure
`ios/Runner/GoogleService-Info.plist` is bundled and pass
`--dart-define=GOOGLE_SERVICE_INFO_PRESENT=true` when `USE_FIREBASE=true`.
