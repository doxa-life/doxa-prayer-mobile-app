import SwiftUI
import WidgetKit

/// The watch face complication and Smart Stack widget: who to pray for next
/// today, or a check mark once every group has been prayed for. Tapping it
/// opens that group's prayer.
@main
struct DoxaWatchWidgets: Widget {
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: "DoxaPrayer", provider: Provider()) { entry in
            ComplicationView(entry: entry)
                .containerBackground(for: .widget) { Theme.primary }
                .widgetURL(entry.next.map { SharedStore.prayerURL($0.slug) })
        }
        .configurationDisplayName("DOXA")
        .description(L10n.string("reminderNotificationBody"))
        .supportedFamilies([.accessoryCircular, .accessoryRectangular, .accessoryInline, .accessoryCorner])
    }
}

struct PrayerEntry: TimelineEntry {
    let date: Date
    /// The first group not yet prayed for today, if any.
    let next: SavedGroup?
    let prayed: Int
    let total: Int

    var allPrayed: Bool { total > 0 && prayed == total }

    static func now(at date: Date = Date()) -> PrayerEntry {
        let groups = SharedStore.groups
        let prayedDays = SharedStore.prayedDays
        let today = APIDate.string(date)
        let done = groups.filter { prayedDays[$0.slug] == today }
        return PrayerEntry(
            date: date,
            next: groups.first { prayedDays[$0.slug] != today },
            prayed: done.count,
            total: groups.count
        )
    }
}

struct Provider: TimelineProvider {
    func placeholder(in context: Context) -> PrayerEntry {
        PrayerEntry(date: Date(), next: SavedGroup(slug: "", name: "Negev Bedouins"), prayed: 1, total: 2)
    }

    func getSnapshot(in context: Context, completion: @escaping (PrayerEntry) -> Void) {
        completion(context.isPreview ? placeholder(in: context) : .now())
    }

    /// The app reloads the timeline whenever something changes; the only
    /// change it can't announce is the day rolling over, so plan for midnight.
    func getTimeline(in context: Context, completion: @escaping (Timeline<PrayerEntry>) -> Void) {
        let now = Date()
        let midnight = Calendar.current.startOfDay(for: now.addingTimeInterval(24 * 3600))
        completion(Timeline(entries: [.now(at: now), .now(at: midnight)], policy: .after(midnight)))
    }
}

struct ComplicationView: View {
    @Environment(\.widgetFamily) private var family
    let entry: PrayerEntry

    var body: some View {
        switch family {
        case .accessoryCircular: circular
        case .accessoryRectangular: rectangular
        case .accessoryInline: inline
        case .accessoryCorner: corner
        default: circular
        }
    }

    private var symbol: String {
        entry.allPrayed ? "checkmark" : "hands.and.sparkles.fill"
    }

    private var progress: Double {
        entry.total == 0 ? 0 : Double(entry.prayed) / Double(entry.total)
    }

    private var circular: some View {
        Gauge(value: progress) {
            Image(systemName: symbol)
        }
        .gaugeStyle(.accessoryCircularCapacity)
        .tint(Theme.accent)
        .widgetAccentable()
    }

    private var rectangular: some View {
        HStack(spacing: 8) {
            Image(systemName: symbol)
                .font(.title2)
                .foregroundStyle(Theme.accent)
                .widgetAccentable()
            VStack(alignment: .leading, spacing: 1) {
                Text("DOXA")
                    .font(.headline)
                    .foregroundStyle(Theme.accent)
                    .widgetAccentable()
                Text(headline)
                    .font(.body)
                    .lineLimit(2)
                    .minimumScaleFactor(0.8)
            }
            Spacer(minLength: 0)
        }
    }

    private var inline: some View {
        Label(headline, systemImage: symbol)
    }

    private var corner: some View {
        Image(systemName: symbol)
            .font(.title3)
            .widgetAccentable()
            .widgetLabel {
                Gauge(value: progress) { Text("DOXA") }
                    .tint(Theme.accent)
            }
    }

    private var headline: String {
        if let next = entry.next { return L10n.format("peopleGroupIntroTitle", next.name) }
        if entry.allPrayed { return L10n.string("prayedToday") }
        return L10n.string("choosePeopleGroup")
    }
}

enum Theme {
    static let accent = Color(red: 0x73 / 255, green: 0xA1 / 255, blue: 0x7F / 255)
    static let primary = Color(red: 0x3B / 255, green: 0x46 / 255, blue: 0x3D / 255)
}
