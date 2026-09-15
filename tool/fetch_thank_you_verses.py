#!/usr/bin/env python3
"""Regenerate assets/thank_you_verses.json from bolls.life.

The thank-you modal rotates through a fixed set of verses. Each locale shows the
verse in that locale's own Bible translation — configured in
doxa-campaigns-server/config/languages.ts — rather than a machine translation of
the English, because these are published translations that must be reproduced
verbatim.

Usage:  python3 tool/fetch_thank_you_verses.py

Edit REFERENCES below to change which verses are in the rotation, then re-run.
"""
import json
import re
import sys
import time
import urllib.request
from pathlib import Path

# (bolls book number, chapter, first verse, last verse)
REFERENCES = [
    (52, 5, 16, 18),  # 1 Thessalonians 5:16-18
    (19, 141, 2, 2),  # Psalm 141:2
    (19, 116, 1, 2),  # Psalm 116:1-2
    (24, 29, 12, 12),  # Jeremiah 29:12
    (19, 145, 18, 18),  # Psalm 145:18
    (60, 3, 12, 12),  # 1 Peter 3:12
    (23, 65, 24, 24),  # Isaiah 65:24
    (40, 6, 6, 6),  # Matthew 6:6
    (19, 86, 9, 9),  # Psalm 86:9
    (19, 2, 8, 8),  # Psalm 2:8
    (66, 7, 9, 9),  # Revelation 7:9
    (40, 9, 38, 38),  # Matthew 9:38
    (19, 67, 1, 2),  # Psalm 67:1-2
    (35, 2, 14, 14),  # Habakkuk 2:14
    (45, 10, 14, 14),  # Romans 10:14
    (51, 4, 3, 3),  # Colossians 4:3
    (54, 2, 4, 4),  # 1 Timothy 2:4
    (61, 3, 9, 9),  # 2 Peter 3:9
    (40, 24, 14, 14),  # Matthew 24:14
    (40, 6, 10, 10),  # Matthew 6:10
    (23, 6, 8, 8),  # Isaiah 6:8
    (51, 4, 2, 2),  # Colossians 4:2
    (19, 126, 5, 5),  # Psalm 126:5
    (49, 6, 18, 18),  # Ephesians 6:18
    (54, 2, 1, 1),  # 1 Timothy 2:1
    (45, 12, 12, 12),  # Romans 12:12
    (42, 11, 9, 9),  # Luke 11:9
    (38, 4, 6, 6),  # Zechariah 4:6
    (23, 55, 11, 11),  # Isaiah 55:11
    (50, 4, 6, 6),  # Philippians 4:6
]

# locale -> (bolls translation id, display label). Mirrors languages.ts.
LOCALES = [
    ("en", "NKJV", "NKJV"),
    ("es", "NVI", "NVI"),
    ("pt", "NAA", "NAA"),
    ("fr", "FRLSG", "LSG"),
    ("ru", "SYNOD", "SYNOD"),
    ("ar", "SVD", "SVD"),
    ("de", "S00", "SCH2000"),
    ("hi", "HIOV", "OV"),
    ("it", "NR06", "NR06"),
    ("ro", "NTR", "NTR"),
    ("zh", "CUNPS", "CUNPS"),
]

PSALMS = 19

# The Synodal text follows the Greek psalter, so English Psalm N is Synodal
# psalm N-1 across most of the range.
PSALM_CHAPTER_OFFSET = {"SYNOD": (10, 146, -1)}

# ...but that blanket offset is wrong at the four points where the Hebrew and
# Greek psalters merge or split. Each entry maps a Hebrew range to its Greek
# chapter plus the shift applied to the verse numbers.
# NOTE: doxa-campaigns-server/server/utils/app/bolls-bible.ts applies the
# blanket offset without these exceptions and returns the wrong passage for
# Psalms 10, 115, 116 and 147.
PSALM_LXX_EXCEPTIONS = [
    ((10, 1, 18), (9, 21)),        # Heb 10        -> LXX 9:22-39
    ((114, 1, 8), (113, 0)),       # Heb 114       -> LXX 113:1-8
    ((115, 1, 18), (113, 8)),      # Heb 115       -> LXX 113:9-26
    ((116, 1, 9), (114, 0)),       # Heb 116:1-9   -> LXX 114
    ((116, 10, 19), (115, -9)),    # Heb 116:10-19 -> LXX 115
    ((147, 1, 11), (146, 0)),      # Heb 147:1-11  -> LXX 146
    ((147, 12, 20), (147, -11)),   # Heb 147:12-20 -> LXX 147
]

# Translations that count a psalm's superscription as verse 1, shifting every
# subsequent verse number by one.
PSALM_VERSE_OFFSET = {"SYNOD", "FRLSG", "S00"}

# Book names for the reference line. Spanish, Portuguese, French and Russian
# come from Bolls; English and Arabic are set here because Bolls returns
# "The Book of PSALMS" for NKJV and English names for the Arabic SVD.
EN_BOOKS = {
    19: "Psalm", 23: "Isaiah", 24: "Jeremiah", 35: "Habakkuk", 38: "Zechariah",
    40: "Matthew", 42: "Luke", 45: "Romans", 49: "Ephesians", 50: "Philippians",
    51: "Colossians", 52: "1 Thessalonians", 54: "1 Timothy", 59: "James",
    60: "1 Peter", 61: "2 Peter", 66: "Revelation",
}
AR_BOOKS = {
    19: "\u0645\u0632\u0645\u0648\u0631", 23: "\u0625\u0634\u0639\u064a\u0627\u0621",
    24: "\u0625\u0631\u0645\u064a\u0627", 35: "\u062d\u0628\u0642\u0648\u0642",
    38: "\u0632\u0643\u0631\u064a\u0627", 40: "\u0645\u062a\u0649",
    42: "\u0644\u0648\u0642\u0627", 45: "\u0631\u0648\u0645\u064a\u0629",
    49: "\u0623\u0641\u0633\u0633", 50: "\u0641\u064a\u0644\u0628\u064a",
    51: "\u0643\u0648\u0644\u0648\u0633\u064a",
    52: "1 \u062a\u0633\u0627\u0644\u0648\u0646\u064a\u0643\u064a",
    54: "1 \u062a\u064a\u0645\u0648\u062b\u0627\u0648\u0633",
    59: "\u064a\u0639\u0642\u0648\u0628", 60: "1 \u0628\u0637\u0631\u0633",
    61: "2 \u0628\u0637\u0631\u0633", 66: "\u0631\u0624\u064a\u0627",
}

DE_BOOKS = {
    19: "Psalm", 23: "Jesaja", 24: "Jeremia", 35: "Habakuk", 38: "Sacharja",
    40: "Matth\u00e4us", 42: "Lukas", 45: "R\u00f6mer", 49: "Epheser",
    50: "Philipper", 51: "Kolosser", 52: "1. Thessalonicher", 54: "1. Timotheus",
    59: "Jakobus", 60: "1. Petrus", 61: "2. Petrus", 66: "Offenbarung",
}
HI_BOOKS = {
    19: "\u092d\u091c\u0928 \u0938\u0902\u0939\u093f\u0924\u093e",
    23: "\u092f\u0936\u093e\u092f\u093e\u0939",
    24: "\u092f\u093f\u0930\u094d\u092e\u092f\u093e\u0939",
    35: "\u0939\u092c\u0915\u094d\u0915\u0942\u0915",
    38: "\u091c\u0915\u0930\u094d\u092f\u093e\u0939",
    40: "\u092e\u0924\u094d\u0924\u0940", 42: "\u0932\u0942\u0915\u093e",
    45: "\u0930\u094b\u092e\u093f\u092f\u094b\u0902",
    49: "\u0907\u092b\u093f\u0938\u093f\u092f\u094b\u0902",
    50: "\u092b\u093f\u0932\u093f\u092a\u094d\u092a\u093f\u092f\u094b\u0902",
    51: "\u0915\u0941\u0932\u0941\u0938\u094d\u0938\u093f\u092f\u094b\u0902",
    52: "1 \u0925\u093f\u0938\u094d\u0938\u0932\u0941\u0928\u0940\u0915\u093f\u092f\u094b\u0902",
    54: "1 \u0924\u0940\u092e\u0941\u0925\u093f\u092f\u0938",
    59: "\u092f\u093e\u0915\u0942\u092c", 60: "1 \u092a\u0924\u0930\u0938",
    61: "2 \u092a\u0924\u0930\u0938",
    66: "\u092a\u094d\u0930\u0915\u093e\u0936\u093f\u0924\u0935\u093e\u0915\u094d\u092f",
}

# Superscriptions Bolls leaves as untagged prose inside verse 1 — nothing marks
# where they end, so the affected passage is named here. (bible, book, chapter).
UNTAGGED_SUPERSCRIPTION = {
    ("NR06", 19, 67): "Al direttore del coro. Per strumenti a corda. Salmo. Canto.",
}

# Han text has no spaces, so the ones left behind by <br/> and by joining
# verses would show as gaps.
CJK = "\u4e00-\u9fff\u3400-\u4dbf\u3000-\u303f\uff00-\uffef"
CJK_SPACE = re.compile(f"(?<=[{CJK}])\\s+(?=[{CJK}])")

ELISION_GAP = re.compile(
    r"(?<=[A-Za-z\u00c0-\u00ff])(['\u2019])\s+(?=[A-Za-z\u00c0-\u00ff])")

TAG = re.compile(r"<[^>]+>")
LEADING_SUPERSCRIPTION = re.compile(
    r"^\s*(?:<(i|b)>.*?</\1>|\u3014.*?\u3015)\s*", re.S)
# Bolls puts footnote markers in <sup> — "[104]" in NVI, a circled letter in NAA
# — and in <f> in SCH2000. They are editorial apparatus, not scripture, so the
# whole element goes.
FOOTNOTE = re.compile(r"<(sup|f)>.*?</\1>", re.S)
LINE_BREAK = re.compile(r"<br\s*/?>", re.I)
_HARAKAT = "[\u064B-\u0652\u0670\u0640]*"
_SELAH_AR = _HARAKAT.join(["\u0633", "\u0644", "\u0627", "\u0647"]) + _HARAKAT
SELAH = re.compile(
    r"\s*(?:[\u2014-]\s*)?[(\[\uff08\u3014]?\s*"
    r"(?:Selah|Pausa|Pause|S\u00e9lah|Sel\u00e1|Sela|"
    r"\u0421\u0435\u043b\u0430|\u0938\u0947\u0932\u093e|\u7ec6\u62c9|"
    + _SELAH_AR + r")\s*[.\u060c]?\s*[)\]\uff09\u3015]?\s*",
    re.I,
)

_cache = {}


def get_json(url):
    req = urllib.request.Request(url, headers={"User-Agent": "doxa-prayer-app"})
    for attempt in range(3):
        try:
            with urllib.request.urlopen(req, timeout=45) as response:
                return json.load(response)
        except Exception:
            if attempt == 2:
                raise
            time.sleep(2)


def chapter(bible, book, ch):
    key = (bible, book, ch)
    if key not in _cache:
        _cache[key] = get_json(f"https://bolls.life/get-text/{bible}/{book}/{ch}/")
        time.sleep(0.35)
    return _cache[key]


def psalm_lxx_exception(ch, v1, v2):
    for (heb_ch, lo, hi), (lxx_ch, shift) in PSALM_LXX_EXCEPTIONS:
        if ch == heb_ch and v1 >= lo and v2 <= hi:
            return lxx_ch, shift
    return None


def clean(text, strip_superscription=False):
    text = re.sub(r"<S>\d+</S>", "", text)
    text = FOOTNOTE.sub("", text)
    text = LINE_BREAK.sub(" ", text)
    if strip_superscription:
        previous = None
        while previous != text:
            previous = text
            text = LEADING_SUPERSCRIPTION.sub("", text)
    text = TAG.sub("", text)
    text = SELAH.sub(" ", text)
    return re.sub(r"\s+", " ", text).strip()


def fetch(bible, book, ch, v1, v2):
    """Returns (text, chapter, first verse, last verse) in the target's numbering."""
    actual_ch, actual_v1, actual_v2 = ch, v1, v2

    offset = PSALM_CHAPTER_OFFSET.get(bible)
    if offset and book == PSALMS:
        exception = psalm_lxx_exception(ch, v1, v2)
        if exception:
            actual_ch, shift = exception
            actual_v1, actual_v2 = v1 + shift, v2 + shift
        elif offset[0] <= ch <= offset[1]:
            actual_ch = ch + offset[2]

    verses = chapter(bible, book, actual_ch)

    if book == PSALMS and bible in PSALM_VERSE_OFFSET:
        english = chapter("NKJV", book, ch)
        delta = max(v["verse"] for v in verses) - max(v["verse"] for v in english)
        if delta > 0:
            actual_v1, actual_v2 = actual_v1 + delta, actual_v2 + delta

    wanted = [v for v in verses if actual_v1 <= v["verse"] <= actual_v2]
    if not wanted:
        raise SystemExit(f"No text for {bible} book {book} {actual_ch}:{actual_v1}-{actual_v2}")

    text = " ".join(
        clean(v["text"], strip_superscription=(book == PSALMS and v["verse"] == 1))
        for v in wanted
    )
    if bible == "NR06":
        text = ELISION_GAP.sub(r"\1", text)
    prose = UNTAGGED_SUPERSCRIPTION.get((bible, book, ch))
    if prose and actual_v1 == 1 and text.startswith(prose):
        text = text[len(prose):].lstrip()
    return CJK_SPACE.sub("", text), actual_ch, actual_v1, actual_v2


def book_name(loc, bolls_books, bible, book_id):
    if loc == "en":
        return EN_BOOKS[book_id]
    if loc == "ar":
        return AR_BOOKS[book_id]
    if loc == "de":
        return DE_BOOKS[book_id]
    if loc == "hi":
        return HI_BOOKS[book_id]
    name = bolls_books[bible][book_id]
    if loc == "ru":
        # "1-e X" -> "1 X", and drop the "Gospel of"/"Epistle to" prefixes.
        name = name.replace("-\u0435 ", " ").replace("-\u044f ", " ")
        for prefix in ("\u041e\u0442 ", "\u041a "):
            if name.startswith(prefix):
                name = name[len(prefix):]
    if loc in ("pt", "it") and name[0].isdigit() and not name[1:2].isspace():
        name = name[0] + " " + name[1:]
    return name


def format_reference(loc, book, ch, v1, v2):
    """Follows the reference style already used in the .arb files."""
    verses = str(v1) if v1 == v2 else f"{v1}-{v2}"
    if loc == "fr":
        return f"{book} {ch}, {verses}"
    if loc == "de":
        return f"{book} {ch},{verses}"
    if loc == "ru":
        return f"{book} {ch}:{verses.replace('-', '\u2013')}"
    return f"{book} {ch}:{verses}"


def main():
    bolls_books = {}
    for _, bible, _ in LOCALES:
        if bible in bolls_books:
            continue
        books = get_json(f"https://bolls.life/get-books/{bible}/")
        bolls_books[bible] = {b["bookid"]: b["name"] for b in books}
        time.sleep(0.3)

    verses = []
    for index, (book, ch, v1, v2) in enumerate(REFERENCES, 1):
        entry = {"locales": {}}
        for loc, bible, label in LOCALES:
            text, actual_ch, actual_v1, actual_v2 = fetch(bible, book, ch, v1, v2)
            entry["locales"][loc] = {
                "text": text,
                "reference": format_reference(
                    loc, book_name(loc, bolls_books, bible, book),
                    actual_ch, actual_v1, actual_v2),
                "translation": label,
            }
        verses.append(entry)
        print(f"  [{index}/{len(REFERENCES)}] {entry['locales']['en']['reference']}",
              file=sys.stderr)

    payload = {
        "_comment": (
            "GENERATED FILE - do not edit by hand, and do not send through DeepL. "
            "Each locale's text is reproduced verbatim from that locale's Bible "
            "translation and must not be machine-translated. "
            "Regenerate with: python3 tool/fetch_thank_you_verses.py"
        ),
        "verses": verses,
    }
    out = Path(__file__).resolve().parent.parent / "assets" / "thank_you_verses.json"
    out.write_text(json.dumps(payload, ensure_ascii=False, indent=2) + "\n")
    print(f"wrote {len(verses)} verses to {out}", file=sys.stderr)


if __name__ == "__main__":
    main()
