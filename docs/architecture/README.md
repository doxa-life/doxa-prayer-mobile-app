<!-- GENERATED FILE — do not edit by hand.
     Facts come from lib/ via tool/architecture/facts.dart.
     Narrative comes from tool/architecture/catalogue.dart.
     Regenerate with: dart run tool/gen_architecture.dart -->

# App architecture

What happens in the background when someone taps something. Written for the case where you have been away from the code for a few weeks and need to know which quiet server call a button sets off.

| Document | What it answers |
| --- | --- |
| [actions.md](actions.md) | Per surface: every action, what the user sees, and what they don't. |
| [identity.md](identity.md) | How a device gets a tracking id, a profile and a prayer subscription — and how it becomes push-addressable. |
| [data-layer.md](data-layer.md) | Endpoint, cache, storage and route inventories, and which action touches which endpoint. |

## Scale

13 HTTP endpoints across 15 built URIs · 15 persisted keys · 15 routes · 25 documented actions.

## Keeping this true

The tables and inventories are scanned out of `lib/` on every regeneration. The prose is hand-written in `tool/architecture/catalogue.dart`, but every fact it cites — a function name, an endpoint, a prefs key — is checked against the source. Rename `submitAnonSignup` and generation fails until the catalogue is updated.

```sh
dart run tool/gen_architecture.dart          # regenerate
dart run tool/gen_architecture.dart --check  # fail if stale
```

`test/architecture_docs_test.dart` runs the check, so drift fails with the rest of the suite rather than waiting to be noticed.

Regeneration also lists any endpoint or persisted key that no documented action accounts for, so a new one cannot quietly go undescribed.

## The one exception

Server-side behaviour cannot be checked from this repo, so those notes are labelled **On the server** and carry their own provenance: read from `doxa-campaigns-server` at `63eee8e` (master) on 2026-08-28, from:

- `server/api/people-groups/[slug]/anon-signup.post.ts`
- `server/api/news-signup.post.ts`
- `server/database/subscribers.ts`
- `server/utils/email-consents.ts`

Update `serverVerification` in `tool/architecture/catalogue.dart` when they are re-checked.
