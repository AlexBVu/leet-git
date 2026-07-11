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

echo "Building (ad-hoc signed)…"
xcodebuild -project LeetGit.xcodeproj -scheme LeetGit -configuration Debug -destination 'platform=macOS' \
  CODE_SIGN_STYLE=Manual DEVELOPMENT_TEAM="" CODE_SIGN_IDENTITY="-" PROVISIONING_PROFILE_SPECIFIER="" \
  CODE_SIGNING_REQUIRED=YES CODE_SIGNING_ALLOWED=YES build >/tmp/leetgit-build.log 2>&1 \
  || { echo "BUILD FAILED — tail of /tmp/leetgit-build.log:"; tail -25 /tmp/leetgit-build.log; exit 1; }

built=$(find "$HOME/Library/Developer/Xcode/DerivedData/LeetGit-"*/Build/Products/Debug \
  -maxdepth 1 -name LeetGit.app -type d 2>/dev/null | head -1)
[ -n "$built" ] || { echo "Could not locate built LeetGit.app"; exit 1; }

echo "Deploying to /Applications…"
killall LeetGit 2>/dev/null || true
rm -rf /Applications/LeetGit.app
ditto "$built" /Applications/LeetGit.app          # ditto preserves the code signature; cp -R breaks it

codesign -v /Applications/LeetGit.app || { echo "Signature invalid after copy"; exit 1; }

"$LSREG" -f /Applications/LeetGit.app
open /Applications/LeetGit.app
sleep 2
killall chronod 2>/dev/null || true               # force the widget gallery to re-scan

echo "✅ Deployed. If the widget didn't refresh, remove & re-add it on the desktop."
