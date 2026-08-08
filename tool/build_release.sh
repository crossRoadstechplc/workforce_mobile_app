#!/usr/bin/env bash
set -euo pipefail

TARGET="${1:-android}"
: "${API_BASE_URL:?Set API_BASE_URL to the production HTTPS API URL}"
: "${SOCKET_BASE_URL:?Set SOCKET_BASE_URL to the production HTTPS Socket.IO URL}"

COMMON=(
  --release
  --dart-define=APP_ENV=production
  --dart-define=API_BASE_URL="$API_BASE_URL"
  --dart-define=SOCKET_BASE_URL="$SOCKET_BASE_URL"
  --dart-define=ENABLE_FIREBASE=true
)

flutter pub get
flutter analyze
flutter test

case "$TARGET" in
  android)
    flutter build appbundle "${COMMON[@]}"
    ;;
  ios)
    flutter build ipa "${COMMON[@]}"
    ;;
  *)
    echo "Usage: $0 [android|ios]" >&2
    exit 2
    ;;
esac
