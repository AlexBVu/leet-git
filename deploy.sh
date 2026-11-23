#!/bin/bash
# Build LeetGit ad-hoc-signed and deploy the widget to the desktop.
# Run this after any code change instead of Xcode's ⌘R — the desktop widget
# runs from /Applications, which Xcode never updates.
#
#   ./deploy.sh
#
# Then, if the on-screen widget doesn't refresh on its own, remove and re-add it
# (right-click desktop -> Edit Widgets -> LeetGit).
set -euo pipefail
cd "$(dirname "$0")"

LSREG=/System/Library/Frameworks/CoreServices.framework/Versions/A/Frameworks/LaunchServices.framework/Versions/A/Support/lsregister

command -v xcodegen >/dev/null || { echo "Installing xcodegen…"; brew install xcodegen; }
[ -d LeetGit.xcodeproj ] || xcodegen generate

# pluginkit/chronod cache a widget extension's metadata (supported sizes, intent
# parameters) per bundle-id + version. Shipping the same "1.0" every time means
# supportedFamilies changes are ignored no matter how often you re-add the
# widget. Stamp a fresh version on every deploy so the caches are forced to drop.
STAMP=$(date +%s)

echo "Building (ad-hoc signed, version 1.0.$STAMP)…"
xcodebuild -project LeetGit.xcodeproj -scheme LeetGit -configuration Debug -destination 'platform=macOS' \
  CODE_SIGN_STYLE=Manual DEVELOPMENT_TEAM="" CODE_SIGN_IDENTITY="-" PROVISIONING_PROFILE_SPECIFIER="" \
  MARKETING_VERSION="1.0.$STAMP" CURRENT_PROJECT_VERSION="$STAMP" \
  CODE_SIGNING_REQUIRED=YES CODE_SIGNING_ALLOWED=YES build >/tmp/leetgit-build.log 2>&1 \
  || { echo "BUILD FAILED — tail of /tmp/leetgit-build.log:"; tail -25 /tmp/leetgit-build.log; exit 1; }

built=$(find "$HOME/Library/Developer/Xcode/DerivedData/LeetGit-"*/Build/Products/Debug \
  -maxdepth 1 -name LeetGit.app -type d 2>/dev/null | head -1)
[ -n "$built" ] || { echo "Could not locate built LeetGit.app"; exit 1; }

appex=/Applications/LeetGit.app/Contents/PlugIns/LeetGitWidget.appex
built_appex="$built/Contents/PlugIns/LeetGitWidget.appex"

echo "Deploying to /Applications…"
killall LeetGit 2>/dev/null || true
pluginkit -r "$built_appex" 2>/dev/null || true  # don't leave the DerivedData copy registered
pluginkit -r "$appex" 2>/dev/null || true         # drop the old extension record
rm -rf /Applications/LeetGit.app
ditto "$built" /Applications/LeetGit.app          # ditto preserves the code signature; cp -R breaks it

codesign -v /Applications/LeetGit.app || { echo "Signature invalid after copy"; exit 1; }

# The DerivedData copy registers the same bundle ids; drop it so the system has
# exactly one LeetGit to resolve.
"$LSREG" -u "$built" 2>/dev/null || true
"$LSREG" -f /Applications/LeetGit.app
pluginkit -a "$appex" 2>/dev/null || true
open /Applications/LeetGit.app
sleep 2
killall LeetGitWidget 2>/dev/null || true         # drop the old widget extension process
killall -9 chronod 2>/dev/null || true            # force the widget gallery to re-scan

echo "✅ Deployed as 1.0.$STAMP. Registered:"
pluginkit -m -i com.leetgit.app.widget 2>/dev/null || true
echo "   Remove & re-add the widget on the desktop to pick up size/layout changes."
