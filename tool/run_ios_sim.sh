#!/usr/bin/env bash
#
# Run the production flavor ("Doxa Prayer", life.doxa.pray) on the iOS simulator.
#
#   tool/run_ios_sim.sh                       use the booted simulator, or boot an iPhone
#   tool/run_ios_sim.sh "iPhone 18 Pro"       use (and boot if needed) a specific simulator
#   tool/run_ios_sim.sh "" --release          extra args are passed through to `flutter run`
#
# Note: the simulator can't run --release builds; the default is debug.
#
set -euo pipefail

here="$(cd "$(dirname "$0")/.." && pwd)"
cd "$here"

wanted="${1:-}"
shift || true

# Booted simulators as "UDID|Name" lines.
booted() {
  xcrun simctl list devices booted | sed -nE 's/^ +(.+) \(([0-9A-F-]{36})\) \(Booted\).*/\2|\1/p'
}

udid=""
if [[ -n "$wanted" ]]; then
  udid="$(xcrun simctl list devices available \
    | sed -nE "s/^ +${wanted} \(([0-9A-F-]{36})\).*/\1/p" | head -1)"
  if [[ -z "$udid" ]]; then
    echo "No available simulator named \"$wanted\". Available iPhones:" >&2
    xcrun simctl list devices available | grep -i iphone >&2
    exit 1
  fi
else
  udid="$(booted | head -1 | cut -d'|' -f1)"
  if [[ -z "$udid" ]]; then
    udid="$(xcrun simctl list devices available \
      | sed -nE 's/^ +iPhone[^(]* \(([0-9A-F-]{36})\).*/\1/p' | head -1)"
  fi
  if [[ -z "$udid" ]]; then
    echo "No iPhone simulators installed. Add one in Xcode → Settings → Components." >&2
    exit 1
  fi
fi

# Boot it if it isn't already, and bring the Simulator app forward.
if ! booted | grep -q "^$udid|"; then
  echo "Booting simulator $udid..."
  xcrun simctl boot "$udid"
fi
open -b com.apple.iphonesimulator 2>/dev/null \
  || open -a Simulator 2>/dev/null \
  || echo "(Couldn't open the Simulator window; the app will still run on the booted device.)"

echo "Running production flavor on $(booted | grep "^$udid|" | cut -d'|' -f2) ($udid)"
exec flutter run -d "$udid" --flavor production "$@"
