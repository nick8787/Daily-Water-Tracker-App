#!/usr/bin/env bash
# Sync local dev version metadata to match CI / Firebase App Distribution.
#
# Usage:
#   bash scripts/local/sync_dev_version.sh 0.0.16 16
#   bash scripts/local/sync_dev_version.sh bump   # increment build from versions/dev.properties
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
PROPS="$ROOT/versions/dev.properties"

if [ "${1:-}" = "bump" ]; then
  CURRENT="$(grep '^versionCode=' "$PROPS" | cut -d= -f2)"
  NEXT="$((CURRENT + 1))"
  VERSION_NAME="0.0.${NEXT}"
  bash "$ROOT/scripts/ci/write_flavor_version.sh" dev "$VERSION_NAME" "$NEXT"
  exit 0
fi

VERSION_NAME="${1:?Usage: sync_dev_version.sh <version_name> <build_number> | bump}"
BUILD_NUMBER="${2:?build_number required unless using bump}"

bash "$ROOT/scripts/ci/write_flavor_version.sh" dev "$VERSION_NAME" "$BUILD_NUMBER"
