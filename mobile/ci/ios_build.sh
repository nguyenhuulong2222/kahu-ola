#!/bin/bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DEFAULT_APP_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/../.." && pwd)"
APP_DIR="${DEFAULT_APP_DIR}"

if [[ ! -f "${APP_DIR}/pubspec.yaml" && -f "${REPO_ROOT}/pubspec.yaml" && -d "${REPO_ROOT}/ios" ]]; then
  APP_DIR="${REPO_ROOT}"
fi

LOG_DIR="${APP_DIR}/build_logs"
TIMESTAMP="$(date +%Y%m%d_%H%M%S)"
LOG_FILE="${LOG_DIR}/ios_build_${TIMESTAMP}.log"

mkdir -p "${LOG_DIR}"

log() {
  printf '[ios-build] %s\n' "$*" | tee -a "${LOG_FILE}"
}

fail() {
  log "ERROR: $*"
  exit 1
}

require_command() {
  if ! command -v "$1" >/dev/null 2>&1; then
    fail "Required command not found: $1"
  fi
}

decode_base64_to_file() {
  local payload="$1"
  local destination="$2"

  mkdir -p "$(dirname "${destination}")"

  if base64 --help 2>/dev/null | grep -q -- '--decode'; then
    printf '%s' "${payload}" | base64 --decode > "${destination}"
  else
    printf '%s' "${payload}" | base64 -D > "${destination}"
  fi
}

cleanup() {
  if [[ -n "${TEMP_GOOGLE_SERVICE_INFO_PATH:-}" && -f "${TEMP_GOOGLE_SERVICE_INFO_PATH}" ]]; then
    rm -f "${TEMP_GOOGLE_SERVICE_INFO_PATH}"
    log "Removed injected GoogleService-Info.plist after build."
  fi
}

trap cleanup EXIT

require_command flutter
require_command dart
HOST_OS="$(uname -s 2>/dev/null || echo unknown)"

DEFAULT_IOS_DIR="${APP_DIR}/ios"
IOS_DIR="${DEFAULT_IOS_DIR}"
if [[ ! -d "${IOS_DIR}" && -d "${REPO_ROOT}/ios" ]]; then
  IOS_DIR="${REPO_ROOT}/ios"
fi

HAS_PODFILE=0
if [[ -f "${IOS_DIR}/Podfile" ]]; then
  HAS_PODFILE=1
fi

{
  echo '=== Toolchain Versions ==='
  flutter --version
  dart --version
  if [[ "${HOST_OS}" == "Darwin" ]]; then
    require_command xcodebuild
    if [[ "${HAS_PODFILE}" == "1" ]]; then
      require_command pod
    fi
    xcodebuild -version
    if [[ "${HAS_PODFILE}" == "1" ]]; then
      pod --version
    else
      echo "pod: skipped (no Podfile at ${IOS_DIR})"
    fi
  else
    echo "xcodebuild: unavailable on ${HOST_OS}"
    echo "pod: unavailable on ${HOST_OS}"
  fi
  echo
} | tee -a "${LOG_FILE}"

[[ -f "${APP_DIR}/pubspec.yaml" ]] || fail "Missing ${APP_DIR}/pubspec.yaml"
[[ -d "${IOS_DIR}" ]] || fail "Missing ${IOS_DIR}"
[[ -d "${IOS_DIR}/Runner.xcodeproj" ]] || fail "Missing ${IOS_DIR}/Runner.xcodeproj"

PUBSPEC_VERSION="$(grep -E '^version:' "${APP_DIR}/pubspec.yaml" | head -n 1 | awk '{print $2}' | tr -d '\r')"
if [[ -z "${PUBSPEC_VERSION}" ]]; then
  fail "Unable to resolve version from ${APP_DIR}/pubspec.yaml"
fi

PUBSPEC_BUILD_NAME="${PUBSPEC_VERSION%%+*}"
PUBSPEC_BUILD_NUMBER="${PUBSPEC_VERSION#*+}"
if [[ "${PUBSPEC_BUILD_NUMBER}" == "${PUBSPEC_VERSION}" ]]; then
  PUBSPEC_BUILD_NUMBER="1"
fi

if [[ -n "${IOS_GOOGLE_SERVICE_INFO_PLIST_BASE64:-}" ]]; then
  TEMP_GOOGLE_SERVICE_INFO_PATH="${IOS_DIR}/Runner/GoogleService-Info.plist"
  decode_base64_to_file "${IOS_GOOGLE_SERVICE_INFO_PLIST_BASE64}" "${TEMP_GOOGLE_SERVICE_INFO_PATH}"
  export GOOGLE_SERVICE_INFO_PRESENT=true
  log "Injected GoogleService-Info.plist from CI secret."
fi

ENV_BUILD_NUMBER="${BUILD_NUMBER:-}"
RESOLVED_BUILD_NAME="${IOS_BUILD_NAME:-${APP_BUILD_NAME:-${PUBSPEC_BUILD_NAME}}}"
RESOLVED_BUILD_NUMBER="${IOS_BUILD_NUMBER:-${PROJECT_BUILD_NUMBER:-${ENV_BUILD_NUMBER:-${APP_BUILD_NUMBER:-${CM_BUILD_NUMBER:-${PUBSPEC_BUILD_NUMBER}}}}}}"
APP_ENV_VALUE="${APP_ENV:-production}"
API_BASE_URL_VALUE="${API_BASE_URL:-}"
USE_FIREBASE_VALUE="${USE_FIREBASE:-false}"
GOOGLE_SERVICE_INFO_PRESENT_VALUE="${GOOGLE_SERVICE_INFO_PRESENT:-false}"
FORCE_CLEAN="${FORCE_FLUTTER_CLEAN:-0}"
IOS_NO_CODESIGN_VALUE="${IOS_NO_CODESIGN:-0}"

if ! [[ "${RESOLVED_BUILD_NUMBER}" =~ ^[0-9]+$ ]]; then
  fail "Resolved build number is not numeric: ${RESOLVED_BUILD_NUMBER}"
fi

if (( RESOLVED_BUILD_NUMBER <= 1 )); then
  if (( PUBSPEC_BUILD_NUMBER > 1 )); then
    log "Resolved build number ${RESOLVED_BUILD_NUMBER} is too low for App Store upload; using pubspec build number ${PUBSPEC_BUILD_NUMBER} instead."
    RESOLVED_BUILD_NUMBER="${PUBSPEC_BUILD_NUMBER}"
  else
    fail "Resolved build number must be greater than 1 for TestFlight upload."
  fi
fi

if [[ -f "${IOS_DIR}/Runner/GoogleService-Info.plist" ]]; then
  GOOGLE_SERVICE_INFO_PRESENT_VALUE="true"
fi

log "App directory: ${APP_DIR}"
log "Pubspec version: ${PUBSPEC_VERSION}"
log "Resolved FLUTTER_BUILD_NAME: ${RESOLVED_BUILD_NAME}"
log "Resolved FLUTTER_BUILD_NUMBER: ${RESOLVED_BUILD_NUMBER}"

GENERATED_XCCONFIG_PATH="${IOS_DIR}/Flutter/Generated.xcconfig"
if [[ -f "${GENERATED_XCCONFIG_PATH}" ]]; then
  XC_BUILD_NAME="$(grep -E '^FLUTTER_BUILD_NAME=' "${GENERATED_XCCONFIG_PATH}" | head -n 1 | cut -d '=' -f 2- | tr -d '\r' || true)"
  XC_BUILD_NUMBER="$(grep -E '^FLUTTER_BUILD_NUMBER=' "${GENERATED_XCCONFIG_PATH}" | head -n 1 | cut -d '=' -f 2- | tr -d '\r' || true)"
  log "Generated.xcconfig FLUTTER_BUILD_NAME: ${XC_BUILD_NAME:-unset}"
  log "Generated.xcconfig FLUTTER_BUILD_NUMBER: ${XC_BUILD_NUMBER:-unset}"
fi

if [[ "${FORCE_CLEAN}" == "1" ]]; then
  log "Running flutter clean because FORCE_FLUTTER_CLEAN=1"
  (
    cd "${APP_DIR}"
    flutter clean
  ) 2>&1 | tee -a "${LOG_FILE}" || fail "flutter clean failed"
else
  log "Skipping flutter clean (default for faster and more deterministic CI)."
fi

log "Running flutter pub get"
(
  cd "${APP_DIR}"
  flutter pub get
) 2>&1 | tee -a "${LOG_FILE}" || fail "flutter pub get failed"

if [[ "${HOST_OS}" != "Darwin" ]]; then
  fail "iOS builds require macOS (Darwin). Current host: ${HOST_OS}"
fi

if [[ "${HAS_PODFILE}" == "1" ]]; then
  log "Installing CocoaPods dependencies"
  POD_INSTALL_FLAGS=(install)
  if [[ -f "${IOS_DIR}/Podfile.lock" ]]; then
    POD_INSTALL_FLAGS+=(--deployment)
    log "Podfile.lock found; using pod install --deployment for deterministic CI."
  else
    log "Podfile.lock is missing; using plain pod install."
  fi

  (
    cd "${IOS_DIR}"
    pod "${POD_INSTALL_FLAGS[@]}"
  ) 2>&1 | tee -a "${LOG_FILE}" || fail "pod install failed"

  [[ -d "${IOS_DIR}/Runner.xcworkspace" ]] || fail "Runner.xcworkspace was not generated by pod install"
else
  if [[ -d "${IOS_DIR}/Runner.xcworkspace" ]]; then
    log "No Podfile found at ${IOS_DIR}; skipping pod install and using existing Runner.xcworkspace."
  else
    fail "Missing Podfile and Runner.xcworkspace under ${IOS_DIR}; unable to continue."
  fi
fi

BUILD_CMD=(flutter build ipa --release "--build-name=${RESOLVED_BUILD_NAME}" "--build-number=${RESOLVED_BUILD_NUMBER}")

if [[ "${IOS_NO_CODESIGN_VALUE}" == "1" ]]; then
  BUILD_CMD=(flutter build ios --release --no-codesign "--build-name=${RESOLVED_BUILD_NAME}" "--build-number=${RESOLVED_BUILD_NUMBER}")
  log "Using flutter build ios --no-codesign because IOS_NO_CODESIGN=1"
fi

if [[ -n "${API_BASE_URL_VALUE}" ]]; then
  BUILD_CMD+=("--dart-define=API_BASE_URL=${API_BASE_URL_VALUE}")
fi

BUILD_CMD+=("--dart-define=APP_ENV=${APP_ENV_VALUE}")

if [[ "${USE_FIREBASE_VALUE}" == "true" ]]; then
  BUILD_CMD+=("--dart-define=USE_FIREBASE=true")
  if [[ "${GOOGLE_SERVICE_INFO_PRESENT_VALUE}" == "true" ]]; then
    BUILD_CMD+=("--dart-define=GOOGLE_SERVICE_INFO_PRESENT=true")
  fi
fi

if [[ -n "${IOS_EXPORT_OPTIONS_PLIST:-}" ]]; then
  BUILD_CMD+=("--export-options-plist=${IOS_EXPORT_OPTIONS_PLIST}")
fi

log "Running: ${BUILD_CMD[*]}"
(
  cd "${APP_DIR}"
  "${BUILD_CMD[@]}"
) 2>&1 | tee -a "${LOG_FILE}" || fail "Flutter iOS build failed"

if [[ "${IOS_NO_CODESIGN_VALUE}" == "1" ]]; then
  APP_BUNDLE_PATH="${APP_DIR}/build/ios/iphoneos/Runner.app"
  [[ -d "${APP_BUNDLE_PATH}" ]] || fail "Expected Runner.app not found at ${APP_BUNDLE_PATH}"
  log "No-code-sign build completed: ${APP_BUNDLE_PATH}"
else
  IPA_PATH="$(find "${APP_DIR}/build/ios/ipa" -maxdepth 1 -name '*.ipa' | head -n 1 || true)"
  [[ -n "${IPA_PATH}" ]] || fail "No IPA found under ${APP_DIR}/build/ios/ipa"
  [[ -f "${IPA_PATH}" ]] || fail "IPA path does not exist: ${IPA_PATH}"
  log "IPA generated successfully: ${IPA_PATH}"
fi

SOURCE_INFO_PLIST_PATH="${IOS_DIR}/Runner/Info.plist"
EFFECTIVE_INFO_PLIST_PATH="${SOURCE_INFO_PLIST_PATH}"
if [[ "${IOS_NO_CODESIGN_VALUE}" == "1" && -f "${APP_DIR}/build/ios/iphoneos/Runner.app/Info.plist" ]]; then
  EFFECTIVE_INFO_PLIST_PATH="${APP_DIR}/build/ios/iphoneos/Runner.app/Info.plist"
elif [[ -f "${APP_DIR}/build/ios/archive/Runner.xcarchive/Products/Applications/Runner.app/Info.plist" ]]; then
  EFFECTIVE_INFO_PLIST_PATH="${APP_DIR}/build/ios/archive/Runner.xcarchive/Products/Applications/Runner.app/Info.plist"
fi

if [[ -f "${EFFECTIVE_INFO_PLIST_PATH}" ]] && command -v /usr/libexec/PlistBuddy >/dev/null 2>&1; then
  BUNDLE_ID="$(/usr/libexec/PlistBuddy -c 'Print :CFBundleIdentifier' "${EFFECTIVE_INFO_PLIST_PATH}" 2>/dev/null || true)"
  VERSION="$(/usr/libexec/PlistBuddy -c 'Print :CFBundleShortVersionString' "${EFFECTIVE_INFO_PLIST_PATH}" 2>/dev/null || true)"
  BUILD="$(/usr/libexec/PlistBuddy -c 'Print :CFBundleVersion' "${EFFECTIVE_INFO_PLIST_PATH}" 2>/dev/null || true)"
  log "Effective Info.plist path: ${EFFECTIVE_INFO_PLIST_PATH}"
  log "Effective Info.plist bundle id: ${BUNDLE_ID:-unknown}"
  log "Effective Info.plist version: ${VERSION:-unknown} (${BUILD:-unknown})"
else
  log "Info.plist validation skipped (no readable Info.plist or PlistBuddy unavailable)."
fi

log "iOS build completed successfully. Full log: ${LOG_FILE}"
