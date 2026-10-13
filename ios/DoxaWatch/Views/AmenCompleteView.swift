import SwiftUI

/// Shown after Amen: a check mark draws itself in, then the thank-you verse.
struct AmenCompleteView: View {
    let verse: ThankYouVerse?
    let onDone: () -> Void

    @State private var ring: CGFloat = 0
    @State private var tick: CGFloat = 0
    @State private var showText = false

    var body: some View {
        ScrollView {
            VStack(spacing: 12) {
                ZStack {
                    Circle()
                        .fill(Theme.accent.opacity(0.15))
                        .scaleEffect(ring)
                    Circle()
                        .trim(from: 0, to: ring)
                        .stroke(Theme.accent, style: StrokeStyle(lineWidth: 5, lineCap: .round))
                        .rotationEffect(.degrees(-90))
                    CheckmarkShape()
                        .trim(from: 0, to: tick)
                        .stroke(Theme.accent, style: StrokeStyle(lineWidth: 6, lineCap: .round, lineJoin: .round))
                        .padding(22)
                }
                .frame(width: 76, height: 76)
                .padding(.top, 8)
                .accessibilityHidden(true)

                Group {
                    Text(L10n.string("prayerThankYouTitle"))
                        .font(.headline)
                        .multilineTextAlignment(.center)
                    if let verse {
                        VStack(spacing: 4) {
                            Text(verse.text)
                                .font(.footnote.italic())
                                .multilineTextAlignment(.center)
                            Text([verse.reference, verse.translation].filter { !$0.isEmpty }.joined(separator: " · "))
                                .font(.caption2)
                                .foregroundStyle(.secondary)
                        }
                    }
                    Button(L10n.string("watchDone"), action: onDone)
                        .tint(Theme.accent)
                        .padding(.top, 4)
                }
                .opacity(showText ? 1 : 0)
                .offset(y: showText ? 0 : 8)
            }
            .padding(.horizontal, 6)
        }
        .onAppear {
            withAnimation(.easeOut(duration: 0.5)) { ring = 1 }
            withAnimation(.spring(duration: 0.45, bounce: 0.3).delay(0.4)) { tick = 1 }
            withAnimation(.smooth(duration: 0.5).delay(0.75)) { showText = true }
        }
    }
}

private struct CheckmarkShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.minX, y: rect.midY + rect.height * 0.05))
        path.addLine(to: CGPoint(x: rect.minX + rect.width * 0.36, y: rect.maxY - rect.height * 0.08))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.minY + rect.height * 0.12))
        return path
    }
}
