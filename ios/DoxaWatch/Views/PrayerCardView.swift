import SwiftUI

/// One card of the prayer. Long cards scroll with the Digital Crown; reaching
/// the end moves on to the next card.
struct PrayerCardView: View {
    let card: PrayerCard
    let isCurrent: Bool
    let onAmen: () -> Void

    var body: some View {
        ScrollView {
            Group {
                switch card.kind {
                case let .intro(name, imageURL):
                    IntroCard(name: name, imageURL: imageURL)
                case let .doc(title, items):
                    DocCard(title: title, items: items)
                case let .groupOfTheDay(name, data):
                    GroupOfTheDayCard(name: name, data: data)
                case let .amen(notices):
                    AmenCard(notices: notices, onAmen: onAmen)
                }
            }
            .padding(.horizontal, 4)
            .padding(.bottom, 16)
        }
        // A gentle settle as each card arrives: the one you're on is crisp and
        // full size, its neighbours recede while the page turns.
        .opacity(isCurrent ? 1 : 0.35)
        .scaleEffect(isCurrent ? 1 : 0.94)
        .animation(.smooth(duration: 0.35), value: isCurrent)
    }
}

private struct IntroCard: View {
    let name: String
    let imageURL: URL?

    var body: some View {
        VStack(spacing: 12) {
            GroupAvatar(url: imageURL, size: 92)
                .overlay(Circle().stroke(Theme.accent.opacity(0.6), lineWidth: 2))
                .padding(.top, 6)
            Text(L10n.format("peopleGroupIntroTitle", name))
                .font(.title3.weight(.semibold))
                .multilineTextAlignment(.center)
            Image(systemName: "chevron.compact.down")
                .font(.title3)
                .foregroundStyle(.secondary)
                .symbolEffect(.pulse)
                .accessibilityHidden(true)
        }
        .frame(maxWidth: .infinity)
    }
}

private struct DocCard: View {
    let title: String?
    let items: [DocItem]

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            if let title {
                Text(title)
                    .font(.headline)
                    .foregroundStyle(Theme.accent)
                    .accessibilityAddTraits(.isHeader)
            }
            ForEach(items) { item in
                switch item.kind {
                case let .heading(text, level):
                    Text(text)
                        .font(level == 1 ? .title2.weight(.bold) : .title3.weight(.semibold))
                        .accessibilityAddTraits(.isHeader)
                case let .paragraph(text):
                    Text(text).font(.body)
                case let .verse(paragraphs, citation):
                    VerseView(paragraphs: paragraphs, citation: citation)
                }
            }
            Text(L10n.string("pauseAndPray").uppercased())
                .font(.caption2.weight(.bold))
                .foregroundStyle(Theme.accentLight)
                .frame(maxWidth: .infinity, alignment: .trailing)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

/// The phone's verse block: Scripture on the app's dark green, in italics,
/// with the reference and translation below.
private struct VerseView: View {
    let paragraphs: [AttributedString]
    let citation: String

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            ForEach(Array(paragraphs.enumerated()), id: \.offset) { _, text in
                Text(text)
                    .font(.body.italic())
                    .foregroundStyle(.white)
            }
            if !citation.isEmpty {
                Text(citation)
                    .font(.caption2.weight(.medium))
                    .foregroundStyle(.white.opacity(0.7))
                    .frame(maxWidth: .infinity, alignment: .trailing)
            }
        }
        .padding(10)
        .background(Theme.primary, in: RoundedRectangle(cornerRadius: 12, style: .continuous))
    }
}

private struct GroupOfTheDayCard: View {
    let name: String
    let data: PeopleGroupData

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(L10n.string("peopleGroupOfTheDay"))
                .font(.headline)
                .foregroundStyle(Theme.accent)
                .accessibilityAddTraits(.isHeader)
            HStack(spacing: 10) {
                GroupAvatar(url: data.imageURL, size: 52)
                Text(name)
                    .font(.title3.weight(.semibold))
                    .lineLimit(3)
            }
            VStack(alignment: .leading, spacing: 4) {
                fact("mappin.and.ellipse", data.country)
                fact("person.2", data.population.map { $0.formatted() })
                fact("character.bubble", data.language)
                fact("building.columns", data.religion)
            }
            .font(.footnote)
            .foregroundStyle(.secondary)
            if !data.description.isEmpty {
                Text(data.description).font(.body)
            }
            Text(L10n.string("pauseAndPray").uppercased())
                .font(.caption2.weight(.bold))
                .foregroundStyle(Theme.accentLight)
                .frame(maxWidth: .infinity, alignment: .trailing)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    @ViewBuilder
    private func fact(_ symbol: String, _ value: String?) -> some View {
        if let value, !value.isEmpty {
            Label(value, systemImage: symbol)
        }
    }
}

/// The last card: Amen, then the Scripture copyright notices, which must be
/// shown wherever the quoted translations appear.
private struct AmenCard: View {
    let notices: [CopyrightNotice]
    let onAmen: () -> Void
    @State private var breathe = false

    var body: some View {
        VStack(spacing: 14) {
            Button(action: onAmen) {
                Text(L10n.string("amen"))
                    .font(.title2.weight(.bold))
                    .foregroundStyle(.black)
                    .frame(width: 104, height: 104)
                    .background(Theme.accent, in: Circle())
                    .background(
                        Circle()
                            .stroke(Theme.accent.opacity(0.5), lineWidth: 2)
                            .scaleEffect(breathe ? 1.18 : 1)
                            .opacity(breathe ? 0 : 1)
                    )
            }
            .buttonStyle(.plain)
            .padding(.top, 10)
            .onAppear {
                withAnimation(.easeOut(duration: 1.6).repeatForever(autoreverses: false)) { breathe = true }
            }
            ForEach(notices, id: \.self) { notice in
                Text(notice.notice)
                    .font(.system(size: 10))
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }
        }
        .frame(maxWidth: .infinity)
    }
}
