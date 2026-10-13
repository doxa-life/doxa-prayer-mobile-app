import Foundation
import UserNotifications

/// The watch's own daily reminder, for the prototype. Once the watch app is
/// embedded, the phone's reminders reach the watch instead and this goes away
/// (two schedulers would remind people twice). The payload uses the phone's
/// format (a slug, or "pray"), so tapping either kind opens the same way.
enum Reminders {
    private static let dailyId = "doxa.watch.daily"
    private static let testId = "doxa.watch.test"

    static func requestPermission() async -> Bool {
        (try? await UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound])) ?? false
    }

    static func schedule(enabled: Bool, minutes: Int, groups: [SavedGroup]) {
        let center = UNUserNotificationCenter.current()
        center.removePendingNotificationRequests(withIdentifiers: [dailyId])
        guard enabled, !groups.isEmpty else { return }
        var time = DateComponents()
        time.hour = minutes / 60
        time.minute = minutes % 60
        let trigger = UNCalendarNotificationTrigger(dateMatching: time, repeats: true)
        center.add(UNNotificationRequest(identifier: dailyId, content: content(groups), trigger: trigger))
    }

    static func sendTest(groups: [SavedGroup]) {
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 5, repeats: false)
        UNUserNotificationCenter.current().add(UNNotificationRequest(identifier: testId, content: content(groups), trigger: trigger))
    }

    private static func content(_ groups: [SavedGroup]) -> UNNotificationContent {
        let content = UNMutableNotificationContent()
        content.title = L10n.string("reminderNotificationTitle")
        content.sound = .default
        if groups.count == 1, let group = groups.first {
            content.body = L10n.format("reminderNotificationBodyForGroup", group.name)
            content.userInfo = ["payload": group.slug]
        } else {
            content.body = L10n.string("reminderNotificationBody")
            content.userInfo = ["payload": "pray"]
        }
        return content
    }

    /// The people group a tapped notification is about, or nil for a generic
    /// one. Understands the phone's local reminders (`payload`: a slug or
    /// "pray") and OneSignal pushes (`custom.a.slug` / `custom.a.route`, see
    /// lib/services/push_notifications_service.dart).
    static func slug(from userInfo: [AnyHashable: Any]) -> String? {
        if let payload = userInfo["payload"] as? String {
            return payload == "pray" || payload.isEmpty ? nil : payload
        }
        var data = userInfo
        if let custom = userInfo["custom"] as? [AnyHashable: Any], let extra = custom["a"] as? [AnyHashable: Any] {
            data = extra
        }
        if let slug = data["slug"] as? String, !slug.isEmpty { return slug }
        if let route = data["route"] as? String {
            let parts = route.split(separator: "/")
            if parts.count == 2, parts[1] == "prayer" { return String(parts[0]) }
        }
        return nil
    }
}
