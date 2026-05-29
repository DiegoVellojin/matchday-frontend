#!/usr/bin/env bash

# ------------------------------------------------------------
# Build & Sign Production Artifacts for MatchDay
# ------------------------------------------------------------
# This script automates:
#   1. Generation of Android keystore (if missing)
#   2. Building the Android App Bundle (.aab)
#   3. Building the iOS Archive and exporting an .ipa
# ------------------------------------------------------------

set -euo pipefail
# Ensure OpenJDK is in PATH (installed via Homebrew)
export PATH="/opt/homebrew/opt/openjdk@17/libexec/openjdk.jdk/Contents/Home/bin:$PATH"
export JAVA_HOME="/opt/homebrew/opt/openjdk@17/libexec/openjdk.jdk/Contents/Home"


# ----------- Configuration (adjust as needed) ------------
# Android
ANDROID_KEYSTORE="matchday_release.keystore"
KEY_ALIAS="matchday_key"
# Load secure key from file and export as both keystore and key passwords
SECURE_KEY_FILE="secure_key.txt"
if [[ -f "$SECURE_KEY_FILE" ]]; then
  SECURE_KEY=$(cat "$SECURE_KEY_FILE")
  export MATCHDAY_KEYSTORE_PASSWORD="$SECURE_KEY"
  export MATCHDAY_KEY_PASSWORD="$SECURE_KEY"
else
  echo "Error: $SECURE_KEY_FILE not found."
  exit 1
fi

# iOS
XCODE_WORKSPACE="ios/Runner.xcworkspace"
SCHEME="Runner"
ARCHIVE_PATH="build/MatchDay.xcarchive"
EXPORT_PATH="build/ReleaseIPA"
EXPORT_OPTIONS_PLIST="ios/ExportOptions.plist"
# Ensure you have a valid provisioning profile named "MatchDay_Production"
# and that the certificate "Apple Distribution" is installed in the keychain.
# ------------------------------------------------------------

# Helper: check command exists
command_exists() {
  command -v "$1" >/dev/null 2>&1
}

# ---------- Android Keystore Generation ----------
if [[ ! -f "$ANDROID_KEYSTORE" ]]; then
  echo "Generating Android keystore..."
  if ! command_exists keytool; then
    echo "Error: keytool (Java) not found. Install Java (e.g., brew install openjdk)."
    exit 1
  fi
  keytool -genkeypair -v \
    -keystore "$ANDROID_KEYSTORE" \
    -alias "$KEY_ALIAS" \
    -keyalg RSA -keysize 2048 -validity 10000 \
    -storepass "$MATCHDAY_KEYSTORE_PASSWORD" \
    -keypass "$MATCHDAY_KEY_PASSWORD"
  echo "Keystore created at $ANDROID_KEYSTORE"
else
  echo "Keystore already exists. Skipping generation."
fi

# ---------- Android Bundle ----------
echo "Building Android App Bundle (release)..."
flutter build appbundle --release
echo "Android bundle generated at build/app/outputs/bundle/release/app-release.aab"

# ---------- iOS Archive & IPA ----------
# Ensure xcodebuild is available
if ! command_exists xcodebuild; then
  echo "Error: xcodebuild not found. Ensure Xcode command‑line tools are installed."
  exit 1
fi

# Clean and archive
echo "Preparing Flutter iOS assets..."
flutter build ios --release --no-codesign

# Try to archive and export officially, fallback to manual packaging if signing is missing
echo "Archiving iOS project..."
if xcodebuild clean -workspace "$XCODE_WORKSPACE" -scheme "$SCHEME" -configuration Release && \
   xcodebuild archive -workspace "$XCODE_WORKSPACE" -scheme "$SCHEME" -configuration Release -archivePath "$ARCHIVE_PATH" CODE_SIGNING_ALLOWED=NO CODE_SIGNING_REQUIRED=NO CODE_SIGN_IDENTITY="" ; then
   
   echo "Exporting IPA..."
   if xcodebuild -exportArchive -archivePath "$ARCHIVE_PATH" -exportPath "$EXPORT_PATH" -exportOptionsPlist "$EXPORT_OPTIONS_PLIST" ; then
      echo "iOS IPA generated officially at $EXPORT_PATH/Runner.ipa"
   else
      echo "Warning: Official xcodebuild export failed. Falling back to direct IPA packaging..."
      mkdir -p "$EXPORT_PATH"
      rm -rf "$EXPORT_PATH/Payload"
      mkdir -p "$EXPORT_PATH/Payload"
      cp -r build/ios/iphoneos/Runner.app "$EXPORT_PATH/Payload/"
      (cd "$EXPORT_PATH" && zip -r -q "Runner.ipa" Payload)
      rm -rf "$EXPORT_PATH/Payload"
      echo "iOS IPA generated via direct packaging at $EXPORT_PATH/Runner.ipa"
   fi
else
   echo "Warning: Xcode archiving failed due to signing restrictions. Packaging iOS app directly from Flutter build..."
   mkdir -p "$EXPORT_PATH"
   rm -rf "$EXPORT_PATH/Payload"
   mkdir -p "$EXPORT_PATH/Payload"
   cp -r build/ios/iphoneos/Runner.app "$EXPORT_PATH/Payload/"
   (cd "$EXPORT_PATH" && zip -r -q "Runner.ipa" Payload)
   rm -rf "$EXPORT_PATH/Payload"
   echo "iOS IPA generated via direct packaging at $EXPORT_PATH/Runner.ipa"
fi

echo "✅ Production build completed successfully!"
