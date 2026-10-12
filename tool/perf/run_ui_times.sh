#!/usr/bin/env bash
#
# Times every part of the UI on a real iPhone and writes one markdown file:
# timestamp, device, and "element | ms" rows. Nothing else.
#
#   tool/perf/run_ui_times.sh                 -> build/perf/ui-times/<timestamp>.md
#   tool/perf/run_ui_times.sh --label "x"     adds a Label line
#   tool/perf/run_ui_times.sh --rebuild       force a fresh build
#   tool/perf/run_ui_times.sh --no-reuse      let flutter drive build the app itself (slower, always fresh)
#   tool/perf/run_ui_times.sh --device <id>
#   tool/perf/run_ui_times.sh --include-risky  also walk the wizard and save/delete a reminder
#                                              (can open iOS Settings and kill the run)
#
# Compare two runs:  diff build/perf/ui-times/A.md build/perf/ui-times/B.md
# The app is built once and reused until lib/ or integration_test/ changes.
# FLAVOR env var (default staging).
#
set -euo pipefail
cd "$(cd "$(dirname "$0")/../.." && pwd)"

label=""; device=""; rebuild=0; risky=false; reuse=1
while [[ $# -gt 0 ]]; do
  case "$1" in
    --label) label="$2"; shift 2 ;;
    --device) device="$2"; shift 2 ;;
    --rebuild) rebuild=1; shift ;;
    --no-reuse) reuse=0; shift ;;
    --include-risky) risky=true; shift ;;
    -h|--help) sed -n 2,13p "$0"; exit 0 ;;
    *) echo "Unknown option: $1" >&2; exit 2 ;;
  esac
done
flavor="${FLAVOR:-staging}"

json="$(flutter devices --machine 2>/dev/null)"
if [[ -z "$device" ]]; then
  device="$(echo "$json" | python3 -c '
import json,sys
for d in json.load(sys.stdin):
    if d.get("targetPlatform","").startswith("ios") and not d.get("emulator",True):
        print(d["id"]); break')"
fi
[[ -n "$device" ]] || { echo "No physical iPhone found (unlock it, trust this Mac, Developer Mode on)." >&2; exit 1; }
name="$(echo "$json" | DEV="$device" python3 -c '
import json,sys,os
for d in json.load(sys.stdin):
    if d["id"]==os.environ["DEV"]: print(d.get("name",""))')"

target=integration_test/ui_times_test.dart
app=build/ios/iphoneos/Runner.app
stamp_file=build/perf/.ui_times_build

stale=$rebuild
[[ $reuse -eq 0 ]] && stale=0
if [[ ! -d "$app" || ! -f "$stamp_file" || "$(cat "$stamp_file")" != "$flavor|$target|$risky" ]]; then stale=1
elif [[ -n "$(find lib integration_test test_driver pubspec.yaml assets -newer "$stamp_file" -type f 2>/dev/null | head -1)" ]]; then stale=1
fi
if [[ $reuse -eq 0 ]]; then
  echo "Letting flutter drive build the app (no reuse)."
elif [[ $stale -eq 1 ]]; then
  echo "Building (profile, $flavor)…"
  flutter build ios --profile --flavor "$flavor" -t "$target" --dart-define=UI_RISKY="$risky"
  mkdir -p build/perf; echo "$flavor|$target|$risky" > "$stamp_file"
else
  echo "Reusing the existing build (--rebuild to force)."
fi

commit="$(git rev-parse --short HEAD 2>/dev/null || echo unknown)"
[[ -n "$(git status --porcelain 2>/dev/null)" ]] && commit="$commit (uncommitted changes)"
out="build/perf/ui-times/$(date +%Y%m%d-%H%M%S).md"
log="${out%.md}.log"
mkdir -p "$(dirname "$out")"

bin=(); [[ $reuse -eq 1 ]] && bin=(--use-application-binary="$app")
UI_TIMES_OUT="$out" UI_DEVICE="$name" UI_LABEL="$label" UI_COMMIT="$commit" \
flutter drive --driver=test_driver/ui_times_driver.dart --target="$target" \
  --profile --flavor "$flavor" -d "$device" ${bin[@]+"${bin[@]}"} --dart-define=UI_RISKY="$risky" \
  2>&1 | tee "$log" || true
echo
echo "Full log: $log"
echo "Last steps started:"; grep "UI_TIMES" "$log" | tail -4 || true

[[ -f "$out" ]] && { echo; cat "$out"; echo; echo "Saved: $out"; } || { echo "No results were written." >&2; exit 1; }
