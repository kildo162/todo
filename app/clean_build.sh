#!/usr/bin/env zsh
set -euxo pipefail

# Clean Flutter and Android build files to fully regenerate resources with the new applicationId
# Usage: cd app && ./clean_build.sh

if command -v flutter >/dev/null 2>&1; then
  echo "Running: flutter clean"
  flutter clean
else
  echo "flutter command not found; skipping flutter clean"
fi

if [[ -f android/gradlew ]]; then
  echo "Running: ./android/gradlew clean"
  ./android/gradlew clean
else
  echo "No android/gradlew found; skipping gradle clean"
fi

# Remove generated build outputs just in case
rm -rf build/ android/app/build/ android/.gradle/ .dart_tool/ pubspec.lock

echo "Cleaned. Next: run 'flutter pub get' then 'flutter build ipa|apk --profile|--release' or 'flutter run'."
