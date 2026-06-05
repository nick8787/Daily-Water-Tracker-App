#!/usr/bin/env bash
# Flutter iOS deps + ensure Manual signing for flavor build configurations on CI.
set -euo pipefail

flutter pub get
find . -name "Podfile" -execdir pod install \;

PBX="ios/Runner.xcodeproj/project.pbxproj"

# Flavor targets (Release-dev, Release-prod, …) use Manual signing in the repo.
# These sed rules are idempotent safety nets if Xcode/Flutter reset anything to Automatic.
sed -i '' 's/CODE_SIGN_STYLE = Automatic;/CODE_SIGN_STYLE = Manual;/g' "$PBX"
sed -i '' 's/ProvisioningStyle = Automatic;/ProvisioningStyle = Manual;/g' "$PBX"

# Never commit machine-specific profile UUIDs or hardcoded profile names.
sed -i '' 's/PROVISIONING_PROFILE_SPECIFIER = ".*";//g' "$PBX"
sed -i '' '/^[[:space:]]*PROVISIONING_PROFILE = /d' "$PBX"

echo "iOS project ready for CI signing."
