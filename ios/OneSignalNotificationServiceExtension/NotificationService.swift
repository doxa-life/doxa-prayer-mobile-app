import UserNotifications
import OneSignalExtension

/// OneSignal Notification Service Extension. Enables confirmed delivery,
/// badge counts, and rich media for incoming pushes. Standard OneSignal
/// boilerplate — do not add app logic here.
///
/// This file is committed ready-to-use, but the extension TARGET must be added
/// via Xcode (see ios/PUSH_NOTIFICATIONS_SETUP.md) — creating a target edits the
/// Runner.xcodeproj/project.pbxproj, which is not safe to hand-edit.
class NotificationService: UNNotificationServiceExtension {
    var contentHandler: ((UNNotificationContent) -> Void)?
    var receivedRequest: UNNotificationRequest!
    var bestAttemptContent: UNMutableNotificationContent?

    override func didReceive(
        _ request: UNNotificationRequest,
        withContentHandler contentHandler: @escaping (UNNotificationContent) -> Void
    ) {
        self.receivedRequest = request
        self.contentHandler = contentHandler
        self.bestAttemptContent = (request.content.mutableCopy() as? UNMutableNotificationContent)

        if let bestAttemptContent = bestAttemptContent {
            OneSignalExtension.didReceiveNotificationExtensionRequest(
                self.receivedRequest,
                with: bestAttemptContent,
                withContentHandler: self.contentHandler
            )
        }
    }

    override func serviceExtensionTimeWillExpire() {
        if let contentHandler = contentHandler, let bestAttemptContent = bestAttemptContent {
            OneSignalExtension.serviceExtensionTimeWillExpireRequest(
                self.receivedRequest,
                with: bestAttemptContent
            )
            contentHandler(bestAttemptContent)
        }
    }
}
