#!/usr/bin/env bash
#
# Performance walkthrough on a real device, in profile mode.
#
#   tool/perf/run_perf.sh                      run, report, compare to the baseline
#   tool/perf/run_perf.sh --label "no shadow"  tag the run (shown in the report)
#   tool/perf/run_perf.sh --save-baseline      also make this run the new baseline
#   tool/perf/run_perf.sh --runs 3             repeat and report the median of each metric
#   tool/perf/run_perf.sh --device <id>        pick a device (see `flutter devices`)
#   tool/perf/run_perf.sh --skip-map           skip the Mapbox scenarios
#   tool/perf/run_perf.sh --allow-nonphysical  run on a Simulator/emulator anyway (numbers
#                                              are NOT comparable with device runs)
#
# Env: FLAVOR (default staging, so no production data is touched).
#
# Output: build/perf/<timestamp>[_label]/run<N>.json, report.md, report.json
# Baseline: tool/perf/baseline.json (commit it to share it).
#
set -euo pipefail
cd "$(cd "$(dirname "$0")/../.." && pwd)"

label=""; save_baseline=0; runs=1; device=""; skip_map=false; allow_nonphysical=0
while [[ $# -gt 0 ]]; do
  case "$1" in
    --label) label="$2"; shift 2 ;;
    --save-baseline) save_baseline=1; shift ;;
    --runs) runs="$2"; shift 2 ;;
    --device) device="$2"; shift 2 ;;
    --skip-map) skip_map=true; shift ;;
    --allow-nonphysical) allow_nonphysical=1; shift ;;
    -h|--help) sed -n 2,19p "$0"; exit 0 ;;
    *) echo "Unknown option: $1" >&2; exit 2 ;;
  esac
done

flavor="${FLAVOR:-staging}"

# --- Pick the device: a connected, physical iPhone unless told otherwise. ----
if [[ -z "$device" ]]; then
  device="$(flutter devices --machine 2>/dev/null | python3 -c '
import json,sys
ds=json.load(sys.stdin)
for d in ds:
    if d.get("targetPlatform","").startswith("ios") and not d.get("emulator",True):
        print(d["id"]); break
')"
fi
if [[ -z "$device" ]]; then
  echo "No physical iPhone found. Plug it in, unlock it, trust this Mac, and check" >&2
  echo "that \`flutter devices\` lists it (Developer Mode must be on)." >&2
  exit 1
fi

info="$(flutter devices --machine 2>/dev/null | DEV="$device" python3 -c '
import json,sys,os
for d in json.load(sys.stdin):
    if d["id"]==os.environ["DEV"]:
        print(("emulator" if d.get("emulator") else "physical"), d.get("name",""))
')"
kind="${info%% *}"; name="${info#* }"
if [[ "$kind" == "emulator" && $allow_nonphysical -eq 0 ]]; then
  echo "\"$name\" is a simulator/emulator: its timings say nothing about a real phone." >&2
  echo "Use a physical device, or pass --allow-nonphysical to run anyway." >&2
  exit 1
fi

sha="$(git rev-parse --short HEAD 2>/dev/null || echo unknown)"
dirty=false; [[ -n "$(git status --porcelain 2>/dev/null)" ]] && dirty=true
stamp="$(date +%Y%m%d-%H%M%S)"
slug="$(echo "$label" | tr -c 'A-Za-z0-9\n' '-' | sed 's/^-*//;s/-*$//')"
out="build/perf/${stamp}${slug:+_$slug}"
mkdir -p "$out"

echo "Device : $name ($device)"
echo "Flavor : $flavor   Commit: $sha (dirty: $dirty)   Runs: $runs"
echo "Output : $out"
echo "Keep the phone unlocked, plugged in, and on the same Wi-Fi each time."
echo "Close other apps; let it cool between runs for comparable numbers."
echo

for ((i = 1; i <= runs; i++)); do
  echo "=== Run $i of $runs ==="
  PERF_OUT="$out/run$i.json" flutter drive \
    --driver=test_driver/perf_driver.dart \
    --target=integration_test/perf_test.dart \
    --profile --flavor "$flavor" -d "$device" \
    --dart-define=PERF_GIT_SHA="$sha" \
    --dart-define=PERF_GIT_DIRTY="$dirty" \
    --dart-define=PERF_LABEL="$label" \
    --dart-define=PERF_FLAVOR="$flavor" \
    --dart-define=PERF_SKIP_MAP="$skip_map"
done

args=(--out "$out" --baseline tool/perf/baseline.json)
[[ $save_baseline -eq 1 ]] && args+=(--save-baseline)
dart run tool/perf/report.dart "${args[@]}"
