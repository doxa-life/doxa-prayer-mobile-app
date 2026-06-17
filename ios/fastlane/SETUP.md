# iOS fastlane setup

Mirrors the Android release automation (`android/fastlane/`). Two flavors map to
two App Store Connect apps and the same campaigns-server version gate.

| Flavor       | Bundle ID                  | Scheme       | Config             |
|--------------|----------------------------|--------------|--------------------|
| staging      | `app.prayer.doxa.staging`  | `staging`    | `Release-staging`    |
| production   | `app.prayer.doxa`          | `production` | `Release-production` |

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
   bundle exec fastlane match appstore -a app.prayer.doxa
   bundle exec fastlane match appstore -a app.prayer.doxa.staging
   ```
5. **Project signing** — set `DEVELOPMENT_TEAM` and switch the `Release-staging`
   / `Release-production` configs to manual signing with the match profiles
   (`match AppStore <bundle id>`). Easiest in Xcode (Runner target → Signing &
   Capabilities, per configuration), or edit
   `ios/Runner.xcodeproj/project.pbxproj`.
6. **Ship it:**
   ```bash
   bundle exec fastlane deploy flavor:staging      # build + TestFlight + staging gate
   bundle exec fastlane deploy flavor:production
   ```

Because every account value lives in `fastlane/.env` + `Appfile`, swapping from
any test account to the final one is just editing `.env`, re-running `match`, and
updating `DEVELOPMENT_TEAM`. The Fastfile, lanes, and `release.sh` never change.

---

## Lanes

| Lane                          | What it does                                                        |
|-------------------------------|--------------------------------------------------------------------|
| `build_unsigned flavor:`      | Compile only, no signing, **no account** — validation              |
| `build_ipa flavor:`           | match (readonly) + signed App Store IPA                             |
| `deploy flavor:`              | `build_ipa` → upload to TestFlight → update server version gate     |
| `update_server_version flavor:` | PUT the gate only (same endpoint as Android)                      |

Version bumping stays on the Android side: `./release.sh bump …` edits the shared
`pubspec.yaml`; iOS reads it automatically. Note the server version gate is shared
by both platforms — releasing iOS sets the same `latest_version` Android uses.
