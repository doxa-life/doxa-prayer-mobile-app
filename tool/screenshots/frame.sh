#!/usr/bin/env bash
# Composite one raw screenshot onto a store-sized, branded canvas with a device
# bezel and a caption. Pure ImageMagick so it runs identically on Linux/macOS
# and gives pixel-exact control over the final dimensions (needed for the strict
# 9:16 / px-range store requirements — the raw capture size doesn't matter).
#
# Usage: frame.sh <raw.png> <out.png> <canvasW> <canvasH> "<caption>"
#        [<frame.png> <scrX> <scrY> <scrW> <scrH>]
#
# With the optional trailing args, the screenshot is composited into a real
# device-frame PNG's transparent screen window (iOS). Without them, a solid
# rounded-rectangle bezel is drawn instead (Android / default).

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/config.sh"

RAW="$1"; OUT="$2"; W="$3"; H="$4"; CAPTION="$5"
FRAME_PNG="${6:-}"; SCR_X="${7:-}"; SCR_Y="${8:-}"; SCR_W="${9:-}"; SCR_H="${10:-}"

command -v convert >/dev/null || { echo "ImageMagick 'convert' not found" >&2; exit 1; }

# ---- layout (integer math, all derived from the canvas size) ----------------
margin=$(( W * 9 / 100 ))        # horizontal breathing room around the device
cap_top=$(( H * 5 / 100 ))       # caption band offset from the top
cap_h=$(( H * 12 / 100 ))        # caption band height
gap=$(( H * 3 / 100 ))           # space between caption and device
bottom=$(( H * 5 / 100 ))        # bottom breathing room
pad=$(( W * 12 / 1000 ))         # bezel thickness (~1.2% of width) — bezel path only
radius=$(( W * 7 / 100 ))        # screen corner radius — bezel path only

top_y=$(( cap_top + cap_h + gap ))                        # device top, below caption
avail_h=$(( H - cap_top - cap_h - gap - bottom - 2 * pad ))

tmp="$(mktemp -d)"
trap 'rm -rf "$tmp"' EXIT

# ---- device layer -----------------------------------------------------------
# Build $tmp/device.png (an opaque device the shadow/compose steps below treat
# identically, via bw/bh/br/left_x/top_y). Two ways:
#   * real frame — a device-frame PNG + its transparent screen-window geometry
#     were passed (iOS): drop the screenshot into the window, lay the frame on
#     top, then scale the whole thing to fit the device slot.
#   * drawn bezel — otherwise (Android): round the screenshot's corners and set
#     it on a solid rounded rectangle. The original behaviour.
if [ -n "$FRAME_PNG" ]; then
  read -r fw fh <<<"$(convert "$FRAME_PNG" -format "%w %h" info:)"
  bw=$(( W - 2 * margin ))                    # fit the whole frame into the slot
  bh=$(( fh * bw / fw ))
  maxh=$(( avail_h + 2 * pad ))               # frame carries its own bezel, no pad reserve
  if [ "$bh" -gt "$maxh" ]; then bh=$maxh; bw=$(( fw * bh / fh )); fi
  br=$(( bw * 9 / 100 ))                      # ~device corner radius (shadow only)

  convert "$RAW" -resize "${SCR_W}x${SCR_H}!" "$tmp/s.png"
  convert -size "${fw}x${fh}" xc:none \
    "$tmp/s.png"  -geometry "+${SCR_X}+${SCR_Y}" -compose over -composite \
    "$FRAME_PNG"  -compose over -composite \
    "$tmp/device_full.png"
  convert "$tmp/device_full.png" -resize "${bw}x${bh}!" "$tmp/device.png"
else
  read -r rw rh <<<"$(convert "$RAW" -format "%w %h" info:)"
  dev_w=$(( W - 2 * margin ))
  dev_h=$(( rh * dev_w / rw ))
  if [ "$dev_h" -gt "$avail_h" ]; then       # height-limited (usual for portrait)
    dev_h=$avail_h
    dev_w=$(( rw * dev_h / rh ))
  fi

  bw=$(( dev_w + 2 * pad ))                   # bezel outer size
  bh=$(( dev_h + 2 * pad ))
  br=$(( radius + pad ))                       # bezel corner radius

  convert "$RAW" -resize "${dev_w}x${dev_h}!" "$tmp/s.png"
  r=$radius
  convert "$tmp/s.png" -alpha set -background none \
    \( +clone -alpha extract \
       -draw "fill black polygon 0,0 0,$r $r,0 fill white circle $r,$r $r,0" \
       \( +clone -flip \) -compose Multiply -composite \
       \( +clone -flop \) -compose Multiply -composite \) \
    -alpha off -compose CopyOpacity -composite "$tmp/rounded.png"

  convert -size "${bw}x${bh}" xc:none -fill "$BEZEL_COLOR" \
    -draw "roundrectangle 0,0 $((bw-1)),$((bh-1)) $br,$br" "$tmp/bezel.png"
  convert "$tmp/bezel.png" "$tmp/rounded.png" -geometry "+${pad}+${pad}" \
    -compose over -composite "$tmp/device.png"
fi

left_x=$(( (W - bw) / 2 ))                     # centre the device horizontally

# ---- 4. drop shadow silhouette ---------------------------------------------
# Draw the silhouette on a canvas padded by `smar` so the blur has room to bleed
# outward instead of being clipped at the layer's edges (that clipping is what
# made the earlier shadow look boxed-in).
smar=$(( W * 5 / 100 ))
ssw=$(( bw + 2 * smar ))
ssh=$(( bh + 2 * smar ))
convert -size "${ssw}x${ssh}" xc:none -fill "black" \
  -draw "roundrectangle ${smar},${smar} $((smar+bw-1)),$((smar+bh-1)) $br,$br" \
  -channel A -evaluate multiply 0.5 +channel -blur "0x$(( W * 22 / 1000 ))" "$tmp/shadow.png"

# ---- 5. background gradient -------------------------------------------------
convert -size "${W}x${H}" "gradient:${BG_TOP}-${BG_BOTTOM}" "$tmp/bg.png"

# ---- 6. caption (auto-wraps + auto-sizes to the band) ----------------------
cap_w=$(( W - 2 * (W * 8 / 100) ))
convert -background none -fill "$CAPTION_COLOR" -font "$CAPTION_FONT" \
  -gravity center -size "${cap_w}x${cap_h}" "caption:${CAPTION}" "$tmp/cap.png"

# ---- 7. compose everything --------------------------------------------------
# The shadow layer is padded by `smar`, so offset back by it to align the
# silhouette with the device, then nudge down by `drop` for a cast-shadow look.
drop=$(( H * 12 / 1000 ))
convert "$tmp/bg.png" \
  "$tmp/shadow.png" -geometry "+$((left_x - smar))+$((top_y - smar + drop))" -compose over -composite \
  "$tmp/device.png" -geometry "+${left_x}+${top_y}" -compose over -composite \
  -gravity North "$tmp/cap.png" -geometry "+0+${cap_top}" -compose over -composite \
  -flatten "$OUT"

echo "  framed $(basename "$OUT") (${W}x${H})"
