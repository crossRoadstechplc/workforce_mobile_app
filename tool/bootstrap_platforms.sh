#!/usr/bin/env bash
set -euo pipefail

flutter create --platforms=android,ios,web .
flutter pub get

echo
echo "Native and web folders created. Review docs/PLATFORM_PERMISSIONS.md and docs/FIREBASE_SETUP.md before running release builds."
