# Firebase Crashlytics — setup

The app code is fully wired for Crashlytics (see `lib/services/crash_reporting_service.dart`,
`main.dart`, the router breadcrumb observer, and the non-fatal `reportError` calls). What remains are
the **Firebase-project + platform config steps that need the console and the Xcode project** — they can't
live in Dart. Do these once per platform, per flavor.

There are **two flavors** with distinct bundle ids, so each needs its own Firebase *app* and config file:

| Flavor       | Bundle id / applicationId     |
|--------------|-------------------------------|
| `production` | `life.doxa.pray`              |
| `staging`    | `app.prayer.doxa.staging`     |

The Firebase project(s) already exist (set up for FCM behind OneSignal); you're adding app registrations
+ Crashlytics, not creating a project.

---

## 1. Register the apps + download config files

For **each** flavor's bundle id, in the Firebase console (Project settings → Your apps), register an
Android app and an iOS app (if not already present for FCM), then download:

- Android → `google-services.json`
- iOS → `GoogleService-Info.plist`

(`flutterfire configure` can automate registration + download; we deliberately do **not** use the
generated `firebase_options.dart` — init reads the native config files instead.)

---

## 2. Android

The Gradle plugins are already applied (`android/settings.gradle.kts`, `android/app/build.gradle.kts`).
Place the per-flavor config in the flavor source sets (create the dirs):

```
android/app/src/production/google-services.json
android/app/src/staging/google-services.json
```

The `com.google.gms.google-services` plugin auto-selects the right file per variant. **Android will not
build until these files exist.** Verify: `flutter build apk --flavor staging`.

---

## 3. iOS — create the two flavors

The iOS flavors are **not** created with `flutter_flavorizr`'s `ios:buildConfigurations`/`ios:schema`
processors, because those rewrite `Runner.xcodeproj` and its schemes wholesale. Instead, everything that
lives in files Xcode does **not** own is already committed:

- `ios/config/{production,staging}/GoogleService-Info.plist` — the two Firebase apps
  (`life.doxa.pray` / `life.doxa.pray.staging`; same project, distinct iOS apps).
- `ios/Flutter/{production,staging}{Debug,Profile,Release}.xcconfig` — the six flavor xcconfigs
  (set `ASSET_PREFIX`, `BUNDLE_NAME`, `BUNDLE_DISPLAY_NAME`).
- `ios/Runner/Info.plist` — already tokenized: `$(PRODUCT_BUNDLE_IDENTIFIER)`, `$(BUNDLE_NAME)`,
  `$(BUNDLE_DISPLAY_NAME)`.
- `ios/Runner/Assets.xcassets` — `AppIcon-production` / `AppIcon-staging` icon sets.
- `ios/scripts/copy_google_service_info.sh` — copies the flavor-matched plist into the `.app` at build.
- `ios/Podfile` — its `project 'Runner', {…}` map already lists the six flavor configurations.

What remains are the changes that only Xcode can make safely, done once in
`open ios/Runner.xcworkspace`. **Do these in order** — the Podfile references the six configs, so
`pod install` will fail until they exist.

### 3a. Build configurations (project → Runner → Info → Configurations)

Duplicate the base configs to produce exactly these six (deleting the base three afterward keeps
`flutter build --flavor …` and fastlane's `Release-production`/`Release-staging` unambiguous):

| Duplicate from | New name             |
|----------------|----------------------|
| Debug          | `Debug-production`   |
| Debug          | `Debug-staging`      |
| Profile        | `Profile-production` |
| Profile        | `Profile-staging`    |
| Release        | `Release-production` |
| Release        | `Release-staging`    |

Duplicating at the **project** level adds each config to both the Runner and RunnerTests targets, which
Flutter needs. Then delete the original `Debug`, `Release`, `Profile`.

### 3b. Base configuration file per config (project → Runner → Info → Configurations)

Expand each configuration and set the Runner target's config file to the matching xcconfig
(`Debug-production` → `productionDebug.xcconfig`, `Release-staging` → `stagingRelease.xcconfig`, etc.).
Leave RunnerTests set to its Pods xcconfig.

> ⚠️ **The reference must resolve to `ios/Flutter/<name>.xcconfig`, not `ios/<name>.xcconfig`.** The
> flavor xcconfigs live in `ios/Flutter/` next to `Generated.xcconfig`, and each one does a *relative*
> `#include "Generated.xcconfig"`. If the base-configuration file reference points at a root-level copy,
> the build fails with `could not find included file 'Generated.xcconfig' in search paths`. Verify with:
> `ruby -rxcodeproj -e 'Xcodeproj::Project.open("ios/Runner.xcodeproj").targets.find{|t|t.name=="Runner"}.build_configurations.each{|c|puts "#{c.name} -> #{c.base_configuration_reference&.real_path}"}'`
> — every path should be under `ios/Flutter/`.

### 3c. Per-flavor build settings (Runner target → Build Settings)

- **Packaging → Product Bundle Identifier**: `life.doxa.pray` for the three `*-production` configs,
  `life.doxa.pray.staging` for the three `*-staging` configs. (Removes the stale
  `app.prayer.doxaPrayerMobileApp`.)
- **Asset Catalog Compiler → App Icon Set Name** (`ASSETCATALOG_COMPILER_APPICON_NAME`): set all six to
  `AppIcon-$(ASSET_PREFIX)` (select all six rows, set once — `ASSET_PREFIX` resolves per flavor).

### 3d. Schemes (Product → Scheme → Manage Schemes)

Duplicate the `Runner` scheme twice → name them `production` and `staging` (Flutter matches the scheme
name to `--flavor`; fastlane already expects these names). In each scheme's Edit dialog, set the build
configuration for every action:

| Action           | `production` scheme  | `staging` scheme  |
|------------------|----------------------|-------------------|
| Run              | `Debug-production`   | `Debug-staging`   |
| Test             | `Debug-production`   | `Debug-staging`   |
| Profile          | `Profile-production` | `Profile-staging` |
| Analyze          | `Debug-production`   | `Debug-staging`   |
| Archive          | `Release-production` | `Release-staging` |

Mark both **Shared** so they land in `xcshareddata/xcschemes/`, then delete the `Runner` scheme.

### 3e. Copy the Firebase plist into the bundle (Runner target → Build Phases)

Add a **New Run Script Phase**, rename it **"Copy GoogleService-Info.plist"**, drag it below "Embed
Frameworks" (so `.app` exists), and set the script to:

```sh
"${SRCROOT}/scripts/copy_google_service_info.sh"
```

The script picks `ios/config/<flavor>/GoogleService-Info.plist` from `$ASSET_PREFIX` and copies it in.
Uncheck "Based on dependency analysis" so it runs every build. The plists are intentionally **not** added
to the project / Copy Bundle Resources — this phase is the only thing that bundles one.

### 3f. Pods — repoint the flavor xcconfigs at the per-config Pods files

Once the configs are named `Debug-staging` etc., `pod install` stops generating the base
`Pods-Runner.debug.xcconfig` and instead emits **per-config** files
(`Pods-Runner.debug-staging.xcconfig`, `Pods-Runner.release-production.xcconfig`, …). Each flavor
xcconfig's first line must `#include?` its exact match, or the Pod settings (Firebase, OneSignal, …)
silently don't apply and linking fails:

| xcconfig                       | includes                                    |
|--------------------------------|---------------------------------------------|
| `Flutter/productionDebug.xcconfig`   | `Pods-Runner.debug-production.xcconfig`   |
| `Flutter/stagingDebug.xcconfig`      | `Pods-Runner.debug-staging.xcconfig`      |
| `Flutter/productionProfile.xcconfig` | `Pods-Runner.profile-production.xcconfig` |
| `Flutter/stagingProfile.xcconfig`    | `Pods-Runner.profile-staging.xcconfig`    |
| `Flutter/productionRelease.xcconfig` | `Pods-Runner.release-production.xcconfig` |
| `Flutter/stagingRelease.xcconfig`    | `Pods-Runner.release-staging.xcconfig`    |

(This is the same table encoded in `ios/Podfile`'s `project 'Runner', {…}` config map.)

### 3g. Verify

```
cd ios && pod install
flutter build ios --flavor staging --debug --no-codesign   # or: ./release.sh validate-ios staging
```

Confirm the built `Runner.app` contains `GoogleService-Info.plist` and that its `BUNDLE_ID` matches the
flavor:

```
APP=build/ios/iphoneos/Runner.app
/usr/libexec/PlistBuddy -c 'Print :BUNDLE_ID' "$APP/GoogleService-Info.plist"   # life.doxa.pray[.staging]
/usr/libexec/PlistBuddy -c 'Print :CFBundleIdentifier' "$APP/Info.plist"
```

> **Alternative (not used here):** `dart run flutter_flavorizr -p ios:buildConfigurations,ios:schema`
> automates 3a–3d, but it regenerates `Runner.xcodeproj`/schemes in one pass — the reason this project
> does it by hand instead.

### iOS crash symbolication (dSYM upload)

For **native iOS** crash stack traces to be readable, add the Crashlytics dSYM upload build phase
(runs `${PODS_ROOT}/FirebaseCrashlytics/run`) with input files `${DWARF_DSYM_FOLDER_PATH}/...` and
`$(TARGET_BUILD_DIR)/$(INFOPLIST_PATH)`, per the FlutterFire iOS docs. Flutter/Dart crashes are
symbolicated via Dart and don't depend on this; it matters for native frames.

---

## 4. Dart obfuscation (future)

Release builds do **not** currently obfuscate (checked the fastlane lanes). If you later add
`--obfuscate --split-debug-info=<dir>` to the release builds, Dart stack traces arrive obfuscated and you
must upload the Dart symbols (`firebase crashlytics:symbols:upload --app=<appId> <dir>`) — add that as a
step in `android/fastlane/Fastfile` / `ios/fastlane/Fastfile` release lanes.

---

## 5. Test it

Collection is **disabled in debug builds** (no dev/hot-reload noise), so test on a profile/release build:

```
flutter run --profile --flavor staging
```

On the `/debug` screen (Crashlytics section):
- **Log test non-fatal** → appears as a non-fatal in the console within minutes.
- **Force test crash** → crashes the app; relaunch, and the fatal report uploads on next start.

Verify the report shows the **user identifier** (profileId/trackingId), **custom keys** (flavor, platform,
os_version, device_model, app_version, app_build, timezone), and **navigation breadcrumbs**. Confirm it
routes to the **staging** Firebase app, then repeat on `production`.
