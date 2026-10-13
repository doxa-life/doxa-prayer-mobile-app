import SwiftUI
import WatchKit

/// The daily prayer for one people group: a card per section, paged with the
/// Digital Crown or a swipe, a progress bar along the bottom, and Amen at the
/// end.
struct PrayerView: View {
    let slug: String

    @Environment(AppModel.self) private var model
    @Environment(\.scenePhase) private var scenePhase

    private enum Phase {
        case loading
        case loaded([PrayerCard])
        case empty
        case failed
    }

    @State private var phase: Phase = .loading
    @State private var date = Date()
    @State private var selection = 0
    @State private var session: PrayerSession?
    @State private var finished = false
    @State private var verse: ThankYouVerse?

    var body: some View {
        content
            .navigationTitle(model.group(slug)?.name ?? "")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar(finished ? .hidden : .automatic, for: .navigationBar)
            .task { await loadIfNeeded() }
            .onDisappear { session?.stop() }
            .onChange(of: scenePhase) { _, newPhase in
                // Like the phone: backgrounding ends the session, coming back
                // starts a new one.
                if newPhase == .background {
                    session?.stop()
                } else if newPhase == .active, !finished {
                    session?.start()
                }
            }
    }

    @ViewBuilder
    private var content: some View {
        switch phase {
        case .loading:
            VStack(spacing: 8) {
                ProgressView()
                Text(L10n.string("watchLoading")).font(.footnote).foregroundStyle(.secondary)
            }
        case .empty:
            Text(L10n.string("noPrayerContentAvailable"))
                .multilineTextAlignment(.center)
                .padding()
        case .failed:
            VStack(spacing: 10) {
                Image(systemName: "wifi.exclamationmark").font(.title2).foregroundStyle(.secondary)
                Text(L10n.string("couldNotLoadPrayerContent")).font(.footnote).multilineTextAlignment(.center)
                Button(L10n.string("retry")) { Task { await load(forceRefresh: true) } }
            }
            .padding(.horizontal)
        case let .loaded(cards):
            if finished {
                AmenCompleteView(verse: verse) { model.path = [] }
                    .transition(.opacity.combined(with: .scale(scale: 0.92)))
            } else {
                pager(cards)
                    .transition(.opacity)
            }
        }
    }

    private func pager(_ cards: [PrayerCard]) -> some View {
        ZStack(alignment: .bottom) {
            TabView(selection: $selection) {
                ForEach(cards) { card in
                    PrayerCardView(card: card, isCurrent: card.id == selection, onAmen: amen)
                        .tag(card.id)
                }
            }
            .tabViewStyle(.verticalPage(transitionStyle: .blur))

            PrayerProgressBar(value: Double(selection + 1) / Double(max(cards.count, 1)))
                .padding(.horizontal, 44)
                .padding(.top, 14)
                .padding(.bottom, 2)
                .frame(maxWidth: .infinity)
                // Fade the text out behind the bar so it never sits on words.
                .background(LinearGradient(colors: [.black.opacity(0), .black], startPoint: .top, endPoint: .center))
                .ignoresSafeArea(edges: .bottom)
                .allowsHitTesting(false)
        }
        .onChange(of: selection) { _, _ in
            WKInterfaceDevice.current().play(.click)
        }
    }

    private func loadIfNeeded() async {
        guard case .loading = phase else { return }
        await load(forceRefresh: false)
    }

    private func load(forceRefresh: Bool) async {
        if forceRefresh { phase = .loading }
        do {
            let response = try await PrayerAPI.prayerContent(
                slug: slug, date: date, language: AppLanguage.current, forceRefresh: forceRefresh
            )
            model.refresh(slug: slug, name: response.peopleGroup.title, imageURL: response.peopleGroup.imageURL)
            guard response.hasContent, !response.content.isEmpty else {
                phase = .empty
                return
            }
            let cards = PrayerCardBuilder.cards(for: response, dayInTheLifeTitle: L10n.string("dayInTheLifeTitle"))
            phase = .loaded(cards)
            startSession()
            #if DEBUG
            applyDemoArguments(cardCount: cards.count)
            #endif
        } catch {
            log.error("Prayer content failed: \(error.localizedDescription, privacy: .public)")
            phase = .failed
        }
    }

    private func startSession() {
        guard session == nil else { return }
        let session = PrayerSession(slug: slug, date: date, trackingId: model.trackingId) { slug, duration in
            AppModel.shared.recordPrayer(slug: slug, duration: duration)
        }
        self.session = session
        session.start()
    }

    private func amen() {
        session?.amen()
        verse = ThankYouVerses.next(language: AppLanguage.current)
        WKInterfaceDevice.current().play(.success)
        AccessibilityNotification.Announcement(L10n.string("prayerRecordedAnnouncement")).post()
        withAnimation(.smooth(duration: 0.45)) { finished = true }
    }

    #if DEBUG
    private func applyDemoArguments(cardCount: Int) {
        let defaults = UserDefaults.standard
        if defaults.object(forKey: "demoCard") != nil {
            selection = min(max(defaults.integer(forKey: "demoCard"), 0), cardCount - 1)
        }
        if defaults.bool(forKey: "demoAmen") { amen() }
    }
    #endif
}

/// A thin bar along the bottom showing how far through the prayer you are.
struct PrayerProgressBar: View {
    let value: Double

    var body: some View {
        GeometryReader { geo in
            ZStack(alignment: .leading) {
                Capsule().fill(.white.opacity(0.18))
                Capsule()
                    .fill(Theme.accent)
                    .frame(width: max(geo.size.width * value, 4))
            }
        }
        .frame(height: 4)
        .animation(.smooth(duration: 0.4), value: value)
        .accessibilityElement()
        .accessibilityValue(Text(value, format: .percent.precision(.fractionLength(0))))
    }
}
