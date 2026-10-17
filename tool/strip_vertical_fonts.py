#!/usr/bin/env python3
"""Strip vertical-writing data from every font the app bundles.

Vertical writing (text set top to bottom, as Chinese and Japanese can be) needs
its own metrics tables and layout features. Flutter's text engine lays text out
horizontally only — it has no vertical writing mode — so that data can never be
used, and in a CJK font it is not small: 0.26 MB of NotoSansSC.

What is removed, from each font under assets/fonts/:
  * the tables `vhea`, `vmtx` and `VORG` (vertical metrics);
  * the layout features `vert`, `vrt2`, `vhal`, `vkrn` and `vpal`, and the
    glyphs that only those features reach (rotated and vertical punctuation
    forms, which no character maps to).

Nothing else changes: every character the font maps before is mapped after —
the script checks, and refuses to write a font that would lose one — and the
horizontal metrics, other features and hinting are left as they are.

`test/font_vertical_data_test.dart` fails when any bundled font carries
vertical data, so a font replaced with a fresh download (or a new font added)
has to go through this script before the suite passes again.

Needs fontTools:  python3 -m pip install fonttools

Usage:
  python3 tool/strip_vertical_fonts.py           # strip, in place
  python3 tool/strip_vertical_fonts.py --check   # exit 1 if any font has it
"""
import os
import sys

try:
    from fontTools import subset
    from fontTools.ttLib import TTFont
except ImportError:
    sys.exit("fontTools is needed: python3 -m pip install fonttools")

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
FONT_DIR = os.path.join(ROOT, "assets", "fonts")
VERTICAL_TABLES = ("vhea", "vmtx", "VORG")
VERTICAL_FEATURES = {"vert", "vrt2", "vhal", "vkrn", "vpal"}


def fonts():
    for dirpath, _, files in os.walk(FONT_DIR):
        for name in sorted(files):
            if name.lower().endswith((".ttf", ".otf")):
                yield os.path.join(dirpath, name)


def features(font):
    tags = set()
    for table in ("GSUB", "GPOS"):
        if table in font and font[table].table.FeatureList:
            tags |= {r.FeatureTag for r in font[table].table.FeatureList.FeatureRecord}
    return tags


def vertical_data(font):
    """What vertical data [font] carries: table tags and feature tags."""
    return (
        [t for t in VERTICAL_TABLES if t in font],
        sorted(features(font) & VERTICAL_FEATURES),
    )


def strip(path):
    font = TTFont(path)
    before = set(font.getBestCmap())
    keep = sorted(features(font) - VERTICAL_FEATURES)

    opts = subset.Options()
    # Keep the font exactly as it is apart from the vertical data.
    opts.layout_features = keep
    opts.drop_tables = list(opts.drop_tables) + list(VERTICAL_TABLES)
    opts.hinting = True
    opts.legacy_kern = True
    opts.notdef_glyph = True
    opts.notdef_outline = True
    opts.recalc_bounds = False
    opts.name_IDs = ["*"]
    opts.name_languages = ["*"]
    opts.name_legacy = True
    opts.glyph_names = True
    opts.symbol_cmap = True
    opts.legacy_cmap = True
    opts.prune_unicode_ranges = False
    opts.prune_codepage_ranges = False

    subsetter = subset.Subsetter(opts)
    subsetter.populate(unicodes=before)
    subsetter.subset(font)

    after = set(font.getBestCmap())
    if after != before:
        sys.exit(
            f"refusing to write {os.path.relpath(path, ROOT)}: it would lose "
            f"{len(before - after)} character(s)"
        )
    size_before = os.path.getsize(path)
    font.save(path)
    print(
        f"stripped {os.path.relpath(path, ROOT)}: "
        f"{size_before / 1e6:.2f} MB -> {os.path.getsize(path) / 1e6:.2f} MB, "
        f"all {len(after)} characters kept"
    )


def main():
    check = "--check" in sys.argv[1:]
    found = []
    for path in fonts():
        tables, feats = vertical_data(TTFont(path, lazy=True))
        if tables or feats:
            found.append((path, tables, feats))

    if check:
        for path, tables, feats in found:
            print(f"{os.path.relpath(path, ROOT)}: tables {tables}, features {feats}")
        if found:
            sys.exit("vertical data found; run: python3 tool/strip_vertical_fonts.py")
        print("no bundled font carries vertical data")
        return

    if not found:
        print("no bundled font carries vertical data; nothing to do")
    for path, _, _ in found:
        strip(path)


if __name__ == "__main__":
    main()
