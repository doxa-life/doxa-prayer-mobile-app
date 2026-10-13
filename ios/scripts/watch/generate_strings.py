#!/usr/bin/env python3
"""Generates ios/DoxaWatch/Localizable.xcstrings from the app's ARB files.

The watch app reuses the phone's reviewed translations wherever a string
already exists in lib/l10n/app_<lang>.arb, so the two apps never drift and the
DOXA glossary stays the single source of terminology. Strings only the watch
needs live in WATCH_ONLY below, in English, until they go through the normal
translation review; watchOS falls back to English for them.

Run after any ARB change (the add-language / sync-language skills should call
it once the watch app ships):

    python3 ios/scripts/watch/generate_strings.py
"""

import json
import re
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
ARB_DIR = ROOT / "lib" / "l10n"
OUT = ROOT / "ios" / "DoxaWatch" / "Localizable.xcstrings"

# ARB keys the watch uses, translated in every language the app ships.
FROM_ARB = [
    "amen",
    "addAnotherPeopleGroup",
    "cancel",
    "choosePeopleGroup",
    "couldNotLoadPrayerContent",
    "dayInTheLifeTitle",
    "myPeopleGroupTitle",
    "noPeopleGroupSelected",
    "noPrayerContentAvailable",
    "pauseAndPray",
    "peopleGroupIntroTitle",
    "peopleGroupOfTheDay",
    "population",
    "prayedToday",
    "prayerRecordedAnnouncement",
    "prayerThankYouTitle",
    "reminderNotificationBody",
    "reminderNotificationBodyForGroup",
    "reminderNotificationTitle",
    "reminders",
    "retry",
    "searchPeopleGroups",
    "settings",
    "time",
]

# Watch-only strings. English only until reviewed against the glossary.
WATCH_ONLY = {
    "watchDailyReminder": "Daily reminder",
    "watchDone": "Done",
    "watchLoading": "Loading…",
    "watchNoMatches": "No matches",
    "watchRemove": "Remove",
    "watchSendTestReminder": "Send test reminder",
    "watchToday": "Today",
}

# ARB locale -> Apple localization identifier.
APPLE_LOCALE = {"zh": "zh-Hans"}

PLACEHOLDER = re.compile(r"\{(\w+)\}")


def to_format(value: str) -> str:
    """ARB `{name}` placeholders -> positional `%1$@` format specifiers."""
    names = []

    def repl(match):
        if match.group(1) not in names:
            names.append(match.group(1))
        return f"%{names.index(match.group(1)) + 1}$@"

    value = value.replace("%", "%%")
    out = PLACEHOLDER.sub(repl, value)
    # A single placeholder reads better (and matches Xcode's own output) as %@.
    return out.replace("%1$@", "%@") if len(names) == 1 else out


def unit(value: str) -> dict:
    return {"stringUnit": {"state": "translated", "value": to_format(value)}}


def main() -> None:
    arbs = {}
    for path in sorted(ARB_DIR.glob("app_*.arb")):
        lang = path.stem.removeprefix("app_")
        arbs[lang] = json.loads(path.read_text(encoding="utf-8"))

    strings = {}
    for key in FROM_ARB:
        if key not in arbs["en"]:
            raise SystemExit(f"{key} is missing from app_en.arb")
        localizations = {}
        for lang, arb in arbs.items():
            if key in arb:
                localizations[APPLE_LOCALE.get(lang, lang)] = unit(arb[key])
        strings[key] = {"extractionState": "manual", "localizations": localizations}

    for key, value in WATCH_ONLY.items():
        strings[key] = {
            "comment": "Watch-only; English until reviewed against the DOXA glossary.",
            "extractionState": "manual",
            "localizations": {"en": unit(value)},
        }

    catalog = {
        "sourceLanguage": "en",
        "strings": dict(sorted(strings.items())),
        "version": "1.0",
    }
    OUT.write_text(json.dumps(catalog, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")
    print(f"Wrote {len(strings)} strings in {len(arbs)} languages to {OUT.relative_to(ROOT)}")


if __name__ == "__main__":
    main()
