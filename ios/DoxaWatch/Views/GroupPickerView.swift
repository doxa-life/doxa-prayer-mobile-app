import SwiftUI

/// Pick a people group to pray for. Stands in for the phone's subscriptions
/// until the settings bridge sends them across.
struct GroupPickerView: View {
    @Environment(AppModel.self) private var model
    @State private var all: [PeopleGroupSummary] = []
    @State private var query = ""
    @State private var failed = false

    private var matches: [PeopleGroupSummary] {
        let available = all.filter { model.group($0.slug) == nil }
        let trimmed = query.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty else { return available }
        return available.filter {
            $0.name.localizedStandardContains(trimmed) || ($0.country?.localizedStandardContains(trimmed) ?? false)
        }
    }

    var body: some View {
        List {
            if all.isEmpty {
                if failed {
                    VStack(spacing: 8) {
                        Text(L10n.string("couldNotLoadPrayerContent")).font(.footnote)
                        Button(L10n.string("retry")) { Task { await load() } }
                    }
                } else {
                    HStack { Spacer(); ProgressView(); Spacer() }
                        .listRowBackground(Color.clear)
                }
            } else if matches.isEmpty {
                Text(L10n.string("watchNoMatches")).foregroundStyle(.secondary)
            } else {
                ForEach(matches) { group in
                    Button {
                        model.add(group)
                        if !model.path.isEmpty { model.path.removeLast() }
                    } label: {
                        HStack(spacing: 10) {
                            GroupAvatar(url: group.imageURL, size: 30)
                            VStack(alignment: .leading, spacing: 1) {
                                Text(group.name).font(.headline).lineLimit(2)
                                if let country = group.country {
                                    Text(country).font(.caption2).foregroundStyle(.secondary)
                                }
                            }
                        }
                    }
                }
            }
        }
        .searchable(text: $query, prompt: L10n.string("searchPeopleGroups"))
        .navigationTitle(L10n.string("choosePeopleGroup"))
        .task { await load() }
    }

    private func load() async {
        failed = false
        do {
            all = try await PrayerAPI.peopleGroups(language: AppLanguage.current)
                .sorted { $0.name.localizedStandardCompare($1.name) == .orderedAscending }
        } catch {
            log.error("People group list failed: \(error.localizedDescription, privacy: .public)")
            failed = true
        }
    }
}
