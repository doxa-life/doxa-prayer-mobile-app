#!/usr/bin/env bash
# Composite one raw screenshot onto a store-sized, branded canvas with a device
# bezel and a caption. Pure ImageMagick so it runs identically on Linux/macOS
# and gives pixel-exact control over the final dimensions (needed for the strict
# 9:16 / px-range store requirements — the raw capture size doesn't matter).
#
# Usage: frame.sh <raw.png> <out.png> <canvasW> <canvasH> "<caption>"

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/config.sh"

RAW="$1"; OUT="$2"; W="$3"; H="$4"; CAPTION="$5"

command -v convert >/dev/null || { echo "ImageMagick 'convert' not found" >&2; exit 1; }

# ---- layout (integer math, all derived from the canvas size) ----------------
margin=$(( W * 9 / 100 ))        # horizontal breathing room around the device
cap_top=$(( H * 5 / 100 ))       # caption band offset from the top
cap_h=$(( H * 12 / 100 ))        # caption band height
gap=$(( H * 3 / 100 ))           # space between caption and device
bottom=$(( H * 5 / 100 ))        # bottom breathing room
pad=$(( W * 12 / 1000 ))         # bezel thickness (~1.2% of width)
radius=$(( W * 7 / 100 ))        # screen corner radius

dev_w=$(( W - 2 * margin ))
avail_h=$(( H - cap_top - cap_h - gap - bottom - 2 * pad ))

dims="$(convert "$RAW" -format "%w %h" info:)"
read -r rw rh <<<"$dims"
dev_h=$(( rh * dev_w / rw ))
if [ "$dev_h" -gt "$avail_h" ]; then       # height-limited (usual for portrait)
  dev_h=$avail_h
  dev_w=$(( rw * dev_h / rh ))
fi

bw=$(( dev_w + 2 * pad ))                   # bezel outer size
bh=$(( dev_h + 2 * pad ))
br=$(( radius + pad ))                       # bezel corner radius
left_x=$(( (W - bw) / 2 ))                   # centre the device horizontally
top_y=$(( cap_top + cap_h + gap ))           # device top, below the caption

tmp="$(mktemp -d)"
trap 'rm -rf "$tmp"' EXIT

# ---- 1. scale the screenshot ------------------------------------------------
convert "$RAW" -resize "${dev_w}x${dev_h}!" "$tmp/s.png"

# ---- 2. round the screenshot corners ---------------------------------------
r=$radius
convert "$tmp/s.png" -alpha set -background none \
  \( +clone -alpha extract \
     -draw "fill black polygon 0,0 0,$r $r,0 fill white circle $r,$r $r,0" \
     \( +clone -flip \) -compose Multiply -composite \
     \( +clone -flop \) -compose Multiply -composite \) \
  -alpha off -compose CopyOpacity -composite "$tmp/rounded.png"

# ---- 3. bezel + device ------------------------------------------------------
convert -size "${bw}x${bh}" xc:none -fill "$BEZEL_COLOR" \
  -draw "roundrectangle 0,0 $((bw-1)),$((bh-1)) $br,$br" "$tmp/bezel.png"
convert "$tmp/bezel.png" "$tmp/rounded.png" -geometry "+${pad}+${pad}" \
  -compose over -composite "$tmp/device.png"

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
