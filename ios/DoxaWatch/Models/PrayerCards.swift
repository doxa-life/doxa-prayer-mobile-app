import SwiftUI

/// One page of the prayer on the watch.
///
/// The phone renders each content block as its own section (each static block
/// ends with "Pause & Pray"), so the watch gives each block its own card, in
/// the same order, followed by the Amen card. See "Card splitting" in
/// docs/apple-watch.md.
struct PrayerCard: Identifiable {
    enum Kind {
        case intro(name: String, imageURL: URL?)
        case doc(title: String?, items: [DocItem])
        case groupOfTheDay(name: String, data: PeopleGroupData)
        case amen(notices: [CopyrightNotice])
    }

    let id: Int
    let kind: Kind
}

struct DocItem: Identifiable {
    enum Kind {
        case heading(AttributedString, level: Int)
        case paragraph(AttributedString)
        case verse(paragraphs: [AttributedString], citation: String)
    }

    let id: Int
    let kind: Kind
}

enum PrayerCardBuilder {
    static func cards(for response: PrayerContentResponse, dayInTheLifeTitle: String) -> [PrayerCard] {
        var kinds: [PrayerCard.Kind] = []
        for block in response.content {
            switch block.kind {
            case .intro:
                guard let data = block.peopleGroupData else { continue }
                kinds.append(.intro(name: block.title, imageURL: data.imageURL))
            case .groupOfTheDay:
                guard let data = block.peopleGroupData else { continue }
                kinds.append(.groupOfTheDay(name: block.title, data: data))
            case .section, .dayInTheLife:
                guard let doc = block.doc else { continue }
                let items = docItems(doc)
                guard !items.isEmpty else { continue }
                kinds.append(.doc(title: block.kind == .dayInTheLife ? dayInTheLifeTitle : nil, items: items))
            case .unknown:
                continue
            }
        }
        kinds.append(.amen(notices: response.copyrightNotices))
        return kinds.enumerated().map { PrayerCard(id: $0.offset, kind: $0.element) }
    }

    /// The block-level nodes of a document, as the phone's PrayerDocView reads
    /// them. Unknown node types are skipped so new content can't break the watch.
    static func docItems(_ doc: DocNode) -> [DocItem] {
        var kinds: [DocItem.Kind] = []
        for node in doc.content {
            switch node.type {
            case "paragraph":
                let text = inline(node.content)
                if !text.characters.isEmpty { kinds.append(.paragraph(text)) }
            case "heading":
                let text = inline(node.content)
                let level: Int
                if case let .number(n) = node.attrs["level"] { level = Int(n) } else { level = 2 }
                if !text.characters.isEmpty { kinds.append(.heading(text, level: level)) }
            case "verse":
                let paragraphs = node.content
                    .filter { $0.type == "paragraph" }
                    .map { inline($0.content) }
                    .filter { !$0.characters.isEmpty }
                guard !paragraphs.isEmpty else { continue }
                let citation = [node.stringAttr("reference"), node.stringAttr("translation")]
                    .compactMap { $0 }
                    .filter { !$0.isEmpty }
                    .joined(separator: " · ")
                kinds.append(.verse(paragraphs: paragraphs, citation: citation))
            default:
                continue
            }
        }
        return kinds.enumerated().map { DocItem(id: $0.offset, kind: $0.element) }
    }

    /// Flattens inline nodes into styled text. A superscript verse number is
    /// tied to the first word after it with a narrow no-break space, so the two
    /// never wrap apart (the phone does the same with SuperscriptText).
    static func inline(_ nodes: [DocNode]) -> AttributedString {
        var out = AttributedString()
        var trimNextLeading = false
        for (index, node) in nodes.enumerated() {
            if node.type == "hardBreak" {
                out += AttributedString("\n")
                continue
            }
            guard node.type == "text", var text = node.text else { continue }
            if trimNextLeading {
                text = String(text.drop(while: \.isWhitespace))
                trimNextLeading = false
            }
            let number = node.isSuperscript ? text.trimmingCharacters(in: .whitespaces) : ""
            guard !number.isEmpty else {
                if !text.isEmpty { out += AttributedString(text) }
                continue
            }
            let lead = text.prefix(while: \.isWhitespace)
            if !lead.isEmpty { out += AttributedString(String(lead)) }

            var superscript = AttributedString(number)
            superscript.font = .caption2.weight(.semibold)
            superscript.baselineOffset = 4
            out += superscript

            let next = index + 1 < nodes.count ? nodes[index + 1] : nil
            if let next, next.type == "text", !next.isSuperscript {
                out += AttributedString("\u{202F}")
                trimNextLeading = true
            }
        }
        return out
    }
}
