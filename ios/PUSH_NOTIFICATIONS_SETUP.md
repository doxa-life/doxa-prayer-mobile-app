# Push notifications — remaining native / dashboard setup

The Flutter/Dart integration, the iOS `aps-environment` + App Group entitlements,
the `remote-notification` background mode, and the Notification Service Extension
(NSE) **source** are all committed. The steps below still have to be done by hand
because they modify `Runner.xcodeproj/project.pbxproj` (target creation) or live
in external dashboards — neither can be safely automated via text edits.

## 1. OneSignal dashboards (two apps: prod + staging)

A OneSignal app binds to a single iOS bundle id / Android package, so create two:

| OneSignal app | iOS bundle id            | Android package            | Env var                    |
| ------------- | ------------------------ | -------------------------- | -------------------------- |
| Production    | `app.prayer.doxa`        | `app.prayer.doxa`          | `ONESIGNAL_APP_ID`         |
| Staging       | `app.prayer.doxa.staging`| `app.prayer.doxa.staging`  | `ONESIGNAL_APP_ID_STAGING` |

Put both App IDs in `.env` (see `.env.example`). For each app:
- **iOS**: upload an APNs `.p8` Auth Key (Key ID + Team ID). Enable the Push
  Notifications capability on the App ID in the Apple Developer portal.
- **Android**: upload the FCM v1 Service Account JSON (no `google-services.json`
  is added to the app — OneSignal handles FCM registration internally).

## 2. Apple Developer portal

- Register the **App Group** `group.app.prayer.doxa.onesignal` and enable it for
  **both** bundle ids (`app.prayer.doxa` and `.staging`).
- Ensure the provisioning profiles for the Runner and the NSE target include the
  Push Notifications + App Groups capabilities.

## 3. Xcode — add the Notification Service Extension target

1. File ▸ New ▸ Target ▸ **Notification Service Extension**. Name it
   `OneSignalNotificationServiceExtension`. Set the deployment target to match
   Runner. When prompted, do **not** activate the scheme.
2. Delete the auto-generated `NotificationService.swift` / `Info.plist` and add
   the committed files from `ios/OneSignalNotificationServiceExtension/` to the
   new target instead (or point the target's build settings at them).
3. Set the extension's **App Groups** capability to `group.app.prayer.doxa.onesignal`
   (both flavor build configs).
4. Confirm the Runner target now shows the **Push Notifications** capability
   (backed by the committed `Runner.entitlements`) and the **App Groups**
   capability with the same id, for both the production and staging configs.

## 4. Podfile — wire the extension's pod

After the target exists, add to `ios/Podfile` (top level) and run `pod install`:

```ruby
target 'OneSignalNotificationServiceExtension' do
  use_frameworks!
  pod 'OneSignalXCFramework', '>= 5.0.0', '< 6.0.0'
end
```

> Do **not** add this block before the Xcode target exists — `pod install` will
> fail on an unknown target.

## 5. Notes

- No `AppDelegate.swift` / `SceneDelegate.swift` changes are needed — the Flutter
  plugin registers via `GeneratedPluginRegistrant`.
- If a Swift 6 / SPM conformance error appears for `onesignal_flutter` (same class
  of issue that pinned `app_settings` to 5.1.1), force the CocoaPods path or pin
  the plugin version accordingly.
