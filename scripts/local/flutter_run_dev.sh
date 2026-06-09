#!/usr/bin/env bash
# Run dev flavor with version labels taken from versions/dev.properties (full rebuild required
# after changing version files — hot reload does not update native bundle metadata).
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
PROPS="$ROOT/versions/dev.properties"
VERSION="$(grep '^versionName=' "$PROPS" | cut -d= -f2)"
BUILD="$(grep '^versionCode=' "$PROPS" | cut -d= -f2)"

exec flutter run \
  --flavor dev \
  --build-name="$VERSION" \
  --build-number="$BUILD" \
  "$@"
