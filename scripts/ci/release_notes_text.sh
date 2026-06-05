#!/usr/bin/env bash
# Release notes for Firebase App Distribution and TestFlight (en-US).
set -euo pipefail
jq -r '.[] | select(.language == "en-US") | .text' release_notes.json
