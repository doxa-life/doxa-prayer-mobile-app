/// The semantic layer of the architecture docs: what each button *means*, and
/// what happens in the background when it is tapped.
///
/// This is the one hand-written file in the pipeline, because "tapping Sign up
/// makes the server hand back an existing subscriber instead of minting an
/// anonymous one" is not recoverable from source by any amount of parsing. What
/// *is* checked is every fact it leans on: each [Anchor] must still resolve to a
/// real symbol, each `endpoint` must still exist in `lib/`, and each `writes`
/// key must still be a live SharedPreferences key. Rename
/// `submitAnonSignup` and `dart run tool/gen_architecture.dart --check` fails,
/// which is what keeps this file honest.
library;

import 'facts.dart';

/// Provenance for the server-side facts in this catalogue. Everything cited
/// from `lib/` is validated on every generation; the campaigns server is a
/// separate repo, so its behaviour is recorded here by hand with the commit it
/// was read at. Re-check it when that repo moves.
const serverVerification = ServerVerification(
  repo: 'doxa-campaigns-server',
  commit: '63eee8e',
  branch: 'master',
  readOn: '2026-08-28',
  files: [
    'server/api/people-groups/[slug]/anon-signup.post.ts',
    'server/api/news-signup.post.ts',
    'server/database/subscribers.ts',
    'server/utils/email-consents.ts',
  ],
);

class ServerVerification {
  const ServerVerification({
    required this.repo,
    required this.commit,
    required this.branch,
    required this.readOn,
    required this.files,
  });

  final String repo;
  final String commit;
  final String branch;
  final String readOn;
  final List<String> files;
}

/// Who is doing something, in the sequence diagrams. Deliberately coarse: these
/// are the boxes a person reasons about, not classes.
enum Actor {
  user('User', 'U'),
  ui('App UI', 'UI'),
  local('On device', 'L'),
  os('OS', 'OS'),
  oneSignal('OneSignal', 'OS1'),
  server('Campaigns server', 'S');

  const Actor(this.label, this.alias);

  final String label;
  final String alias;
}

/// One hop in an action's background chain.
class Step {
  const Step({
    required this.from,
    required this.to,
    required this.text,
    this.anchor,
    this.endpoint,
    this.writes,
    this.when,
    this.server,
    this.background = false,
  });

  final Actor from;
  final Actor to;

  /// What happens, in plain language.
  final String text;

  /// Where in `lib/` this hop lives. Validated.
  final Anchor? anchor;

  /// `METHOD /path` — must match a real endpoint. Validated.
  final String? endpoint;

  /// SharedPreferences keys written by this hop. Validated.
  final List<String>? writes;

  /// When set, the hop is conditional and this is the condition.
  final String? when;

  /// What the campaigns server does with this request. **Not machine-checked**
  /// — it lives in another repo, so see [serverVerification] for the commit
  /// these were read against.
  final String? server;

  /// True when the user has no way of knowing this happened. These are the hops
  /// worth documenting; they're marked in the rendered diagrams.
  final bool background;
}

/// A thing a person can do, and everything it sets off.
class UserAction {
  const UserAction({
    required this.id,
    required this.surface,
    required this.title,
    required this.trigger,
    required this.visible,
    required this.background,
    required this.steps,
    this.notes = const <String>[],
  });

  final String id;

  /// Id of the [Surface] this belongs to.
  final String surface;
  final String title;

  /// The widget/handler the tap enters. Validated.
  final Anchor trigger;

  /// What the user sees happen.
  final String visible;

  /// What they don't. The reason this catalogue exists.
  final String background;

  final List<Step> steps;

  /// Sharp edges: asymmetries, ordering that matters, things that silently
  /// don't happen.
  final List<String> notes;
}

/// A place in the app that actions are grouped under.
class Surface {
  const Surface({required this.id, required this.title, required this.blurb});

  final String id;
  final String title;
  final String blurb;
}

const surfaces = <Surface>[
  Surface(
    id: 'launch',
    title: 'Launch and background work',
    blurb:
        'Nothing here is a button, but it sets the state every other action '
        'depends on — most importantly whether an identity exists yet.',
  ),
  Surface(
    id: 'wizard',
    title: 'Onboarding wizard',
    blurb:
        'The only place a prayer subscription is created, and the only place an '
        'email reaches `anon-signup`. Every step can be skipped, and skipping '
        'group selection simply defers that signup until the user picks a '
        'group later.',
  ),
  Surface(
    id: 'pray',
    title: 'Pray tab',
    blurb:
        'Reads are cached per group/date/language. Writes are fire-and-forget '
        'and happen on leaving the screen as well as on Amen.',
  ),
  Surface(
    id: 'browse',
    title: 'Browse tab and group details',
    blurb:
        'Long TTLs with a short background refresh, so counts move without the '
        'user ever waiting. Switching group here has server side effects.',
  ),
  Surface(
    id: 'reminders',
    title: 'Reminders tab',
    blurb:
        'Local notifications only — but this is also the single place the OS '
        'notification permission is ever requested, which is what makes push '
        'work.',
  ),
  Surface(
    id: 'settings',
    title: 'Settings',
    blurb:
        'The news-signup here looks like the wizard step but identifies the '
        'user differently — by tracking_id rather than by email — and leaves '
        'their prayer subscription alone.',
  ),
  Surface(
    id: 'update',
    title: 'Update gate',
    blurb:
        'Wraps every screen. Its state comes from the launch version check, and '
        'dismissing it writes two separate suppression keys.',
  ),
  Surface(
    id: 'links',
    title: 'Deep links and push taps',
    blurb: 'Entry points that bypass the normal tab navigation.',
  ),
];

// ---------------------------------------------------------------------------
// Identity model, documented once and referenced by the actions below.
// ---------------------------------------------------------------------------

/// The three-field identity every server call is hung off. Rendered as a state
/// machine in `identity.md`.
const identityFields = <String, String>{
  'trackingId':
      'Minted **by the server** on the first `anon-signup`, then persisted. The '
      'app never generates one — it posts an empty string and adopts what comes '
      'back. Every other call sends it.',
  'profileId':
      'The campaigns-server subscriber. Returned by `anon-signup` *and* by '
      '`news-signup`. Its presence is what unlocks profile sync and switches '
      'the OneSignal external id.',
  'subscriptionId':
      'The prayer subscription for one people group. Set only from an '
      '`anon-signup` response. `news-signup` does not return one and does not '
      'need to: the server leaves an existing prayer subscription alone, so a '
      'later news-signup neither creates nor disturbs it.',
};

const identityStates = <String, String>{
  'none':
      'No identity **held by the app**. Fresh install, and also where a user '
      'who skipped group selection in the wizard sits, since `anon-signup` '
      'needs a slug. An expected state, not a broken one — picking a group '
      'anywhere in the app resolves it. Until then push has no external id to '
      'register against.',
  'profiled':
      'trackingId + profileId, no subscription. Reached by a user with no prior '
      'anon-signup who signs up through settings. They are signed up for email '
      'and not praying for a group yet.',
  'subscribed':
      'All three. Where nearly everyone lands: selecting a group in the wizard '
      'always posts an `anon-signup`, whether they then sign up for news or '
      'skip it.',
};

/// Edges of the identity state machine. Kept beside the states so the diagram
/// and the prose cannot disagree.
const identityTransitions = <List<String>>[
  ['none', 'subscribed', 'finish the wizard with a group selected'],
  ['none', 'none', 'finish the wizard having skipped group selection'],
  ['none', 'profiled', 'settings news-signup with no prior anon-signup'],
  ['profiled', 'subscribed', 'select a people group (deferred anon-signup)'],
  [
    'subscribed',
    'subscribed',
    'settings news-signup — name/email updated in place, subscription kept',
  ],
  ['subscribed', 'subscribed', 'reminder or group change (profile PUT)'],
];

/// Stated so a reader does not go looking for a state that cannot happen.
const identityStateCaveat =
    'These are the states of the identity the **app** holds, which is what '
    'gates push registration and profile sync. They are not a claim about what '
    'rows exist server-side: analytics events and prayer sessions are posted '
    'with an empty identifier and their responses are never read, so the server '
    'may well hold an anonymous record the app knows nothing about. Note too '
    'that there is no state with a `trackingId` but no `profileId` — '
    '`anon-signup` returns both together.';

/// Wizard news step vs settings news-signup. Narrative, so it lives here rather
/// than in the renderer.
const signupComparison = <String, List<String>>{
  'Requests': [
    '`POST /api/people-groups/{slug}/anon-signup` **then** '
        '`POST /api/news-signup`',
    '`POST /api/news-signup` only',
  ],
  'Email reaches anon-signup': ['Yes — this is the mechanism', 'No'],
  'How the server finds the person': [
    'By the **email** in the anon-signup body, so an existing account is '
        'matched rather than a new anonymous one created',
    'By the **tracking_id**, so it updates the anon user already on the device',
  ],
  'Effect on name and email': [
    'Set as part of creating or matching the subscriber',
    'Updated in place on the existing anon user',
  ],
  'Effect on the prayer subscription': [
    'Created for the selected group',
    '**Left in place, untouched** — it is neither created nor moved here',
  ],
  '`profileId` after': ['Set', 'Set'],
  '`subscriptionId` after': [
    'Set from the response',
    'Unchanged — already set for anyone who selected a group in the wizard',
  ],
  'Leaves someone without a prayer subscription': [
    'No — it creates one',
    'Only for a user who has not chosen a group yet, which choosing one fixes',
  ],
};

const actions = <UserAction>[
  // -------------------------------------------------------------------------
  // Launch
  // -------------------------------------------------------------------------
  UserAction(
    id: 'cold-start',
    surface: 'launch',
    title: 'Cold start',
    trigger: Anchor('lib/main.dart', 'main'),
    visible: 'Splash, then either the wizard or the home tab.',
    background:
        'Seven persisted values are loaded in parallel, then push is '
        'initialised, three listeners are installed that will later fire '
        'network calls on their own, the caches are warmed and pruned, an '
        'update check runs and an app_open event is posted.',
    steps: [
      Step(
        from: Actor.ui,
        to: Actor.local,
        text:
            'Load selected group, prayed-today, reminders, wizard flag, locale, '
            'identity and referred slug — in parallel',
        anchor: Anchor('lib/main.dart', 'loadIdentity'),
      ),
      Step(
        from: Actor.ui,
        to: Actor.oneSignal,
        text:
            'Initialise the SDK. Deliberately no permission prompt here, so a '
            'fresh install has no push token yet',
        anchor: Anchor(
          'lib/services/push_notifications_service.dart',
          'initPushNotifications',
        ),
        background: true,
      ),
      Step(
        from: Actor.ui,
        to: Actor.ui,
        text:
            'Install the deferred anon-signup listener — it watches the selected '
            'group and can POST a signup with no user action at all',
        anchor: Anchor(
          'lib/services/anon_signup_service.dart',
          'installDeferredAnonSignupListener',
        ),
        background: true,
      ),
      Step(
        from: Actor.ui,
        to: Actor.ui,
        text:
            'Install the profile-sync listeners on reminders and selected group',
        anchor: Anchor(
          'lib/services/profile_update_service.dart',
          'installProfileUpdateListeners',
        ),
        background: true,
      ),
      Step(
        from: Actor.ui,
        to: Actor.server,
        text:
            'Warm the group caches from disk; prefetch today\'s prayer content',
        anchor: Anchor('lib/services/cache_warmup.dart', 'warmCachesOnLaunch'),
        endpoint: 'GET /api/people-groups/{slug}/prayer-content/{date}',
        when: 'a group is already selected',
        background: true,
      ),
      Step(
        from: Actor.ui,
        to: Actor.server,
        text: 'Version check, feeding the update gate',
        anchor: Anchor(
          'lib/services/update_controller.dart',
          'checkForAppUpdate',
        ),
        endpoint: 'GET /api/app/version',
        background: true,
      ),
      Step(
        from: Actor.ui,
        to: Actor.server,
        text: 'Post an app_open analytics event',
        anchor: Anchor('lib/services/analytics_service.dart', 'trackAppOpen'),
        endpoint: 'POST /api/collect/app',
        background: true,
      ),
      Step(
        from: Actor.ui,
        to: Actor.server,
        text: 'Android only: Play install-referrer lookup for a referred group',
        anchor: Anchor(
          'lib/services/install_referrer_service.dart',
          'fetchInstallReferrer',
        ),
        writes: ['install_referrer_checked', 'referred_people_group_slug'],
        background: true,
      ),
    ],
    notes: [
      'Push init is ordered **after** `loadIdentity()` on purpose, so the first '
          '`OneSignal.login()` uses the right external id.',
      'The install-referrer lookup is fire-and-forget but the welcome CTA awaits '
          'it (bounded to 5s), so a fast tapper cannot race it.',
      'Foreground resumes post a second `app_open` from `app_shell.dart`, so the '
          'event counts sessions, not launches.',
    ],
  ),

  // -------------------------------------------------------------------------
  // Wizard
  // -------------------------------------------------------------------------
  UserAction(
    id: 'wizard-welcome-start',
    surface: 'wizard',
    title: 'Welcome → Start',
    trigger: Anchor('lib/services/wizard_controller.dart', 'startFromWelcome'),
    visible:
        'A spinner on the CTA, then either the people-group list or the confirm '
        'step with a group already filled in.',
    background:
        'Waits up to 5 seconds on the Play install-referrer lookup. If an '
        'install referrer or deep link supplied a slug, that group is fetched '
        'and the list step is skipped entirely.',
    steps: [
      Step(
        from: Actor.ui,
        to: Actor.server,
        text: 'Await the in-flight install-referrer lookup, capped at 5s',
        anchor: Anchor(
          'lib/services/install_referrer_service.dart',
          'fetchInstallReferrer',
        ),
        background: true,
      ),
      Step(
        from: Actor.ui,
        to: Actor.server,
        text: 'Resolve the referred slug to a real group',
        anchor: Anchor(
          'lib/services/people_groups_service.dart',
          'fetchPeopleGroupDetail',
        ),
        endpoint: 'GET /api/people-groups/detail/{slug}',
        when: 'a referred slug is present',
      ),
      Step(
        from: Actor.ui,
        to: Actor.local,
        text:
            'Consume the referral so re-entering the wizard cannot re-trigger it',
        anchor: Anchor(
          'lib/services/referral_controller.dart',
          'clearReferredPeopleGroup',
        ),
        writes: ['referred_people_group_slug'],
        background: true,
      ),
    ],
    notes: [
      'A referral arriving *mid-wizard* is handled by a listener instead, and '
          'only while the user is still on the list or confirm step — later steps '
          'are left alone so the user is not yanked backwards.',
    ],
  ),

  UserAction(
    id: 'wizard-confirm-group',
    surface: 'wizard',
    title: 'Confirm a people group',
    trigger: Anchor(
      'lib/components/wizard/wizard_step_people_group_confirm.dart',
      'setSelectedPeopleGroup',
    ),
    visible: 'The wizard advances to the reminder step.',
    background:
        'Three prefs keys are written and two listeners fire — but both '
        'no-op at this point, because the wizard is not complete and there is '
        'no profile yet. The same tap after onboarding does hit the network.',
    steps: [
      Step(
        from: Actor.ui,
        to: Actor.local,
        text: 'Persist slug, name and image url',
        anchor: Anchor(
          'lib/services/selected_people_group_controller.dart',
          'setSelectedPeopleGroup',
        ),
        writes: [
          'selected_people_group_slug',
          'selected_people_group_name',
          'selected_people_group_image_url',
        ],
      ),
      Step(
        from: Actor.ui,
        to: Actor.ui,
        text:
            'Deferred anon-signup listener wakes and bails: the wizard is not '
            'complete yet',
        anchor: Anchor(
          'lib/services/anon_signup_service.dart',
          '_maybeFireDeferredSignup',
        ),
        background: true,
      ),
      Step(
        from: Actor.ui,
        to: Actor.ui,
        text: 'Profile-sync listener wakes and bails: no profileId yet',
        anchor: Anchor(
          'lib/services/profile_update_service.dart',
          '_onSyncTrigger',
        ),
        background: true,
      ),
    ],
  ),

  UserAction(
    id: 'wizard-skip-group',
    surface: 'wizard',
    title: 'People-groups step → Skip',
    trigger: Anchor(
      'lib/components/wizard/wizard_step_people_groups.dart',
      'skipPeopleGroup',
    ),
    visible: 'The wizard moves on to the reminder step.',
    background:
        'Nothing is persisted and nothing is posted — and because '
        '`anon-signup` needs a slug, this user finishes onboarding with **no '
        'identity at all**. No tracking id, no profile, no prayer '
        'subscription, and push cannot register.',
    steps: [
      Step(
        from: Actor.ui,
        to: Actor.ui,
        text: 'Clear any candidate group and advance; nothing is written',
        anchor: Anchor(
          'lib/services/wizard_controller.dart',
          'skipPeopleGroup',
        ),
      ),
      Step(
        from: Actor.ui,
        to: Actor.ui,
        text:
            'At the end of the wizard the anon-signup is skipped entirely, '
            'because there is no slug to sign up for',
        anchor: Anchor(
          'lib/services/wizard_controller.dart',
          '_submitPeopleGroupSignup',
        ),
        background: true,
      ),
    ],
    notes: [
      'This is the only route to finishing onboarding with no identity, and it '
          'is the reason the settings news-signup can leave someone without a '
          'prayer subscription.',
      'They recover the moment they select a group anywhere in the app: the '
          'deferred anon-signup listener fires and posts the signup for them.',
    ],
  ),

  UserAction(
    id: 'wizard-save-reminder',
    surface: 'wizard',
    title: 'Reminder step → Save',
    trigger: Anchor('lib/components/wizard/wizard_step_reminder.dart', '_save'),
    visible:
        'The OS notification dialog, then the wizard advances to the news step.',
    background:
        'This is where push notifications are really enabled. Granting the '
        'permission nudges OneSignal to mint a token — with no second dialog — '
        'and that token would be registered with the server, except identity '
        'does not exist yet, so registration is skipped and only lands after '
        'the next step.',
    steps: [
      Step(
        from: Actor.ui,
        to: Actor.os,
        text: 'Request the shared notification permission',
        anchor: Anchor(
          'lib/services/reminders_notifications.dart',
          'ensureNotificationPermission',
        ),
      ),
      Step(
        from: Actor.ui,
        to: Actor.oneSignal,
        text:
            'Nudge OneSignal to register its APNs/FCM token. Shows NO dialog, '
            'because permission was just granted',
        anchor: Anchor(
          'lib/services/reminders_notifications.dart',
          '_nudgeOneSignalRegister',
        ),
        when: 'permission was granted',
        background: true,
      ),
      Step(
        from: Actor.oneSignal,
        to: Actor.ui,
        text: 'Push subscription observer fires with the new subscription id',
        anchor: Anchor(
          'lib/services/push_notifications_service.dart',
          'initPushNotifications',
        ),
        background: true,
      ),
      Step(
        from: Actor.ui,
        to: Actor.ui,
        text:
            'Server registration is **skipped** — identity is still null this '
            'early in onboarding',
        anchor: Anchor(
          'lib/services/push_notifications_service.dart',
          '_registerPushWithServer',
        ),
        background: true,
      ),
      Step(
        from: Actor.ui,
        to: Actor.local,
        text: 'Persist the reminder and schedule it locally',
        anchor: Anchor('lib/services/reminders_controller.dart', 'addReminder'),
        writes: ['reminders'],
      ),
    ],
    notes: [
      'The OS notification permission is shared between '
          '`flutter_local_notifications` and OneSignal. The reminders flow owns it; '
          'the coupling to OneSignal is one-directional and intentional.',
      'A user who never touches reminders and never signs up therefore never '
          'becomes addressable by push, even though the SDK is initialised.',
    ],
  ),

  UserAction(
    id: 'wizard-news-signup',
    surface: 'wizard',
    title: 'News step → Sign up',
    trigger: Anchor('lib/services/wizard_controller.dart', 'signUp'),
    visible:
        'A "check your email" confirmation, plus an enable-notifications offer.',
    background:
        'Two POSTs, in a load-bearing order. The anon-signup goes **first and '
        'carries the email the user just typed**, so the server resolves an '
        'existing subscriber by that address instead of minting an anonymous '
        'one. The news-signup then runs with the same tracking id. Gaining a '
        'profileId also re-points the OneSignal external id and finally '
        'registers the push token.',
    steps: [
      Step(
        from: Actor.ui,
        to: Actor.server,
        text:
            'anon-signup **with email, name and consents** — plus reminder '
            'schedule and timezone',
        anchor: Anchor(
          'lib/services/anon_signup_service.dart',
          'submitAnonSignup',
        ),
        endpoint: 'POST /api/people-groups/{slug}/anon-signup',
        server:
            'Because an email is present, the handler resolves the subscriber '
            'with `findOrCreateForNews` — literally the same resolver '
            '`/api/news-signup` uses — so an existing web subscriber with that '
            'address is matched instead of a new anonymous one being created. '
            'It then upserts the single `delivery_method = \'app\'` '
            'subscription for (subscriber, people group).',
      ),
      Step(
        from: Actor.server,
        to: Actor.local,
        text:
            'Returns tracking_id, profile_id and subscription_id — the matched '
            'account, not a new anonymous one',
        anchor: Anchor('lib/services/identity_service.dart', 'setIdentity'),
        writes: [
          'identity_tracking_id',
          'identity_profile_id',
          'identity_subscription_id',
        ],
        background: true,
      ),
      Step(
        from: Actor.ui,
        to: Actor.server,
        text: 'news-signup, carrying the tracking id just adopted',
        anchor: Anchor(
          'lib/services/news_signup_service.dart',
          'submitNewsSignup',
        ),
        endpoint: 'POST /api/news-signup',
      ),
      Step(
        from: Actor.ui,
        to: Actor.oneSignal,
        text:
            'Identity changed → external id switches from tracking_id to '
            'profile_id; both are also set as tags',
        anchor: Anchor(
          'lib/services/push_notifications_service.dart',
          '_syncExternalId',
        ),
        background: true,
      ),
      Step(
        from: Actor.ui,
        to: Actor.server,
        text:
            'Register the push subscription — the call that was skipped at the '
            'reminder step now succeeds',
        anchor: Anchor(
          'lib/services/push_notifications_service.dart',
          '_registerPushWithServer',
        ),
        endpoint: 'POST /api/push/register',
        when: 'a push token exists',
        background: true,
      ),
    ],
    notes: [
      'Order is the whole mechanism: `_submitPeopleGroupSignup` runs before '
          '`submitNewsSignup`. Swapping them would change which record the server '
          'treats as canonical.',
      'The anon-signup is best-effort — its failure is logged and swallowed so '
          'onboarding is never blocked. A news-signup failure **is** rethrown so the '
          'step can offer a retry. So it is possible to end up with an email signup '
          'and no prayer subscription.',
      'Signing up does not complete the wizard. The user still has to tap Finish.',
    ],
  ),

  UserAction(
    id: 'wizard-news-finish',
    surface: 'wizard',
    title: 'News step → Finish',
    trigger: Anchor(
      'lib/components/wizard/wizard_step_news_signup.dart',
      '_finish',
    ),
    visible: 'Onboarding ends and the home tab appears.',
    background:
        'Only marks onboarding complete. All the server work already happened '
        'when Sign up was tapped — but marking completion is what arms the '
        'deferred anon-signup listener for every later group change.',
    steps: [
      Step(
        from: Actor.ui,
        to: Actor.local,
        text: 'Mark onboarding complete, which redirects the router to /home',
        anchor: Anchor(
          'lib/services/wizard_completion_controller.dart',
          'markWizardCompleted',
        ),
        writes: ['wizard_completed'],
      ),
      Step(
        from: Actor.ui,
        to: Actor.ui,
        text:
            'From now on the deferred anon-signup listener will act on a group '
            'change instead of bailing',
        anchor: Anchor(
          'lib/services/anon_signup_service.dart',
          '_maybeFireDeferredSignup',
        ),
        background: true,
      ),
    ],
    notes: [
      'A user who taps Sign up and then kills the app without tapping Finish '
          'keeps their signup but stays in the wizard on next launch, because the '
          'router redirects on the `wizard_completed` flag alone.',
    ],
  ),

  UserAction(
    id: 'wizard-news-skip',
    surface: 'wizard',
    title: 'News step → Skip',
    trigger: Anchor('lib/services/wizard_controller.dart', 'skip'),
    visible: 'Straight to the home tab.',
    background:
        'Still posts an anon-signup — with empty email and no consents — so the '
        'user gets a prayer subscription and a server-minted tracking id. No '
        'email is sent and no newsletter consent is recorded.',
    steps: [
      Step(
        from: Actor.ui,
        to: Actor.server,
        text: 'anon-signup with empty email/name and both consents false',
        anchor: Anchor(
          'lib/services/anon_signup_service.dart',
          'submitAnonSignup',
        ),
        endpoint: 'POST /api/people-groups/{slug}/anon-signup',
        server:
            'With no email the handler takes `findOrCreateByTrackingId`. The '
            'app sends an empty tracking_id, which fails the UUID test, so it '
            'falls through to creating a fresh subscriber named `Anonymous` '
            'with newly minted tracking_id and profile_id — then the app '
            'subscription for the group.',
        background: true,
      ),
      Step(
        from: Actor.server,
        to: Actor.local,
        text: 'Adopt the returned identity',
        anchor: Anchor('lib/services/identity_service.dart', 'setIdentity'),
        writes: [
          'identity_tracking_id',
          'identity_profile_id',
          'identity_subscription_id',
        ],
        background: true,
      ),
      Step(
        from: Actor.ui,
        to: Actor.local,
        text: 'Mark onboarding complete, which redirects the router to /home',
        anchor: Anchor(
          'lib/services/wizard_completion_controller.dart',
          'markWizardCompleted',
        ),
        writes: ['wizard_completed'],
      ),
    ],
    notes: [
      'Skipping is not "no server contact" — it is a full anonymous signup. The '
          'only difference from the Sign up path is the absent email and the absent '
          '`news-signup` POST.',
    ],
  ),

  // -------------------------------------------------------------------------
  // Pray
  // -------------------------------------------------------------------------
  UserAction(
    id: 'pray-open',
    surface: 'pray',
    title: 'Open the Pray tab',
    trigger: Anchor(
      'lib/components/prayer_content/prayer_session_view.dart',
      '_startSession',
    ),
    visible: 'Today\'s prayer content, usually with no skeleton.',
    background:
        'A session timer starts. Leaving the tab later posts that duration even '
        'if the user never taps Amen.',
    steps: [
      Step(
        from: Actor.ui,
        to: Actor.local,
        text:
            'Peek the in-memory cache before the first frame, so a warm cache '
            'paints with no skeleton',
        anchor: Anchor(
          'lib/components/misc/cached_data_builder.dart',
          'CachedDataBuilder',
        ),
      ),
      Step(
        from: Actor.ui,
        to: Actor.server,
        text: 'Fetch the day\'s content, keyed by group + date + language',
        anchor: Anchor(
          'lib/services/prayer_content_service.dart',
          'fetchPrayerContent',
        ),
        endpoint: 'GET /api/people-groups/{slug}/prayer-content/{date}',
        when: 'no cache entry younger than the TTL',
      ),
      Step(
        from: Actor.ui,
        to: Actor.ui,
        text: 'Start the session clock and mint the session id',
        anchor: Anchor(
          'lib/components/prayer_content/prayer_session_view.dart',
          '_startSession',
        ),
        background: true,
      ),
      Step(
        from: Actor.ui,
        to: Actor.server,
        text:
            'Report the session as open, then re-report every 60s for up to 15 '
            'minutes so it stays visible in the praying-now count',
        anchor: Anchor(
          'lib/components/prayer_content/prayer_session_view.dart',
          '_postSessionPing',
        ),
        endpoint:
            'POST /api/people-groups/{slug}/prayer-content/{date}/session',
        when: 'the visit outlasts the minimum duration',
        background: true,
      ),
      Step(
        from: Actor.ui,
        to: Actor.server,
        text:
            'Refresh how many people are praying right now, for the banner. '
            'Runs on every session start, which is the only thing that moves '
            'the number',
        anchor: Anchor(
          'lib/services/prayer_stats_service.dart',
          'refreshPrayingNow',
        ),
        endpoint: 'GET /api/people-groups/statistics',
        background: true,
      ),
    ],
    notes: [
      'A past day\'s content never changes, so this is the one cached read with '
          'no background revalidation.',
      'The open report and every later ping upsert the SAME row server-side, '
          'keyed on the session id minted at start — so one visit is one row, '
          'whose timestamp tracks when the user was last seen.',
      'The praying-now count is read uncached on purpose: the shared response '
          'cache falls back to expired data when a refetch fails, which would '
          'show a stale live number rather than nothing.',
      'The banner reads a controller instead of fetching on mount. The Pray tab '
          'sits in an `IndexedStack`, so its widgets are never disposed and an '
          '`initState` fetch would run once per app launch and then sit frozen.',
    ],
  ),

  UserAction(
    id: 'pray-amen',
    surface: 'pray',
    title: 'Tap Amen',
    trigger: Anchor(
      'lib/components/prayer_content/prayer_session_view.dart',
      '_onAmen',
    ),
    visible: 'The thank-you modal with a rolling verse.',
    background:
        'Posts the session duration against the id minted when the session '
        'started, then writes a local prayer record. Both are best-effort — a '
        'failure never reaches the user.',
    steps: [
      Step(
        from: Actor.ui,
        to: Actor.server,
        text:
            'Post session id, tracking id, duration, timestamp and the '
            'prayer_logged flag',
        anchor: Anchor(
          'lib/services/prayer_content_service.dart',
          'postPrayerSession',
        ),
        endpoint:
            'POST /api/people-groups/{slug}/prayer-content/{date}/session',
      ),
      Step(
        from: Actor.ui,
        to: Actor.local,
        text:
            'Append to the local prayer history, driving the prayed-today state',
        anchor: Anchor(
          'lib/services/prayer_history_service.dart',
          'recordPrayer',
        ),
        writes: ['prayer_history'],
      ),
      Step(
        from: Actor.ui,
        to: Actor.local,
        text:
            'Advance the verse rotation, so the next Amen shows a different '
            'verse',
        anchor: Anchor(
          'lib/components/prayer_content/prayer_session_view.dart',
          'nextThankYouVerse',
        ),
        writes: ['thank_you_verse_index'],
      ),
    ],
    notes: [
      '`postPrayerSession` is skipped on **any non-release build**, not just '
          'when the app secret is missing. Every other service skips only on a '
          'missing secret — so this is the one endpoint you cannot exercise from a '
          'debug or profile build.',
      'Only the Amen carries `track_event: prayer_logged`; the pings a running '
          'session makes leave it unset. The server, not the app, forwards that '
          'to the analytics backend — the app never talks to it directly.',
    ],
  ),

  UserAction(
    id: 'pray-leave-without-amen',
    surface: 'pray',
    title: 'Leave the Pray tab without tapping Amen',
    trigger: Anchor(
      'lib/components/prayer_content/prayer_session_view.dart',
      '_endSession',
    ),
    visible: 'Nothing at all.',
    background:
        'The session is posted anyway, as long as it lasted longer than the '
        'minimum duration. Navigating away is treated as an implicit Amen.',
    steps: [
      Step(
        from: Actor.ui,
        to: Actor.ui,
        text:
            'Route change ends the session and fires the background record once',
        anchor: Anchor(
          'lib/components/prayer_content/prayer_session_view.dart',
          '_recordAmenInBackground',
        ),
        background: true,
      ),
      Step(
        from: Actor.ui,
        to: Actor.server,
        text: 'Post the session',
        anchor: Anchor(
          'lib/services/prayer_content_service.dart',
          'postPrayerSession',
        ),
        endpoint:
            'POST /api/people-groups/{slug}/prayer-content/{date}/session',
        when: 'the session outlasted the minimum duration',
        background: true,
      ),
      Step(
        from: Actor.ui,
        to: Actor.local,
        text: 'Append to local history',
        anchor: Anchor(
          'lib/services/prayer_history_service.dart',
          'recordPrayer',
        ),
        writes: ['prayer_history'],
        background: true,
      ),
    ],
    notes: [
      'An `_amenFired` latch stops the tap and the leave path both recording the '
          'same session.',
    ],
  ),

  // -------------------------------------------------------------------------
  // Browse
  // -------------------------------------------------------------------------
  UserAction(
    id: 'browse-open',
    surface: 'browse',
    title: 'Open the Browse tab',
    trigger: Anchor(
      'lib/components/widgets/people_groups_list.dart',
      'fetchPeopleGroups',
    ),
    visible: 'The UUPG list, usually instantly.',
    background:
        'The list is ~850 KB and cached for 7 days, but refreshed in the '
        'background once the copy is over an hour old so praying counts move. '
        'JSON decoding happens in a separate isolate to avoid dropped frames.',
    steps: [
      Step(
        from: Actor.ui,
        to: Actor.local,
        text: 'Serve the cached list from memory, warmed at launch',
        anchor: Anchor(
          'lib/services/cache_warmup.dart',
          'warmPeopleGroupCaches',
        ),
      ),
      Step(
        from: Actor.ui,
        to: Actor.server,
        text: 'Fetch or background-revalidate the list',
        anchor: Anchor(
          'lib/services/people_groups_service.dart',
          'fetchPeopleGroups',
        ),
        endpoint: 'GET /api/people-groups/list',
        when: 'cache is missing, past TTL, or older than the refresh window',
      ),
      Step(
        from: Actor.server,
        to: Actor.ui,
        text: 'Revalidated counts are pushed into the live list in place',
        anchor: Anchor('lib/services/response_cache.dart', 'addCacheListener'),
        background: true,
      ),
    ],
  ),

  UserAction(
    id: 'browse-switch-group',
    surface: 'browse',
    title: 'Group details → pray for this group',
    trigger: Anchor(
      'lib/services/select_people_group_flow.dart',
      'showSelectPeopleGroupConfirmation',
    ),
    visible: 'A confirm dialog, then the group becomes theirs.',
    background:
        'The single most consequential tap outside onboarding. For an existing '
        'subscriber it moves the prayer subscription to the new group. For '
        'someone who skipped group selection in the wizard it is the moment '
        'their anonymous subscriber is created server-side and the app gains an '
        'identity at last — which is also what finally lets push register.',
    steps: [
      Step(
        from: Actor.ui,
        to: Actor.local,
        text: 'Persist the new selection',
        anchor: Anchor(
          'lib/services/selected_people_group_controller.dart',
          'setSelectedPeopleGroup',
        ),
        writes: [
          'selected_people_group_slug',
          'selected_people_group_name',
          'selected_people_group_image_url',
        ],
      ),
      Step(
        from: Actor.ui,
        to: Actor.server,
        text:
            'Profile sync moves the subscription to the new group and re-sends '
            'the reminder schedule',
        anchor: Anchor(
          'lib/services/profile_update_service.dart',
          'submitProfileUpdate',
        ),
        endpoint: 'PUT /api/profile/{profileId}',
        when: 'a profileId exists',
        background: true,
      ),
      Step(
        from: Actor.ui,
        to: Actor.server,
        text: 'Deferred anon-signup creates the missing prayer subscription',
        anchor: Anchor(
          'lib/services/anon_signup_service.dart',
          '_maybeFireDeferredSignup',
        ),
        endpoint: 'POST /api/people-groups/{slug}/anon-signup',
        when: 'onboarding is complete and there is still no subscriptionId',
        server:
            'For a user who has no identity yet this is where their anonymous '
            'subscriber is created: empty tracking_id → '
            '`findOrCreateByTrackingId` → a fresh `Anonymous` subscriber, plus '
            'the app subscription. The app then adopts all three ids from the '
            'response.',
        background: true,
      ),
      Step(
        from: Actor.server,
        to: Actor.local,
        text:
            'A merge server-side can return a different subscription id, which '
            'is adopted so the cached identity stays correct',
        anchor: Anchor(
          'lib/services/profile_update_service.dart',
          'setIdentity',
        ),
        writes: ['identity_subscription_id'],
        background: true,
      ),
    ],
    notes: [
      'Both background calls can fire from one tap, and both are best-effort: a '
          'failure is reported to Crashlytics and never shown, so the user believes '
          'the switch fully succeeded.',
      'This is the only path to a first prayer subscription outside the '
          'wizard, and the deferred listener does it with no extra UI — '
          'selecting a group is all the user has to do.',
    ],
  ),

  // -------------------------------------------------------------------------
  // Reminders
  // -------------------------------------------------------------------------
  UserAction(
    id: 'reminders-save',
    surface: 'reminders',
    title: 'Add or edit a reminder',
    trigger: Anchor(
      'lib/components/reminders/reminder_editor.dart',
      'ensureNotificationPermission',
    ),
    visible:
        'The reminder appears in the list; possibly an OS permission dialog.',
    background:
        'Asks for the shared notification permission and, on a grant, silently '
        'opts the device into OneSignal push. Then, if a profile exists, the '
        'whole reminder schedule is PUT to the server.',
    steps: [
      Step(
        from: Actor.ui,
        to: Actor.os,
        text: 'Request notification permission if not already granted',
        anchor: Anchor(
          'lib/services/reminders_notifications.dart',
          'ensureNotificationPermission',
        ),
      ),
      Step(
        from: Actor.ui,
        to: Actor.oneSignal,
        text: 'Nudge the push token into existence — no second dialog',
        anchor: Anchor(
          'lib/services/reminders_notifications.dart',
          '_nudgeOneSignalRegister',
        ),
        when: 'permission was granted',
        background: true,
      ),
      Step(
        from: Actor.ui,
        to: Actor.local,
        text: 'Persist and reschedule all reminders',
        anchor: Anchor('lib/services/reminders_controller.dart', 'addReminder'),
        writes: ['reminders'],
      ),
      Step(
        from: Actor.ui,
        to: Actor.server,
        text:
            'Profile sync sends frequency, time, days-of-week and timezone — '
            'derived from the *earliest enabled* reminder, with the union of all '
            'enabled weekdays',
        anchor: Anchor(
          'lib/services/profile_update_service.dart',
          'submitProfileUpdate',
        ),
        endpoint: 'PUT /api/profile/{profileId}',
        when: 'a profileId exists',
        background: true,
      ),
      Step(
        from: Actor.ui,
        to: Actor.server,
        text: 'Register the push subscription now that a token exists',
        anchor: Anchor(
          'lib/services/push_notifications_service.dart',
          '_registerPushWithServer',
        ),
        endpoint: 'POST /api/push/register',
        when: 'identity exists and this subscription/external-id pair is new',
        background: true,
      ),
    ],
    notes: [
      'The server only ever learns one schedule, however many reminders the user '
          'has locally. Weekdays are converted from Dart\'s Mon=1..Sun=7 to the '
          'backend\'s Sun=0..Sat=6.',
      'Toggling, editing and deleting a reminder all trigger the same profile '
          'sync, because the listener is on the reminders controller rather than on '
          'any one button.',
    ],
  ),

  // -------------------------------------------------------------------------
  // Settings
  // -------------------------------------------------------------------------
  UserAction(
    id: 'settings-news-signup',
    surface: 'settings',
    title: 'Settings → Sign up for updates → Sign up',
    trigger: Anchor(
      'lib/screens/news_signup_settings_screen.dart',
      '_onSubmit',
    ),
    visible:
        'The same form and the same "check your email" confirmation as the '
        'wizard step, plus an enable-notifications offer.',
    background:
        'One POST, not the wizard\'s two — and that is fine. It carries the '
        'existing `tracking_id`, so the server updates the name and email on '
        'the anon user already on this device and **leaves their prayer '
        'subscription in place**. The app deliberately does not touch '
        '`subscriptionId`, because it already has the right one.',
    steps: [
      Step(
        from: Actor.ui,
        to: Actor.server,
        text:
            'news-signup with email, name, consents, current group slug, '
            'language and the existing tracking_id',
        anchor: Anchor(
          'lib/services/news_signup_service.dart',
          'submitNewsSignup',
        ),
        endpoint: 'POST /api/news-signup',
      ),
      Step(
        from: Actor.server,
        to: Actor.server,
        text:
            'Resolves the anon user by tracking_id, attaches the email, and '
            'leaves the prayer subscription untouched',
        server:
            '`findOrCreateForNews` tries the email first, then the '
            'tracking_id: finding the device\'s anon subscriber it *adds* the '
            'email as a contact method and fills in the name only if the '
            'existing one is still blank or `Anonymous`. Nothing in this '
            'handler or in `applyEmailConsents` touches '
            '`people_group_subscriptions`, so the prayer subscription is '
            'untouched. It returns tracking_id and profile_id only.',
        background: true,
      ),
      Step(
        from: Actor.server,
        to: Actor.local,
        text:
            'Returns tracking_id and profile_id; subscriptionId is left as it '
            'was, which is already correct',
        anchor: Anchor('lib/services/identity_service.dart', 'setIdentity'),
        writes: ['identity_tracking_id', 'identity_profile_id'],
        background: true,
      ),
      Step(
        from: Actor.ui,
        to: Actor.oneSignal,
        text:
            'External id switches to profile_id, if this is the first time one '
            'has been set',
        anchor: Anchor(
          'lib/services/push_notifications_service.dart',
          '_syncExternalId',
        ),
        background: true,
      ),
      Step(
        from: Actor.ui,
        to: Actor.server,
        text: 'Re-register the push subscription against the new external id',
        anchor: Anchor(
          'lib/services/push_notifications_service.dart',
          '_registerPushWithServer',
        ),
        endpoint: 'POST /api/push/register',
        when: 'the external id actually changed and a push token exists',
        background: true,
      ),
    ],
    notes: [
      'The two signup screens differ in *how the server identifies the person* '
          '— by email in the wizard, by tracking_id here — not in whether a prayer '
          'subscription survives. It survives.',
      'A user who skipped group selection in the wizard has no `anon-signup` '
          'behind them, so this gives them a profile and still no prayer '
          'subscription — expected, since they have not chosen a group. '
          'Choosing one later posts the signup via the deferred listener.',
      'From this point on, every reminder edit and group switch silently PUTs '
          'the profile, because `profileId` is now set.',
      'The response is parsed for `tracking_id` and `profile_id` only. Any '
          '`subscription_id` the server returned would be discarded — harmless '
          'while the server leaves the subscription alone.',
    ],
  ),

  UserAction(
    id: 'settings-enable-notifications',
    surface: 'settings',
    title: 'Enable notifications (prompt or settings row)',
    trigger: Anchor(
      'lib/components/notifications/enable_notifications_prompt.dart',
      '_onEnable',
    ),
    visible:
        'The OS dialog, or the system settings app if permission was previously '
        'denied.',
    background:
        'This is the only push-facing control in the app, and it works by going '
        'through the reminders permission helper — so granting it also mints the '
        'OneSignal token and registers the device.',
    steps: [
      Step(
        from: Actor.ui,
        to: Actor.os,
        text:
            'Try a real permission request; fall back to opening app settings',
        anchor: Anchor(
          'lib/services/reminders_notifications.dart',
          'promptEnableNotifications',
        ),
      ),
      Step(
        from: Actor.ui,
        to: Actor.oneSignal,
        text: 'Nudge token registration',
        anchor: Anchor(
          'lib/services/reminders_notifications.dart',
          '_nudgeOneSignalRegister',
        ),
        when: 'permission was granted',
        background: true,
      ),
      Step(
        from: Actor.ui,
        to: Actor.server,
        text: 'Register the subscription id and platform',
        anchor: Anchor(
          'lib/services/push_notifications_service.dart',
          '_registerPushWithServer',
        ),
        endpoint: 'POST /api/push/register',
        when: 'identity exists',
        background: true,
      ),
    ],
    notes: [
      'When the fallback to OS settings is taken, the grant lands *after* this '
          'returns; a lifecycle observer re-checks on resume.',
    ],
  ),

  UserAction(
    id: 'settings-account-emails',
    surface: 'settings',
    title: 'Settings → view signed-up emails',
    trigger: Anchor(
      'lib/components/settings/account_settings_section.dart',
      'fetchProfileEmails',
    ),
    visible:
        'The email addresses signed up with, each shown verified or not, plus a '
        'link out to the web profile.',
    background:
        'Fetches the profile on every identity change and again on returning to '
        'the screen. Addresses arrive **redacted** from the server, so the app '
        'never holds them in full here.',
    steps: [
      Step(
        from: Actor.ui,
        to: Actor.server,
        text: 'Fetch the email list with verification status',
        anchor: Anchor(
          'lib/services/profile_service.dart',
          'fetchProfileEmails',
        ),
        endpoint: 'GET /api/profile/{profileId}',
        when: 'a profileId exists — the whole section hides without one',
      ),
    ],
    notes: [
      'The same endpoint returns the primary address unredacted under '
          '`subscriber.email`; this list uses the redacted `emails` array instead.',
    ],
  ),

  UserAction(
    id: 'settings-resend-verification',
    surface: 'settings',
    title: 'Settings → Resend verification email',
    trigger: Anchor(
      'lib/components/settings/signed_up_email_tile.dart',
      'resendVerification',
    ),
    visible: 'A snackbar: sent, already verified, or a countdown to retry.',
    background:
        'Server-side rate limited. A 429 carries `retryAfterSeconds`, which '
        'drives the countdown on the button rather than surfacing as an error.',
    steps: [
      Step(
        from: Actor.ui,
        to: Actor.server,
        text: 'Request a new verification email for one contact method',
        anchor: Anchor(
          'lib/services/profile_service.dart',
          'resendVerification',
        ),
        endpoint: 'POST /api/profile/{profileId}/resend-verification',
      ),
    ],
    notes: [
      'This call never throws — every failure maps to a status the UI can show, '
          'so a network problem looks the same as a refusal.',
    ],
  ),

  UserAction(
    id: 'settings-language',
    surface: 'settings',
    title: 'Change language',
    trigger: Anchor('lib/services/locale_controller.dart', 'setLocale'),
    visible: 'The UI switches language.',
    background:
        'Every cached read is keyed by language, so the whole content cache is '
        'effectively invalidated — the next Browse and Pray visit refetch. An '
        'analytics event records the switch.',
    steps: [
      Step(
        from: Actor.ui,
        to: Actor.local,
        text: 'Persist the language code',
        anchor: Anchor('lib/services/locale_controller.dart', 'setLocale'),
        writes: ['app_locale_language_code'],
      ),
      Step(
        from: Actor.ui,
        to: Actor.server,
        text: 'Post a language_switched event with the previous language',
        anchor: Anchor(
          'lib/services/analytics_service.dart',
          'trackLanguageSwitched',
        ),
        endpoint: 'POST /api/collect/app',
        background: true,
      ),
      Step(
        from: Actor.ui,
        to: Actor.server,
        text:
            'Subsequent content reads miss the cache, because keys embed the '
            'language',
        anchor: Anchor(
          'lib/services/people_groups_service.dart',
          'peopleGroupListCacheKey',
        ),
        background: true,
      ),
    ],
    notes: [
      'Language is *not* sent to the profile endpoint, so a signed-up user\'s '
          'email language is only set by whatever they signed up with.',
    ],
  ),

  UserAction(
    id: 'settings-feedback',
    surface: 'settings',
    title: 'Send feedback',
    trigger: Anchor('lib/services/feedback_service.dart', 'submitFeedback'),
    visible: 'A thank-you confirmation, or an inline rate-limit message.',
    background:
        'Attaches the tracking id, locale and a device diagnostics blob. If the '
        'user has a profile, the form is pre-filled by fetching their '
        'non-redacted primary email.',
    steps: [
      Step(
        from: Actor.ui,
        to: Actor.server,
        text: 'Pre-fill: fetch the primary email for the profile',
        anchor: Anchor(
          'lib/services/profile_service.dart',
          'fetchPrimaryEmail',
        ),
        endpoint: 'GET /api/profile/{profileId}',
        when: 'a profileId exists',
        background: true,
      ),
      Step(
        from: Actor.ui,
        to: Actor.server,
        text:
            'Post type, message, consent, tracking id, language and device info',
        anchor: Anchor('lib/services/feedback_service.dart', 'submitFeedback'),
        endpoint: 'POST /api/feedback',
      ),
    ],
    notes: [
      'The profile endpoint returns email addresses redacted in its `emails` '
          'list but plaintext under `subscriber.email` — the pre-fill relies on the '
          'latter.',
    ],
  ),

  // -------------------------------------------------------------------------
  // Update gate
  // -------------------------------------------------------------------------
  UserAction(
    id: 'update-dismiss',
    surface: 'update',
    title: 'Dismiss the optional update banner',
    trigger: Anchor(
      'lib/components/misc/update_gate.dart',
      'dismissOptionalUpdate',
    ),
    visible: 'The banner disappears.',
    background:
        'Writes **two** suppression keys: the dismissed version, so this version '
        'never nags again, and a shorter snooze timestamp that also suppresses '
        'the banner after a cancelled update attempt.',
    steps: [
      Step(
        from: Actor.ui,
        to: Actor.local,
        text: 'Snooze the banner for a fixed window',
        anchor: Anchor(
          'lib/services/update_controller.dart',
          '_snoozeOptionalUpdate',
        ),
        writes: ['update_snooze_until'],
        background: true,
      ),
      Step(
        from: Actor.ui,
        to: Actor.local,
        text:
            'Record the dismissed version, so only a newer release re-prompts',
        anchor: Anchor(
          'lib/services/update_controller.dart',
          'dismissOptionalUpdate',
        ),
        writes: ['update_dismissed_version'],
        background: true,
      ),
    ],
    notes: [
      'A forced update has no dismiss path — the gate renders a blocking modal '
          'instead of a banner.',
      'The snooze key is written on a cancelled or failed update attempt too, '
          'not just on an explicit dismiss.',
    ],
  ),

  UserAction(
    id: 'update-start',
    surface: 'update',
    title: 'Start the update',
    trigger: Anchor('lib/components/misc/update_gate.dart', 'startAppUpdate'),
    visible:
        'Android: the native in-app update flow. iOS: the store listing opens.',
    background:
        'No server call of its own — the target version came from the launch '
        'version check.',
    steps: [
      Step(
        from: Actor.ui,
        to: Actor.os,
        text:
            'Android uses Play in-app update (blocking when forced); other '
            'platforms deep-link to the store',
        anchor: Anchor('lib/services/update_controller.dart', 'startAppUpdate'),
      ),
    ],
  ),

  // -------------------------------------------------------------------------
  // Links
  // -------------------------------------------------------------------------
  UserAction(
    id: 'link-app-slug',
    surface: 'links',
    title: 'Open an /app/<slug> share link',
    trigger: Anchor('lib/router.dart', 'app-deep-link'),
    visible:
        'Either the group\'s detail page, or the wizard with that group '
        'pre-selected.',
    background:
        'Before onboarding the slug is stashed in prefs for the wizard to pick '
        'up, which is the same channel the Play install-referrer writes to.',
    steps: [
      Step(
        from: Actor.ui,
        to: Actor.local,
        text: 'Stash the referred slug, then redirect into the wizard',
        anchor: Anchor(
          'lib/services/referral_controller.dart',
          'setReferredPeopleGroup',
        ),
        writes: ['referred_people_group_slug'],
        when: 'onboarding is not complete',
        background: true,
      ),
      Step(
        from: Actor.ui,
        to: Actor.server,
        text: 'Otherwise go straight to the details page and fetch the group',
        anchor: Anchor(
          'lib/services/people_groups_service.dart',
          'fetchPeopleGroupDetail',
        ),
        endpoint: 'GET /api/people-groups/detail/{slug}',
        when: 'onboarding is complete',
      ),
    ],
    notes: [
      'The share link is built with `ApiConfig.buildUri`, so a staging build '
          'shares a staging URL.',
    ],
  ),

  UserAction(
    id: 'link-prayer',
    surface: 'links',
    title: 'Open a /<slug>/prayer link',
    trigger: Anchor('lib/router.dart', '_prayDeepLinkRedirect'),
    visible:
        'The Pray tab showing that group, or a standalone prayer screen with a '
        'wizard CTA for a user who has not onboarded.',
    background:
        'For an onboarded user the group is stashed as a **one-visit override** '
        'rather than becoming their selection — so no subscription changes, and '
        'leaving the tab reverts it.',
    steps: [
      Step(
        from: Actor.ui,
        to: Actor.ui,
        text: 'Stash a one-visit pray override and redirect to /pray',
        anchor: Anchor(
          'lib/services/pray_override_controller.dart',
          'setPrayOverride',
        ),
        when: 'onboarding is complete',
        background: true,
      ),
      Step(
        from: Actor.ui,
        to: Actor.server,
        text: 'Fetch that group\'s content for the requested date',
        anchor: Anchor(
          'lib/services/prayer_content_service.dart',
          'fetchPrayerContent',
        ),
        endpoint: 'GET /api/people-groups/{slug}/prayer-content/{date}',
      ),
      Step(
        from: Actor.ui,
        to: Actor.ui,
        text: 'Leaving the Pray tab clears the override',
        anchor: Anchor(
          'lib/services/pray_override_controller.dart',
          'attachPrayOverrideAutoClear',
        ),
        background: true,
      ),
    ],
    notes: [
      'A prayer session posted while an override is active is attributed to the '
          'overridden group, not the user\'s own.',
    ],
  ),

  UserAction(
    id: 'push-tap',
    surface: 'links',
    title: 'Tap a push notification',
    trigger: Anchor(
      'lib/services/push_notifications_service.dart',
      '_onNotificationClick',
    ),
    visible: 'The app opens on a prayer page.',
    background:
        'The target is read from the notification payload — an explicit `route`, '
        'or a bare `slug` mapped to the prayer deep link. With neither, it falls '
        'back to the same sink local reminders use.',
    steps: [
      Step(
        from: Actor.oneSignal,
        to: Actor.ui,
        text: 'Click listener extracts a route from additionalData',
        anchor: Anchor(
          'lib/services/push_notifications_service.dart',
          '_routeFromData',
        ),
      ),
      Step(
        from: Actor.ui,
        to: Actor.ui,
        text:
            'Navigate via the pray deep-link route, so any group can be opened '
            'regardless of the user\'s own selection',
        anchor: Anchor('lib/router.dart', '_prayDeepLinkRedirect'),
      ),
      Step(
        from: Actor.ui,
        to: Actor.ui,
        text: 'Generic push with no target → the local-reminder tap sink',
        anchor: Anchor(
          'lib/services/reminders_notifications.dart',
          'reminderTapPayload',
        ),
        when: 'the payload carries neither route nor slug',
        background: true,
      ),
    ],
  ),
];
