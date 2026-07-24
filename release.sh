#!/usr/bin/env bash
#
# Doxa Prayer — release wrapper around fastlane (Android + iOS).
#
#   ./release.sh bump [build|patch|minor|major]    cut a release: bump version,
#                                                  draft notes from commits, commit, tag
#   ./release.sh deploy [staging|production]       build + upload Android app, update gate
#   ./release.sh build [staging|production]        build a signed AAB only (no upload)
#
#   ./release.sh deploy-ios [staging|production]         build + upload iOS app, update gate (macOS only)
#   ./release.sh build-ios [staging|production]          build a signed iOS IPA only (macOS only)
#   ./release.sh upload-ios [staging|production]         upload the built IPA to TestFlight, no gate change (macOS only)
#   ./release.sh verify-upload-ios [staging|production]  preflight the upload: auth + app record, no upload (macOS only)
#   ./release.sh validate-ios [staging|production]       compile iOS unsigned — no Apple account (macOS only)
#   ./release.sh screenshots-ios                         capture + frame iOS App Store screenshots (macOS only)
#   ./release.sh deploy-screenshots-ios [staging|production]  upload iOS screenshots to App Store Connect (macOS only)
#
# Self-contained: this script selects the project's pinned Ruby via rbenv and
# installs each directory's bundler gems on demand, so a bare `./release.sh <cmd>`
# works with no shell setup and no manual `bundle install`.
#
# Typical flow:
#   ./release.sh bump minor
#   ./release.sh deploy staging      # test on the Doxa Staging app
#   git push --follow-tags
#
set -euo pipefail

here="$(cd "$(dirname "$0")" && pwd)"

# --- Ruby toolchain --------------------------------------------------------
# Use the project's pinned Ruby (.ruby-version, currently 3.3.5) no matter how
# the caller's shell is set up. `bundle exec` needs rbenv's Ruby; a shell that
# never initialised rbenv otherwise falls back to system Ruby and fastlane fails.
# Find rbenv even when it isn't on PATH, then put its shims first — shims honour
# .ruby-version automatically, and rbenv on PATH lets those shims resolve.
if ! command -v rbenv >/dev/null 2>&1; then
  for d in "$HOME/.rbenv/bin" /opt/homebrew/bin /usr/local/bin; do
    if [ -x "$d/rbenv" ]; then export PATH="$d:$PATH"; break; fi
  done
fi
if command -v rbenv >/dev/null 2>&1; then
  export PATH="$(rbenv root)/shims:$PATH"
else
  echo "warning: rbenv not found; falling back to '$(command -v ruby || echo no-ruby)'." >&2
  echo "         install rbenv + ruby $(cat "$here/.ruby-version" 2>/dev/null) if fastlane/bundler fail." >&2
fi

# Run a fastlane lane inside a project subdir (android|ios), installing that
# dir's gems first if any are missing — so no manual `bundle install` is needed.
fl() {
  local dir="$1"; shift
  (
    cd "$here/$dir"
    bundle check >/dev/null 2>&1 || bundle install
    bundle exec fastlane "$@"
  )
}

cmd="${1:-}"
arg="${2:-}"

# Google Play API track identifier. The built-in tracks have fixed names:
# internal | alpha (closed testing) | beta (open testing) | production.
# "Open testing" in the console is `beta` in the API.
track="beta"

case "$cmd" in
  deploy)                 fl android deploy flavor:"${arg:-staging}" track:"${track}" ;;
  build)                  fl android build_aab flavor:"${arg:-staging}" ;;
  upload)                 fl android upload flavor:"${arg:-staging}" track:"${track}" ;;
  deploy-screenshots)     fl android upload_screenshots flavor:"${arg:-staging}" track:"${track}" ;;
  bump)                   fl android bump type:"${arg:-build}" ;;
  deploy-ios)             fl ios deploy flavor:"${arg:-staging}" ;;
  build-ios)              fl ios build_ipa flavor:"${arg:-staging}" ;;
  upload-ios)             fl ios upload flavor:"${arg:-staging}" ;;
  verify-upload-ios)      fl ios verify_upload flavor:"${arg:-staging}" ;;
  validate-ios)           fl ios build_unsigned flavor:"${arg:-staging}" ;;
  screenshots-ios)        fl ios screenshots ;;
  deploy-screenshots-ios) fl ios upload_screenshots flavor:"${arg:-staging}" ;;
  *)
    echo "usage: ./release.sh {deploy|build|upload [staging|production] | bump [build|patch|minor|major]" >&2
    echo "                     | deploy-screenshots [staging|production]" >&2
    echo "                     | deploy-ios|build-ios|upload-ios|verify-upload-ios|validate-ios [staging|production]" >&2
    echo "                     | screenshots-ios | deploy-screenshots-ios [staging|production]}" >&2
    exit 1
    ;;
esac
