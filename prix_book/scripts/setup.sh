#!/bin/bash
# Prix Book — One-time local setup
# Run once before your first git push if gradle-wrapper.jar is missing.
set -e

echo "→ Checking gradle-wrapper.jar..."
JAR="android/gradle/wrapper/gradle-wrapper.jar"

if [ ! -f "$JAR" ] || [ ! -s "$JAR" ]; then
  echo "→ Downloading gradle-wrapper.jar (Gradle 8.4)..."
  curl -L "https://github.com/gradle/gradle/raw/v8.4.0/gradle/wrapper/gradle-wrapper.jar" -o "$JAR"
  echo "✓ Downloaded ($(wc -c < "$JAR") bytes)"
else
  echo "✓ Already present"
fi

echo "→ flutter pub get..."
flutter pub get

echo ""
echo "✓ Ready. Push to GitHub and trigger a Codemagic build."
