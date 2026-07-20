#!/usr/bin/env bash
# Re-frame ALREADY-CAPTURED iOS raw screenshots — no simulator, no re-capture.
# Use this when only the framing changed (e.g. a frame.sh fix) and the raws in
# build/screenshots_raw/ios_<key>/ are still good.
#
#   tool/screenshots/reframe_ios.sh              # re-frame all iOS canvases
#   tool/screenshots/reframe_ios.sh iphone69     # just one (key from config)
#
# Reads:
#   build/screenshots_raw/ios_<key>/*.png                (raw, left untouched)
# Writes:
#   build/screenshots_framed/ios/<key>/*.png             (framed, overwritten)
#
# Pure ImageMagick (via frame.sh), so it runs on any machine with the raws —
# it does NOT need macOS/Xcode the way capture_ios.sh does.

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/config.sh"

command -v convert >/dev/null || { echo "ImageMagick 'convert' not found" >&2; exit 1; }

WANT=("$@")

for spec in "${IOS_DEVICES[@]}"; do
  IFS='|' read -r key devname cw ch frame scr_x scr_y scr_w scr_h <<<"$spec"
  if [ ${#WANT[@]} -gt 0 ] && [[ ! " ${WANT[*]} " == *" $key "* ]]; then continue; fi

  raw_out="$RAW_DIR/ios_$key"; framed_out="$FRAMED_DIR/ios/$key"
  if [ ! -d "$raw_out" ]; then
    echo "WARN: no raws at $raw_out — run capture_ios.sh $key first; skipping" >&2
    continue
  fi
  mkdir -p "$framed_out"

  echo "==== $key (${cw}x${ch}) ===="
  echo "→ reframing from $raw_out …"
  for base in "${SHOT_ORDER[@]}"; do
    raw="$raw_out/$base.png"
    [ -f "$raw" ] || { echo "  WARN: missing $raw — skipped" >&2; continue; }
    bash "$SCRIPT_DIR/frame.sh" "$raw" "$framed_out/$base.png" "$cw" "$ch" "$(caption "$base")" \
      "$SCRIPT_DIR/$frame" "$scr_x" "$scr_y" "$scr_w" "$scr_h"
  done
  echo "✔ $key done → $framed_out"
done

echo "All requested iOS canvases reframed. Framed screenshots in $FRAMED_DIR/ios/"
