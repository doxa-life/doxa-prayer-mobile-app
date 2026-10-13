import SwiftUI
import UserNotifications
import WatchKit

/// Entry point for the DOXA Apple Watch companion.
///
/// The watch app is self-contained: it lives entirely under `ios/DoxaWatch/`
/// and is not embedded in the iPhone app yet, so it cannot affect how Runner
/// builds or behaves. See docs/apple-watch.md for the plan and how to remove it.
@main
struct DoxaWatchApp: App {
    @WKApplicationDelegateAdaptor private var delegate: AppDelegate
    @Environment(\.scenePhase) private var scenePhase
    @State private var model = AppModel.shared

    var body: some Scene {
        WindowGroup {
            HomeView()
                .environment(model)
                .tint(Theme.accent)
                .onOpenURL { model.handleURL($0) }
        }
        .onChange(of: scenePhase) { _, phase in
            if phase == .active {
                Task { await model.prefetch() }
                Prefetch.scheduleNext()
            }
        }
        .backgroundTask(.appRefresh(Prefetch.identifier)) {
            await AppModel.shared.prefetch()
            await Prefetch.scheduleNext()
        }
    }
}

/// Background refresh, so tomorrow's prayer is already on the watch.
enum Prefetch {
    static let identifier = "doxa.prefetch"

    @MainActor
    static func scheduleNext() {
        let next = Date().addingTimeInterval(6 * 3600)
        WKApplication.shared().scheduleBackgroundRefresh(withPreferredDate: next, userInfo: identifier as NSString) { error in
            if let error { log.error("Background refresh not scheduled: \(error.localizedDescription, privacy: .public)") }
        }
    }
}

final class AppDelegate: NSObject, WKApplicationDelegate, UNUserNotificationCenterDelegate {
    func applicationDidFinishLaunching() {
        UNUserNotificationCenter.current().delegate = self
    }

    /// Show reminders even while the app is open.
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification) async -> UNNotificationPresentationOptions {
        [.banner, .sound]
    }

    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse) async {
        let userInfo = response.notification.request.content.userInfo
        await MainActor.run { AppModel.shared.handleNotification(userInfo) }
    }
}

enum Theme {
    /// AppColors.secondary — the app's green, readable on the watch's black.
    static let accent = Color(red: 0x73 / 255, green: 0xA1 / 255, blue: 0x7F / 255)
    /// AppColors.primary — the verse card background on the phone.
    static let primary = Color(red: 0x3B / 255, green: 0x46 / 255, blue: 0x3D / 255)
    /// AppColors.onPrimary — warm off-white for text on primary.
    static let onPrimary = Color(red: 0xCB / 255, green: 0xC5 / 255, blue: 0xB9 / 255)
    /// AppColors.secondaryLight.
    static let accentLight = Color(red: 0x92 / 255, green: 0xB1 / 255, blue: 0x95 / 255)
}
