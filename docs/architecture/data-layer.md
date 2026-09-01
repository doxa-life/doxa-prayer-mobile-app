<!-- GENERATED FILE — do not edit by hand.
     Facts come from lib/ via tool/architecture/facts.dart.
     Narrative comes from tool/architecture/catalogue.dart.
     Regenerate with: dart run tool/gen_architecture.dart -->

# Data layer inventory

Every table here is scanned out of `lib/`. If something is missing from it, it is missing from the code.

## Endpoints

All requests are built through `ApiConfig.buildUri`, which resolves the host from `--dart-define`, then `.env`, then the build flavour.

| Method | Path | Cached | TTL | Bg refresh | Built in |
| --- | --- | --- | --- | --- | --- |
| GET | `/api/app/version` | — | — | — | `version_check_service.dart:39` |
| POST | `/api/collect/app` | — | — | — | `analytics_service.dart:84` |
| POST | `/api/feedback` | — | — | — | `feedback_service.dart:64` |
| POST | `/api/news-signup` | — | — | — | `news_signup_service.dart:25` |
| GET | `/api/people-groups/detail/{slug}` | yes | 7 days (`peopleGroupDetail`) | 1 hour (`peopleGroupCounts`) | `people_groups_service.dart:67` |
| GET | `/api/people-groups/list` | yes | 7 days (`peopleGroupList`) | 1 hour (`peopleGroupCounts`) | `people_groups_service.dart:43` |
| GET | `/api/people-groups/statistics` | — | — | — | `prayer_stats_service.dart:20` |
| POST | `/api/people-groups/{slug}/anon-signup` | — | — | — | `anon_signup_service.dart:38` |
| GET | `/api/people-groups/{slug}/prayer-content/{date}` | yes | 30 days (`prayerContent`) | — | `prayer_content_service.dart:43` |
| POST | `/api/people-groups/{slug}/prayer-content/{date}/session` | — | — | — | `prayer_content_service.dart:91` |
| GET | `/api/profile/{profileId}` | — | — | — | `profile_service.dart:44`<br>`profile_service.dart:63` |
| PUT | `/api/profile/{profileId}` | — | — | — | `profile_update_service.dart:38` |
| POST | `/api/profile/{profileId}/resend-verification` | — | — | — | `profile_service.dart:83` |
| POST | `/api/push/register` | — | — | — | `push_notifications_service.dart:164` |
| LINK | `/app/{slug}` | — | — | — | `home_screen.dart:101` |
| LINK | `/subscriber` | — | — | — | `profile_service.dart:127` |

`LINK` rows are URIs built for sharing or opening in a browser — they are never requested by the app.

## Which action touches which endpoint

The reverse index: change an endpoint, and these are the actions to retest.

| Endpoint | Actions |
| --- | --- |
| `GET /api/app/version` | Cold start |
| `POST /api/collect/app` | Cold start; Change language |
| `POST /api/feedback` | Send feedback |
| `POST /api/news-signup` | News step → Sign up; Settings → Sign up for updates → Sign up |
| `GET /api/people-groups/detail/{slug}` | Welcome → Start; Open an /app/<slug> share link |
| `GET /api/people-groups/list` | Open the Browse tab |
| `GET /api/people-groups/statistics` | Open the Pray tab |
| `POST /api/people-groups/{slug}/anon-signup` | News step → Sign up; News step → Skip; Group details → pray for this group |
| `GET /api/people-groups/{slug}/prayer-content/{date}` | Cold start; Open the Pray tab; Open a /<slug>/prayer link |
| `POST /api/people-groups/{slug}/prayer-content/{date}/session` | Open the Pray tab; Tap Amen; Leave the Pray tab without tapping Amen |
| `GET /api/profile/{profileId}` | Settings → view signed-up emails; Send feedback |
| `PUT /api/profile/{profileId}` | Group details → pray for this group; Add or edit a reminder |
| `POST /api/profile/{profileId}/resend-verification` | Settings → Resend verification email |
| `POST /api/push/register` | News step → Sign up; Add or edit a reminder; Settings → Sign up for updates → Sign up; Enable notifications (prompt or settings row) |

## Cache policy

Every entry is a *soft* expiry: past it the app refetches, but a failed refetch still falls back to the expired copy, so an offline user keeps seeing what they last loaded.

| Field | Duration | Covers |
| --- | --- | --- |
| `images` | 30 days | People-group photos, held on disk by `image_cache_manager.dart`. |
| `prayerContent` | 30 days | A single day's prayer content for one people group and language. Keyed by date, so each day is cached separately and past days never change. |
| `peopleGroupList` | 7 days | The UUPG (unreached people group) browse list. |
| `peopleGroupDetail` | 7 days | One people group's detail page. |
| `peopleGroupCounts` | 1 hour | How long a people-group payload may go without a background refresh.  The list and detail responses carry the people-praying and people-committed counts, which move as others pray and shouldn't sit frozen for the whole 7 days. Past this the cached copy is still shown immediately — the refresh happens behind it and the counts update in place, so the user never waits for it. |
| `maxResponseAge` | prayerContent | The longest of the response TTLs — how far back the startup sweep in `response_cache.dart` keeps files before deleting them. |

## Cache keys

| Endpoint | Key expression |
| --- | --- |
| `GET /api/people-groups/detail/{slug}` | `peopleGroupDetailCacheKey(slug, lang)` |
| `GET /api/people-groups/list` | `peopleGroupListCacheKey(lang)` |
| `GET /api/people-groups/{slug}/prayer-content/{date}` | `prayerContentCacheKey(slug: slug, date: date, language: language)` |

Language is part of every content cache key, which is why switching language invalidates the content caches in effect.

## Persisted keys (SharedPreferences)

| Key | Constant | Declared in | Written by |
| --- | --- | --- | --- |
| `app_locale_language_code` | `_storageKey` | [locale_controller.dart:25](../../lib/services/locale_controller.dart#L25) | Change language |
| `identity_profile_id` | `_profileIdKey` | [identity_service.dart:17](../../lib/services/identity_service.dart#L17) | News step → Sign up; News step → Skip; Settings → Sign up for updates → Sign up |
| `identity_subscription_id` | `_subscriptionIdKey` | [identity_service.dart:18](../../lib/services/identity_service.dart#L18) | News step → Sign up; News step → Skip; Group details → pray for this group |
| `identity_tracking_id` | `_trackingIdKey` | [identity_service.dart:16](../../lib/services/identity_service.dart#L16) | News step → Sign up; News step → Skip; Settings → Sign up for updates → Sign up |
| `install_referrer_checked` | `_checkedFlagKey` | [install_referrer_service.dart:14](../../lib/services/install_referrer_service.dart#L14) | Cold start |
| `prayer_history` | `_historyKey` | [prayer_history_service.dart:7](../../lib/services/prayer_history_service.dart#L7) | Tap Amen; Leave the Pray tab without tapping Amen |
| `referred_people_group_slug` | `_referredSlugKey` | [referral_controller.dart:15](../../lib/services/referral_controller.dart#L15) | Cold start; Welcome → Start; Open an /app/<slug> share link |
| `reminders` | `_storageKey` | [reminders_controller.dart:8](../../lib/services/reminders_controller.dart#L8) | Reminder step → Save; Add or edit a reminder |
| `selected_people_group_image_url` | `_imageUrlKey` | [selected_people_group_controller.dart:18](../../lib/services/selected_people_group_controller.dart#L18) | Confirm a people group; Group details → pray for this group |
| `selected_people_group_name` | `_nameKey` | [selected_people_group_controller.dart:17](../../lib/services/selected_people_group_controller.dart#L17) | Confirm a people group; Group details → pray for this group |
| `selected_people_group_slug` | `_slugKey` | [selected_people_group_controller.dart:16](../../lib/services/selected_people_group_controller.dart#L16) | Confirm a people group; Group details → pray for this group |
| `thank_you_verse_index` | `_indexKey` | [thank_you_verse_service.dart:8](../../lib/services/thank_you_verse_service.dart#L8) | Tap Amen |
| `update_dismissed_version` | `_dismissedVersionKey` | [update_controller.dart:13](../../lib/services/update_controller.dart#L13) | Dismiss the optional update banner |
| `update_snooze_until` | `_snoozeUntilKey` | [update_controller.dart:14](../../lib/services/update_controller.dart#L14) | Dismiss the optional update banner |
| `wizard_completed` | `_storageKey` | [wizard_completion_controller.dart:4](../../lib/services/wizard_completion_controller.dart#L4) | News step → Finish; News step → Skip |

Cached API responses are not in SharedPreferences — they are files under the response cache directory, swept at launch past `CachePolicy.maxResponseAge`.

## Routes

| Name | Path |
| --- | --- |
| `home` | `/home` |
| `pray` | `/pray` |
| `peopleGroups` | `/people-groups` |
| `reminders` | `/reminders` |
| `app-deep-link` | `/app/:slug` |
| `pray-deep-link` | `/:slug/prayer` |
| `pray-deep-link-dated` | `/:slug/prayer/:date` |
| `people-group-details` | `/people-groups/:slug` |
| `settings` | `/settings` |
| `settings-news-signup` | `/settings/news-signup` |
| `settings-notifications` | `/settings/notifications` |
| `feedback` | `/feedback` |
| `gallery` | `/gallery` |
| `debug` | `/debug` |
| `wizard` | `/wizard` |
