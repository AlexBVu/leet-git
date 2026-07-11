# LeetGit

A macOS widget that shows your LeetCode submissions as a GitHub-style green
contribution graph. Pulls from LeetCode's public API (no login) using just your
username. Username and history range are set right on the widget.

## Build & run

Requires Xcode and [XcodeGen](https://github.com/yonyz/XcodeGen).

```sh
brew install xcodegen        # one time
xcodegen generate            # project.yml -> LeetGit.xcodeproj
open LeetGit.xcodeproj
```

In Xcode:

1. **LeetGit** target → **Signing & Capabilities** → set your Team. A **free**
   personal Apple ID works (the widget uses only app-sandbox + network-client,
   no restricted entitlements). Do the same for **LeetGitWidget**. If your Apple
   ID isn't listed, add it under Xcode → Settings → Accounts.
2. **Run** (⌘R) once — this installs the widget. The host app just shows a
   reminder of where to configure things.
3. Add the widget: right-click the desktop (or open Notification Center) →
   **Edit Widgets** → find **LeetCode Activity** → add the medium (or large) size.
4. **Right-click the widget → Edit Widget** → type your LeetCode username and
   pick a history range.

The widget refreshes itself roughly every 15 minutes (WidgetKit throttles this
system-side, so it's a request, not a promise).

## Updating after a code change

Xcode's ⌘R does **not** update the desktop widget — that runs from
`/Applications/LeetGit.app`. After changing code, run:

```sh
./deploy.sh
```

It builds ad-hoc-signed, copies to `/Applications` with `ditto` (preserves the
signature — `cp -R` breaks it), re-registers, and restarts the widget daemon. If
the on-screen widget doesn't refresh, remove and re-add it.

## Ranges

Last month / 3 months / 6 months / last year — all sliced from LeetCode's
trailing-year data. (No "all time"; that would need older per-year fetches.)

## Changing bundle IDs

If `com.leetgit.*` clashes with something you own, edit the IDs in `project.yml`
(`bundleIdPrefix`, both `PRODUCT_BUNDLE_IDENTIFIER`s) and re-run `xcodegen generate`.

## Layout

```
project.yml              XcodeGen spec (app + widget targets)
Shared/                  compiled into BOTH targets
  HistoryRange.swift       range presets (an App Intents enum)
  LeetCodeAPI.swift        async GraphQL fetch -> [Date: Int]
  ContributionData.swift   Day (level bucketing) + ContributionGrid.build()
App/                     minimal SwiftUI host app (required shell for the widget)
Widget/                  WidgetKit extension: config intent + Provider + grid view
```
