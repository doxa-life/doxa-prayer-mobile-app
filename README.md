# doxa_prayer_mobile_app

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Learn Flutter](https://docs.flutter.dev/get-started/learn-flutter)
- [Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Flutter learning resources](https://docs.flutter.dev/reference/learning-resources)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.

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
