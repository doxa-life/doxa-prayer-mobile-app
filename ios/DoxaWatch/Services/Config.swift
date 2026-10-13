import Foundation

/// Server and language settings, matching lib/services/api_config.dart and
/// lib/services/locale_controller.dart.
enum APIConfig {
    #if STAGING
    static let host = "campaigns-server-k4ax-production.up.railway.app"
    #else
    static let host = "pray.doxa.life"
    #endif

    static func url(_ path: String, query: [String: String] = [:]) -> URL {
        var components = URLComponents()
        components.scheme = "https"
        components.host = host
        components.path = path
        if !query.isEmpty {
            components.queryItems = query.sorted { $0.key < $1.key }.map { URLQueryItem(name: $0.key, value: $0.value) }
        }
        return components.url!
    }
}

enum AppLanguage {
    /// The languages the phone app ships (lib/services/locale_controller.dart).
    static let supported = ["en", "es", "pt", "fr", "de", "it", "ro", "ru", "fi", "zh", "ar", "hi"]

    /// The language the watch shows and asks the server for: the watch's own
    /// language when the app supports it, else English. The phone's in-app
    /// language choice will replace this once the settings bridge lands.
    static var current: String {
        let localization = Bundle.main.preferredLocalizations.first ?? "en"
        let code = String(localization.prefix { $0 != "-" && $0 != "_" })
        return supported.contains(code) ? code : "en"
    }
}
