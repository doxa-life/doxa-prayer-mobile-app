# Store screenshots

Automated App Store / Play Store screenshots for Doxa Prayer. One Flutter
`integration_test` drives the real app against the **staging** server, snaps each
screen, and ImageMagick frames the raw shots onto branded, store-sized canvases.
Fastlane uploads them.

```
integration_test/screenshot_test.dart   the capture harness (seeds state, drives, snaps)
test_driver/screenshot_driver.dart       writes each PNG to disk under flutter drive
tool/screenshots/
  config.sh          device matrix, captions, canvas sizes, theme  ← edit here
  capture_android.sh  boots emulators → drives → frames (Linux/macOS)
  capture_ios.sh      boots simulators → drives → frames (macOS only)
  frame.sh            ImageMagick compositor (device frame / bezel + caption + canvas)
  frames/             real device-frame PNGs (transparent screen window) — iOS
```

iOS shots use real device frames (`frames/iphone69.png`, `frames/ipad13.png`)
composited around the screenshot; Android uses a drawn rounded-rectangle bezel.
iOS also captures the **full device screen** via `simctl io` (not just the Flutter
surface) so the system status bar shows, pinned to a clean 9:41 / full-signal /
full-battery via `simctl status_bar override` in `capture_ios.sh`.

## What gets captured

Six screens, driven in a seeded state so they always look populated:

| File | Screen | Caption (default) |
|------|--------|-------------------|
| `01_home` | Home (group selected) | Pray for the unreached, every day |
| `02_pray` | Daily prayer session | A guided daily prayer for every people group |
| `03_people_groups` | Browse list | Explore thousands of people groups |
| `04_people_group_details` | Group profile | Learn their story, language and needs |
| `05_reminders` | Reminders | Gentle reminders to keep you praying |
| `06_onboarding` | Welcome / wizard | Get started in under a minute |

Store listings order by filename, so `01…06` is the order. Rename to reorder.

**Seeded state** (in `screenshot_test.dart`, written to SharedPreferences before
`main()`): wizard complete, locale `en`, selected people group **afar** (a real
staging group with a photo, full profile and daily prayer content), and two
reminders. Transient overlays (update banner, the home prayer nudge, the
notifications/exact-alarm warnings) are pinned off so shots stay clean.

## Prerequisites

**Android** (works on this Linux box):
- Android SDK with `emulator`, `adb`, `avdmanager` (set `ANDROID_HOME` if not `~/Android/Sdk`)
- The `android-33 google_apis x86_64` system image (AVDs are auto-created from it)
- ImageMagick (`convert`)

**iOS** (macOS + Xcode only — no iOS simulators exist on Linux):
- Xcode with the `iPhone 17 Pro Max` and `iPad Pro 13-inch (M5)` simulators installed
  (the names in `IOS_DEVICES`, config.sh)
- ImageMagick (`brew install imagemagick`)

## Run it

### Android (this machine)

```bash
tool/screenshots/capture_android.sh              # all buckets: phone, 7", 10"
tool/screenshots/capture_android.sh phone        # a single bucket
```

Each bucket boots a headless emulator, drives the app (`flutter drive --flavor
staging --profile`), frames the shots, and shuts the emulator down. Output:

```
build/screenshots_raw/android_<key>/*.png            raw device captures
build/screenshots_framed/android/<playFolder>/*.png  framed, ready to upload
```

### iOS (on a Mac)

```bash
tool/screenshots/capture_ios.sh                  # 6.9" iPhone + 13" iPad
```

Output under `build/screenshots_framed/ios/<key>/`.

## Upload (fastlane)

The framed images are staged into a clean, images-only tree under `build/supply`
(Android) / `ios/fastlane/screenshots` (iOS) and uploaded listing-only (no
binary). Android deliberately does NOT reuse the committed `metadata/` dir — it
holds release changelogs that supply would try to attach to a nonexistent
release. Screenshots are visually flavor-neutral, so they go to the
**production** listing by default.

```bash
# Android — from android/
bundle exec fastlane screenshots          # capture + frame + stage (no upload)
bundle exec fastlane upload_screenshots   # upload to production listing
bundle exec fastlane upload_screenshots validate:true          # dry run
bundle exec fastlane upload_screenshots flavor:staging         # staging app
bundle exec fastlane upload_screenshots track:alpha            # look up the release on another track
bundle exec fastlane upload_screenshots version_code:20        # pin the release explicitly

# iOS — from ios/ (macOS)
bundle exec fastlane screenshots
bundle exec fastlane upload_screenshots
```

Note: screenshots are listing-level, but `supply` still requires an existing
**release** to upload them (it resolves a version code first). The lane looks up
the newest release on the `internal` track by default (where `deploy` publishes)
and passes it. If the app has no release yet, deploy a build first, or pass
`track:`/`version_code:`.

Play uploads need `PLAY_SERVICE_ACCOUNT_JSON`; App Store uploads need the ASC API
key (`ASC_KEY_ID` etc). See each platform's `fastlane/.env.example`.

## Store size requirements (why framing exists)

Raw device resolution rarely matches store rules (a Pixel 6 is 9:20, not 9:16),
so `frame.sh` composites each shot onto an exact canvas. Change sizes in
`config.sh`.

| Bucket | Canvas (9:16) | Store rule |
|--------|---------------|-----------|
| Android phone | 1080×1920 | 16:9 or 9:16, each side 320–3840 px |
| Android 7" tablet | 1080×1920 | 16:9 or 9:16, each side 320–3840 px |
| Android 10" tablet | 1440×2560 | 16:9 or 9:16, each side 1080–7680 px |
| iOS 6.9" iPhone | 1290×2796 | ASC 6.9" display family |
| iOS 13" iPad | 2064×2752 | ASC 13" display family |

## Customising

- **Captions / order** — `CAPTIONS` and `SHOT_ORDER` in `config.sh`.
- **Which screens** — add/remove `binding.takeScreenshot(...)` calls in
  `screenshot_test.dart` (and the matching caption in `config.sh`).
- **People group / reminders / locale** — the `_seedState()` constants in
  `screenshot_test.dart`.
- **Theme (background, bezel, font colour)** — `config.sh`.
- **Canvas sizes / devices** — `ANDROID_DEVICES` / `IOS_DEVICES` in `config.sh`.
- **iOS device frames** — swap the PNGs in `frames/` and update each row's
  `frame png | scrX | scrY | scrW | scrH` in `IOS_DEVICES`. The screen-window
  geometry is the transparent region's bounding box; measure it with
  `convert frame.png -alpha extract -threshold 50% -negate -connected-components 8 …`
  (or use the frameit-frames `offsets.json` values).

## Troubleshooting

- **Blank image on a screen** — its network image didn't finish loading; give
  that screen the longer wait by passing `network: true` to `_settle(...)` in
  `screenshot_test.dart` (already set for the image-heavy screens).
- **Emulator won't boot headless** — the scripts use `-gpu swiftshader_indirect`
  for reliable headless software rendering; ensure no stale emulator is on port
  5554 (`adb -s emulator-5554 emu kill`).
- **Debug banner in shots** — captures run in `--profile`, which has none; don't
  switch to `--debug`.
- **iOS on Linux** — impossible. Run `capture_ios.sh` on a Mac or macOS CI.
