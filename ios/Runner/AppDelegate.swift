import FirebaseCore
import Flutter
import UIKit
import UserNotifications

@main
@objc class AppDelegate: FlutterAppDelegate, FlutterImplicitEngineDelegate {
  /// Retained so the badge channel's handler isn't torn down after setup.
  private var badgeChannel: FlutterMethodChannel?

  /// Native → Dart bridge for reminder-notification taps. In this app's
  /// UIScene / implicit-engine setup, plugins register on the *implicit engine's*
  /// registry, which is NOT the app-lifecycle list FlutterAppDelegate forwards
  /// UNUserNotificationCenter callbacks to — so flutter_local_notifications never
  /// sees a tap. We handle the tap in `userNotificationCenter(_:didReceive:)`
  /// below and forward the payload over this channel instead. Consumed by
  /// initRemindersNotifications() in lib/services/reminders_notifications.dart.
  private var notificationChannel: FlutterMethodChannel?

  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    // Reads GoogleService-Info.plist from the app bundle. The correct per-flavor
    // plist must be present for the active flavor — see FIREBASE_CRASHLYTICS_SETUP.md
    // ("iOS" section) for the per-flavor plist + build-phase setup.
    FirebaseApp.configure()

    // Make this AppDelegate the UNUserNotificationCenter delegate so our
    // `userNotificationCenter(_:didReceive:)` override below runs on a
    // notification tap. Re-asserted in didInitializeImplicitFlutterEngine in
    // case engine setup swaps the delegate afterwards.
    UNUserNotificationCenter.current().delegate = self

    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  func didInitializeImplicitFlutterEngine(_ engineBridge: FlutterImplicitEngineBridge) {
    GeneratedPluginRegistrant.register(with: engineBridge.pluginRegistry)

    // Reset the app-icon badge on request from Dart (clearNotificationBadge).
    // flutter_local_notifications can set a badge but not clear it, so we do it
    // natively here.
    let registrar = engineBridge.pluginRegistry.registrar(forPlugin: "DoxaBadgePlugin")
    if let messenger = registrar?.messenger() {
      let channel = FlutterMethodChannel(
        name: "app.prayer.doxa/badge", binaryMessenger: messenger)
      channel.setMethodCallHandler { call, result in
        guard call.method == "clearBadge" else {
          result(FlutterMethodNotImplemented)
          return
        }
        if #available(iOS 16.0, *) {
          UNUserNotificationCenter.current().setBadgeCount(0)
        } else {
          UIApplication.shared.applicationIconBadgeNumber = 0
        }
        result(nil)
      }
      badgeChannel = channel

      // Native → Dart channel for reminder-notification taps (see the
      // UNUserNotificationCenter delegate override below).
      notificationChannel = FlutterMethodChannel(
        name: "app.prayer.doxa/notifications", binaryMessenger: messenger)
    }

    // Re-assert the notification delegate after the engine is up, in case engine
    // initialisation installed its own delegate.
    UNUserNotificationCenter.current().delegate = self
  }

  /// Handles a notification tap. FlutterAppDelegate's built-in forwarding can't
  /// reach flutter_local_notifications here (plugins live on the implicit
  /// engine's registry), so we identify the reminder by its `payload` userInfo
  /// key — set by flutter_local_notifications at schedule time — and forward it
  /// to Dart over `notificationChannel`. Dart then routes to the Pray tab.
  override func userNotificationCenter(
    _ center: UNUserNotificationCenter,
    didReceive response: UNNotificationResponse,
    withCompletionHandler completionHandler: @escaping () -> Void
  ) {
    let userInfo = response.notification.request.content.userInfo
    let payload = userInfo["payload"] as? String
    NSLog(
      "[REMINDER_TAP native] didReceive actionId=%@ payload=%@",
      response.actionIdentifier, payload ?? "nil")

    // Only the default "tap the notification" action opens the app to the
    // reminder; ignore dismiss and other action identifiers.
    if response.actionIdentifier == UNNotificationDefaultActionIdentifier,
      let payload = payload
    {
      notificationChannel?.invokeMethod("reminderTapped", arguments: payload)
    }

    // We own the delegate, so no other handler will call this — call it here.
    completionHandler()
  }
}
