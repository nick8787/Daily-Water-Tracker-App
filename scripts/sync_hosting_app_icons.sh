#!/usr/bin/env bash
# Regenerate Firebase Hosting assets from Android launcher foregrounds (prod + dev).
set -euo pipefail

root_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
icons_dir="$root_dir/assets/launcher/icons"
assets_dir="$root_dir/public/assets"

prod_src="$icons_dir/android_icon_foreground.png"
dev_src="$icons_dir/android_icon_foreground_dev.png"

for src in "$prod_src" "$dev_src"; do
  if [[ ! -f "$src" ]]; then
    echo "Missing icon source: $src" >&2
    exit 1
  fi
done

sips -z 180 180 "$prod_src" --out "$assets_dir/app-icon-prod.png"
sips -z 180 180 "$dev_src" --out "$assets_dir/app-icon-dev.png"
cp "$assets_dir/app-icon-prod.png" "$assets_dir/app-icon.png"

sips -z 58 58 "$prod_src" --out "$assets_dir/favicon-prod.png"
sips -z 58 58 "$dev_src" --out "$assets_dir/favicon-dev.png"
cp "$assets_dir/favicon-prod.png" "$assets_dir/favicon.png"

sips -z 180 180 "$prod_src" --out "$assets_dir/apple-touch-icon-prod.png"
sips -z 180 180 "$dev_src" --out "$assets_dir/apple-touch-icon-dev.png"
cp "$assets_dir/apple-touch-icon-prod.png" "$assets_dir/apple-touch-icon.png"

sips -z 512 512 "$prod_src" --out "$assets_dir/og-share-prod.png"
sips -z 512 512 "$dev_src" --out "$assets_dir/og-share-dev.png"
cp "$assets_dir/og-share-prod.png" "$assets_dir/og-share.png"

cp "$prod_src" "$icons_dir/web_prod.png"
cp "$dev_src" "$icons_dir/web_dev.png"

echo "Updated hosting icons from Android launcher sources:"
echo "  prod: $prod_src"
echo "  dev:  $dev_src"
