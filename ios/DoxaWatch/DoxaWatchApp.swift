import SwiftUI

/// Entry point for the DOXA Apple Watch companion.
///
/// The watch app is self-contained: it lives entirely under `ios/DoxaWatch/`
/// and is not embedded in the iPhone app yet, so it cannot affect how Runner
/// builds or behaves. See docs/apple-watch.md for the plan and how to remove it.
@main
struct DoxaWatchApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
