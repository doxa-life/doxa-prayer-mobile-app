import SwiftUI

/// Placeholder home screen. Replaced by today's people groups once the prayer
/// flow lands (see "Build order" in docs/apple-watch.md).
struct ContentView: View {
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: "hands.and.sparkles.fill")
                .font(.title)
                .foregroundStyle(.tint)
            Text("DOXA")
                .font(.headline)
            Text("Prayer is coming to your wrist.")
                .font(.footnote)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding()
    }
}

#Preview {
    ContentView()
}
