import Foundation

/// The verse shown after Amen. Reads the phone's own
/// assets/thank_you_verses.json (bundled by reference, not copied), and
/// advances through it the same way lib/services/thank_you_verse_service.dart
/// does, so a returning user gets a new verse each time.
struct ThankYouVerse {
    let text: String
    let reference: String
    let translation: String
}

enum ThankYouVerses {
    private static let indexKey = "watch.thankYouVerseIndex"

    private struct File: Decodable {
        let verses: [Entry]
        struct Entry: Decodable { let locales: [String: Verse] }
        struct Verse: Decodable { let text: String; let reference: String; let translation: String }
    }

    private static let verses: [File.Entry] = {
        guard let url = Bundle.main.url(forResource: "thank_you_verses", withExtension: "json"),
              let data = try? Data(contentsOf: url),
              let file = try? JSONDecoder().decode(File.self, from: data) else { return [] }
        return file.verses
    }()

    static func next(language: String) -> ThankYouVerse? {
        guard !verses.isEmpty else { return nil }
        let defaults = UserDefaults.standard
        let index = defaults.integer(forKey: indexKey) % verses.count
        defaults.set((index + 1) % verses.count, forKey: indexKey)
        let locales = verses[index].locales
        guard let verse = locales[language] ?? locales["en"] else { return nil }
        return ThankYouVerse(text: verse.text, reference: verse.reference, translation: verse.translation)
    }
}
