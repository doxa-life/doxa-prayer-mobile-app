# Multiple people groups — implementation plan

Lets someone pray for up to **5** people groups instead of exactly 1.
Decisions were settled in discovery on 2026-09-11; this plan is the build order.

> **Built.** All seven phases are implemented on `feat/v2` and were verified on a
> Pixel 6 against staging: add, the cap and its swap modal (reached both from the
> browse list and from an `/app/<slug>` share link), remove with its reminder
> cascade, per-group reminders and their stacked notifications, the home carousel
> and the Pray tab switcher. Two things changed from the plan as written — see
> **As built** at the end.

Server note: **no doxa-campaigns-server changes are required.** It already stores
one `campaign_subscriptions` row per `(subscriber, people_group)` with
`delivery_method = 'app'`, `anon-signup` is already an upsert per slug, and
`POST /api/people-groups/{slug}/unsubscribe` already exists.

---

## Phase 1 — Storage and the subscription list

Replaces the single-selection controller. Nothing user-visible changes yet.

**New** `lib/services/subscribed_people_groups_controller.dart`

```dart
class SubscribedPeopleGroup {   // slug, name, imageUrl, subscriptionId
class SubscribedPeopleGroups {  // List<SubscribedPeopleGroup> list, String? activeSlug
```

- `peopleGroupsController` — `ValueNotifier<SubscribedPeopleGroups>`.
- `activePeopleGroup` getter: the entry matching `activeSlug`, else the first, else null.
- `addPeopleGroup`, `removePeopleGroup(slug)`, `setActivePeopleGroup(slug)`,
  `setSubscriptionId(slug, id)`, `loadPeopleGroups()`.
- `kMaxPeopleGroups = 5`.

**Persistence** — two new prefs keys, replacing the three `selected_people_group_*` ones:

| Key | Holds |
| --- | --- |
| `people_group_subscriptions` | JSON list of `{slug, name, imageUrl, subscriptionId}`, in add order |
| `active_people_group_slug` | the active slug |

**Migration** (runs once inside `loadPeopleGroups`): if the new key is absent and
`selected_people_group_slug` is present, build a one-entry list from the three old
keys, take `subscriptionId` from `identity_subscription_id`, set it active, write the
new keys, delete the old three. `identity_subscription_id` itself stays — the
news-signup path still writes it — but people-group operations stop reading it.

**Delete** `lib/services/selected_people_group_controller.dart` once callers move.
Callers to update: `home_screen.dart`, `pray_screen.dart`, `cache_warmup.dart`,
`anon_signup_service.dart`, `profile_update_service.dart`,
`select_people_group_flow.dart`, `select_people_group_button.dart`,
`wizard_step_people_group_confirm.dart`, `people_groups_service.dart` warm-up.

**Tests** — `test/subscribed_people_groups_controller_test.dart`: migration from the
old keys, add/remove, cap enforcement, active-slug fallback when the active group
is removed.

---

## Phase 2 — Server sync, per group

`_selectPrayerReminder` is currently duplicated verbatim in `anon_signup_service.dart`
and `profile_update_service.dart`. Extract it first.

**New** `lib/services/reminder_schedule.dart` — `scheduleForGroup(String slug)`
returning `(hour, minute, weekdays)` from that group's reminders only, with the
existing 08:00-daily fallback when the group has none.

**`anon_signup_service.dart`** — `submitAnonSignup` already takes a slug; call it per
newly added group and store the returned `subscription_id` against that slug via
`setSubscriptionId`. `installDeferredAnonSignupListener` keeps working for the first
group (it fires on the first entry appearing).

**`profile_update_service.dart`** — `submitProfileUpdate` becomes
`submitProfileUpdate({String? slug})`:
- with a slug, PUT that group's `subscription_id` + its own schedule;
- with none, PUT every subscribed group (used on timezone/locale change).
- `consent_people_group_slug` keeps pointing at the **active** group only.
- Debounce the controller listener (~500ms) so one reminder edit is one PUT, and
  only for the affected slug — today it fires a PUT on every notifier change.

**New** `lib/services/unsubscribe_service.dart` —
`POST /api/people-groups/{slug}/unsubscribe?id={profileId}&sid={subscriptionId}`.
`sid` is **required**: `all=true` would also unsubscribe that person's *email*
subscriptions for the group. No-op (logged) when `profileId` is null — identity may
not have resolved yet.

---

## Phase 3 — Add, remove, and the cap

**Rename** `select_people_group_flow.dart` → `lib/services/people_group_subscription_flow.dart`:

- `addPeopleGroupFlow(context, slug, name, imageUrl)` — under the cap, adds and fires
  anon-signup. At the cap, opens the swap modal.
- `removePeopleGroupFlow(context, slug)` — confirm modal, then remove + delete that
  group's reminders + reschedule + POST unsubscribe.

**New components** (one per file):
- `lib/components/misc/swap_people_group_modal.dart` — lists the 5 current groups.
  Nothing preselected; confirm disabled until one is picked; cancel carries the
  visual weight. Names what is lost, including the reminder count.
- `lib/components/misc/remove_people_group_modal.dart` — "Stop praying for {name}?
  Its {n} reminders will be deleted."
- `lib/components/buttons/subscribe_people_group_button.dart` — replaces
  `select_people_group_button.dart`. Three states: Add / Praying (tap to remove) /
  Add (at cap → swap).

Every add route goes through `addPeopleGroupFlow`, including the `/app/{slug}` share
link (which already lands on the details screen — no router change) and the wizard's
referral path.

**Tests** — `test/swap_people_group_modal_test.dart` (confirm stays disabled with
nothing picked), `test/remove_people_group_modal_test.dart` (reminder count in copy).

---

## Phase 4 — Reminders belong to a group

**`lib/services/reminders_controller.dart`**
- `Reminder` gains `final String slug;` — required, in `toJson`/`fromJson`/`copyWith`.
- `fromJson` migration: a reminder with no `slug` adopts the active group's slug.
- `deleteRemindersForGroup(String slug)` — used by the remove flow.

**`lib/services/reminders_notifications.dart`**
- `_notificationId` is keyed by `(slug, weekday, hour, minute)` instead of
  `(weekday, hour, minute)`. Two reminders for the *same* group at 08:00 still
  collapse into one alert; two *different* groups at 08:00 now stack. Hash the slug
  into the high bits and keep the result under 2^31.
- Notification copy takes the group name: `reminderNotificationBody(groupName)`.
- Payload becomes the slug instead of the flat `'pray'` string.

**`lib/app_shell.dart`** — `_onReminderTap` reads the slug from the payload, calls
`setActivePeopleGroup(slug)`, then switches to the Pray branch.

**`lib/components/reminders/reminder_form.dart`** — new group field, required,
defaulting to the active group. **New** `lib/components/reminders/reminder_group_field.dart`.

**`lib/components/cards/reminder_card.dart`** — group name above the time, in the
secondary colour, uppercase caption style.

**`lib/screens/reminders_screen.dart`** — list stays flat and time-sorted. Empty state
with no groups: FAB disabled, message plus a "Choose a people group" button routing
to `/people-groups`.

**Tests** — `test/reminder_notification_ids_test.dart` (same group collapses, different
groups don't), update `test/reminders_screen_test.dart`.

---

## Phase 5 — Home carousel

**New** `lib/components/cards/people_group_carousel.dart` — horizontal `PageView` or
snapping `ListView`, cards in add order (oldest first), no active marker, but the
controller's `initialPage` is the active group's index.

**New** `lib/components/cards/add_people_group_card.dart` — trailing card routing to
`/people-groups`. Hidden at the cap.

**`lib/screens/home_screen.dart`** — `_peopleGroupCardOrCTA` becomes the carousel
(zero groups keeps the existing CTA). Tapping Pray on a card calls
`setActivePeopleGroup(slug)` then navigates. Share/QR already take the slug.

`RemindersSummary` is unchanged — still one card, still the next reminder across all
groups; its `nextReminder` line gains the group name.

**Tests** — `test/people_group_carousel_test.dart`: card count, add card hidden at 5,
initial page is the active group.

---

## Phase 6 — Pray tab

**New** `lib/components/prayer_content/people_group_avatar.dart` — image + name,
reusing the existing prayed-today pill from `people_group_card.dart` (extract
`_PrayedTodayPill` into `lib/components/misc/prayed_today_pill.dart` and have both use it).

**New** `lib/components/prayer_content/people_group_avatar_row.dart` — horizontal row
above the prayer content; tapping one calls `setActivePeopleGroup`. Hidden with fewer
than two groups.

**`lib/screens/pray_screen.dart`** — reads `activePeopleGroup` instead of the single
selection. Deep-link override still wins for the visit. `_NoSelectionView` gains a
"Choose a people group" button to `/people-groups`.

**`lib/components/prayer_content/prayer_thank_you_modal.dart`** — when an unprayed
subscribed group remains, add a "Pray for {name}" action above the Home button; it
sets that group active and stays on the Pray tab.

**`lib/services/cache_warmup.dart`** — prefetch today's content for **every**
subscribed group, issued sequentially rather than through `Future.wait`, so a poor
connection gets a trickle rather than a burst. `warmPeopleGroupCaches` takes a list of
slugs instead of one.

---

## Phase 7 — Strings, docs, verification

**Strings** — add to `lib/l10n/app_en.arb` (sorted, with the duplicated `@` metadata
this project uses), then propagate with `/sync-language` against the DOXA glossary.
Never hand-edit `lib/l10n/app_localizations*.dart`; run `flutter gen-l10n`.

Roughly: `addPeopleGroup`, `praying`, `atPeopleGroupLimit`, `swapPeopleGroupTitle`,
`swapPeopleGroupBody`, `removePeopleGroupTitle`, `removePeopleGroupBody`,
`removePeopleGroupWithReminders`, `choosePeopleGroup`, `noPeopleGroupsYet`,
`reminderForGroup`, `reminderGroupLabel`, `prayForNextGroup`,
`reminderNotificationBody` (gains a placeholder), `nextReminderForGroup`.

**Architecture docs** — `test/architecture_docs_test.dart` fails until
`tool/architecture/catalogue.dart` covers the two new prefs keys and the unsubscribe
endpoint. Then `dart run tool/gen_architecture.dart`.

**Verification** — `flutter test`, then on device with `--flavor staging` only:
upgrade path from a build with one group, add to 5, hit the cap, swap, remove to zero,
two groups reminding at the same minute, tapping each notification, and a
`/app/{slug}` link while at the cap.


---

## As built — where this differs from the plan

- **`GroupSchedule` instead of a tuple.** Phase 2 said `scheduleForGroup` would
  return `(hour, minute, weekdays)`. It returns a `GroupSchedule` that also owns
  `frequency`, `time` and `encodedWeekdays`, because both callers were otherwise
  re-deriving the same three server-shaped fields.

- **Per-group PUTs are diffed, not just debounced.** The plan called for a
  debounce; on its own that still sends five PUTs whenever any reminder changes.
  `profile_update_service.dart` keeps the last schedule signature it got the
  server to accept and sends only the groups whose signature actually changed —
  verified on device as exactly one PUT for one reminder edit. The listeners are
  installed after the initial load and seed themselves from it, so a cold start
  re-sends nothing.

- **A reminder can carry an empty slug.** Only from one migration case: a device
  that had reminders but no selected group when it upgraded. It shows unlabelled
  and falls back to the generic notification copy. Reminders created in-app
  always have a group.

- **`IntrinsicHeight` in the carousel.** `CrossAxisAlignment.stretch` against the
  home screen's unbounded height forces an infinite height and renders the whole
  page blank. `IntrinsicHeight` is what makes the stretch legal; the carousel
  test pumps inside a `SingleChildScrollView` so that context is reproduced.

- **Cancel is the trailing button in the remove modal.** `ButtonBarWrap` puts the
  *trailing* button on top once labels are long enough to stack, so the safe
  choice had to go in that slot.
