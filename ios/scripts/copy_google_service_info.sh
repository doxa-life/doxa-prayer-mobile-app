#!/bin/sh
#
# Copies the flavor-matched GoogleService-Info.plist into the built .app bundle
# so FirebaseApp.configure() (see Runner/AppDelegate.swift) finds it at runtime.
#
# Invoked from a "Copy GoogleService-Info.plist" Run Script build phase on the
# Runner target (added in Xcode — see FIREBASE_CRASHLYTICS_SETUP.md §3). The
# per-flavor plists live at ios/config/{production,staging}/ and are NOT added
# to the Xcode project / Copy Bundle Resources — this script is the only thing
# that puts one in the bundle, which is how prod/staging stay separated.
#
set -eu

# Flavor comes from ASSET_PREFIX (defined in the flavor xcconfigs, e.g.
# Flutter/stagingRelease.xcconfig). Fall back to parsing the build
# CONFIGURATION name (e.g. "Release-staging") if it is somehow unset.
FLAVOR="${ASSET_PREFIX:-}"
if [ -z "$FLAVOR" ]; then
  case "${CONFIGURATION:-}" in
    *[Ss]taging*) FLAVOR="staging" ;;
    *) FLAVOR="production" ;;
  esac
fi

SRC="${SRCROOT}/config/${FLAVOR}/GoogleService-Info.plist"
DEST_DIR="${TARGET_BUILD_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}"

if [ ! -f "$SRC" ]; then
  echo "error: GoogleService-Info.plist not found for flavor '${FLAVOR}' at ${SRC}" >&2
  exit 1
fi

echo "Copying ${SRC} -> ${DEST_DIR}/GoogleService-Info.plist"
mkdir -p "$DEST_DIR"
cp "$SRC" "${DEST_DIR}/GoogleService-Info.plist"
