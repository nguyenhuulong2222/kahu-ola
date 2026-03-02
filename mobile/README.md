# Kahu Ola Mobile CI Notes

This folder contains the Flutter mobile client. The current production target is
iOS via Codemagic/TestFlight, with Android support kept buildable for future
work.

## iOS CI Build

Use the checked-in build helper:

```bash
cd mobile
bash ./ci/ios_build.sh
```

The script is designed for CI safety:

- skips `flutter clean` by default for better determinism and faster builds
- runs `flutter pub get`
- runs `pod install` in `ios/`
- uses `pod install --deployment` when `ios/Podfile.lock` exists
- verifies `Runner.xcworkspace` exists after CocoaPods resolution
- runs `flutter build ipa --release` by default
- supports `IOS_NO_CODESIGN=1` to switch to `flutter build ios --release --no-codesign`
- verifies the IPA (or `Runner.app` for no-code-sign builds) exists before succeeding

## Required CI Environment Variables

These values should be stored as secure environment variables in Codemagic, not
committed to git.

### Build metadata

- `IOS_BUILD_NAME`
- `IOS_BUILD_NUMBER`

Fallbacks:

- `APP_BUILD_NAME`
- `APP_BUILD_NUMBER`
- `CM_BUILD_NUMBER`

### Runtime configuration

- `APP_ENV`
- `API_BASE_URL`
- `USE_FIREBASE`

### Firebase injection (only if Firebase is enabled)

- `IOS_GOOGLE_SERVICE_INFO_PLIST_BASE64`

When `IOS_GOOGLE_SERVICE_INFO_PLIST_BASE64` is present, the build script writes
it to `ios/Runner/GoogleService-Info.plist` during CI, marks
`GOOGLE_SERVICE_INFO_PRESENT=true` for Dart config validation, and deletes the
file after the build completes.

### Signing / App Store delivery

Use Codemagic managed code signing where possible. Typical secure values are:

- App Store Connect API key material (issuer ID, key ID, private key)
- distribution certificate
- provisioning profile

Do not hardcode Team IDs, signing identities, certificates, or provisioning
files in the repository.

## CocoaPods Policy

- Prefer `pod install` in CI.
- Use `pod repo update` only when you intentionally need newer specs.
- Commit `ios/Podfile.lock` after a successful local `pod install` so CI can use
  `pod install --deployment` for deterministic builds.

## Codemagic Example Steps

1. Restore Flutter and Xcode toolchains on the macOS build machine.
2. Inject secure environment variables for signing, `API_BASE_URL`, and Firebase.
3. Run:

   ```bash
   cd mobile
   bash ./ci/ios_build.sh
   ```

4. Publish the generated IPA to TestFlight using Codemagic's App Store Connect
   integration.

## Troubleshooting

### `pod install` fails

- Verify `ios/Podfile` exists and is checked in.
- If `ios/Podfile.lock` is stale, regenerate it locally with `pod install`,
  review the diff, and commit it.
- Avoid `pod repo update` in normal CI runs unless a new podspec is required.

### `Runner.xcworkspace` is missing

- `pod install` did not complete successfully.
- Ensure `ios/Runner.xcodeproj` exists in the repo and has not been removed.

### Code signing / export issues

- Prefer Codemagic-managed signing instead of local developer settings.
- If archive signing is temporarily blocked, run with `IOS_NO_CODESIGN=1` to
  validate compilation first.
- If using a custom export options plist, set `IOS_EXPORT_OPTIONS_PLIST`.

### Firebase startup issues

- Ensure `USE_FIREBASE=true` only when the CI job also injects
  `IOS_GOOGLE_SERVICE_INFO_PLIST_BASE64`.
- The app's runtime config will intentionally fail fast and show diagnostics if
  Firebase is declared on but its config file is missing.

### TestFlight blank screen

- Tap the app title 7 times, or long-press the top-left corner for 2 seconds.
- Open the hidden diagnostics panel.
- Copy diagnostics and inspect the bootstrap step, last error, and network
  reachability.
