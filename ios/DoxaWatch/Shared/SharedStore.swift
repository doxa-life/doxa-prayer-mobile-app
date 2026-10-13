import Foundation

// Compiled into both the watch app and its widget extension.

struct SavedGroup: Codable, Hashable, Identifiable {
    let slug: String
    var name: String
    var imageURL: URL?

    var id: String { slug }
}

/// The state the app and the complication share, kept in the App Group so the
/// widget extension can read what the app writes.
enum SharedStore {
    /// `group.life.doxa.pray[.staging].watch`, derived from the bundle id so it
    /// follows the flavor in both targets. Matches DOXA_APP_GROUP in the build
    /// settings (see ios/scripts/watch/add_watch_target.rb).
    static let appGroup: String = {
        let id = Bundle.main.bundleIdentifier ?? "life.doxa.pray.watchkitapp"
        let base = id.components(separatedBy: ".watchkitapp").first ?? id
        return "group.\(base).watch"
    }()

    static let defaults = UserDefaults(suiteName: appGroup) ?? .standard

    private static let groupsKey = "watch.groups"
    private static let prayedKey = "watch.prayedDays"

    static var groups: [SavedGroup] {
        get {
            guard let data = defaults.data(forKey: groupsKey) else { return [] }
            return (try? JSONDecoder().decode([SavedGroup].self, from: data)) ?? []
        }
        set {
            if let data = try? JSONEncoder().encode(newValue) { defaults.set(data, forKey: groupsKey) }
        }
    }

    /// Slug -> the last day (YYYY-MM-DD) it was prayed for.
    static var prayedDays: [String: String] {
        get { defaults.dictionary(forKey: prayedKey) as? [String: String] ?? [:] }
        set { defaults.set(newValue, forKey: prayedKey) }
    }

    /// Opens the app on one group's prayer, from the complication.
    static func prayerURL(_ slug: String) -> URL {
        URL(string: "doxa-watch://pray/\(slug)")!
    }
}

/// Dates as the API wants them: the local calendar day, YYYY-MM-DD.
enum APIDate {
    static func string(_ date: Date) -> String {
        let c = Calendar.current.dateComponents([.year, .month, .day], from: date)
        return String(format: "%04d-%02d-%02d", c.year ?? 0, c.month ?? 0, c.day ?? 0)
    }
}

enum L10n {
    /// Watch-only strings exist in English only until they're reviewed, so a
    /// key missing from the current language falls back to English rather
    /// than showing the key itself.
    static func string(_ key: String) -> String {
        let value = NSLocalizedString(key, comment: "")
        guard value == key, let english = englishBundle else { return value }
        return english.localizedString(forKey: key, value: key, table: nil)
    }

    private static let englishBundle: Bundle? = Bundle.main
        .path(forResource: "en", ofType: "lproj")
        .flatMap(Bundle.init(path:))

    static func format(_ key: String, _ args: CVarArg...) -> String {
        String(format: string(key), locale: Locale.current, arguments: args)
    }
}
