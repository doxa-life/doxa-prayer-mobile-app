# iOS fastlane setup

Mirrors the Android release automation (`android/fastlane/`). Two flavors map to
two App Store Connect apps and the same campaigns-server version gate.

| Flavor       | Bundle ID                  | Scheme       | Config               |
|--------------|----------------------------|--------------|----------------------|
| staging      | `life.doxa.pray.staging`   | `staging`    | `Release-staging`    |
| production   | `life.doxa.pray`           | `production` | `Release-production` |

Each flavor also ships a OneSignal Notification Service Extension whose bundle
id extends the main app's (`…OneSignalNotificationServiceExtension`); the exact
values live in `fastlane/.env` (`ONESIGNAL_APP_ID`, `ONESIGNAL_APP_ID_STAGING`)
and are picked up by both `Matchfile` and `Fastfile` — one match run signs both
main + extension per flavor.

> **iOS builds require macOS + Xcode.** None of the build/upload lanes run on
> Linux. The scaffold (this folder) is committed from anywhere; you run it on a Mac.

---

## What you can do NOW — no Apple account needed

On a Mac, with no Apple Developer account and no signing set up:

```bash
cd ios
bundle install
bundle exec fastlane build_unsigned flavor:staging
bundle exec fastlane build_unsigned flavor:production
```

This compiles the app (`flutter build ios --no-codesign`) and proves the whole
iOS pipeline — flavors, xcconfigs, plugins, assets — works. It is the most you
can validate before committing to an account.

You can also run it on the simulator: `flutter run --flavor staging` (no signing).

---

## What's deferred until the FINAL App Store Connect account exists

These are the only account-bound steps. Doing them now against a personal team
would just be redone, so wait — and when the real account lands, this is the
entire list (~15 min, no code changes):

1. **Membership** — confirm the org is in the Apple Developer Program; copy the
   **Team ID** (App Store Connect → Membership).
2. **App records** — create two apps in App Store Connect, one per bundle ID
   above.
3. **API key** — App Store Connect → Users and Access → Integrations → App Store
   Connect API. Download the `.p8`, note Key ID + Issuer ID. Store the `.p8`
   outside the repo.
4. **match repo** — create a private git repo for certs/profiles, then on the Mac:
   ```bash
   cd ios
   cp fastlane/.env.example fastlane/.env   # fill in all values
   bundle exec fastlane match appstore     # picks up all 4 bundle ids from Matchfile
   ```
   Matchfile lists the two main-app bundle ids plus the two OneSignal extension
   ids (from `ONESIGNAL_APP_ID` / `ONESIGNAL_APP_ID_STAGING` in `.env`), so one
   call syncs everything. `MATCH_PASSWORD` is a passphrase *you invent* (used
   to AES-encrypt the certs before pushing to the match repo) — generate one
   with `openssl rand -base64 32`, save it in a password manager, keep the
   `.env` off any shared drive.
5. **Project signing** — for both **Runner** and
   **OneSignalNotificationServiceExtension** targets, switch the
   `Release-staging` / `Release-production` configs to manual signing with the
   match profiles. Per configuration set:
   ```
   CODE_SIGN_STYLE = Manual
   CODE_SIGN_IDENTITY = "Apple Distribution"
   PROVISIONING_PROFILE_SPECIFIER = "match AppStore $(PRODUCT_BUNDLE_IDENTIFIER)"
   DEVELOPMENT_TEAM = <your APPLE_TEAM_ID>
   ```
   Also replace the placeholder `DEVELOPMENT_TEAM = Z463F93SW9` in the four
   Debug/Profile configs with the real team id. Easiest in Xcode (target →
   Signing & Capabilities → per-configuration), or edit
   `ios/Runner.xcodeproj/project.pbxproj` directly. Debug/Profile can keep
   `CODE_SIGN_STYLE = Automatic` — only archives need match.
6. **Ship it** — from the repo root:
   ```bash
   ./release.sh deploy-ios staging               # build + TestFlight + staging gate
   ./release.sh screenshots-ios                  # capture 6.9" iPhone + 13" iPad
   ./release.sh deploy-screenshots-ios staging   # upload to Doxa Staging listing
   # once staging is green:
   ./release.sh deploy-ios production
   ./release.sh deploy-screenshots-ios production
   ```

Because every account value lives in `fastlane/.env` + `Appfile`, swapping from
any test account to the final one is just editing `.env`, re-running `match`, and
updating `DEVELOPMENT_TEAM`. The Fastfile, lanes, and `release.sh` never change.

---

## Lanes

| Lane                            | What it does                                                       |
|---------------------------------|--------------------------------------------------------------------|
| `build_unsigned flavor:`        | Compile only, no signing, **no account** — validation              |
| `build_ipa flavor:`             | match (readonly) + signed App Store IPA (main app + OneSignal ext) |
| `deploy flavor:`                | `build_ipa` → upload to TestFlight → update server version gate    |
| `update_server_version flavor:` | PUT the gate only (same endpoint as Android)                       |
| `screenshots`                   | Capture + frame 6.9" iPhone + 13" iPad shots on the simulator      |
| `upload_screenshots flavor:`    | Push framed screenshots to a flavor's ASC listing (via `deliver`)  |

Version bumping stays on the Android side: `./release.sh bump …` edits the shared
`pubspec.yaml`; iOS reads it automatically. Note the server version gate is shared
by both platforms — releasing iOS sets the same `latest_version` Android uses.
