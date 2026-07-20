#!/usr/bin/env bash
# Capture + frame iOS App Store screenshots on the simulator. macOS + Xcode ONLY
# — iOS simulators do not exist on Linux, so this cannot run on the CI/dev box
# that drives Android. Run it on a Mac (yours or a macOS CI runner).
#
#   tool/screenshots/capture_ios.sh              # all iOS canvases
#   tool/screenshots/capture_ios.sh iphone69     # just one (key from config)
#
# Output:
#   build/screenshots_raw/ios_<key>/*.png                (raw)
#   build/screenshots_framed/ios/<key>/*.png             (framed, ready to upload)
#
# Requires the simulator device types named in IOS_DEVICES (config.sh) to be
# installed (Xcode → Settings → Components, or `xcrun simctl list devicetypes`).

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/config.sh"

[ "$(uname)" = "Darwin" ] || { echo "capture_ios.sh runs on macOS only." >&2; exit 1; }
command -v xcrun >/dev/null || { echo "xcrun not found — install Xcode." >&2; exit 1; }
command -v flutter >/dev/null || { echo "flutter not on PATH" >&2; exit 1; }

WANT=("$@")
booted_udid=""
shutdown_sim() { [ -n "$booted_udid" ] && xcrun simctl shutdown "$booted_udid" >/dev/null 2>&1 || true; booted_udid=""; }
trap shutdown_sim EXIT

udid_for() {
  # First available simulator matching the device name exactly.
  xcrun simctl list devices available \
    | grep -F "$1 (" \
    | grep -oE '[0-9A-Fa-f-]{36}' | head -1
}

for spec in "${IOS_DEVICES[@]}"; do
  IFS='|' read -r key devname cw ch frame scr_x scr_y scr_w scr_h <<<"$spec"
  if [ ${#WANT[@]} -gt 0 ] && [[ ! " ${WANT[*]} " == *" $key "* ]]; then continue; fi

  udid="$(udid_for "$devname" || true)"
  if [ -z "$udid" ]; then
    echo "WARN: no simulator named '$devname' — create it in Xcode; skipping $key" >&2
    continue
  fi

  raw_out="$RAW_DIR/ios_$key"; framed_out="$FRAMED_DIR/ios/$key"
  rm -rf "$raw_out"; mkdir -p "$raw_out" "$framed_out"

  echo "==== $key ($devname → ${cw}x${ch}) ===="
  xcrun simctl boot "$udid" >/dev/null 2>&1 || true   # no-op if already booted
  booted_udid="$udid"

  # Pin a clean marketing status bar (9:41, full signal/wifi, 100% battery).
  # This is what shows in the shots because the host driver captures the FULL
  # device screen via `simctl io` — the Flutter surface alone has no status bar.
  # --batteryState discharging keeps 100% without the charging bolt.
  xcrun simctl status_bar "$udid" override \
    --time "9:41" \
    --dataNetwork wifi --wifiMode active --wifiBars 3 \
    --cellularMode active --cellularBars 4 \
    --batteryState discharging --batteryLevel 100 \
    >/dev/null 2>&1 || echo "  WARN: status_bar override failed (need iOS 13+ sim)" >&2

  # --flavor "$FLAVOR" mirrors the Android script and points ApiConfig at the
  # staging host via `appFlavor` (see lib/services/api_config.dart).
  #
  # No --profile here (unlike Android): iOS simulators can't AOT-compile, so
  # Flutter rejects profile/release for them ("release/profile builds are only
  # supported for physical devices"). We run debug; the harness sets
  # WidgetsApp.debugAllowBannerOverride=false so no DEBUG banner leaks in.
  #
  # iOS uses the host-driven flutter_driver harness ($IOS_DRIVER/$IOS_TARGET), not
  # integration_test: the host (screenshot_ios_driver.dart) tells the app to go to
  # each screen, waits for it to settle, then grabs the full device screen — real
  # status bar included — with `simctl io`. CAPTURE_UDID is the sim to screenshot.
  echo "→ driving app (--flavor $FLAVOR)…"
  SCREENSHOT_OUT="$raw_out" CAPTURE_UDID="$udid" flutter drive \
    --driver="$IOS_DRIVER" --target="$IOS_TARGET" \
    --flavor "$FLAVOR" \
    -d "$udid"

  echo "→ framing…"
  for base in "${SHOT_ORDER[@]}"; do
    raw="$raw_out/$base.png"
    [ -f "$raw" ] || { echo "  WARN: missing $raw — skipped" >&2; continue; }
    bash "$SCRIPT_DIR/frame.sh" "$raw" "$framed_out/$base.png" "$cw" "$ch" "$(caption "$base")" \
      "$SCRIPT_DIR/$frame" "$scr_x" "$scr_y" "$scr_w" "$scr_h"
  done

  shutdown_sim
  echo "✔ $key done → $framed_out"
done

echo "All iOS canvases captured. Framed screenshots in $FRAMED_DIR/ios/"
