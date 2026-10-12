# Hyphenation languages

Long words that don't fit on a line (mostly at large accessibility text sizes)
are broken with a hyphen by `lib/services/hyphenation_service.dart`, using
hyphenation rules ("patterns") from the
[hyphenatorx](https://pub.dev/packages/hyphenatorx) package. Each language
needs its own pattern file.

## Why the package lives in `third_party/`

The pub.dev package bundles pattern files for about 70 languages, 13 MB in
total, and Flutter puts every one of them in the app whether it's used or not.
The app uses a handful, so `third_party/hyphenatorx` is a copy of the package
(1.5.11) that keeps only those, saving about 10 MB of install size.
`pubspec.yaml` points at it with `path: third_party/hyphenatorx`.

**Never switch it back to `hyphenatorx: ^x.y.z`**, including during dependency
upgrades. `flutter pub upgrade` won't do this by itself (path dependencies
aren't upgraded), but editing the line by hand would bring the full 13 MB back.
`test/hyphenation_assets_test.dart` fails if that happens.

## What's in the copy

| Path | Contents |
| --- | --- |
| `assets/language_*.json` | Pattern files the app loads at runtime. **These ship in the app.** |
| `lib/languages/language_*.dart` | The same patterns as Dart. Never imported by app code, so they don't ship; the unit tests use them because asset loading doesn't work in tests. |
| `lib/` (everything else) | The package code, unchanged. |

Both pattern folders hold the same languages: the ones mapped in
`_languageByCode` in `lib/services/hyphenation_service.dart`.

Currently hyphenated: English (`en_us`), Spanish (`es`), French (`fr`),
Portuguese (`pt`), Russian (`ru`), German (`de_1996`), Italian (`it`),
Romanian (`ro`), Finnish (`fi`).

Deliberately not hyphenated (`unhyphenatedLanguages`): Arabic, Hindi and
Chinese. None of those scripts hyphenates words, so adding hyphens would be
wrong.

## Adding a language

Do this whenever a new app language is added (the `add-language` skill includes
it as a step).

1. **Decide whether it hyphenates at all.** Latin, Cyrillic and Greek scripts
   generally do. Arabic, Hebrew, Devanagari, Thai, Chinese, Japanese and Korean
   don't. If it doesn't, add it to `unhyphenatedLanguages` in
   `hyphenation_service.dart` with the reason, and stop. Every app language
   must be in exactly one of `_languageByCode` or `unhyphenatedLanguages`;
   `test/language_parity_test.dart` fails otherwise.
2. **Find its pattern name** in the upstream package. The full list is the
   `Language` enum in upstream `lib/languages/languageconfig.dart` (that file is
   copied unchanged, so the local one has the same list). Names look like
   `language_nl`, `language_pl` or `language_en_gb`; some languages have
   variants (German has `de_1901`, `de_1996`, `de_ch_1901`), so pick the modern
   standard one. If the language isn't in the enum, hyphenatorx can't hyphenate
   it. That's a gap rather than a script without hyphenation, so raise it
   instead of listing the language as exempt.
3. **Copy its two files** from the upstream package into the local copy. After
   `flutter pub get` has fetched the upstream package once, it's at
   `~/.pub-cache/hosted/pub.dev/hyphenatorx-1.5.11/`; otherwise download it from
   [pub.dev](https://pub.dev/packages/hyphenatorx/versions/1.5.11) or
   [GitHub](https://github.com/xErik/hyphenatorx).

   ```bash
   UP=~/.pub-cache/hosted/pub.dev/hyphenatorx-1.5.11
   cp $UP/assets/language_nl.json        third_party/hyphenatorx/assets/
   cp $UP/lib/languages/language_nl.dart third_party/hyphenatorx/lib/languages/
   ```

   If the upstream package isn't in the cache, fetch it without changing the app:
   `dart pub cache add hyphenatorx --version 1.5.11`.
4. **Map it** in `_languageByCode` in `lib/services/hyphenation_service.dart`,
   keyed by the app's language code: `'nl': Language.language_nl,`.
5. **Update the "Currently hyphenated" list** above.
6. **Run `flutter test test/hyphenation_assets_test.dart test/language_parity_test.dart`.**
   The first fails if the map and the pattern files don't match in either
   direction; the second if any app language has no hyphenation decision.

Without step 3, nothing crashes: loading the patterns fails, the error is
logged and caught, and that language quietly goes without hyphenation. The test
is what catches it.

## Removing a language

Delete its entry from `_languageByCode`, then delete both of its files
(`assets/language_xx.json` and `lib/languages/language_xx.dart`) and any test
that imports the `.dart` file.

## Upgrading hyphenatorx

Rarely needed: the package is small and stable. To move to a newer version:

1. `dart pub cache add hyphenatorx --version <new>` to fetch it.
2. Replace `third_party/hyphenatorx/lib/` with the new version's `lib/`, then
   delete every `lib/languages/language_*.dart` **except**
   `languageconfig.dart` and the languages in `_languageByCode`.
3. Replace each file in `third_party/hyphenatorx/assets/` with the new version's
   file of the same name. Don't copy the others.
4. Copy over `LICENSE` and `README.md`, and set `version:` in
   `third_party/hyphenatorx/pubspec.yaml`. Keep that pubspec's comments and its
   `flutter:` section as they are (no `fonts:`; upstream declares a test font
   that would otherwise ship in the app).
5. Update the version number in this doc, then run `flutter test`.
