#!/usr/bin/env bash
#
# Doxa Prayer — release wrapper around fastlane (Android + iOS).
#
#   ./release.sh bump [build|patch|minor|major]    cut a release: bump version,
#                                                  draft notes in $EDITOR, commit, tag
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
# Typical flow:
#   ./release.sh bump minor
#   ./release.sh deploy staging      # test on the Doxa Staging app
#   git push --follow-tags
#
set -euo pipefail

# Run under the project's pinned Ruby (.ruby-version, currently 3.3.5) regardless
# of how the caller's shell is set up. `bundle exec` below needs rbenv's Ruby;
# without this, a shell that hasn't initialised rbenv falls back to system Ruby
# and fastlane/bundler fail. rbenv shims honour .ruby-version automatically.
if command -v rbenv >/dev/null 2>&1; then
  export PATH="$(rbenv root)/shims:$PATH"
elif [ -d "$HOME/.rbenv/shims" ]; then
  export PATH="$HOME/.rbenv/shims:$PATH"
fi

cmd="${1:-}"
arg="${2:-}"

# Google Play API track identifier. The built-in tracks have fixed names:
# internal | alpha (closed testing) | beta (open testing) | production.
# "Open testing" in the console is `beta` in the API.
track="beta"

here="$(dirname "$0")"

case "$cmd" in
  deploy)
    (cd "$here/android" && bundle exec fastlane deploy flavor:"${arg:-staging}" track:"${track}")
    ;;
  build)
    (cd "$here/android" && bundle exec fastlane build_aab flavor:"${arg:-staging}")
    ;;
  upload)
    (cd "$here/android" && bundle exec fastlane upload flavor:"${arg:-staging}" track:"${track}")
    ;;
  deploy-screenshots)
    (cd "$here/android" && bundle exec fastlane upload_screenshots flavor:"${arg:-staging}" track:"${track}")
    ;;
  bump)
    (cd "$here/android" && bundle exec fastlane bump type:"${arg:-build}")
    ;;
  deploy-ios)
    (cd "$here/ios" && bundle exec fastlane deploy flavor:"${arg:-staging}")
    ;;
  build-ios)
    (cd "$here/ios" && bundle exec fastlane build_ipa flavor:"${arg:-staging}")
    ;;
  upload-ios)
    (cd "$here/ios" && bundle exec fastlane upload flavor:"${arg:-staging}")
    ;;
  verify-upload-ios)
    (cd "$here/ios" && bundle exec fastlane verify_upload flavor:"${arg:-staging}")
    ;;
  validate-ios)
    (cd "$here/ios" && bundle exec fastlane build_unsigned flavor:"${arg:-staging}")
    ;;
  screenshots-ios)
    (cd "$here/ios" && bundle exec fastlane screenshots)
    ;;
  deploy-screenshots-ios)
    (cd "$here/ios" && bundle exec fastlane upload_screenshots flavor:"${arg:-staging}")
    ;;
  *)
    echo "usage: ./release.sh {deploy|build|upload [staging|production] | bump [build|patch|minor|major]" >&2
    echo "                     | deploy-screenshots [staging|production]" >&2
    echo "                     | deploy-ios|build-ios|upload-ios|verify-upload-ios|validate-ios [staging|production]" >&2
    echo "                     | screenshots-ios | deploy-screenshots-ios [staging|production]}" >&2
    exit 1
    ;;
esac
