import SwiftUI

/// Today's people groups, each with a check mark once prayed for. Opening the
/// app from a reminder skips this and goes straight into the prayer.
struct HomeView: View {
    @Environment(AppModel.self) private var model

    var body: some View {
        @Bindable var model = model
        NavigationStack(path: $model.path) {
            List {
                if model.groups.isEmpty {
                    emptyState
                } else {
                    Section {
                        ForEach(model.groups) { group in
                            NavigationLink(value: Route.prayer(slug: group.slug)) {
                                GroupRow(group: group, prayed: model.isPrayedToday(group.slug))
                            }
                        }
                        .onDelete { model.remove(at: $0) }
                    } header: {
                        Text(L10n.string("watchToday"))
                    }
                    if model.groups.count < AppModel.maxGroups {
                        NavigationLink(value: Route.picker) {
                            Label(L10n.string("addAnotherPeopleGroup"), systemImage: "plus")
                                .foregroundStyle(Theme.accent)
                        }
                    }
                }
                NavigationLink(value: Route.settings) {
                    Label(L10n.string("settings"), systemImage: "gearshape")
                        .foregroundStyle(.secondary)
                }
            }
            .navigationTitle("DOXA")
            .navigationDestination(for: Route.self) { route in
                switch route {
                case let .prayer(slug): PrayerView(slug: slug)
                case .picker: GroupPickerView()
                case .settings: SettingsView()
                }
            }
        }
    }

    private var emptyState: some View {
        VStack(spacing: 10) {
            Image(systemName: "hands.and.sparkles.fill")
                .font(.title2)
                .foregroundStyle(Theme.accent)
            Text(L10n.string("noPeopleGroupSelected"))
                .font(.footnote)
                .multilineTextAlignment(.center)
            NavigationLink(value: Route.picker) {
                Text(L10n.string("choosePeopleGroup"))
                    .font(.headline)
                    .foregroundStyle(.black)
                    .multilineTextAlignment(.center)
                    .padding(.vertical, 10)
                    .frame(maxWidth: .infinity)
                    .background(Theme.accent, in: Capsule())
            }
            .buttonStyle(.plain)
        }
        .frame(maxWidth: .infinity)
        .listRowBackground(Color.clear)
    }
}

private struct GroupRow: View {
    let group: SavedGroup
    let prayed: Bool

    var body: some View {
        HStack(spacing: 10) {
            GroupAvatar(url: group.imageURL, size: 34)
            Text(group.name)
                .font(.headline)
                .lineLimit(2)
                .frame(maxWidth: .infinity, alignment: .leading)
            if prayed {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundStyle(Theme.accent)
                    .accessibilityLabel(L10n.string("prayedToday"))
            }
        }
        .padding(.vertical, 4)
    }
}

/// A round people-group photo with a quiet placeholder while it loads.
struct GroupAvatar: View {
    let url: URL?
    let size: CGFloat

    var body: some View {
        AsyncImage(url: url) { phase in
            if let image = phase.image {
                image.resizable().scaledToFill()
            } else {
                ZStack {
                    Theme.primary
                    Image(systemName: "person.3.fill")
                        .font(.system(size: size * 0.32))
                        .foregroundStyle(Theme.onPrimary.opacity(0.6))
                }
            }
        }
        .frame(width: size, height: size)
        .clipShape(Circle())
        .accessibilityHidden(true)
    }
}
