import Foundation

// Mirrors lib/models/prayer_content.dart. Decoding is deliberately lenient,
// like the Dart side: missing fields fall back to empty values, and numbers the
// server sends as strings ("1200") still decode.

struct PrayerContentResponse: Decodable {
    let peopleGroup: PrayerPeopleGroup
    let date: String
    let language: String
    let content: [PrayerBlock]
    let hasContent: Bool
    let copyrightNotices: [CopyrightNotice]

    private enum CodingKeys: String, CodingKey {
        case peopleGroup = "people_group", date, language, content, hasContent, metadata
    }

    private struct Metadata: Decodable {
        let copyrightNotices: [CopyrightNotice]?
        private enum CodingKeys: String, CodingKey { case copyrightNotices = "copyright_notices" }
    }

    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        peopleGroup = try c.decode(PrayerPeopleGroup.self, forKey: .peopleGroup)
        date = try c.decodeIfPresent(String.self, forKey: .date) ?? ""
        language = try c.decodeIfPresent(String.self, forKey: .language) ?? ""
        content = (try? c.decodeIfPresent([PrayerBlock].self, forKey: .content)) ?? []
        hasContent = try c.decodeIfPresent(Bool.self, forKey: .hasContent) ?? false
        let metadata = try? c.decodeIfPresent(Metadata.self, forKey: .metadata)
        copyrightNotices = metadata?.copyrightNotices ?? []
    }
}

struct PrayerPeopleGroup: Decodable {
    let slug: String
    let title: String
    let imageURL: URL?

    private enum CodingKeys: String, CodingKey { case slug, title, imageURL = "image_url" }

    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        slug = try c.decodeIfPresent(String.self, forKey: .slug) ?? ""
        title = try c.decodeIfPresent(String.self, forKey: .title) ?? ""
        imageURL = (try? c.decodeIfPresent(String.self, forKey: .imageURL)).flatMap(URL.init(string:))
    }
}

struct CopyrightNotice: Decodable, Hashable {
    let id: String
    let notice: String
}

struct PrayerBlock: Decodable {
    enum Kind {
        /// The selected group's introduction (`people_group`, id -1).
        case intro
        /// "People Group of the Day" (`people_group`, id -2).
        case groupOfTheDay
        /// "Day in the Life" (`static`, id -3).
        case dayInTheLife
        /// An ordinary prayer section (`static`).
        case section
        case unknown
    }

    let id: Int
    let title: String
    let kind: Kind
    let doc: DocNode?
    let peopleGroupData: PeopleGroupData?

    private enum CodingKeys: String, CodingKey {
        case id, title
        case contentType = "content_type"
        case contentJSON = "content_json"
        case peopleGroupData = "people_group_data"
    }

    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        id = (try? c.decodeIfPresent(LossyInt.self, forKey: .id))?.value ?? 0
        title = (try? c.decodeIfPresent(String.self, forKey: .title)) ?? ""
        let type = (try? c.decodeIfPresent(String.self, forKey: .contentType))
        switch type {
        case "people_group": kind = id == -2 ? .groupOfTheDay : .intro
        case "static": kind = id == -3 ? .dayInTheLife : .section
        default: kind = .unknown
        }
        doc = (try? c.decodeIfPresent(DocNode.self, forKey: .contentJSON))
        peopleGroupData = (try? c.decodeIfPresent(PeopleGroupData.self, forKey: .peopleGroupData))
    }
}

struct PeopleGroupData: Decodable, Hashable {
    let name: String
    let description: String
    let imageURL: URL?
    let population: Int?
    let language: String?
    let religion: String?
    let country: String?

    private enum CodingKeys: String, CodingKey {
        case name, description, population, language, religion, country
        case imageURL = "image_url"
    }

    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        name = (try? c.decodeIfPresent(String.self, forKey: .name)) ?? ""
        description = (try? c.decodeIfPresent(String.self, forKey: .description)) ?? ""
        imageURL = (try? c.decodeIfPresent(String.self, forKey: .imageURL)).flatMap(URL.init(string:))
        population = (try? c.decodeIfPresent(LossyInt.self, forKey: .population))?.value
        language = (try? c.decodeIfPresent(String.self, forKey: .language))
        religion = (try? c.decodeIfPresent(String.self, forKey: .religion))
        country = (try? c.decodeIfPresent(String.self, forKey: .country))
    }
}

/// A node of the TipTap document in a block's `content_json`.
struct DocNode: Decodable {
    let type: String
    let text: String?
    let attrs: [String: JSONValue]
    let marks: [String]
    let content: [DocNode]

    private enum CodingKeys: String, CodingKey { case type, text, attrs, marks, content }
    private struct Mark: Decodable { let type: String }

    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        type = (try? c.decodeIfPresent(String.self, forKey: .type)) ?? ""
        text = (try? c.decodeIfPresent(String.self, forKey: .text))
        attrs = (try? c.decodeIfPresent([String: JSONValue].self, forKey: .attrs)) ?? [:]
        marks = ((try? c.decodeIfPresent([Mark].self, forKey: .marks)) ?? []).map(\.type)
        content = (try? c.decodeIfPresent([DocNode].self, forKey: .content)) ?? []
    }

    var isSuperscript: Bool { marks.contains("superscript") }

    func stringAttr(_ key: String) -> String? {
        if case let .string(value) = attrs[key] { return value }
        return nil
    }
}

enum JSONValue: Decodable {
    case string(String)
    case number(Double)
    case bool(Bool)
    case other

    init(from decoder: Decoder) throws {
        let c = try decoder.singleValueContainer()
        if let v = try? c.decode(String.self) { self = .string(v) }
        else if let v = try? c.decode(Double.self) { self = .number(v) }
        else if let v = try? c.decode(Bool.self) { self = .bool(v) }
        else { self = .other }
    }
}

/// An integer the server may send as a number or a numeric string.
struct LossyInt: Decodable {
    let value: Int?

    init(from decoder: Decoder) throws {
        let c = try decoder.singleValueContainer()
        if let i = try? c.decode(Int.self) { value = i }
        else if let d = try? c.decode(Double.self) { value = Int(d) }
        else if let s = try? c.decode(String.self) { value = Int(s) ?? Double(s).map { Int($0) } }
        else { value = nil }
    }
}
