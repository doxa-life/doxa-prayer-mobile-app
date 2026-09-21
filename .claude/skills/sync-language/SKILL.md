---
name: sync-language
description: Bring the app's existing strings for one language into line with the current DOXA glossary — the ARB file, the generated localizations, and the parity checks. Use after a reviewer confirms or changes terminology. Invoke with /sync-language <code>.
user-invocable: true
---

# Align the app with the glossary

Argument: a language code the app already carries. For a new one, use
`/add-language`.

## 1. Read the glossary

```bash
curl -s https://pray.doxa.life/api/glossary/{code}?format=markdown
```

The DOXA glossary is maintained in the campaigns server's admin, where reviewers
confirm each term through a magic link, and it is authoritative for the app, the
prayer site and the marketing site alike. The response carries `notes` as well
as terms: this language's register, its prayer-prompt verbs, acronym policy and
number format. Read those first.

A `draft` term is still authoritative — wording nobody has ruled on yet, not
wording to ignore.

**The ARB strings carry no authority of their own.** They were machine-drafted
and have needed several correction passes. Never reason that four locales agree
so the fifth is wrong; past audits found cases where the four were all wrong.

## 2. Check the checkout is current

```bash
git fetch
git status
```

Locales have been added on branches. A language can look absent here and exist
upstream, and a sweep against a stale checkout silently redoes someone's work.
If the working tree sits on another language's branch, do this one in a
`git worktree` rather than switching.

## 3. Edit the ARB

`lib/l10n/app_{code}.arb`. Never edit `lib/l10n/app_localizations*.dart` — they
are generated.

- Replace deviant terms with the glossary wording.
- Keys never change. Placeholder names never change.
- Keep the `@key` metadata blocks. Each locale file carries its own copy and a
  stale one misleads whoever reads it next.
- Apply the notes: register, acronyms, numerals.

Terminology that the glossary does not cover — notifications, reminders,
profile, feedback — is not a glossary question. Follow what the file already
uses and stay consistent.

## 4. Regenerate and check

```bash
flutter gen-l10n
python3 tool/check_arb.py
flutter analyze
```

`check_arb.py` verifies the key set against English, `@key` coverage,
placeholder parity, brace balance, and that "Doxa" is never transliterated.
A non-zero exit means do not merge.

The generated Dart files are tracked, so commit them with the ARB.

`flutter pub get` rewrites `macos/Flutter/*.xcconfig` and creates
`macos/Podfile`. Discard both before committing.

## 5. Things that bite in this repository

- **Plurals.** Use the CLDR category names — `one`, `few`, `many`, `other` —
  never `=1`. `gen-l10n` compiles `=1` to the `one` category, which in Russian
  also matches 21, 31 and 101. A literal digit inside a category branch is the
  bug; use the placeholder.
- **French spacing.** A narrow no-break space (U+202F) before `; ? !` and inside
  guillemets, a no-break space (U+00A0) before `:` and between a number and its
  unit. They look identical to a normal space and are destroyed by ordinary
  copy-paste. Write them programmatically and verify by codepoint.
- **Right-to-left.** Verify Arabic by codepoint comparison, not by eye. A
  bidi-naive editor can reorder what it displays.
- **Length.** Translations run up to about 2.6 times English on short labels.
  Check a new button in the longest language at a large text scale.

## 6. Report

Strings changed, anything deliberately left, and any question only a reviewer
can settle. Leave the changes uncommitted unless asked for a pull request.
