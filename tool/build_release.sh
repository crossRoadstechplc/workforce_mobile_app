#!/usr/bin/env bash
set -euo pipefail

TARGET="${1:-android}"
: "${API_BASE_URL:?Set API_BASE_URL to the production HTTPS API URL}"
: "${SOCKET_BASE_URL:?Set SOCKET_BASE_URL to the production HTTPS Socket.IO URL}"

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
  web)
    flutter build web "${COMMON[@]}"
    echo
    echo "Web artifact: build/web"
    echo "Deploy: firebase deploy --only hosting"
    ;;
  *)
    echo "Usage: $0 [android|ios|web]" >&2
    exit 2
    ;;
esac
