#!/usr/bin/env bash
set -euo pipefail

root_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$root_dir"

main_res="android/app/src/main/res"
dev_res="android/app/src/dev/res"
prod_res="android/app/src/prod/res"

ensure_dirs() {
  mkdir -p "$main_res" "$dev_res" "$prod_res"
}

clean_generated_from_main() {
  rm -rf "$main_res"/mipmap-* "$main_res"/mipmap-anydpi-v26 "$main_res"/drawable/ic_launcher* "$main_res"/mipmap/ic_launcher* 2>/dev/null || true
  rm -f "android/app/src/main/ic_launcher-playstore.png" 2>/dev/null || true
}

move_icons_from_main_to() {
  local target_res="$1"
  mkdir -p "$target_res"
  rm -rf "$target_res"/mipmap-* "$target_res"/mipmap-anydpi-v26 "$target_res"/drawable/ic_launcher* 2>/dev/null || true

  if ls "$main_res"/mipmap-* >/dev/null 2>&1; then
    mv "$main_res"/mipmap-* "$target_res"/
  fi
  if [[ -d "$main_res/mipmap-anydpi-v26" ]]; then
    mv "$main_res/mipmap-anydpi-v26" "$target_res"/
  fi
  if ls "$main_res"/drawable/ic_launcher* >/dev/null 2>&1; then
    mkdir -p "$target_res/drawable"
    mv "$main_res"/drawable/ic_launcher* "$target_res/drawable"/
  fi
}

generate_for() {
  local config="$1"
  local target_res="$2"

  clean_generated_from_main
  dart run flutter_launcher_icons --file "$config"
  move_icons_from_main_to "$target_res"
}

ensure_dirs

echo "Generating PROD icons (also used as default in main)..."
clean_generated_from_main
dart run flutter_launcher_icons --file flutter_launcher_icons-prod.yaml
move_icons_from_main_to "$prod_res"

clean_generated_from_main
dart run flutter_launcher_icons --file flutter_launcher_icons-prod.yaml

echo "Generating DEV icons..."
generate_for flutter_launcher_icons-dev.yaml "$dev_res"

echo "Done. DEV/PROD icons generated."
