---
name: add-language
description: Bring a new language into the app — the ARB file translated off the DOXA glossary, the locale list, fonts for a new script, and the thank-you verses in that language's Bible. Use after the language has a glossary with reviewed terms. Invoke with /add-language <code>.
user-invocable: true
---

# Add a language to the app

Argument: the language code. The language must already exist in the DOXA
glossary, maintained in the campaigns server's admin and published at
`https://pray.doxa.life/api/glossary/{code}`.

## 1. Refuse to start without a glossary

```bash
curl -s -o /dev/null -w '%{http_code}\n' https://pray.doxa.life/api/glossary/{code}
```

A 404 means the language has no terminology yet. Stop and say so: an admin adds
it at `/admin/glossary` on pray.doxa.life and a reviewer confirms the terms.
Strings written before that have to be rewritten after.

Read the whole glossary first, `notes` included.

## 2. Check the checkout is current

`git fetch`, then look at the branches. A locale may already exist upstream. If
the working tree sits on another language's branch, work in a `git worktree`
rather than switching.

## 3. Write the ARB

Copy `lib/l10n/app_en.arb` to `lib/l10n/app_{code}.arb` and translate every
value, keeping the `@key` metadata blocks.

- Never add or drop a key, and never change a placeholder name.
- Read each `@key` description before translating its string: it says where the
  text renders and how much room it has.
- **Counted strings.** Use the CLDR plural categories this language actually
  has, not `=1`. Russian needs `one`, `few`, `many`, `other`; Arabic needs
  `zero`, `one`, `two`, `few`, `many`, `other`. `=0` is safe everywhere. Never
  put a literal digit inside a category branch.
- **"Doxa" is never translated or transliterated.** Not in any script.
- Apply the glossary notes: register, acronyms, numerals.

## 4. Offer it in the app

Add the locale to `AppLanguage` in `lib/services/locale_controller.dart` with
its endonym, in the same form the other entries use.

## 5. Fonts, for a new script

`lib/theme/app_typography.dart` picks a family per script and `pubspec.yaml`
declares what ships. Latin, Cyrillic, Arabic and Han are covered by the vendored
faces. A script none of them covers needs its font file added to `assets/fonts/`
with its license, declared in `pubspec.yaml`, and wired into the typography
fallback list. Check that the heading face has glyphs for the script; where it
does not, the script falls back, which is expected rather than a defect.

## 6. Thank-you verses

`assets/thank_you_verses.json` holds each locale's verses in that locale's own
published Bible translation, never a machine translation.

```bash
python3 tool/fetch_thank_you_verses.py
```

It reads each language's edition from the campaigns server's `/api/languages`
(`https://pray.doxa.life` unless `DOXA_SITE_URL` points elsewhere), for every
locale that has an `app_{code}.arb`. A language whose glossary records no Bible
edition cannot have this step: say so rather than translating the verses, and
raise it as a question for the reviewer.

## 7. Verify

```bash
flutter gen-l10n
python3 tool/check_arb.py
flutter analyze
flutter run --flavor staging
```

Generated Dart files are tracked, so they are part of the change. Walk the
onboarding wizard, the pray screen, reminders and settings in the new language.
Check a long label at a large text scale; translations run up to about 2.6 times
English. For a right-to-left language, confirm the layout mirrors and verify the
strings by codepoint rather than by eye.

`flutter pub get` dirties `macos/Flutter/*.xcconfig` and creates
`macos/Podfile`. Discard both before committing.

## 8. Store listings

`android/fastlane/metadata/` carries the Play listing. Adding a listing for the
new language is a separate decision about market presence, not part of shipping
the strings. Name it in the report rather than doing it.

## 9. Report

What was added, what still falls back to English, which fonts were added, and
anything a reviewer must answer. Leave the changes uncommitted unless a pull
request is asked for.
