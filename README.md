# doxa_prayer_mobile_app

The Doxa Prayer mobile app (Flutter), backed by the campaigns server API.

## Running the app

The Android build defines two product flavors, `staging` and `production`
(see `android/app/build.gradle.kts`), so **you must pass `--flavor`** — a
plain `flutter run` fails with "Gradle build failed to produce an .apk file"
because no unflavored APK is ever produced.

```bash
flutter run --flavor staging      # installs as "Doxa Staging" (life.doxa.pray.staging)
flutter run --flavor production   # installs as "Doxa Prayer" (life.doxa.pray)
```

The two flavors install side by side on a device. The active flavor also
selects the API host (see `lib/services/api_config.dart`): `staging` → the
Railway staging server, `production` → `pray.doxa.life`.

### VS Code

`.vscode/launch.json` provides three launch configurations:

- **debug (local API)** — staging flavor pointed at `http://localhost:3000`
  via an inline `--dart-define=API_BASE_URL=...`. Use this when running the
  campaigns server locally (`bun run dev`).
- **staging** / **production** — the plain flavors against their real hosts.

### Pointing a build at a different API host

In resolution order (first match wins):

1. `--dart-define=API_BASE_URL=<url>` at build/run time (what the
   "debug (local API)" launch config uses).
2. `API_BASE_URL=<url>` in `.env` — applies to any build without rebuilding
   tooling; see `.env.example`.
3. The build flavor, as above.

When targeting `localhost:3000` from a **physical device over USB**, forward
the port first so the device's localhost reaches your machine:

```bash
adb reverse tcp:3000 tcp:3000
```

The same applies to Android **emulators** (their `localhost` is the emulator
itself, not your machine): run `adb reverse tcp:3000 tcp:3000`, or point the
override at `http://10.0.2.2:3000`, the emulator's alias for the host.

## Releasing (Android)

Releases are automated with [fastlane](https://fastlane.tools), fronted by
`./release.sh`. Each flavor ships to its **own** Play app and updates its **own**
server version gate:

| Target | Flavor | Play app | Version gate |
|---|---|---|---|
| staging | `staging` | `life.doxa.pray.staging` | staging campaigns server |
| production | `production` | `life.doxa.pray` | `pray.doxa.life` |

### One-time setup

1. `cd android && bundle install` (needs Ruby + Bundler: `gem install bundler`).
2. Copy `android/fastlane/.env.example` to `android/fastlane/.env` and fill in:
   - `PLAY_SERVICE_ACCOUNT_JSON` — path to a Google Play service-account JSON
     with release permission on **both** apps (Play Console → Setup → API access).
   - `STAGING_*` / `PRODUCTION_*` — each campaigns server's base URL and an admin
     token with the `content.edit` permission.
3. Signing is unchanged: builds use the existing `android/key.properties` →
   local keystore. `.env`, the service-account JSON, and `key.properties` are all
   gitignored.

### Release flow

```bash
./release.sh bump minor   # 1.0.6+6 -> 1.1.0+7: opens $EDITOR with notes drafted
                          # from git, then commits and tags v1.1.0
./release.sh staging      # builds + uploads to the staging app (internal track),
                          # updates the staging version gate
# ...test on the Doxa Staging app...
./release.sh production   # same build -> production app + production gate
git push --follow-tags    # publish the release commit and tag
```

- `bump` types: `build` (default, just `+N`), `patch`, `minor`, `major`.
- On `bump`, an editor opens with release notes generated from your
  **conventional commits** (`feat:`/`fix:`/…) since the last release tag, via
  [fastlane-plugin-semantic_release](https://github.com/xotahal/fastlane-plugin-semantic_release).
  **Save to proceed; save an empty file to cancel** the release (no commit/tag).
  The notes land in `CHANGELOG.md` and in both flavors' Play changelog files
  (`android/fastlane/metadata/<flavor>/.../changelogs/`). Writing commits in
  conventional format gives the cleanest notes.
- `./release.sh build staging` builds a signed AAB only (no upload).
- Re-deploying the same target without a new `bump` is rejected by Play
  (duplicate version code) — run `bump` first.

## Testing reminders

Local notifications are scheduled by `lib/services/reminders_notifications.dart` and triggered via the reminders CRUD in `lib/services/reminders_controller.dart`. To verify the end-to-end flow on a device:

1. **Build & install on Android device/emulator (API 34+):** `flutter run`. Open the Reminders screen, create a reminder for ~1 minute from now (one weekday only). Confirm the system permission prompt appears on Save. Grant it. Wait. Verify the notification fires with the localized title/body.
2. **Tap the notification** while the app is backgrounded → app foregrounds on `/pray`. Force-stop the app, wait for the next firing, tap the cold-start notification → app launches and lands on `/pray`.
3. **Toggle a reminder off:** verify it does not fire at the next slot. Toggle back on: verify it fires.
4. **Edit weekdays:** change Mon → Tue, verify the Mon slot no longer fires and the Tue slot does.
5. **Delete a reminder:** confirm `adb shell dumpsys alarm | grep <pkg>` no longer lists alarms for that id, or read `_plugin.pendingNotificationRequests()` from a debug button if one is wired.
6. **iOS simulator (or device):** repeat steps 1–4. iOS doesn't require exact-alarm permission. Use a real device if simulator local notifications act flaky.
7. **Permission denial path:** revoke notification permission from system settings, save a reminder, confirm the snackbar shows and the reminder is still persisted.
8. **Reboot persistence (Android):** after creating a reminder, reboot the device, wait for the next slot, confirm the notification fires (validates the boot receiver + the `rescheduleAllReminders` call in `loadReminders()`).
9. **Locale switch:** create a reminder, switch app locale from Settings, fire the reminder, confirm title/body are in the new locale (validates the locale-change reschedule listener in `initRemindersNotifications`).
10. **Static checks:** `flutter analyze` is clean; `flutter test` still passes.
