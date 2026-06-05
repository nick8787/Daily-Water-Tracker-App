#!/usr/bin/env python3
"""
Pin the fetched .mobileprovision UUID into flavor Xcode configs (Release-dev,
Release-prod, Profile-dev, Profile-prod).

Called by ios/ci/setup_codemagic_signing.sh after fetch-signing-files.

Environment:
  CM_BUNDLE_ID     — default com.dailywatertracker.app.dev
  CM_PROFILE_KIND  — development (default) | adhoc | appstore
"""

from __future__ import annotations

import os
import plistlib
import subprocess
import sys
from pathlib import Path


PBXPROJ = Path(__file__).resolve().parents[1] / "Runner.xcodeproj" / "project.pbxproj"


def bundle_id() -> str:
    return os.environ.get("CM_BUNDLE_ID", "com.dailywatertracker.app.dev").strip()


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


def _is_development(pl: dict) -> bool:
    ent = pl.get("Entitlements") or {}
    return ent.get("get-task-allow", False) is True


def _is_app_store(pl: dict) -> bool:
    ent = pl.get("Entitlements") or {}
    if ent.get("get-task-allow", False):
        return False
    if pl.get("ProvisionedDevices"):
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


def find_profile(profile_kind: str, bundle: str) -> tuple[str, str]:
    matchers = {
        "development": _is_development,
        "adhoc": _is_ad_hoc,
        "appstore": _is_app_store,
    }
    labels = {
        "development": "Development",
        "adhoc": "Ad Hoc",
        "appstore": "App Store",
    }
    matcher = matchers[profile_kind]
    label = labels[profile_kind]

    candidates: list[tuple[Path, dict]] = []
    for path in _iter_mobileprovisions():
        pl = _decode_provision(path)
        if not pl:
            continue
        if not _matches_bundle(pl, bundle):
            continue
        if not matcher(pl):
            continue
        candidates.append((path, pl))

    if not candidates:
        roots = _profile_search_roots()
        print(
            f"No {label} .mobileprovision found for {bundle}.\n"
            f"Searched: {', '.join(str(r) for r in roots)} + ios/ tree.\n"
            "If fetch-signing-files failed, verify codemagic_api_key and App ID capabilities.",
            file=sys.stderr,
        )
        sys.exit(1)

    candidates.sort(
        key=lambda item: item[1].get("CreationDate") or item[1].get("Name") or "",
        reverse=True,
    )
    best_path, best_pl = candidates[0]
    name = best_pl.get("Name")
    if not name or not isinstance(name, str):
        print(f"Profile at {best_path} has no Name field", file=sys.stderr)
        sys.exit(1)
    profile_uuid = best_path.stem
    print(f"Using {label.lower()} profile: {name!r} ({profile_uuid})")
    return profile_uuid, name


def pbxproj_escape_value(s: str) -> str:
    return s.replace("\\", "\\\\").replace('"', '\\"')


def inject_development(pbx: str, profile_uuid: str, bundle: str) -> str:
    needle = (
        '\t\t\t\tCODE_SIGN_STYLE = Manual;\n'
        '\t\t\t\t"CODE_SIGN_IDENTITY[sdk=iphoneos*]" = "iPhone Developer";\n'
    )
    repl = (
        '\t\t\t\tCODE_SIGN_STYLE = Manual;\n'
        f'\t\t\t\tPROVISIONING_PROFILE = "{pbxproj_escape_value(profile_uuid)}";\n'
        '\t\t\t\t"CODE_SIGN_IDENTITY[sdk=iphoneos*]" = "iPhone Developer";\n'
    )
    if needle not in pbx:
        if "PROVISIONING_PROFILE" in pbx and bundle in pbx:
            print("PROVISIONING_PROFILE already present; skipping inject.")
            return pbx
        print(
            "Expected Manual+iPhone Developer block not found in project.pbxproj",
            file=sys.stderr,
        )
        sys.exit(1)
    count = pbx.count(needle)
    if count != 2:
        print(
            f"Expected exactly 2 Manual+iPhone Developer blocks for {bundle}, found {count}",
            file=sys.stderr,
        )
        sys.exit(1)
    return pbx.replace(needle, repl)


def inject_distribution(pbx: str, profile_uuid: str, bundle: str) -> str:
    needle = (
        '\t\t\t\t"CODE_SIGN_IDENTITY[sdk=iphoneos*]" = "iPhone Distribution";\n'
        '\t\t\t\tCODE_SIGN_STYLE = Manual;\n'
    )
    repl = (
        '\t\t\t\t"CODE_SIGN_IDENTITY[sdk=iphoneos*]" = "iPhone Distribution";\n'
        '\t\t\t\tCODE_SIGN_STYLE = Manual;\n'
        f'\t\t\t\tPROVISIONING_PROFILE = "{pbxproj_escape_value(profile_uuid)}";\n'
    )
    if needle not in pbx:
        if "PROVISIONING_PROFILE" in pbx and bundle in pbx:
            print("PROVISIONING_PROFILE already present; skipping inject.")
            return pbx
        print(
            "Expected Manual+iPhone Distribution block not found in project.pbxproj",
            file=sys.stderr,
        )
        sys.exit(1)
    count = pbx.count(needle)
    if count != 2:
        print(
            f"Expected exactly 2 Manual+iPhone Distribution blocks for {bundle}, found {count}",
            file=sys.stderr,
        )
        sys.exit(1)
    return pbx.replace(needle, repl)


def main() -> None:
    profile_kind = os.environ.get("CM_PROFILE_KIND", "development").strip().lower()
    bundle = bundle_id()
    if profile_kind not in {"development", "adhoc", "appstore"}:
        print(f"Unsupported CM_PROFILE_KIND={profile_kind!r}", file=sys.stderr)
        sys.exit(1)

    profile_uuid, _ = find_profile(profile_kind, bundle)
    text = PBXPROJ.read_text(encoding="utf-8")
    if profile_kind == "development":
        new_text = inject_development(text, profile_uuid, bundle)
    else:
        new_text = inject_distribution(text, profile_uuid, bundle)
    PBXPROJ.write_text(new_text, encoding="utf-8")
    print(f"Updated {PBXPROJ} for {bundle} ({profile_kind})")


if __name__ == "__main__":
    main()
