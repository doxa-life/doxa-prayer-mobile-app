# Apple Watch companion

A watchOS app for doing the daily prayer on the wrist: a reminder arrives, the
watch opens straight into that people group's prayer, the user pages through it
section by section, taps Amen and gets on with their day.

Work happens on the `apple-watch-companion` branch. **Nothing here may change
how the iPhone app builds or behaves**, and all of it must be removable (see
[Removing the watch app](#removing-the-watch-app)).

## Decisions

| Topic | Decision |
|---|---|
| Platform | Apple Watch first, native SwiftUI. Flutter cannot target watchOS. Kept portable so a Wear OS app can follow (see [Wear OS later](#wear-os-later)). |
| Minimum OS | watchOS 10 (Series 4 and newer). |
| Connectivity | Fully independent: the watch calls the prayer API itself over Wi-Fi or cellular, and prefetches today and tomorrow so it works offline. The phone only sends settings. |
| Several groups | Opening from a notification goes straight to that group. Opening the app directly lists today's groups with a check mark on each one prayed for. |
| Content | The entire prayer, split into sections the way the app splits it, one card per section. |
| First release | Notification → cards → Amen, plus a complication/Smart Stack widget, a haptic on each new card, smooth transitions between cards, a progress bar along the bottom, and an animated check mark when the prayer is finished. |
| Later | Guided auto-advance, Handoff to iPhone, Wear OS. |
| Backend | No changes for now; see [Proposed backend changes](#proposed-backend-changes). |

## What's set up

- `ios/DoxaWatch/`: the watch app (a placeholder screen for now), its asset
  catalog (each flavor's icon, copied from Runner's 1024px icons) and
  `DoxaWatch.xcconfig`, which takes the version from `pubspec.yaml` so the
  watch app always matches the iPhone app.
- A `DoxaWatch` target in `Runner.xcodeproj` with all six configurations
  (`Debug|Release|Profile` × `staging|production`) and shared schemes
  `DoxaWatch-staging` and `DoxaWatch-production`.
  - Bundle IDs: `life.doxa.pray.watchkitapp` and
    `life.doxa.pray.staging.watchkitapp`.
  - Automatic signing for development. Release signing comes with embedding.
- `ios/scripts/watch/add_watch_target.rb` and `remove_watch_target.rb`, which
  add and remove the target. They use the `xcodeproj` gem that CocoaPods
  installs.

The target is **not** a dependency of Runner and is **not** embedded in it, so
`flutter build`, fastlane and the App Store build are unchanged.

### Building and running

```bash
cd ios
xcodebuild -project Runner.xcodeproj -scheme DoxaWatch-staging \
  -destination 'generic/platform=watchOS Simulator' CODE_SIGNING_ALLOWED=NO build
```

To run it, open `ios/Runner.xcworkspace`, pick the `DoxaWatch-staging` scheme
and a watch simulator. If no watch simulator is listed, install the watchOS
platform from Xcode › Settings › Components.

## Keeping the iPhone app safe

**Don't add `WKCompanionAppBundleIdentifier` to the project yet.** If that
string appears anywhere in `project.pbxproj`, `flutter build ios` treats the
project as having a watch companion and changes the `xcodebuild` arguments for
*every* iPhone build: it drops `-sdk` and `ARCHS`, and simulator builds fail
without `-d <device id>`. The key goes in during the embedding step, when the
watch app really ships inside Runner (see [Build order](#build-order) step 7).

Every change to the main app's files is listed here, so removal is never
guesswork:

| File | Change | Phase |
|---|---|---|
| `ios/Runner.xcodeproj/project.pbxproj` | `DoxaWatch` target, group and product added. Xcode-style resaving also reorders two build settings in Runner's Release configs alphabetically; their values don't change. | Setup |
| `ios/Runner.xcodeproj/xcshareddata/xcschemes/DoxaWatch-*.xcscheme` | New files | Setup |
| `ios/Runner/WatchBridge.swift` | New: sends settings to the watch | Planned |
| `ios/Runner/AppDelegate.swift` | One line to start `WatchBridge` | Planned |
| `ios/fastlane/Fastfile`, `Matchfile` | Watch bundle IDs added to signing | Planned (embedding) |
| `ios/Runner/AppDelegate.swift`, `lib/services/reminders_notifications.dart` | "Pray now" notification action | Phase 2, its own commit |
| History sync back to the phone | To be designed | Phase 2, its own commit |

## Removing the watch app

Before it's merged, just don't merge the branch. After it's merged:

```bash
cd ios
ruby scripts/watch/remove_watch_target.rb   # target, group, product, schemes
rm -rf DoxaWatch scripts/watch
```

Then revert the one-line `AppDelegate.swift` hook, delete `WatchBridge.swift`,
take the watch bundle IDs out of fastlane, and delete this file. The table
above lists everything. The remove script has been tested: running add and
then remove leaves the project as it was, apart from the alphabetical
reordering noted above.

## Build order

1. **Setup.** Done: target, schemes, icons, versioning, add/remove scripts.
2. **Models and API client.** Swift `Codable` types matching
   `lib/models/prayer_content.dart`, a client for
   `GET /api/people-groups/{slug}/prayer-content/{date}?language=`, and a
   disk cache. Use `docs/sample-prayer-api-output.json` as the first test file.
3. **Card splitting.** Turn the content blocks into cards, following the
   rules in [Card splitting](#card-splitting) and covered by the shared test
   files.
4. **Prayer flow.** Vertical card paging (`TabView(.verticalPage)`) with the
   Digital Crown, a custom progress bar along the bottom, smooth transitions,
   a haptic on each new card, the Amen card, the check-mark animation, the
   thank-you verse and the copyright notices.
5. **Session reporting.** Copy `PrayerSessionView`: one session ID for the
   whole prayer, pings every 60s for up to 15 min, the same minimum duration,
   and `track_event` only on Amen.
6. **Settings bridge.** `WatchBridge.swift` reads subscribed groups, language
   and `tracking_id` from the `UserDefaults` keys that `shared_preferences`
   already writes (`flutter.`-prefixed) and sends them with WatchConnectivity
   `updateApplicationContext`. No Dart changes. It does nothing if no watch
   is paired.
7. **Embedding.** Add `WKCompanionAppBundleIdentifier`, an "Embed Watch
   Content" phase and a dependency to Runner. Create the two App IDs in the
   developer portal, add them to match and the Fastfile `bundle_ids`, then
   check `flutter run -d <simulator>` and a release archive.
8. **Complication and Smart Stack widget.** WidgetKit extension showing today's
   group and a check mark once prayed for.
9. **Localization.** Generate the watch's String Catalog from the ARB files,
   check Arabic (right-to-left) layout, and add the watch to the
   `add-language` / `sync-language` skills.
10. **Phase 2.** "Pray now" notification action, history sync back to the
    phone.

## Card splitting

The rules live in this document so the watchOS and Wear OS apps (and the
backend, if it ever takes this over) split the prayer identically. Shared test
files (`fixtures/<name>.json` with the API response, `fixtures/<name>.cards.json`
with the expected cards) check each implementation.

Rules to settle during step 3, starting from how the phone renders
(`lib/components/prayer_content/`):

- One intro card per people group block (photo, name, country, population).
- A `heading` starts a new card. The paragraphs after it stay with it.
- A `verse` node gets its own card in verse styling.
- `hardBreak` stays a line break inside a card.
- Very long sections are split at paragraph boundaries.
- The final card holds Amen. The copyright notices come after it and are
  always shown.

## Proposed backend changes

These need approval from the backend owners. Neither is required for the first
release.

1. **An endpoint that returns the prayer already split into cards**, e.g.
   `GET /api/people-groups/{slug}/prayer-content/{date}/sections`.
   *Why:* the splitting rules would live in one place instead of being written
   in Swift, again in Kotlin or Dart for Wear OS, and possibly again for the
   phone. Changing how prayers are split would no longer need app releases.
2. **A `source` field on prayer sessions** (`"watch"`, `"ios"`, `"android"`,
   `"web"`) on `POST …/session`.
   *Why:* without it, watch prayers can't be told apart from phone prayers, so
   there's no way to know whether the watch app is used or worth maintaining.

## Wear OS later

Wear OS is Android, so Flutter runs there (with `wear_plus` for round screens
and ambient mode), but tiles, complications and notification actions still
need Kotlin. What carries over from the watchOS work: the API contract, the
card-splitting rules and test files, the session-reporting rules, and the
interface strings generated from the ARB files.
