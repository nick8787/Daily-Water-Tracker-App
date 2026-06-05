#!/usr/bin/env bash
# Download Apple signing assets and pin the provisioning profile into flavor Xcode configs.
#
# Usage: setup_codemagic_signing.sh <bundle_id> <profile_kind>
#   profile_kind: development | appstore | adhoc
#
# Each step is required on every CI build:
#   fetch-signing-files --create  — download cert/profile (creates only if missing on Apple side)
#   keychain add-certificates     — install the distribution/development certificate
#   xcode-project use-profiles    — applies profiles to standard Debug/Release configs only
#   inject_ci_profile.py          — pins UUID into Release-dev / Release-prod (use-profiles skips these)
set -euo pipefail

BUNDLE_ID="${1:?Usage: setup_codemagic_signing.sh <bundle_id> <profile_kind>}"
PROFILE_KIND="${2:?Usage: setup_codemagic_signing.sh <bundle_id> <profile_kind>}"

if [ -z "${CERTIFICATE_PRIVATE_KEY:-}" ]; then
  echo "CERTIFICATE_PRIVATE_KEY is missing (Codemagic group: common)." >&2
  echo "Required so Codemagic can store the signing certificate private key." >&2
  exit 1
fi

case "$PROFILE_KIND" in
  development) PROFILE_TYPE="IOS_APP_DEVELOPMENT" ;;
  appstore)    PROFILE_TYPE="IOS_APP_STORE" ;;
  adhoc)       PROFILE_TYPE="IOS_APP_ADHOC" ;;
  *)
    echo "Unknown profile kind: $PROFILE_KIND (expected development, appstore, or adhoc)" >&2
    exit 1
    ;;
esac

keychain initialize
app-store-connect fetch-signing-files "$BUNDLE_ID" --type "$PROFILE_TYPE" --create
keychain add-certificates
xcode-project use-profiles

CM_BUNDLE_ID="$BUNDLE_ID" CM_PROFILE_KIND="$PROFILE_KIND" python3 ios/ci/inject_ci_profile.py
