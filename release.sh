#!/usr/bin/env bash
#
# Doxa Prayer — Android release wrapper around fastlane.
#
#   ./release.sh bump [build|patch|minor|major]    cut a release: bump version,
#                                                  draft notes in $EDITOR, commit, tag
#   ./release.sh deploy [staging|production]       build + upload app, update gate
#   ./release.sh build [staging|production]        build a signed AAB only (no upload)
#
# Typical flow:
#   ./release.sh bump minor
#   ./release.sh deploy staging      # test on the Doxa Staging app
#   git push --follow-tags
#
set -euo pipefail

cmd="${1:-}"
arg="${2:-}"

cd "$(dirname "$0")/android"

case "$cmd" in
  deploy)
    bundle exec fastlane deploy flavor:"${arg:-staging}"
    ;;
  build)
    bundle exec fastlane build_aab flavor:"${arg:-staging}"
    ;;
  upload)
    bundle exec fastlane upload flavor:"${arg:-staging}"
    ;;
  bump)
    bundle exec fastlane bump type:"${arg:-build}"
    ;;
  *)
    echo "usage: ./release.sh {deploy [staging|production] | build [staging|production] | bump [build|patch|minor|major]}" >&2
    exit 1
    ;;
esac
