import Foundation

/// One row of `/api/people-groups/list`, trimmed to what the watch shows.
struct PeopleGroupSummary: Decodable, Identifiable, Hashable {
    let slug: String
    let name: String
    let imageURL: URL?
    let country: String?

    var id: String { slug }

    private enum CodingKeys: String, CodingKey {
        case slug, name
        case imageURL = "image_url"
        case countryCode = "country_code"
    }

    private struct Labelled: Decodable { let label: String? }

    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        slug = try c.decode(String.self, forKey: .slug)
        name = (try? c.decodeIfPresent(String.self, forKey: .name)) ?? slug
        imageURL = (try? c.decodeIfPresent(String.self, forKey: .imageURL)).flatMap(URL.init(string:))
        country = (try? c.decodeIfPresent(Labelled.self, forKey: .countryCode))?.label
    }
}

struct PeopleGroupList: Decodable {
    let posts: [PeopleGroupSummary]

    private enum CodingKeys: String, CodingKey { case posts }

    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        // Skip any row that fails to decode rather than losing the whole list.
        let rows = try c.decode([Lenient].self, forKey: .posts)
        posts = rows.compactMap(\.value)
    }

    private struct Lenient: Decodable {
        let value: PeopleGroupSummary?
        init(from decoder: Decoder) throws { value = try? PeopleGroupSummary(from: decoder) }
    }
}
