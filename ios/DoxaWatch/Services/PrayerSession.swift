import Foundation

/// Reports one prayer to the server, following the phone's rules in
/// lib/components/prayer_content/prayer_session_view.dart:
///
/// - one session id for the whole prayer, so every report upserts one row;
/// - nothing is sent until the prayer has been open for more than 5 seconds;
/// - a ping every 60 seconds keeps it in the "praying now" count, for at most
///   15 minutes;
/// - leaving without Amen still records the time spent (no analytics event);
/// - Amen records it with `track_event: prayer_logged`.
@MainActor
final class PrayerSession {
    static let minimumDuration: TimeInterval = 5
    static let pingInterval: TimeInterval = 60
    static let pingMaxAge: TimeInterval = 15 * 60

    typealias Recorder = (_ slug: String, _ duration: Int) -> Void

    private let slug: String
    private let date: Date
    private let trackingId: String
    private let onRecorded: Recorder

    private var sessionId = ""
    private var openedAt: Date?
    private var pings: Task<Void, Never>?
    private(set) var isActive = false

    init(slug: String, date: Date, trackingId: String, onRecorded: @escaping Recorder) {
        self.slug = slug
        self.date = date
        self.trackingId = trackingId
        self.onRecorded = onRecorded
    }

    func start() {
        guard !isActive else { return }
        isActive = true
        sessionId = Self.makeId()
        let opened = Date()
        openedAt = opened
        pings = Task { [weak self] in
            try? await Task.sleep(for: .seconds(Self.minimumDuration))
            while !Task.isCancelled, Date().timeIntervalSince(opened) <= Self.pingMaxAge {
                self?.send(trackEvent: nil)
                try? await Task.sleep(for: .seconds(Self.pingInterval))
            }
        }
    }

    /// The prayer was left without Amen (navigated away, or the app went to
    /// the background). Records the time if it passed the minimum.
    func stop() {
        guard isActive, let openedAt else { return }
        endPings()
        let duration = Date().timeIntervalSince(openedAt)
        guard duration > Self.minimumDuration else { return }
        send(trackEvent: nil)
        onRecorded(slug, Int(duration))
    }

    /// Amen: records the prayer and raises the analytics event.
    func amen() {
        guard isActive, let openedAt else { return }
        endPings()
        send(trackEvent: "prayer_logged", openedAt: openedAt)
        onRecorded(slug, Int(Date().timeIntervalSince(openedAt)))
    }

    private func endPings() {
        isActive = false
        pings?.cancel()
        pings = nil
    }

    private func send(trackEvent: String?, openedAt: Date? = nil) {
        guard let opened = openedAt ?? self.openedAt else { return }
        let now = Date()
        let report = PrayerAPI.SessionReport(
            sessionId: sessionId,
            trackingId: trackingId,
            duration: Int(now.timeIntervalSince(opened)),
            timestamp: Self.timestamp(now),
            trackEvent: trackEvent
        )
        let slug = slug, date = date
        Task.detached {
            do {
                try await PrayerAPI.postSession(slug: slug, date: date, report: report)
            } catch {
                log.error("Prayer session report failed: \(error.localizedDescription, privacy: .public)")
            }
        }
    }

    private static func makeId() -> String {
        let ms = String(Int(Date().timeIntervalSince1970 * 1000), radix: 16)
        let rand = String(Int.random(in: 0..<0x7fffffff), radix: 16)
        return "\(ms)-\(rand)"
    }

    private static func timestamp(_ date: Date) -> String {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        return formatter.string(from: date)
    }
}
