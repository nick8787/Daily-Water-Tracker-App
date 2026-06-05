#!/usr/bin/env bash
# Template: copy and replace placeholders, or run directly with real values.
# Example:
#   sh scripts/configure_envs_dev.sh
sh "$(dirname "$0")/configure_envs.sh" {flavor} {firebase_project_id} {android_package_name} {ios_bundle_id}
