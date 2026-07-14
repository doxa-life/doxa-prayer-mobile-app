# App ID migration — `app.prayer.doxa` → `life.doxa.pray`

> **Amendment (staging kept on `app.prayer.doxa.staging`).** Only *production*
> moved. Staging was reverted to its original `app.prayer.doxa.staging` package
> to reuse the existing (permanent) Play + Firebase app slot rather than burn a
> new one. The tables below reflect the final state.

Moving the Android app off the old **testing** Play account onto a new Play
account:

| Flavor       | Old (testing)             | New                        |
|--------------|---------------------------|----------------------------|
| `production` | `app.prayer.doxa`         | **`life.doxa.pray`**         |
| `staging`    | `app.prayer.doxa.staging` | **`app.prayer.doxa.staging`** (unchanged) |

Production uses the default `applicationId`; staging is not a suffix of it, so it
sets a full `applicationId = "app.prayer.doxa.staging"`
([android/app/build.gradle.kts](../android/app/build.gradle.kts)).

**Scope: Android / Play only.** iOS bundle ids (`app.prayer.doxaPrayerMobileApp`)
are a separate scheme and were intentionally left untouched — see the last
section if you ever want parity.

> ⚠️ Play package names are **permanent and non-reusable**. A typo means a
> throwaway app slot forever. Copy/paste the package names, don't retype.

---

## Phase 1 — Firebase (do first)

The `com.google.gms.google-services` + Crashlytics Gradle plugins require a
`google-services.json` whose `package_name` matches each flavor's applicationId.
New packages ⇒ new Firebase Android apps.

1. Firebase console → Project settings → **Add app → Android**:
   - `life.doxa.pray` (new production app)
   - `app.prayer.doxa.staging` already exists — reused, no new app needed
2. Download each `google-services.json` and place:
   - `android/app/src/production/google-services.json`  ← **new directory**
   - `android/app/src/staging/google-services.json`     ← overwrite existing
   > Note: only `src/staging/` existed before this migration. Production now
   > needs its own file or the release build's Crashlytics step fails.
3. Add the release signing SHA-1 / SHA-256 to each Firebase app (needed if
   Google Sign-In / Play Integrity is used).

## Phase 2 — In-repo code changes  ✅ DONE

Already applied in this migration commit:

- `android/app/build.gradle.kts` — `namespace` + `applicationId` → `life.doxa.pray`
- `android/fastlane/Fastfile` — `FLAVORS` packages → `life.doxa.pray[.staging]`
- `pubspec.yaml` — flavorizr Android `applicationId` entries
- `lib/screens/debug_screen.dart`, `test/update_gate_test.dart` — Play Store URL
- `README.md`, `FIREBASE_CRASHLYTICS_SETUP.md` — reference tables

## Phase 3 — New Play Console account & apps

1. In the **new** Play Console, create the production app with package name
   exactly `life.doxa.pray`. Staging stays as the existing
   `app.prayer.doxa.staging` app.
2. Complete each app's setup wizard (content rating, data safety, target
   audience, etc.) — internal-track uploads are blocked until this is done.
3. **Play App Signing**: fresh apps, so Google establishes the app-signing key
   on first upload. The existing **upload** keystore (`android/key.properties`)
   is reused as-is — no keystore changes needed.

## Phase 4 — Point fastlane at the new Play account

fastlane authenticates via `PLAY_SERVICE_ACCOUNT_JSON`
([android/fastlane/Fastfile](../android/fastlane/Fastfile)).

1. New Play Console → **Setup → API access** → create/link a Google Cloud
   service account and download its JSON key.
2. Grant that service account **Release** permission on **both** new apps.
3. Edit `android/fastlane/.env`:
   ```
   PLAY_SERVICE_ACCOUNT_JSON=/path/to/new-play-service-account.json
   ```
4. `STAGING_/PRODUCTION_SERVER_URL` + tokens are the campaigns-server version
   gates — unrelated to the Play account, leave them alone.

## Phase 5 — First deploy & verify

```bash
flutter clean                 # namespace/appId change needs a clean build
cd android
bundle exec fastlane deploy flavor:staging      # → new staging app, internal track
bundle exec fastlane deploy flavor:production    # → new production app, internal track
```

Brand-new Play apps have no prior `versionCode`, so the current pubspec version
uploads without a bump.

## Also update (out of the repo)

- **OneSignal / FCM**: each OneSignal app binds to one package + FCM project.
  New package + new Firebase project ⇒ update each OneSignal app's Android
  package name and FCM v1 service-account credentials, or the `ONESIGNAL_APP_ID*`
  values in `.env`.

## iOS parity (not done — for reference)

If iOS is ever moved to match, these still carry `app.prayer.doxa*`:
`ios/Runner.xcodeproj/project.pbxproj`, `ios/Runner/Info.plist`, the App Group
`group.app.prayer.doxa.onesignal`, `pubspec.yaml` flavorizr `bundleId` entries,
and the `ios/fastlane` docs.
