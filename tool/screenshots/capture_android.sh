#!/usr/bin/env bash
# Capture + frame Android store screenshots on emulators — no physical device,
# no manual steps. For each Play bucket (phone / 7" / 10") it boots a headless
# emulator, drives the app against staging via integration_test, then frames the
# raw shots onto store-sized canvases.
#
#   tool/screenshots/capture_android.sh              # all buckets
#   tool/screenshots/capture_android.sh phone        # just one (key from config)
#
# Output:
#   build/screenshots_raw/android_<key>/*.png            (raw, per device)
#   build/screenshots_framed/android/<playFolder>/*.png  (framed, ready to upload)

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/config.sh"

EMULATOR="$ANDROID_SDK/emulator/emulator"
ADB="$ANDROID_SDK/platform-tools/adb"
AVDMANAGER="$ANDROID_SDK/cmdline-tools/latest/bin/avdmanager"
PORT=5554
SERIAL="emulator-$PORT"

for bin in "$EMULATOR" "$ADB" "$AVDMANAGER"; do
  [ -x "$bin" ] || { echo "Missing SDK tool: $bin (set ANDROID_HOME)" >&2; exit 1; }
done
command -v flutter >/dev/null || { echo "flutter not on PATH" >&2; exit 1; }

# Which buckets to run (default: all keys from ANDROID_DEVICES).
WANT=("$@")

emu_pid=""
shutdown_emu() {
  "$ADB" -s "$SERIAL" emu kill >/dev/null 2>&1 || true
  [ -n "$emu_pid" ] && wait "$emu_pid" 2>/dev/null || true
  emu_pid=""
}
cleanup() { shutdown_emu; }
trap cleanup EXIT

ensure_avd() {
  local avd="$1" profile="$2"
  if "$EMULATOR" -list-avds 2>/dev/null | grep -qx "$avd"; then return; fi
  echo "→ creating AVD $avd (profile: $profile)"
  echo "no" | "$AVDMANAGER" create avd -n "$avd" -k "$ANDROID_SYSTEM_IMAGE" -d "$profile" --force >/dev/null
}

# Ensure a portrait framebuffer (width <= height). The captured framebuffer uses
# hw.lcd.width/height directly, so a landscape-native profile (e.g. Nexus 10,
# 2560x1600) is captured landscape no matter the sensor orientation. Swapping the
# dims to portrait is deterministic where user_rotation is not (rotation 0 means
# "natural", which is landscape on such tablets).
force_portrait_lcd() {
  local avd="$1" cfg="$HOME/.android/avd/$avd.avd/config.ini"
  [ -f "$cfg" ] || return
  local w h
  w="$(grep -E '^hw\.lcd\.width' "$cfg" | grep -oE '[0-9]+' | head -1)"
  h="$(grep -E '^hw\.lcd\.height' "$cfg" | grep -oE '[0-9]+' | head -1)"
  [ -n "$w" ] && [ -n "$h" ] || return
  grep -q '^hw\.initialOrientation' "$cfg" || echo "hw.initialOrientation = portrait" >>"$cfg"
  if [ "$w" -gt "$h" ]; then
    sed -i "s/^hw\.lcd\.width.*/hw.lcd.width = $h/; s/^hw\.lcd\.height.*/hw.lcd.height = $w/" "$cfg"
    echo "  normalised $avd LCD to portrait (${h}x${w})"
  fi
}

boot_emu() {
  local avd="$1"
  echo "→ booting $avd (headless)…"
  "$EMULATOR" -avd "$avd" -port "$PORT" \
    -no-window -no-audio -no-boot-anim -no-snapshot \
    -gpu swiftshader_indirect -accel auto >/dev/null 2>&1 &
  emu_pid=$!
  "$ADB" -s "$SERIAL" wait-for-device
  local tries=0
  until [ "$("$ADB" -s "$SERIAL" shell getprop sys.boot_completed 2>/dev/null | tr -d '\r')" = "1" ]; do
    sleep 2; tries=$((tries+1))
    [ $tries -gt 150 ] && { echo "emulator boot timed out" >&2; exit 1; }
  done
  # Lock to portrait so tablet layouts render upright for the 9:16 canvases.
  "$ADB" -s "$SERIAL" shell settings put system accelerometer_rotation 0 >/dev/null 2>&1 || true
  "$ADB" -s "$SERIAL" shell settings put system user_rotation 0 >/dev/null 2>&1 || true
  echo "  booted."
}

for spec in "${ANDROID_DEVICES[@]}"; do
  IFS='|' read -r key avd profile cw ch play_folder <<<"$spec"
  if [ ${#WANT[@]} -gt 0 ] && [[ ! " ${WANT[*]} " == *" $key "* ]]; then continue; fi

  raw_out="$RAW_DIR/android_$key"
  framed_out="$FRAMED_DIR/android/$play_folder"
  rm -rf "$raw_out"; mkdir -p "$raw_out" "$framed_out"

  echo "==== $key ($avd → ${cw}x${ch}, $play_folder) ===="
  ensure_avd "$avd" "$profile"
  force_portrait_lcd "$avd"
  boot_emu "$avd"

  echo "→ driving app (flavor=$FLAVOR)…"
  SCREENSHOT_OUT="$raw_out" flutter drive \
    --driver="$DRIVER" --target="$TARGET" \
    --flavor "$FLAVOR" --profile \
    -d "$SERIAL"

  echo "→ framing…"
  for base in "${SHOT_ORDER[@]}"; do
    raw="$raw_out/$base.png"
    [ -f "$raw" ] || { echo "  WARN: missing $raw — skipped" >&2; continue; }
    bash "$SCRIPT_DIR/frame.sh" "$raw" "$framed_out/$base.png" "$cw" "$ch" "${CAPTIONS[$base]}"
  done

  shutdown_emu
  echo "✔ $key done → $framed_out"
done

echo "All Android buckets captured. Framed screenshots in $FRAMED_DIR/android/"
