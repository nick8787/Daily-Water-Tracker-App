#!/usr/bin/env python3
"""Write Firebase App IDs from decoded CI secrets into CM_ENV."""
from __future__ import annotations

import json
import os
import plistlib
import sys
from pathlib import Path


def main() -> None:
    flavor = sys.argv[1] if len(sys.argv) > 1 else "dev"
    prefix = "PROD" if flavor == "prod" else "DEV"
    suffix = "_PROD" if flavor == "prod" else ""

    android_path = Path(f"android/app/src/{flavor}/google-services.json")
    ios_path = Path(f"ios/config/{flavor}/GoogleService-Info.plist")

    with android_path.open(encoding="utf-8") as f:
        android_app_id = json.load(f)["client"][0]["client_info"]["mobilesdk_app_id"]

    lines = [f"FIREBASE_APP_ID_ANDROID{suffix}={android_app_id}\n"]

    if ios_path.exists():
        with ios_path.open("rb") as f:
            ios_app_id = plistlib.load(f)["GOOGLE_APP_ID"]
        lines.append(f"FIREBASE_APP_ID_IOS{suffix}={ios_app_id}\n")

    cm_env = os.environ.get("CM_ENV")
    if cm_env:
        with open(cm_env, "a", encoding="utf-8") as f:
            f.writelines(lines)

    print(f"Firebase App IDs extracted ({prefix})")


if __name__ == "__main__":
    main()
