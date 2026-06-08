#!/usr/bin/env bash
# Firebase password-reset emails use the Action URL from the Console template,
# NOT from ActionCodeSettings in the app (that only sets continueUrl).
#
# Run this script for a reminder, then set the URL manually in Console.

set -euo pipefail

DEV_URL="https://dailywatertracker-app-dev.web.app/__/auth/action"
PROD_URL="https://dailywatertracker-app-prod.web.app/__/auth/action"

cat <<EOF
Configure Firebase Auth email Action URL (password reset emails)

DEV project:  dailywatertracker-app-dev
  Console: https://console.firebase.google.com/project/dailywatertracker-app-dev/authentication/emails
  Action URL: $DEV_URL

PROD project: dailywatertracker-app-prod
  Console: https://console.firebase.google.com/project/dailywatertracker-app-prod/authentication/emails
  Action URL: $PROD_URL

Steps (repeat for DEV and PROD):
  1. Authentication → Templates → Password reset → pencil icon
  2. Scroll down → "Customize action URL"
  3. Paste the Action URL above → Save

Custom /password-reset page in browser requires Console to accept that path
(currently blocked with EMAIL_TEMPLATE_UPDATE_NOT_ALLOWED on web.app).
The /password-reset Hosting page still works for direct links and mobile deep links.

Verify hosting page (no email needed):
  https://dailywatertracker-app-dev.web.app/password-reset
  https://dailywatertracker-app-prod.web.app/password-reset
EOF
