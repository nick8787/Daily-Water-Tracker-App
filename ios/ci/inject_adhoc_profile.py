#!/usr/bin/env python3
"""
Codemagic: after `app-store-connect fetch-signing-files`, find the Ad Hoc
.mobileprovision for the dev bundle id and pin PROVISIONING_PROFILE_SPECIFIER
into Runner's Release-dev / Profile-dev Xcode configs.

`xcode-project use-profiles` often skips non-standard configuration names
(e.g. Release-dev), which causes: "Runner requires a provisioning profile".
"""

from __future__ import annotations

import os
import plistlib
import subprocess
import sys
from pathlib import Path


BUNDLE_ID = "com.dailywatertracker.app.dev"
PBXPROJ = Path(__file__).resolve().parents[1] / "Runner.xcodeproj" / "project.pbxproj"


def _profile_search_roots() -> list[Path]:
    roots: list[Path] = []
    env_dir = os.environ.get("CM_PROFILES_DIR", "").strip()
    if env_dir:
        roots.append(Path(env_dir))
    roots.extend(
        [
            Path.home() / "Library/MobileDevice/Provisioning Profiles",
            Path.home() / "Library/Developer/Xcode/UserData/Provisioning Profiles",
        ]
    )
    # Dedupe while preserving order
    seen: set[str] = set()
    out: list[Path] = []
    for r in roots:
        key = str(r)
        if key in seen:
            continue
        seen.add(key)
        out.append(r)
    return out


def _iter_mobileprovisions() -> list[Path]:
    found: list[Path] = []
    seen_paths: set[str] = set()

    for root in _profile_search_roots():
        if root.is_dir():
            for p in root.glob("*.mobileprovision"):
                k = str(p.resolve())
                if k not in seen_paths:
                    seen_paths.add(k)
                    found.append(p)

    # CI sometimes leaves profiles only under the clone; shallow search.
    repo_ios = Path(__file__).resolve().parents[1]
    for p in repo_ios.rglob("*.mobileprovision"):
        if ".symlinks" in p.parts or "Pods/" in p.parts:
            continue
        k = str(p.resolve())
        if k not in seen_paths:
            seen_paths.add(k)
            found.append(p)

    return found


def _decode_provision(path: Path) -> dict | None:
    try:
        raw = subprocess.check_output(
            ["security", "cms", "-D", "-i", str(path)],
            stderr=subprocess.DEVNULL,
        )
    except subprocess.CalledProcessError:
        return None
    try:
        return plistlib.loads(raw)
    except Exception:
        return None


def _is_ad_hoc(pl: dict) -> bool:
    ent = pl.get("Entitlements") or {}
    if ent.get("get-task-allow", False):
        return False
    devices = pl.get("ProvisionedDevices") or []
    if not devices:
        return False
    if pl.get("ProvisionsAllDevices"):
        return False
    return True


def _bundle_from_application_identifier(appid: str) -> str | None:
    appid = appid.strip()
    if not appid:
        return None
    parts = appid.split(".", 1)
    if len(parts) == 2 and len(parts[0]) == 10 and parts[0].isalnum():
        return parts[1]
    return appid


def _matches_bundle(pl: dict, bundle: str) -> bool:
    ent = pl.get("Entitlements") or {}
    appid = ent.get("application-identifier") or ""
    if isinstance(appid, bytes):
        appid = appid.decode("utf-8", errors="replace")
    bid = _bundle_from_application_identifier(appid)
    if not bid:
        return False
    if bid == bundle:
        return True
    if bid.endswith(".*") and bundle.startswith(bid[:-2]):
        return True
    return appid.endswith("." + bundle)


def find_ad_hoc_profile_name() -> str:
    candidates: list[tuple[Path, dict]] = []
    for path in _iter_mobileprovisions():
        pl = _decode_provision(path)
        if not pl:
            continue
        if not _matches_bundle(pl, BUNDLE_ID):
            continue
        if not _is_ad_hoc(pl):
            continue
        candidates.append((path, pl))

    if not candidates:
        roots = _profile_search_roots()
        print(
            f"No Ad Hoc .mobileprovision found for {BUNDLE_ID}.\n"
            f"Searched: {', '.join(str(r) for r in roots)} + ios/ tree.\n"
            "If fetch-signing-files failed, verify APP_STORE_CONNECT_* env vars and API key role (App Manager+).\n"
            "For --create, add CERTIFICATE_PRIVATE_KEY in Codemagic when Apple must mint a new distribution certificate.",
            file=sys.stderr,
        )
        sys.exit(1)

    def sort_key(item: tuple[Path, dict]):
        pl = item[1]
        return pl.get("CreationDate") or pl.get("Name") or ""

    candidates.sort(key=sort_key, reverse=True)
    best_path, best_pl = candidates[0]
    name = best_pl.get("Name")
    if not name or not isinstance(name, str):
        print(f"Profile at {best_path} has no Name field", file=sys.stderr)
        sys.exit(1)
    print(f"Using provisioning profile: {name!r} ({best_path.name})")
    return name


def pbxproj_escape_value(s: str) -> str:
    return s.replace("\\", "\\\\").replace('"', '\\"')


def inject(pbx: str, profile_name: str) -> str:
    needle = (
        '\t\t\t\tCODE_SIGN_STYLE = Manual;\n'
        '\t\t\t\t"CODE_SIGN_IDENTITY[sdk=iphoneos*]" = "iPhone Distribution";\n'
    )
    repl = (
        '\t\t\t\tCODE_SIGN_STYLE = Manual;\n'
        f'\t\t\t\tPROVISIONING_PROFILE_SPECIFIER = "{pbxproj_escape_value(profile_name)}";\n'
        '\t\t\t\t"CODE_SIGN_IDENTITY[sdk=iphoneos*]" = "Apple Distribution";\n'
    )
    if needle not in pbx:
        if "PROVISIONING_PROFILE_SPECIFIER" in pbx and "Release-dev" in pbx:
            print("PROVISIONING_PROFILE_SPECIFIER already present; skipping inject.")
            return pbx
        print(
            "Expected Manual+iPhone Distribution block not found in project.pbxproj",
            file=sys.stderr,
        )
        sys.exit(1)
    count = pbx.count(needle)
    if count != 2:
        print(
            f"Expected exactly 2 Manual+iPhone Distribution blocks (Release-dev + Profile-dev), found {count}",
            file=sys.stderr,
        )
        sys.exit(1)
    return pbx.replace(needle, repl)


def main() -> None:
    name = find_ad_hoc_profile_name()
    text = PBXPROJ.read_text(encoding="utf-8")
    new_text = inject(text, name)
    PBXPROJ.write_text(new_text, encoding="utf-8")
    print(f"Updated {PBXPROJ}")


if __name__ == "__main__":
    main()
