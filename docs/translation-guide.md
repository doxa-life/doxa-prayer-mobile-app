# Translation Guide

How to add and change user-facing strings in this app without breaking the five
translations. Written up from the July 2026 translation audit
([REPORT.md](translation-audit/REPORT.md)), which found six shipping Blockers — most of
them caused by patterns that look perfectly fine in English.

**Languages:** English (`en`) is the template. The rest are listed in
`lib/services/locale_controller.dart`, which is what the app offers, and each
has an `app_{code}.arb`. Check that file rather than this line; languages are
added on branches.

---

## 1. The rules that matter most

1. **The DOXA glossary is the source of truth for terminology**, not the `.arb`
   files. See §2.
2. **Never hand-edit `lib/l10n/app_localizations*.dart`.** It is generated. Edit the
   `.arb` and run `flutter gen-l10n`.
3. **Never write a user-visible string as a Dart literal.** It will ship in English to
   every non-English user. The audit found exactly one (`Text('Retry')`) and it had gone
   unnoticed through a release.
4. **`=0` / `=1` in a plural is a trap in Russian and Arabic.** This is the single
   highest-value thing in this document — see §4.
5. **Changing an English string invalidates all five translations.** Say so in the PR;
   don't assume the translations still fit.

---

## 2. Authority order for terminology

When there is any question about *which word* to use:

| Rank | Source |
|---|---|
| 1 | **The DOXA glossary for that language**, `https://pray.doxa.life/api/glossary/{lang}` — add `?format=markdown` to read it |
| 2 | Its `notes` field, for register, acronym policy and number format |
| 3 | The app's own existing approved strings, as precedent |

The glossary is maintained in the campaigns server's admin at `/admin/glossary`,
where native-speaking reviewers confirm each term through a magic link, and it
is authoritative for this app, the prayer site and the marketing site alike. A
term marked `draft` is still authoritative: wording nobody has ruled on yet, not
wording to ignore.

The `.arb` strings themselves carry **no** authority — they are AI-generated and have
needed three correction passes. Never reason "the other four locales say X, so X is
right"; the audit found cases where four locales agreed and were all wrong, and cases
where one locale differed and was the only correct one.

The glossary is **read-only from this repository**. If a term is wrong or
missing, that is a conversation with whoever runs the review, and the fix is
made in the admin so every property gets it. `/sync-language <code>` brings this
repository into line after they do.

### Where the glossary is silent

Most platform vocabulary (notifications, alarms, verification email, profile, feedback)
has no glossary entry. Resolve it from the nearest glossary precedent plus what the file
already uses, and **record the decision** — the audit's per-language decision tables are
in `translation-audit/findings-{lang}.md`. The canonical renderings settled there:

| Concept | ar | es | fr | pt | ru |
|---|---|---|---|---|---|
| notifications | الإشعارات | notificaciones | notifications | notificações | уведомления |
| exact alarms | المنبّهات الدقيقة | alarmas exactas | alarmes exactes | alarmes exatos | точные будильники |
| reminder | تذكير | recordatorio | rappel | lembrete | напоминание |
| verification email | رسالة التحقق | correo de verificación | e-mail de vérification | e-mail de verificação | письмо для подтверждения |
| feedback | تعليقات | comentarios | commentaires | comentários | отзыв |
| updates / news | آخر المستجدات | novedades | actualités | novidades | новости |
| profile | الملف الشخصي | perfil | profil | perfil | профиль |
| phone (the device) | هاتف | móvil | téléphone | celular | телефон |

Note the last row is es-ES **móvil** and pt-BR **celular** — see §6.

---

## 3. Placeholders

- A placeholder is `{name}`. The **name must be identical** in every locale — never
  translate, rename, reorder-into-nonsense, drop, or add one.
- **Name-like placeholders get quoted; numeric and technical ones do not.**

| Class | Placeholders | Delimiter |
|---|---|---|
| Name-like (a people group, a user-supplied name) | `{name}`, `{currentName}`, `{newName}`, `{peopleGroup}` | quoted, per language below |
| Numeric / technical | `{count}`, `{seconds}`, `{time}`, `{weekday}`, `{version}`, `{email}` | **bare** |

Per-language delimiter, settled by the audit:

| Lang | Delimiter | Note |
|---|---|---|
| `ar` | `«{x}»` | U+00AB / U+00BB, no inner space |
| `es` | `«{x}»` | no inner space — Spanish differs from French here |
| `fr` | `« {x} »` | **U+202F inside both**, see §5 |
| `pt` | `“{x}”` | U+201C / U+201D — curly quotes, **not** guillemets (see §6) |
| `ru` | `«{x}»` | no inner space |

Quotes are typography only — they sit outside the ICU braces, so substitution is
unaffected, and screen readers do not speak them.

**Watch the direction of prepositions.** The audit caught French
`feedbackSuccessBody` saying the feedback was sent *to* `{email}` when the English
means *from* it. Placeholder-adjacent prepositions are where meaning quietly reverses.

---

## 4. Counted strings and ICU plurals — read this before adding one

### The `=1` trap

`gen-l10n` does **not** compile `=1` to an exact-value match. It emits the branch as the
`one:` argument of `Intl.pluralLogic`, which then consults the **target language's CLDR
rule**. Russian's `one` category is `n % 10 == 1 && n % 100 != 11`, so:

```jsonc
// app_ru.arb — WRONG, and shipped for months
"nPeopleGroups": "{count, plural, =0{Нет народов} =1{1 народ} other{{count} народов}}"
```

rendered the literal string **"1 народ" at counts 21, 31, 41, 101 …** on the
people-group search screen, which routinely shows more than 21 results. It also rendered
`2 народов` where Russian needs `2 народа`.

**Rule:** in a locale file, use the **CLDR category names**, not `=N` branches:

```jsonc
// app_ru.arb — correct
"nPeopleGroups": "{count, plural, =0{Нет народов} one{{count} народ} few{{count} народа} many{{count} народов} other{{count} народов}}"
```

- `=0` is safe in every language we ship — no locale has a CLDR `zero` category that
  captures other numbers, so the branch fires only at exactly 0.
- Never put a **literal digit** inside a category branch (`one{1 народ}`). Use `{count}`.
  A hardcoded `1` inside a category that also matches 21 and 101 *is* the bug.
- Categories needed: `es`/`fr`/`pt` → `one`/`other`. `ru` → `one`/`few`/`many`/`other`.
  `ar` → `zero`/`one`/`two`/`few`/`many`/`other`.
- `=1` is harmless in `en` and `ar` (their CLDR `one` is exactly `n == 1`), but prefer
  the category name everywhere so the pattern isn't copied into a language where it
  breaks.

### Author counted strings as plurals from the start

English hides agreement by abbreviating — `Resend in {seconds}s`. Arabic cannot: it has
to spell the unit out, and the counter ticks through 1, 2 (dual) and 3–10 (broken
plural), each needing a different form. So a flat English template forces the Arabic
translator to either introduce plural machinery alone or ship something ungrammatical.

**If a string interpolates a count, make it an ICU plural in `app_en.arb` even when
English does not strictly need one.** `gen-l10n` accepts a flat English template
alongside pluralised locales, so a later fix is possible — but it lands as a
five-language change nobody scheduled.

### Known open item

`ar` `nPeopleGroups` and `nRemindersSet` are still wrong at counts 2 and 3–10 — they
lack `two` and `few`. The skeletons are ready in
[REPORT.md §6](translation-audit/REPORT.md); they need an Arabic speaker to supply the
dual and 3–10 noun forms. Nobody should guess these.

---

## 5. French typography — invisible characters that are load-bearing

French requires a **no-break space** before certain punctuation, and the width differs by
mark. These characters are visually identical to a normal space and are silently
destroyed by ordinary copy-paste — the audit's own handoff degraded them once.

| Before | Character | Codepoint | `ord()` |
|---|---|---|---|
| `;` `?` `!` and inside `« »` | narrow no-break space | **U+202F** | 8239 |
| `:` and between a number and its unit (`{seconds} s`) | no-break space | **U+00A0** | 160 |

An ordinary ASCII space here is a **rendering defect**, not just a style nit: Flutter can
wrap the line and orphan the `?` or `!` at the start of the next one.

**Build these programmatically, never by hand:**

```python
s = "Merci !"                 # not "Merci !"
assert ord(s[-2]) == 8239          # verify before writing
```

Then verify after writing: for every `; ? ! :` and guillemet in a changed French string,
print `ord()` of the adjacent character and confirm 8239 or 160 — **never 32**.

Other per-language typography:
- `es` — `¿`/`¡` must be paired with their closing marks.
- `ru` — the file writes `ё` (`Вперёд`, `ещё`, `всё`). Keep it; `все` vs `всё` is a real
  meaning difference (*everyone* vs *everything*).
- `ar` — `Doxa` stays in **Latin script**, never transliterated as `دوكسا`. Verify RTL
  strings by codepoint comparison, not by eye; a bidi-naive editor can permute them.

---

## 6. Language variants

| Locale | Variant | Diagnostic vocabulary |
|---|---|---|
| `es` | **European Spanish**, informal *tú* | `ajustes`, `aplicación`, `móvil` — not *configuraciones*, *app*, *celular* |
| `pt` | **Brazilian Portuguese**, *você* | `aplicativo`, `Configurações`, `Salvar`, `celular` — not *aplicação*, *definições*, *guardar*, *telemóvel* |

**The `pt` file is named `app_pt.arb` and its glossary `glossary.pt_PT.md`, but the target
is pt-BR.** The glossary's own front matter says `language: Portuguese (Brazil-leaning)`.
Do not "correct" that file toward European Portuguese on the strength of the filename.

Register per language, taken from the approved strings: `ar` formal · `es` tú ·
`fr` vous · `pt` você · `ru` вы (lowercase, never capitalised «Вы»).

Button labels are **infinitive** in every language (`Guardar`, `S'inscrire`,
`Inscrever-se`, `Сохранить`); imperatives are reserved for body prose and CTAs.

---

## 7. Non-translatables

- **`Doxa`** — proper name. Never translated, never transliterated, never inflected. The
  audit found Arabic had rendered `appName` as "prayer of Doxa" and told users to open
  "the **book** Doxa".
- **`DOXA`** all-caps on buttons comes from `ActionButton`'s `label.toUpperCase()` at
  runtime — do not bake it into a string.
- `pt` keeps a deliberate gender split: **`o Doxa`** = the app (permissions, opening it),
  **`a Doxa`** = the ministry (sender of news). Don't harmonise them.

---

## 8. Workflow

### Adding or changing a string

1. Edit `lib/l10n/app_en.arb`. Every key needs an `@key` block with a `description` that
   states **where it renders and what it means** — translators are held to it, and five
   reviewers judged 19 strings without one because the blocks had been skipped.
   Mark the slot in the description if it is tight (button, chip, status label).
2. Add the same key to every locale file, **with the `@key` block duplicated**. That
   duplication is this repo's convention: whoever translates that file reads the
   description in it, so a stale copy misleads them.
3. Run `flutter gen-l10n`, then `flutter analyze`.
4. Run the parity check:

   ```bash
   python3 tool/check_arb.py
   ```

   It verifies key-set equality against `app_en.arb`, `@key` coverage, ICU placeholder
   parity, brace balance, encoding hygiene, and that `Doxa` is never transliterated.
   **Exit 1 means don't merge.**

### Changing an existing English string

This invalidates all five translations. Update them in the same change, or the app ships
a translation that answers a different question — which is how `prayerReminderTitle`
came to read "feel like praying today?" in all five languages instead of naming the daily
commitment.

### Deleting a key

Delete the string **and** its `@key` block from every locale file. `tool/check_arb.py`
catches one left behind.

### Length

Translations run longer than English — up to 2.6× on short labels (`Sign up` →
`Зарегистрироваться`). Nothing in `lib/` uses `maxLines: 1` or `TextOverflow.ellipsis`,
so the failure mode is an extra line rather than truncation, and `ButtonBarWrap` measures
labels and stacks them when a pair won't fit. Still: for a new button or chip, check
`ru` and `fr` at large text scale before shipping. This app has had two button-overflow
bugs (`344ff12`, `1d10434`).

---

## 9. Accessibility strings

Six keys are **spoken only, never seen** (`*Label` keys, `prayerRecordedAnnouncement`,
`partial`). Judge them as speech: full words, no abbreviations, no punctuation artefacts,
natural spoken word order.

Two traps the audit documented:
- Status words like `partial` are announced as their **own isolated `Semantics` node**,
  deliberately not composed with the marker label — a bare "No" at the tail of a longer
  phrase was read by TTS as the abbreviation "№". So they are uttered alone, and there is
  no noun for an adjective to agree with. Russian correctly uses the adverb «Частично».
- Quotes around a placeholder are silent, so an a11y label like "Pray for Kyrk" gives the
  listener nothing marking Kyrk as a people group. Russian therefore spells the head noun
  out: «Помолиться за народ «{peopleGroup}»».

---

## 10. Keeping up with the glossary

Reviewers edit the glossary live, so terminology moves without this repository
moving. `/sync-language <code>` is what brings a locale back into line: it reads
the glossary, applies the terms and the notes, regenerates, and runs the parity
check.

`/add-language <code>` covers a language the app does not carry yet — the ARB,
the locale list, fonts for a new script, and the thank-you verses in that
language's own Bible.

Both refuse to start for a language with no glossary. That is deliberate:
strings written before the terminology exists have to be rewritten after.

Two things to know before editing an ARB by hand:

- **Key order.** Keys sit in alphabetical position. Insert a new one where it
  belongs and leave the rest alone; an ordering diff is noise, not a fix.
- **`@@locale`.** None of the files carries one, so the language is identified
  by filename. Adding it is a known outstanding item (REPORT.md H-06) and was
  deliberately left alone.

---

## 11. Further reading

| Document | What it holds |
|---|---|
| [translation-audit/REPORT.md](translation-audit/REPORT.md) | The July 2026 audit: every ruling, the arbitration log, per-language change sets |
| [translation-audit/findings-{lang}.md](translation-audit/) | Per-language reasoning and the glossary-silent decision tables |
| [translation-audit/findings-mechanical.md](translation-audit/findings-mechanical.md) | The ICU/plural analysis, including the `Intl.pluralLogic` proof behind §4 |
| [translation-audit-plan.md](translation-audit-plan.md) | The audit method, if another one is ever needed |
