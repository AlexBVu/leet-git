# LeetGit

A macOS widget that shows your LeetCode submissions as a GitHub-style green
contribution graph. Pulls from LeetCode's public API (no login) using just your
username. Comes with a tiny host app to set the username and history range.

![medium widget: a grid of green cells with month + weekday labels]

## Build & run

Requires Xcode and [XcodeGen](https://github.com/yonyz/XcodeGen).

```sh
brew install xcodegen        # one time
xcodegen generate            # project.yml -> LeetGit.xcodeproj
open LeetGit.xcodeproj
```

In Xcode:

1. Select the **LeetGit** target → **Signing & Capabilities** → set your Team
   (a free personal Apple ID works). Do the same for **LeetGitWidget**.
2. **Run** (⌘R) once. The host app launches — type your LeetCode username, pick a
   range, done. This also installs the widget extension.
3. Add the widget: right-click the desktop (or open Notification Center) →
   **Edit Widgets** → find **LeetCode Activity** → add the medium (or large) size.

The widget refreshes itself roughly every 15 minutes (WidgetKit throttles this
system-side, so it's a request, not a promise). Changing username/range in the
app refreshes it immediately.

## Ranges

Last month / 3 months / 6 months / last year — all sliced from LeetCode's
trailing-year data. (No "all time"; that would need older per-year fetches.)

## App Group signing note

Both targets share config through the App Group `group.com.leetgit`. On a **free**
personal Apple ID this usually provisions fine for a locally-run build, but if
Xcode complains it can't create the App Group:

- Easiest fix: hardcode your username. In `Shared/AppGroup.swift`, make
  `username` return a literal, and remove the
  `com.apple.security.application-groups` block from both `.entitlements` files.
  The host app becomes decorative but the widget works.

## Changing bundle IDs

If `com.leetgit.*` clashes with something you own, edit the three IDs in
`project.yml` (`bundleIdPrefix`, both `PRODUCT_BUNDLE_IDENTIFIER`s) and the group
id in `Shared/AppGroup.swift` + both `.entitlements` files, then re-run
`xcodegen generate`.

## Layout

```
project.yml              XcodeGen spec (app + widget targets, App Group)
Shared/                  compiled into BOTH targets
  AppGroup.swift           shared config store + HistoryRange
  LeetCodeAPI.swift        async GraphQL fetch -> [Date: Int]
  ContributionData.swift   Day (level bucketing) + ContributionGrid.build()
App/                     SwiftUI host app (username + range)
Widget/                  WidgetKit extension (Provider + grid view)
```
