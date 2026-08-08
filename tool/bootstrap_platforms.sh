#!/usr/bin/env bash
set -euo pipefail

flutter create --platforms=android,ios .
flutter pub get

echo
echo "Native folders created. Review docs/PLATFORM_PERMISSIONS.md and docs/FIREBASE_SETUP.md before running release builds."
