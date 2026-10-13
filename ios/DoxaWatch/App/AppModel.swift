import Foundation
import Observation
import WidgetKit

enum Route: Hashable {
    case prayer(slug: String)
    case picker
    case settings
}

/// App-wide state: the people groups the user prays for, what's been prayed
/// today, reminder settings, and navigation.
///
/// For the prototype the groups are chosen on the watch. Once the settings
/// bridge lands (docs/apple-watch.md, build order step 6) they come from the
/// phone instead, along with the language and tracking id.
@MainActor
@Observable
final class AppModel {
    static let shared = AppModel()

    /// The phone allows at most this many (kMaxPeopleGroups).
    static let maxGroups = 5

    var path: [Route] = []
    private(set) var groups: [SavedGroup] = []
    private(set) var prayedDays: [String: String] = [:]
    var reminderEnabled = false { didSet { persist(); reschedule() } }
    var reminderMinutes = 8 * 60 { didSet { persist(); reschedule() } }

    /// Sent with every prayer report. Empty until the phone shares its
    /// anon-signup tracking id, the same as a phone that hasn't signed up.
    var trackingId: String { defaults.string(forKey: Keys.trackingId) ?? "" }

    private let defaults = UserDefaults.standard
    private var loading = false

    private enum Keys {
        static let reminderEnabled = "watch.reminderEnabled"
        static let reminderMinutes = "watch.reminderMinutes"
        static let trackingId = "watch.trackingId"
    }

    private init() {
        loading = true
        groups = SharedStore.groups
        prayedDays = SharedStore.prayedDays
        reminderEnabled = defaults.bool(forKey: Keys.reminderEnabled)
        if defaults.object(forKey: Keys.reminderMinutes) != nil {
            reminderMinutes = defaults.integer(forKey: Keys.reminderMinutes)
        }
        loading = false
        #if DEBUG
        applyDemoArguments()
        #endif
    }

    // MARK: Groups

    func add(_ group: PeopleGroupSummary) {
        guard !groups.contains(where: { $0.slug == group.slug }), groups.count < Self.maxGroups else { return }
        groups.append(SavedGroup(slug: group.slug, name: group.name, imageURL: group.imageURL))
        persist()
        reschedule()
        Task { await prefetch() }
    }

    func remove(at offsets: IndexSet) {
        groups.remove(atOffsets: offsets)
        persist()
        reschedule()
    }

    func group(_ slug: String) -> SavedGroup? {
        groups.first { $0.slug == slug }
    }

    /// Keeps a group's name and photo current with what the server last sent.
    func refresh(slug: String, name: String, imageURL: URL?) {
        guard let index = groups.firstIndex(where: { $0.slug == slug }) else { return }
        guard groups[index].name != name || groups[index].imageURL != imageURL else { return }
        groups[index].name = name
        groups[index].imageURL = imageURL ?? groups[index].imageURL
        persist()
    }

    // MARK: Prayed today

    func isPrayedToday(_ slug: String) -> Bool {
        prayedDays[slug] == APIDate.string(Date())
    }

    func recordPrayer(slug: String, duration: Int) {
        prayedDays[slug] = APIDate.string(Date())
        persist()
        log.info("Recorded prayer for \(slug, privacy: .public) (\(duration)s)")
    }

    // MARK: Navigation

    func openPrayer(_ slug: String) {
        path = [.prayer(slug: slug)]
    }

    /// `doxa-watch://pray/<slug>`, from the complication.
    func handleURL(_ url: URL) {
        guard url.scheme == "doxa-watch" else { return }
        if url.host == "pray", let slug = url.pathComponents.dropFirst().first {
            openPrayer(slug)
        } else {
            path = []
        }
    }

    /// A tapped reminder or push: straight into that group's prayer, or the
    /// group list when it isn't about one group (unless there's only one).
    func handleNotification(_ userInfo: [AnyHashable: Any]) {
        if let slug = Reminders.slug(from: userInfo) {
            openPrayer(slug)
        } else if groups.count == 1, let only = groups.first {
            openPrayer(only.slug)
        } else {
            path = []
        }
    }

    // MARK: Offline

    /// Downloads today's and tomorrow's prayer for every group, so the prayer
    /// opens instantly and works without a connection.
    func prefetch() async {
        let language = AppLanguage.current
        let today = Date()
        let tomorrow = Calendar.current.date(byAdding: .day, value: 1, to: today) ?? today
        for group in groups {
            for day in [today, tomorrow] {
                guard let response = try? await PrayerAPI.prayerContent(slug: group.slug, date: day, language: language) else { continue }
                if day == today {
                    refresh(slug: group.slug, name: response.peopleGroup.title, imageURL: response.peopleGroup.imageURL)
                }
            }
        }
        await ResponseCache.shared.prune(olderThan: PrayerAPI.prayerContentMaxAge)
    }

    // MARK: Persistence

    private func persist() {
        guard !loading else { return }
        SharedStore.groups = groups
        SharedStore.prayedDays = prayedDays
        reloadComplications()
        defaults.set(reminderEnabled, forKey: Keys.reminderEnabled)
        defaults.set(reminderMinutes, forKey: Keys.reminderMinutes)
    }

    /// Tells the complication to redraw after anything it shows has changed.
    private func reloadComplications() {
        guard !loading else { return }
        WidgetCenter.shared.reloadAllTimelines()
    }

    private func reschedule() {
        guard !loading else { return }
        Reminders.schedule(enabled: reminderEnabled, minutes: reminderMinutes, groups: groups)
    }

    #if DEBUG
    /// Launch arguments for trying the app in the simulator without tapping
    /// through it, e.g. `-demoGroups abai-sungai,negev-bedouins -demoOpen abai-sungai`.
    /// `-demoCard <n>` (read by PrayerView) starts on a given card and
    /// `-demoAmen YES` shows the finished screen, `-demoRoute picker|settings`
    /// opens those screens and `-demoNotification <payload>` acts as if a
    /// reminder with that payload was tapped.
    private func applyDemoArguments() {
        if let slugs = defaults.string(forKey: "demoGroups") {
            groups = slugs.split(separator: ",").map { slug in
                let name = slug.split(separator: "-").map { $0.capitalized }.joined(separator: " ")
                return SavedGroup(slug: String(slug), name: name, imageURL: nil)
            }
        }
        if let open = defaults.string(forKey: "demoOpen") {
            path = [.prayer(slug: open)]
        }
        switch defaults.string(forKey: "demoRoute") {
        case "picker": path = [.picker]
        case "settings": path = [.settings]
        default: break
        }
        // Runs the same routing a tapped notification does, e.g. "pray" or a slug.
        if let payload = defaults.string(forKey: "demoNotification") {
            handleNotification(["payload": payload])
        }
    }
    #endif
}
