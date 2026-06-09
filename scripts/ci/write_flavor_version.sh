#!/usr/bin/env bash
# Writes per-flavor version metadata used by Android Gradle and iOS xcconfig.
set -euo pipefail

FLAVOR="${1:?Usage: write_flavor_version.sh <dev|prod> <version_name> <build_number>}"
VERSION_NAME="${2:?version_name required}"
BUILD_NUMBER="${3:?build_number required}"

ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
PROPS_FILE="$ROOT/versions/${FLAVOR}.properties"
IOS_XCCONFIG="$ROOT/ios/config/${FLAVOR}/Version.xcconfig"

mkdir -p "$(dirname "$PROPS_FILE")" "$(dirname "$IOS_XCCONFIG")"

cat > "$PROPS_FILE" <<EOF
versionName=${VERSION_NAME}
versionCode=${BUILD_NUMBER}
EOF

cat > "$IOS_XCCONFIG" <<EOF
FLUTTER_BUILD_NAME=${VERSION_NAME}
FLUTTER_BUILD_NUMBER=${BUILD_NUMBER}
EOF

# Keep pubspec aligned with dev so `flutter run` / Generated.xcconfig match flavor files.
if [ "$FLAVOR" = "dev" ] && [ -f "$ROOT/pubspec.yaml" ]; then
  perl -i -pe "s/^version: .*/version: ${VERSION_NAME}+${BUILD_NUMBER}/" "$ROOT/pubspec.yaml"
fi

echo "Set ${FLAVOR} version to ${VERSION_NAME} (${BUILD_NUMBER})"
