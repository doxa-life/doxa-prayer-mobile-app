import Foundation
import os

let log = Logger(subsystem: "life.doxa.pray.watch", category: "DoxaWatch")

/// The prayer API, with a disk cache so the prayer works offline once fetched.
/// Mirrors lib/services/prayer_content_service.dart and people_groups_service.dart.
enum PrayerAPI {
    /// A day's content doesn't change once that day has started
    /// (CachePolicy.prayerContent on the phone).
    static let prayerContentMaxAge: TimeInterval = 30 * 24 * 3600
    static let peopleGroupListMaxAge: TimeInterval = 7 * 24 * 3600

    static func prayerContent(slug: String, date: Date, language: String, forceRefresh: Bool = false) async throws -> PrayerContentResponse {
        let day = APIDate.string(date)
        return try await getJSON(
            url: APIConfig.url("/api/people-groups/\(slug)/prayer-content/\(day)", query: ["language": language]),
            cacheKey: "prayer-\(slug)-\(day)-\(language)",
            maxAge: prayerContentMaxAge,
            forceRefresh: forceRefresh
        )
    }

    static func peopleGroups(language: String) async throws -> [PeopleGroupSummary] {
        let list: PeopleGroupList = try await getJSON(
            url: APIConfig.url("/api/people-groups/list", query: ["lang": language, "fields": "name,slug,image_url,country_code"]),
            cacheKey: "people-groups-\(language)",
            maxAge: peopleGroupListMaxAge,
            forceRefresh: false
        )
        return list.posts
    }

    struct SessionReport: Encodable {
        let sessionId: String
        let trackingId: String
        let duration: Int
        let timestamp: String
        /// Set on the explicit Amen only, as on the phone, so the pings a
        /// running session makes don't each raise an analytics event.
        let trackEvent: String?

        private enum CodingKeys: String, CodingKey {
            case sessionId = "session_id", trackingId = "tracking_id", duration, timestamp, trackEvent = "track_event"
        }
    }

    static func postSession(slug: String, date: Date, report: SessionReport) async throws {
        let url = APIConfig.url("/api/people-groups/\(slug)/prayer-content/\(APIDate.string(date))/session")
        let body = try JSONEncoder().encode(report)
        #if DEBUG
        // Like the phone, development builds never write to the live counts.
        log.debug("Skipping prayer session POST (debug build) \(url.absoluteString, privacy: .public) \(String(decoding: body, as: UTF8.self), privacy: .public)")
        return
        #else
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = body
        let (_, response) = try await URLSession.shared.data(for: request)
        guard (response as? HTTPURLResponse)?.statusCode == 200 else {
            throw APIError.status((response as? HTTPURLResponse)?.statusCode ?? 0)
        }
        #endif
    }

    enum APIError: Error { case status(Int) }

    /// Cache-first: a fresh cached copy is used without a network round-trip.
    /// When the network fails, a stale copy is still better than nothing.
    private static func getJSON<T: Decodable>(url: URL, cacheKey: String, maxAge: TimeInterval, forceRefresh: Bool) async throws -> T {
        let decoder = JSONDecoder()
        if !forceRefresh, let cached = await ResponseCache.shared.read(cacheKey, maxAge: maxAge),
           let value = try? decoder.decode(T.self, from: cached) {
            return value
        }
        do {
            var request = URLRequest(url: url)
            request.setValue("application/json", forHTTPHeaderField: "Accept")
            let (data, response) = try await URLSession.shared.data(for: request)
            guard let status = (response as? HTTPURLResponse)?.statusCode, status == 200 else {
                throw APIError.status((response as? HTTPURLResponse)?.statusCode ?? 0)
            }
            let value = try decoder.decode(T.self, from: data)
            await ResponseCache.shared.write(cacheKey, data)
            return value
        } catch {
            if let stale = await ResponseCache.shared.read(cacheKey, maxAge: .infinity),
               let value = try? decoder.decode(T.self, from: stale) {
                log.info("Serving stale \(cacheKey, privacy: .public) after \(error.localizedDescription, privacy: .public)")
                return value
            }
            throw error
        }
    }
}

actor ResponseCache {
    static let shared = ResponseCache()

    private let directory: URL = {
        let base = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask)[0]
        let dir = base.appendingPathComponent("api", isDirectory: true)
        try? FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
        return dir
    }()

    private func file(_ key: String) -> URL {
        let safe = key.map { $0.isLetter || $0.isNumber || $0 == "-" ? $0 : "_" }
        return directory.appendingPathComponent(String(safe) + ".json")
    }

    func read(_ key: String, maxAge: TimeInterval) -> Data? {
        let url = file(key)
        guard let attributes = try? FileManager.default.attributesOfItem(atPath: url.path),
              let modified = attributes[.modificationDate] as? Date,
              Date().timeIntervalSince(modified) <= maxAge else { return nil }
        return try? Data(contentsOf: url)
    }

    func write(_ key: String, _ data: Data) {
        try? data.write(to: file(key), options: .atomic)
    }

    /// Drops anything older than [age], so day-by-day content can't pile up.
    func prune(olderThan age: TimeInterval) {
        let files = (try? FileManager.default.contentsOfDirectory(at: directory, includingPropertiesForKeys: [.contentModificationDateKey])) ?? []
        for url in files {
            let modified = (try? url.resourceValues(forKeys: [.contentModificationDateKey]))?.contentModificationDate ?? .distantPast
            if Date().timeIntervalSince(modified) > age { try? FileManager.default.removeItem(at: url) }
        }
    }
}
