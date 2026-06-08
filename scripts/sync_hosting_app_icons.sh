#!/usr/bin/env bash
# Regenerate Firebase Hosting app icons from launcher sources (dev + prod).
set -euo pipefail

root_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
icons_dir="$root_dir/assets/launcher/icons"
assets_dir="$root_dir/public/assets"

sips -z 180 180 "$icons_dir/web_prod.png" --out "$assets_dir/app-icon-prod.png"
sips -z 180 180 "$icons_dir/web_dev.png" --out "$assets_dir/app-icon-dev.png"
cp "$assets_dir/app-icon-prod.png" "$assets_dir/app-icon.png"

echo "Updated:"
echo "  $assets_dir/app-icon-prod.png"
echo "  $assets_dir/app-icon-dev.png"
echo "  $assets_dir/app-icon.png (prod fallback)"
