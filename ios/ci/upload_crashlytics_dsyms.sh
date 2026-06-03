#!/usr/bin/env bash
# Upload iOS dSYM bundles from `flutter build ipa` to Firebase Crashlytics.
# Usage: upload_crashlytics_dsyms.sh <path/to/GoogleService-Info.plist>
set -euo pipefail

GSP="${1:?Usage: upload_crashlytics_dsyms.sh <GoogleService-Info.plist>}"
ROOT="${CM_BUILD_DIR:-$PWD}"
ARCHIVE_DSYMS="${ROOT}/build/ios/archive/Runner.xcarchive/dSYMs"

# Keep in sync with FirebaseCrashlytics in ios/Podfile.lock (fallback download).
FIREBASE_IOS_SDK_VERSION="${FIREBASE_IOS_SDK_VERSION:-12.12.1}"
UPLOAD_SYMBOLS_CACHE="${ROOT}/ios/ci/.crashlytics/upload-symbols"
UPLOAD_SYMBOLS_URL="https://raw.githubusercontent.com/firebase/firebase-ios-sdk/${FIREBASE_IOS_SDK_VERSION}/Crashlytics/upload-symbols"

# Symbols required for readable Flutter/Crashlytics stack traces.
REQUIRED_DSYM_NAMES=(
  "Runner.app.dSYM"
  "App.framework.dSYM"
  "Flutter.framework.dSYM"
)

if [[ ! -f "$GSP" ]]; then
  echo "GoogleService-Info.plist not found: $GSP" >&2
  exit 1
fi

is_upload_symbols_binary() {
  local path="$1"
  [[ -f "$path" && -s "$path" ]]
}

find_upload_symbols_in_tree() {
  local dir="$1"
  [[ -d "$dir" ]] || return 1
  find "$dir" -path '*/Crashlytics/upload-symbols' -type f 2>/dev/null | head -1
}

# Search Pods, SPM checkouts, symlinks, build output, and Xcode DerivedData.
find_upload_symbols() {
  local candidate=""
  local -a search_roots=(
    "${ROOT}/ios/Pods"
    "${ROOT}/ios/.symlinks"
    "${ROOT}/build"
    "${ROOT}/ios"
  )

  if [[ -d "${HOME}/Library/Developer/Xcode/DerivedData" ]]; then
    search_roots+=("${HOME}/Library/Developer/Xcode/DerivedData")
  fi

  for dir in "${search_roots[@]}"; do
    candidate="$(find_upload_symbols_in_tree "$dir" || true)"
    if is_upload_symbols_binary "$candidate"; then
      echo "$candidate"
      return 0
    fi
  done

  return 1
}

download_upload_symbols_fallback() {
  mkdir -p "$(dirname "$UPLOAD_SYMBOLS_CACHE")"
  echo "Downloading upload-symbols (Firebase iOS SDK ${FIREBASE_IOS_SDK_VERSION})..." >&2
  if ! curl -fsSL "$UPLOAD_SYMBOLS_URL" -o "$UPLOAD_SYMBOLS_CACHE"; then
    echo "Failed to download upload-symbols from ${UPLOAD_SYMBOLS_URL}" >&2
    return 1
  fi
  chmod +x "$UPLOAD_SYMBOLS_CACHE"
  if ! is_upload_symbols_binary "$UPLOAD_SYMBOLS_CACHE"; then
    echo "Downloaded upload-symbols is empty or missing." >&2
    return 1
  fi
  printf '%s\n' "$UPLOAD_SYMBOLS_CACHE"
}

resolve_upload_symbols() {
  local found=""
  if found="$(find_upload_symbols)"; then
    chmod +x "$found" 2>/dev/null || true
    echo "Using upload-symbols: ${found}" >&2
    printf '%s\n' "$found"
    return 0
  fi

  if is_upload_symbols_binary "$UPLOAD_SYMBOLS_CACHE"; then
    chmod +x "$UPLOAD_SYMBOLS_CACHE" 2>/dev/null || true
    echo "Using cached upload-symbols: ${UPLOAD_SYMBOLS_CACHE}" >&2
    printf '%s\n' "$UPLOAD_SYMBOLS_CACHE"
    return 0
  fi

  echo "upload-symbols not found in Pods/SPM/DerivedData; using GitHub fallback." >&2
  download_upload_symbols_fallback
}

UPLOAD_SYMBOLS="$(resolve_upload_symbols)"
if [[ -z "$UPLOAD_SYMBOLS" ]] || ! is_upload_symbols_binary "$UPLOAD_SYMBOLS"; then
  echo "Could not locate or download Firebase Crashlytics upload-symbols." >&2
  exit 1
fi

if [[ ! -d "$ARCHIVE_DSYMS" ]]; then
  echo "No dSYM directory at ${ARCHIVE_DSYMS} — skipping Crashlytics symbol upload."
  exit 0
fi

upload_one_dsym() {
  local dsym_path="$1"
  local required="${2:-false}"
  local name
  name="$(basename "$dsym_path")"

  echo "  → ${name}"
  if "$UPLOAD_SYMBOLS" -gsp "$GSP" -p ios "$dsym_path"; then
    echo "    ✓ uploaded"
    return 0
  fi

  echo "    ✗ upload failed" >&2
  if [[ "$required" == "true" ]]; then
    return 1
  fi
  echo "    (optional dSYM — continuing)"
  return 0
}

shopt -s nullglob
all_dsyms=( "${ARCHIVE_DSYMS}"/*.dSYM )
if [[ ${#all_dsyms[@]} -eq 0 ]]; then
  echo "No .dSYM bundles in ${ARCHIVE_DSYMS} — skipping Crashlytics symbol upload."
  exit 0
fi

echo "Uploading dSYM bundle(s) to Firebase Crashlytics (GSP: ${GSP})"

required_failed=0
for required_name in "${REQUIRED_DSYM_NAMES[@]}"; do
  required_path="${ARCHIVE_DSYMS}/${required_name}"
  if [[ -d "$required_path" ]]; then
    upload_one_dsym "$required_path" true || required_failed=1
  else
    echo "  ! missing required dSYM: ${required_name}" >&2
    required_failed=1
  fi
done

for dsym in "${all_dsyms[@]}"; do
  name="$(basename "$dsym")"
  for required_name in "${REQUIRED_DSYM_NAMES[@]}"; do
    if [[ "$name" == "$required_name" ]]; then
      continue 2
    fi
  done
  upload_one_dsym "$dsym" false || true
done

if [[ "$required_failed" -ne 0 ]]; then
  echo "Crashlytics dSYM upload failed for one or more required app symbols." >&2
  exit 1
fi

echo "Crashlytics dSYM upload finished."
