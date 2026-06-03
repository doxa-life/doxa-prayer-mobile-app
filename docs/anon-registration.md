# Anonymous mobile registration

This app doesn't require a user to login.
So we need to manage things as an anonymous user.

Below are some of the changes needed in the mobile app in order to facilitate this.

The endpoints that are going to be used are found at
- https://pray.doxa.life/_scalar#tag/signups/POST/api/people-groups/{slug}/anon-signup
POST /api/people-groups/%7Bslug%7D/anon-signup HTTP/1.1
Host: pray.doxa.life
Content-Type: application/json
x-app-secret: YOUR_SECRET_TOKEN

{"tracking_id":"","frequency":"daily","time":"08:00","days_of_week":[1,3,5],"timezone":"Europe/London","language":"en","email":"","name":"","consent_doxa_general":true,"consent_people_group_updates":true}

with 200 response like
{
  "type": "object",
  "properties": {
    "tracking_id": {
      "type": "string",
      "format": "uuid"
    },
    "profile_id": {
      "type": "string",
      "format": "uuid"
    },
    "subscription_id": {
      "type": "integer"
    }
  }
}

- https://pray.doxa.life/_scalar#tag/signups/POST/api/news-signup
POST /api/news-signup HTTP/1.1
Host: pray.doxa.life
Content-Type: application/json
x-app-secret: YOUR_SECRET_TOKEN

{"email":"jane@example.com","name":"Jane Doe","consent_doxa_general":true,"consent_people_group_updates":true,"people_group_slug":"","country":"GB","language":"en","tracking_id":""}

with 200 response like

{
  "type": "object",
  "properties": {
    "success": {
      "type": "boolean",
      "example": true
    },
    "tracking_id": {
      "type": "string",
      "format": "uuid"
    },
    "profile_id": {
      "type": "string",
      "format": "uuid"
    }
  }
}

and then when a user prays they will record their prayer with
- https://pray.doxa.life/_scalar#tag/prayer/POST/api/people-groups/{slug}/prayer-content/{date}/session
POST /api/people-groups/%7Bslug%7D/prayer-content/2026-01-12/session HTTP/1.1
Host: pray.doxa.life
Content-Type: application/json

{"sessionId":"","trackingId":"","duration":1,"timestamp":""}

with response like
{
  "type": "object",
  "properties": {
    "success": {
      "type": "boolean"
    },
    "message": {
      "type": "string"
    }
  }
}

When they hit the pray page create the SessionId with something like
sessionId = ref(${Date.now()}-${Math.random().toString(36).substring(2, 9)})
When the user hits the 'Amen' button or otherwise navigates away from the pray page (already stubbed in the app), then record the prayer using the API request above and using this sessionId


## Mobile (`../doxa-prayer-mobile-app`)

- **M1** `lib/services/identity_service.dart` (new): persist/read `tracking_id` + `profile_id` in `SharedPreferences`; always overwrite from endpoint responses.
- **M2** `lib/services/api_config.dart` (new): central host (`pray.doxa.life`) + `X-App-Secret` header from `--dart-define=ANON_SIGNUP_SECRET=…`.
- **M3** `lib/services/anon_signup_service.dart` (new): `POST …/[slug]/anon-signup`. Map reminder → `time="HH:MM"`; `frequency = weekdays.length==7 ? 'daily' : 'weekly'`; `days_of_week = weekday % 7` (Flutter Mon=1..Sun=7 → backend Sun=0..Sat=6); IANA `timezone`. Store returned ids via M1.
- **M4** `lib/services/wizard_controller.dart` + people-group steps: thread selected PG slug; call M3 at Finish (timing is the mobile dev's call).
- **M5** `lib/services/news_signup_service.dart`: replace stub with a single `POST /api/news-signup` (`name`, `email`, `consent_doxa_general`, `consent_people_group_updates`, `people_group_slug?`, `tracking_id?`). Store returned ids.
- **M6** (recommended, deferrable) `lib/screens/pray_screen.dart`: use the persisted `tracking_id` for prayer-session reports so `people_praying` attributes to the subscriber.

