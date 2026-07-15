#!/usr/bin/env bash
#
# Doxa Prayer — release wrapper around fastlane (Android + iOS).
#
#   ./release.sh bump [build|patch|minor|major]    cut a release: bump version,
#                                                  draft notes in $EDITOR, commit, tag
#   ./release.sh deploy [staging|production]       build + upload Android app, update gate
#   ./release.sh build [staging|production]        build a signed AAB only (no upload)
#
#   ./release.sh deploy-ios [staging|production]   build + upload iOS app, update gate (macOS only)
#   ./release.sh build-ios [staging|production]    build a signed iOS IPA only (macOS only)
#   ./release.sh validate-ios [staging|production] compile iOS unsigned — no Apple account (macOS only)
#
# Typical flow:
#   ./release.sh bump minor
#   ./release.sh deploy staging      # test on the Doxa Staging app
#   git push --follow-tags
#
set -euo pipefail

cmd="${1:-}"
arg="${2:-}"

track="open"

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
  validate-ios)
    (cd "$here/ios" && bundle exec fastlane build_unsigned flavor:"${arg:-staging}")
    ;;
  *)
    echo "usage: ./release.sh {deploy|build|upload [staging|production] | bump [build|patch|minor|major]" >&2
    echo "                     | deploy-ios|build-ios|validate-ios [staging|production]}" >&2
    exit 1
    ;;
esac
