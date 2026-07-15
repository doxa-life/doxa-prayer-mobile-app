#!/usr/bin/env bash
# Generate the Play Store feature graphic (1024x500) — the promo banner at the
# top of the listing. On-brand campaign lockup on a light field:
#
#     OUR GIFT TO JESUS:                        (dark green)
#     ENGAGE EVERY PEOPLE BY 2033               (ENGAGE + 2033 sage, rest dark)
#
# with the DOXA mark above. Everything sits in a centred safe zone so Google's
# crops / play-button overlay never clip it.
#
#   tool/screenshots/feature_graphic.sh
#
# Output: build/screenshots_framed/android/featureGraphic.png

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/config.sh"

W=1024; H=500
FONT="$CAPTION_FONT"                       # BebasKai — the app's display face
DARK="#3B463D"                             # AppColors.primary
SAGE="#73A17F"                             # AppColors.secondary
CREAM="#E9E5DB"
BG_A="#48574B"; BG_B="#28312A"             # light cream field (mutedSurface family)
LOGO="$REPO/assets/images/doxa-logo.png"   # beige wordmark, recoloured dark below
PATTERN="$REPO/assets/images/mobile-background.svg"
TARGET_W=$(( W * 88 / 100 ))               # width the wider text line fills
BASE_PS=120                                # render text big, then scale to fit

OUT_DIR="$FRAMED_DIR/android"
OUT="$OUT_DIR/featureGraphic.png"
mkdir -p "$OUT_DIR"

tmp="$(mktemp -d)"; trap 'rm -rf "$tmp"' EXIT

# ---- 1. light field + very faint brand texture ----------------------------
convert -size "${W}x${H}" "gradient:${BG_A}-${BG_B}" "$tmp/bg.png"
convert -background none "$PATTERN" -resize "${W}x" "$tmp/pat_full.png"
convert "$tmp/pat_full.png" -gravity north -crop "${W}x${H}+0+0" +repage \
  -channel A -evaluate multiply 0.05 +channel "$tmp/pat.png"
convert "$tmp/bg.png" "$tmp/pat.png" -compose over -composite "$tmp/field.png"

# ---- 2. text lines (rendered big at BASE_PS, scaled together to fit) --------
# Line 1: single colour.
convert -background none -font "$FONT" -pointsize "$BASE_PS" -fill "$CREAM" \
  label:"OUR GIFT TO JESUS:" "$tmp/line1.png"

# Line 2: per-word colours — append coloured segments (trailing spaces = gaps).
convert -background none -font "$FONT" -pointsize "$BASE_PS" -fill "$SAGE" label:"ENGAGE " "$tmp/s1.png"
convert -background none -font "$FONT" -pointsize "$BASE_PS" -fill "$CREAM" label:"EVERY PEOPLE BY " "$tmp/s2.png"
convert -background none -font "$FONT" -pointsize "$BASE_PS" -fill "$SAGE" label:"2033" "$tmp/s3.png"
convert "$tmp/s1.png" "$tmp/s2.png" "$tmp/s3.png" +append -background none "$tmp/line2.png"

# Scale both lines by one factor so the wider line hits TARGET_W (keeps the two
# lines the same type size).
w1="$(convert "$tmp/line1.png" -format "%w" info:)"
w2="$(convert "$tmp/line2.png" -format "%w" info:)"
wmax=$(( w1 > w2 ? w1 : w2 ))
scale_pct=$(( TARGET_W * 100 / wmax ))
convert "$tmp/line1.png" -resize "${scale_pct}%" "$tmp/line1s.png"
convert "$tmp/line2.png" -resize "${scale_pct}%" "$tmp/line2s.png"

# ---- 3. logo, recoloured dark for the light field --------------------------
logo_w=$(( W * 28 / 100 ))
convert "$LOGO" -resize "${logo_w}x" "$tmp/logo.png"

# ---- 4. stack logo + two lines, vertically centred -------------------------
lh="$(convert "$tmp/logo.png"  -format "%h" info:)"
h1="$(convert "$tmp/line1s.png" -format "%h" info:)"
h2="$(convert "$tmp/line2s.png" -format "%h" info:)"
gap_logo=$(( H * 7 / 100 ))
gap_lines=$(( H * 2 / 100 ))
block_h=$(( lh + gap_logo + h1 + gap_lines + h2 ))
y=$(( (H - block_h) / 2 ))

convert "$tmp/field.png" \
  -gravity north \
  "$tmp/logo.png"   -geometry "+0+${y}"                                   -composite \
  "$tmp/line1s.png" -geometry "+0+$(( y + lh + gap_logo ))"               -composite \
  "$tmp/line2s.png" -geometry "+0+$(( y + lh + gap_logo + h1 + gap_lines ))" -composite \
  -flatten "$OUT"

echo "feature graphic → $OUT ($(identify -format '%wx%h' "$OUT"))"
