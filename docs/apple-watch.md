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

## Status: working prototype

What works today, tested in the watchOS simulator against the live API:

- **Home:** today's groups with photos and a check mark once prayed for, plus
  "Add another people group" (up to 5, as on the phone) and Settings. Swipe a
  row to remove it.
- **Group picker:** the full list from `/api/people-groups/list`, searchable.
- **Prayer:** one card per section, paged with the Digital Crown or a swipe,
  with a blur transition, a light haptic on each new card and a progress bar
  along the bottom. Cards: intro (photo, "Pray for the …"), Day in the Life,
  each themed section (heading, Scripture in the green verse block with
  superscript verse numbers, prayer, "Pause & Pray"), People Group of the Day,
  and Amen with the Scripture copyright notices.
- **Amen:** an animated check mark, "Thank you for praying" and the next
  thank-you verse from the phone's own `assets/thank_you_verses.json`.
- **Session reporting** with the phone's rules (see `PrayerSession.swift`).
  Like the phone, debug builds log the report instead of sending it.
- **Offline:** prayer content is cached on disk; today's and tomorrow's are
  downloaded on launch and by background refresh.
- **Reminders:** a daily reminder (Settings) whose tap opens the group's
  prayer. The tap handler also understands the phone's reminder payloads and
  OneSignal pushes, ready for when those reach the watch.
- **Complication / Smart Stack widget** (circular, rectangular, inline,
  corner): who to pray for next, or a check mark once everyone is prayed for.
  Tapping it opens that prayer.
- **12 languages**, right-to-left included. Interface strings come from the
  ARB files; the server sends content in the watch's language.

### Prototype-only pieces

These stand in for parts that need the main app and go away at embedding:

- **People groups are chosen on the watch.** Later they come from the phone
  through the settings bridge (build order step 6), along with the in-app
  language and the anon-signup `tracking_id`. Until then reports send an empty
  `tracking_id`, like a phone that hasn't signed up.
- **The watch schedules its own reminder.** Later the phone's reminders reach
  the watch instead; keeping both would remind people twice.
- **`WKWatchOnly = YES`.** watchOS requires either this or a companion id, and
  the companion id can't go in yet (see
  [Keeping the iPhone app safe](#keeping-the-iphone-app-safe)).

### Not verified yet

- **Tapping a real notification.** The simulator can't grant notification
  permission without a tap on "Allow". The routing it triggers is tested
  (`-demoNotification`); try it by hand with Settings › Send test reminder.
- **The complication on a watch face.** It builds, is embedded, and reads the
  shared state (checked in the App Group container), but hasn't been looked
  at on a face. Add it with a long press on the face › Edit › Complications.
- **A real watch.** Needs the App IDs and App Group registered in the
  developer portal (build order step 7).
- **No automated tests yet**, including the card-splitting test files
  described below.

## How it's built

```
ios/DoxaWatch/            the watch app
  App/                    entry point, app state (AppModel), notifications
  Models/                 API types (mirroring lib/models/), cards
  Services/               API + disk cache, session reporting, reminders, verses
  Shared/                 compiled into the app and the widget (App Group store)
  Views/                  home, picker, settings, prayer, cards, Amen
  Localizable.xcstrings   generated from the ARB files, don't edit by hand
  DoxaWatch.xcconfig      version from pubspec.yaml
ios/DoxaWatchWidgets/     the complication / Smart Stack widget extension
ios/scripts/watch/        add/remove the targets, generate the strings
```

- Targets `DoxaWatch` (app) and `DoxaWatchWidgets` (embedded in the watch app,
  not in Runner), with all six configurations and schemes `DoxaWatch-staging`
  and `DoxaWatch-production`.
- Bundle IDs: `life.doxa.pray[.staging].watchkitapp` and
  `….watchkitapp.widgets`. App Group: `group.life.doxa.pray[.staging].watch`.
- The staging scheme talks to the staging server, production to
  `pray.doxa.life` (the `STAGING` compilation condition).
- Automatic signing for development. Release signing comes with embedding.

**Adding or removing files** under `DoxaWatch/` or `DoxaWatchWidgets/`:
re-run the scripts, which pick files up by folder.

```bash
cd ios
ruby scripts/watch/remove_watch_target.rb && ruby scripts/watch/add_watch_target.rb
```

**After changing ARB files**, regenerate the strings. The `add-language` /
`sync-language` skills should do this once the watch app ships.

```bash
python3 ios/scripts/watch/generate_strings.py
```

Strings the watch reuses from the ARB files are translated in every language.
Watch-only strings (`WATCH_ONLY` in the script) are English until they're
reviewed against the glossary, and fall back to English in other languages.

### Building and running

Open `ios/Runner.xcworkspace`, pick the `DoxaWatch-staging` scheme and a watch
simulator, and run. From the command line:

```bash
cd ios
xcodebuild -project Runner.xcodeproj -scheme DoxaWatch-staging \
  -destination 'generic/platform=watchOS Simulator' build
```

Debug builds accept launch arguments for trying screens without tapping
through them (Xcode › Edit Scheme › Arguments, or `xcrun simctl launch`):

| Argument | Effect |
|---|---|
| `-demoGroups abai-sungai,negev-bedouins` | Sets the groups prayed for |
| `-demoOpen abai-sungai` | Opens that group's prayer |
| `-demoCard 3` | Starts the prayer on card 3 |
| `-demoAmen YES` | Taps Amen as soon as the prayer loads |
| `-demoRoute picker` / `settings` | Opens that screen |
| `-demoNotification <slug or pray>` | Routes as if a reminder with that payload was tapped |
| `-AppleLanguages "(ar)"` | Runs in another language (standard iOS argument) |

## Keeping the iPhone app safe

**Don't add `WKCompanionAppBundleIdentifier` to the project yet.** If that
string appears anywhere in `project.pbxproj`, `flutter build ios` treats the
project as having a watch companion and changes the `xcodebuild` arguments for
*every* iPhone build: it drops `-sdk` and `ARCHS`, and simulator builds fail
without `-d <device id>`. The key goes in during the embedding step, when the
watch app really ships inside Runner (see [Build order](#build-order) step 7).

Checked on this branch: `flutter build ios --simulator --flavor staging` builds
exactly as before, and `Runner.app` contains no watch app.

Every change to the main app's files is listed here, so removal is never
guesswork:

| File | Change | Phase |
|---|---|---|
| `ios/Runner.xcodeproj/project.pbxproj` | `DoxaWatch` and `DoxaWatchWidgets` targets, groups and products added. Xcode-style resaving also reorders two build settings in Runner's Release configs alphabetically; their values don't change. | Setup |
| `ios/Runner.xcodeproj/xcshareddata/xcschemes/DoxaWatch-*.xcscheme` | New files | Setup |
| `ios/Runner/WatchBridge.swift` | New: sends settings to the watch | Planned |
| `ios/Runner/AppDelegate.swift` | One line to start `WatchBridge` | Planned |
| `ios/fastlane/Fastfile`, `Matchfile` | Watch bundle IDs added to signing | Planned (embedding) |
| `ios/Runner/AppDelegate.swift`, `lib/services/reminders_notifications.dart` | "Pray now" notification action | Phase 2, its own commit |
| History sync back to the phone | To be designed | Phase 2, its own commit |

The watch app reads `assets/thank_you_verses.json` by reference but never
changes it.

## Removing the watch app

Before it's merged, just don't merge the branch. After it's merged:

```bash
cd ios
ruby scripts/watch/remove_watch_target.rb   # targets, groups, products, schemes
rm -rf DoxaWatch DoxaWatchWidgets scripts/watch
```

Then revert the one-line `AppDelegate.swift` hook, delete `WatchBridge.swift`,
take the watch bundle IDs out of fastlane, and delete this file. The table
above lists everything. The remove script is tested: after running it, the
project matches `master` apart from the alphabetical reordering noted above.

## Build order

1. **Setup.** Done.
2. **Models and API client.** Done.
3. **Card splitting.** Done; test files still to write (see below).
4. **Prayer flow.** Done.
5. **Session reporting.** Done.
6. **Settings bridge.** `WatchBridge.swift` reads subscribed groups, language
   and `tracking_id` from the `UserDefaults` keys that `shared_preferences`
   already writes (`flutter.`-prefixed) and sends them with WatchConnectivity
   `updateApplicationContext`. No Dart changes. It does nothing if no watch
   is paired. The watch then drops its own picker and reminder.
7. **Embedding.** Swap `WKWatchOnly` for `WKCompanionAppBundleIdentifier` +
   `WKRunsIndependentlyOfCompanionApp`, add an "Embed Watch Content" phase and
   a dependency to Runner. Register the App IDs and the App Group in the
   developer portal, add the bundle IDs to match and the Fastfile
   `bundle_ids`, then check `flutter run -d <simulator>` and a release archive.
8. **Complication and Smart Stack widget.** Done; to be checked on a face.
9. **Localization.** Done for existing strings; watch-only strings need
   translation review, and the language skills need to run the generator.
10. **Phase 2.** "Pray now" notification action, history sync back to the
    phone.

## Card splitting

The rules live here so the watchOS and Wear OS apps (and the backend, if it
ever takes this over) split the prayer identically. They follow how the phone
renders the prayer (`lib/components/prayer_content/`), where each block is its
own section. Implemented in `ios/DoxaWatch/Models/PrayerCards.swift`.

- One card per content block, in the order the API returns them.
- `people_group` id -1 (the selected group): intro card with the photo and
  "Pray for the {name}".
- `static` id -3: "Day in the Life" card.
- Other `static` blocks: one card each, rendering `heading`, `paragraph` and
  `verse` nodes in order and ending with "Pause & Pray". A long card scrolls;
  the Crown moves on to the next card at its end.
- `people_group` id -2: "People Group of the Day" card (photo, name, country,
  population, language, religion, description).
- Unknown block or node types are skipped.
- Inline: `hardBreak` is a line break; a `superscript` verse number is tied
  to the first word after it so they never wrap apart.
- The last card holds Amen, followed by the Scripture copyright notices,
  which are always shown.

Still to add: shared test files (`fixtures/<name>.json` with the API response
and `fixtures/<name>.cards.json` with the expected cards), checked by each
implementation. `docs/sample-prayer-api-output.json` is a good first one.

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
