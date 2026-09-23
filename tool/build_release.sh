#!/usr/bin/env bash
set -euo pipefail

TARGET="${1:-android}"
: "${API_BASE_URL:?Set API_BASE_URL to the production HTTPS API URL}"
: "${SOCKET_BASE_URL:?Set SOCKET_BASE_URL to the production HTTPS Socket.IO URL}"
APP_VERSION="${APP_VERSION:-1.0.0}"

# Web Hosting can ship without push; native releases expect Firebase configured.
if [[ -z "${ENABLE_FIREBASE:-}" ]]; then
  if [[ "$TARGET" == "web" ]]; then
    ENABLE_FIREBASE=false
  else
    ENABLE_FIREBASE=true
  fi
fi

COMMON=(
  --release
  --dart-define=APP_ENV=production
  --dart-define=API_BASE_URL="$API_BASE_URL"
  --dart-define=SOCKET_BASE_URL="$SOCKET_BASE_URL"
  --dart-define=ENABLE_FIREBASE="$ENABLE_FIREBASE"
  --dart-define=APP_VERSION="$APP_VERSION"
)

flutter pub get
flutter analyze
flutter test

case "$TARGET" in
  android)
    flutter build appbundle "${COMMON[@]}"
    ;;
  apk)
    flutter build apk "${COMMON[@]}"
    echo
    echo "APK artifact: build/app/outputs/flutter-apk/app-release.apk"
    ;;
  ios)
    flutter build ipa "${COMMON[@]}"
    ;;
  web)
    flutter build web "${COMMON[@]}"
    echo
    echo "Web artifact: build/web"
    echo "Deploy: firebase deploy --only hosting"
    ;;
  *)
    echo "Usage: $0 [android|apk|ios|web]" >&2
    exit 2
    ;;
esac
