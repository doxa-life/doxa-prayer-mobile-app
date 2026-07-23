#!/usr/bin/env bash
# Shared configuration for the store-screenshot tooling.
# Sourced by capture_android.sh, capture_ios.sh and frame.sh — not run directly.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO="$(cd "$SCRIPT_DIR/../.." && pwd)"

# Build flavor — `staging` points ApiConfig at the staging host (see api_config.dart).
# Used by both the Android and iOS capture scripts.
FLAVOR="${FLAVOR:-staging}"

DRIVER="test_driver/screenshot_driver.dart"
TARGET="integration_test/screenshot_test.dart"

# iOS uses a separate, host-driven flutter_driver harness (not integration_test):
# the host walks the app screen-by-screen and grabs the full device screen — real
# status bar included — with `xcrun simctl io screenshot` between steps. See
# capture_ios.sh and test_driver/screenshot_ios_{app,driver}.dart.
IOS_DRIVER="test_driver/screenshot_ios_driver.dart"
IOS_TARGET="test_driver/screenshot_ios_app.dart"

# Raw = straight off the device; framed = composited onto store-sized canvases.
RAW_DIR="$REPO/build/screenshots_raw"
FRAMED_DIR="$REPO/build/screenshots_framed"

# Caption font: the app's own display face, so captions match the in-app headings.
CAPTION_FONT="$REPO/assets/fonts/BebasKai/BebasKai.ttf"

# Framing theme (brand greens — matches the #3B463D splash / dark UI chrome).
BG_TOP="#49584C"
BG_BOTTOM="#28302A"
BEZEL_COLOR="#141915"
CAPTION_COLOR="#F4F1EA"

# Capture order + marketing captions, keyed by the base name the harness emits
# (integration_test/screenshot_test.dart). Store listings order by filename.
# NB: macOS ships bash 3.2 which lacks associative arrays, so caption() is a
# case statement rather than a `declare -A` map.
SHOT_ORDER=(01_home 02_pray 03_people_groups 04_people_group_details 05_reminders 06_onboarding)
caption() {
  case "$1" in
    01_home)                  echo "Pray for the unreached, every day" ;;
    02_pray)                  echo "A guided daily prayer for every people group" ;;
    03_people_groups)         echo "Explore thousands of people groups" ;;
    04_people_group_details)  echo "Learn their story, language and needs" ;;
    05_reminders)             echo "Gentle reminders to keep you praying" ;;
    06_onboarding)            echo "Get started in under a minute" ;;
    *)                        echo "" ;;
  esac
}

# Android device matrix — one per Play screenshot bucket.
#   key | AVD name | avdmanager device profile | canvas W | canvas H | play folder
# Canvases are exact 9:16 within each bucket's px bounds (phone/7": 320-3840,
# 10": 1080-7680). Raw capture resolution is irrelevant — framing normalises it.
ANDROID_DEVICES=(
  "phone|doxa_phone|pixel_6|1080|1920|phoneScreenshots"
  "tablet7|doxa_tablet7|Nexus 7|1080|1920|sevenInchScreenshots"
  "tablet10|doxa_tablet10|Nexus 10|1440|2560|tenInchScreenshots"
)

# iOS device matrix (macOS only). Canvases are App Store Connect required sizes:
#   - iPhone 6.7" Display slot: 1284x2778 — the universal iPhone size, accepted
#     in BOTH the 6.5" and 6.7" slots. (The 6.9"-only 1290x2796 is rejected by
#     the 6.5"/6.7" slots, which is the upload error this avoids.)
#   - iPad  13"  Display slot: 2064x2752 (also accepts 2048x2732)
#
# Real device frames (frames/*.png) replace the drawn bezel for iOS. Each frame
# is a PNG with a transparent screen window; the trailing fields give that
# window's geometry so frame.sh can drop the screenshot into it and lay the
# frame on top. Values are measured directly from the PNG (and match the
# frameit-frames offsets.json entries for these devices).
#   key | simulator device name | canvas W | canvas H | frame png | scrX | scrY | scrW | scrH
IOS_DEVICES=(
  "iphone69|iPhone 17 Pro Max|1284|2778|frames/iphone69.png|75|66|1320|2868"
  "ipad13|iPad Pro 13-inch (M5)|2064|2752|frames/ipad13.png|96|102|2048|2732"
)

# Android system image used to auto-create missing AVDs.
ANDROID_SYSTEM_IMAGE="system-images;android-33;google_apis;x86_64"
ANDROID_SDK="${ANDROID_HOME:-${ANDROID_SDK_ROOT:-$HOME/Android/Sdk}}"
