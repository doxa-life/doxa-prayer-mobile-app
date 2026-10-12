#!/usr/bin/env bash
#
# Prepare the iOS project the way `flutter build ios` does, then open it in Xcode
# so the `production` (or `staging`) scheme builds and runs from ⌘R / ⌘B.
#
#   tool/open_xcode.sh                    production flavor, release-mode config
#   tool/open_xcode.sh staging            staging flavor
#   tool/open_xcode.sh production --clean also wipe this project's Xcode DerivedData
#   tool/open_xcode.sh production --debug generate a debug-mode config instead
#
# Why: Xcode never runs `flutter pub get`, regenerates Flutter/Generated.xcconfig,
# or runs `pod install` — the CLI does all three before every build. When any of
# them is stale (after a pubspec change, a flavor switch, or the SPM → CocoaPods
# move), Xcode fails with "No such module 'Flutter'" / "'FirebaseCore'" while
# `flutter build` keeps working. `flutter build ios --config-only` does exactly
# that prep without compiling.
#
set -euo pipefail

here="$(cd "$(dirname "$0")/.." && pwd)"
cd "$here"

flavor="production"
mode="--release"
clean=0
for arg in "$@"; do
  case "$arg" in
    production|staging) flavor="$arg" ;;
    --clean) clean=1 ;;
    --debug) mode="--debug" ;;
    --profile) mode="--profile" ;;
    --release) mode="--release" ;;
    *) echo "Unknown argument: $arg" >&2; sed -n '2,10p' "$0" >&2; exit 1 ;;
  esac
done

workspace="$here/ios/Runner.xcworkspace"

if [[ "$clean" == 1 ]]; then
  # Only this project's DerivedData (matched by the workspace path Xcode records),
  # plus folders whose workspace no longer exists (e.g. an old checkout location).
  for d in "$HOME"/Library/Developer/Xcode/DerivedData/Runner-*; do
    [[ -d "$d" ]] || continue
    ws="$(plutil -extract WorkspacePath raw "$d/info.plist" 2>/dev/null || true)"
    if [[ -z "$ws" || "$ws" == "$workspace" || ! -e "$ws" ]]; then
      echo "Removing DerivedData ${d##*/} (${ws:-unknown workspace})"
      rm -rf "$d"
    fi
  done
  rm -rf ios/build
fi

if pgrep -xq Xcode; then
  echo "Note: Xcode is running. If it has this workspace open, it will reload the"
  echo "      regenerated Pods project; if builds still fail, quit Xcode and rerun."
fi

echo "==> flutter pub get"
flutter pub get

echo "==> flutter build ios --config-only $mode --flavor $flavor (regenerates Generated.xcconfig, runs pod install)"
flutter build ios --config-only "$mode" --flavor "$flavor"

# Sanity checks: the things Xcode needs that it can't produce itself.
grep -q "^FLAVOR=$flavor$" ios/Flutter/Generated.xcconfig \
  || { echo "Generated.xcconfig is not set to flavor '$flavor'" >&2; exit 1; }
cmp -s ios/Podfile.lock ios/Pods/Manifest.lock \
  || { echo "Pods are out of sync with Podfile.lock; run 'cd ios && pod install'" >&2; exit 1; }

echo
echo "Ready. In Xcode, select the '$flavor' scheme, pick a device, and press ⌘R."
echo "(Always open Runner.xcworkspace, never Runner.xcodeproj — the .xcodeproj alone"
echo " doesn't include the Pods project, so FirebaseCore and Flutter can't be found.)"
open "$workspace"
