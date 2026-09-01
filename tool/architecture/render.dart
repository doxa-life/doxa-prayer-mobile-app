/// Turns [Facts] + the action [catalogue] into the markdown under
/// `docs/architecture/`.
library;

import 'catalogue.dart';
import 'facts.dart';

/// Says plainly which facts are machine-checked and which are not, so the two
/// are never mistaken for each other. Server behaviour lives in another repo,
/// so it is hand-recorded rather than validated.
String get _serverProvenance =>
    '> **On server-side facts.** Everything cited from `lib/` is validated on '
    'every regeneration. The **On the server** notes describe another repo and '
    'are hand-recorded: read from `${serverVerification.repo}` at '
    '`${serverVerification.commit}` (${serverVerification.branch}) on '
    '${serverVerification.readOn}. Re-check them when that repo moves.';

const _generatedBanner =
    '<!-- GENERATED FILE — do not edit by hand.\n'
    '     Facts come from lib/ via tool/architecture/facts.dart.\n'
    '     Narrative comes from tool/architecture/catalogue.dart.\n'
    '     Regenerate with: dart run tool/gen_architecture.dart -->';

/// Every generated document, keyed by repo-relative path.
Map<String, String> renderAll(Facts facts) => {
  'docs/architecture/README.md': _renderIndex(facts),
  'docs/architecture/actions.md': _renderActions(facts),
  'docs/architecture/identity.md': _renderIdentity(facts),
  'docs/architecture/data-layer.md': _renderDataLayer(facts),
};

// ---------------------------------------------------------------------------
// README
// ---------------------------------------------------------------------------

String _renderIndex(Facts facts) {
  final b = _Buf()
    ..line(_generatedBanner)
    ..blank()
    ..line('# App architecture')
    ..blank()
    ..line(
      'What happens in the background when someone taps something. Written for '
      'the case where you have been away from the code for a few weeks and need '
      'to know which quiet server call a button sets off.',
    )
    ..blank()
    ..line('| Document | What it answers |')
    ..line('| --- | --- |')
    ..line(
      '| [actions.md](actions.md) | Per surface: every action, what the user '
      'sees, and what they don\'t. |',
    )
    ..line(
      '| [identity.md](identity.md) | How a device gets a tracking id, a '
      'profile and a prayer subscription — and how it becomes push-addressable. |',
    )
    ..line(
      '| [data-layer.md](data-layer.md) | Endpoint, cache, storage and route '
      'inventories, and which action touches which endpoint. |',
    )
    ..blank()
    ..line('## Scale')
    ..blank()
    ..line(
      '${facts.requests.length} HTTP endpoints across '
      '${facts.endpoints.length} built URIs · ${facts.prefsKeys.length} '
      'persisted keys · ${facts.routes.length} routes · ${actions.length} '
      'documented actions.',
    )
    ..blank()
    ..line('## Keeping this true')
    ..blank()
    ..line(
      'The tables and inventories are scanned out of `lib/` on every '
      'regeneration. The prose is hand-written in '
      '`tool/architecture/catalogue.dart`, but every fact it cites — a function '
      'name, an endpoint, a prefs key — is checked against the source. Rename '
      '`submitAnonSignup` and generation fails until the catalogue is updated.',
    )
    ..blank()
    ..line('```sh')
    ..line('dart run tool/gen_architecture.dart          # regenerate')
    ..line('dart run tool/gen_architecture.dart --check  # fail if stale')
    ..line('```')
    ..blank()
    ..line(
      '`test/architecture_docs_test.dart` runs the check, so drift fails with '
      'the rest of the suite rather than waiting to be noticed.',
    )
    ..blank()
    ..line(
      'Regeneration also lists any endpoint or persisted key that no documented '
      'action accounts for, so a new one cannot quietly go undescribed.',
    )
    ..blank()
    ..line('## The one exception')
    ..blank()
    ..line(
      'Server-side behaviour cannot be checked from this repo, so those notes '
      'are labelled **On the server** and carry their own provenance: read from '
      '`${serverVerification.repo}` at `${serverVerification.commit}` '
      '(${serverVerification.branch}) on ${serverVerification.readOn}, from:',
    )
    ..blank();
  for (final file in serverVerification.files) {
    b.line('- `$file`');
  }
  b
    ..blank()
    ..line(
      'Update `serverVerification` in `tool/architecture/catalogue.dart` when '
      'they are re-checked.',
    );
  return b.toString();
}

// ---------------------------------------------------------------------------
// actions.md
// ---------------------------------------------------------------------------

String _renderActions(Facts facts) {
  final b = _Buf()
    ..line(_generatedBanner)
    ..blank()
    ..line('# Actions and their background effects')
    ..blank()
    ..line(
      'Each entry pairs what the user perceives with what actually happens. In '
      'the diagrams a **solid arrow** is something the user caused and can '
      'perceive; a **dashed arrow** is background work they have no way of '
      'seeing. `opt` blocks are conditional.',
    )
    ..blank()
    ..line(_serverProvenance)
    ..blank()
    ..line('## At a glance')
    ..blank()
    ..line('| Surface | Action | Requests it can fire | Writes |')
    ..line('| --- | --- | --- | --- |');

  for (final surface in surfaces) {
    for (final action in actions.where((a) => a.surface == surface.id)) {
      final endpoints = action.steps
          .map((s) => s.endpoint)
          .whereType<String>()
          .toSet()
          .map((e) => '`$e`')
          .join('<br>');
      final writes = action.steps
          .expand((s) => s.writes ?? const <String>[])
          .toSet()
          .map((k) => '`$k`')
          .join('<br>');
      b.line(
        '| ${surface.title} | [${action.title}](#${_slug(action.title)}) | '
        '${endpoints.isEmpty ? '—' : endpoints} | '
        '${writes.isEmpty ? '—' : writes} |',
      );
    }
  }

  for (final surface in surfaces) {
    final own = actions.where((a) => a.surface == surface.id).toList();
    if (own.isEmpty) continue;
    b
      ..blank()
      ..line('---')
      ..blank()
      ..line('## ${surface.title}')
      ..blank()
      ..line(surface.blurb);

    for (final action in own) {
      b
        ..blank()
        ..line('### ${action.title}')
        ..blank()
        ..line(
          'Entered at `${action.trigger.symbol}` in [${action.trigger.file}](${_up(action.trigger.file)}).',
        )
        ..blank()
        ..line('**Visible** — ${action.visible}')
        ..blank()
        ..line('**Background** — ${action.background}')
        ..blank()
        ..line(_sequenceDiagram(action));

      final serverSteps = action.steps.where((s) => s.server != null).toList();
      if (serverSteps.isNotEmpty) {
        b
          ..blank()
          ..line('**On the server**');
        b.blank();
        for (final step in serverSteps) {
          final endpoint = step.endpoint;
          b.line('- ${endpoint == null ? '' : '`$endpoint` — '}${step.server}');
        }
      }

      if (action.notes.isNotEmpty) {
        b
          ..blank()
          ..line('**Worth knowing**');
        b.blank();
        for (final note in action.notes) {
          b.line('- $note');
        }
      }
    }
  }
  return b.toString();
}

String _sequenceDiagram(UserAction action) {
  final used = <Actor>{Actor.user};
  for (final step in action.steps) {
    used
      ..add(step.from)
      ..add(step.to);
  }

  final b = _Buf()
    ..line('```mermaid')
    ..line('sequenceDiagram')
    ..line('    autonumber');
  for (final actor in Actor.values.where(used.contains)) {
    b.line('    participant ${actor.alias} as ${actor.label}');
  }
  b.line(
    '    ${Actor.user.alias}->>${Actor.ui.alias}: ${_label(action.title)}',
  );

  for (final step in action.steps) {
    final arrow = step.background ? '-->>' : '->>';
    var text = _label(step.text);
    if (step.endpoint != null) text = '${step.endpoint} — $text';
    final line = '${step.from.alias}$arrow${step.to.alias}: $text';
    if (step.when != null) {
      b
        ..line('    opt ${_label(step.when!)}')
        ..line('        $line')
        ..line('    end');
    } else {
      b.line('    $line');
    }
    final writes = step.writes;
    if (writes != null && writes.isNotEmpty) {
      b.line('    Note over ${step.to.alias}: writes ${writes.join(", ")}');
    }
  }
  b.line('```');
  return b.toString();
}

// ---------------------------------------------------------------------------
// identity.md
// ---------------------------------------------------------------------------

String _renderIdentity(Facts facts) {
  final b = _Buf()
    ..line(_generatedBanner)
    ..blank()
    ..line('# Identity, signup and push')
    ..blank()
    ..line(
      'Three fields decide what the app is allowed to do with the server. Which '
      'of them a user ends up with depends on a path they cannot see.',
    )
    ..blank()
    ..line('## The three fields')
    ..blank()
    ..line('| Field | Stored as | Meaning |')
    ..line('| --- | --- | --- |');

  const fieldKeys = {
    'trackingId': 'identity_tracking_id',
    'profileId': 'identity_profile_id',
    'subscriptionId': 'identity_subscription_id',
  };
  identityFields.forEach((field, meaning) {
    b.line('| `$field` | `${fieldKeys[field]}` | $meaning |');
  });

  b
    ..blank()
    ..line('## States a device can be in')
    ..blank()
    ..line('```mermaid')
    ..line('stateDiagram-v2')
    ..line('    [*] --> none')
    ..line('    none: No identity');
  identityStates.forEach((state, desc) {
    if (state == 'none') return;
    b.line('    $state: ${_label(desc.split('.').first)}');
  });
  for (final t in identityTransitions) {
    b.line('    ${t[0]} --> ${t[1]}: ${_label(t[2])}');
  }
  b
    ..line('```')
    ..blank()
    ..line(identityStateCaveat)
    ..blank()
    ..line('| State | Reached how |')
    ..line('| --- | --- |');
  identityStates.forEach((state, desc) {
    b.line('| `$state` | $desc |');
  });

  b
    ..blank()
    ..line('## What writes which field')
    ..blank()
    ..line(
      'Derived from the catalogue, so it stays complete as actions are added.',
    )
    ..blank()
    ..line('| Key | Written by |')
    ..line('| --- | --- |');

  for (final key in fieldKeys.values) {
    final writers = actions
        .where((a) => a.steps.any((s) => (s.writes ?? const []).contains(key)))
        .map((a) => a.title)
        .toList();
    b.line('| `$key` | ${writers.isEmpty ? '—' : writers.join('; ')} |');
  }

  b
    ..blank()
    ..line('## Wizard signup vs settings signup')
    ..blank()
    ..line(
      'These two screens show the same form. What differs is how the server '
      'identifies the person, not whether their prayer subscription survives.',
    )
    ..blank()
    ..line('| | Wizard news step | Settings → Sign up for updates |')
    ..line('| --- | --- | --- |');

  signupComparison.forEach((row, cells) {
    b.line('| $row | ${cells[0]} | ${cells[1]} |');
  });

  b
    ..blank()
    ..line(
      '> In the wizard, the email is passed straight from the news-signup form '
      'into `submitAnonSignup`, and that is what makes the server return a '
      'matched account rather than a fresh anonymous one. The ordering in '
      '`WizardController.signUp` is load-bearing.',
    )
    ..blank()
    ..line(
      '> In settings, the `tracking_id` does the identifying instead: the '
      'server finds the anon user already on the device, updates their name and '
      'email, and leaves the prayer subscription alone.',
    )
    ..blank()
    ..line('## How a device becomes push-addressable')
    ..blank()
    ..line(
      'Four links, none of which is a push setting the user can find. The chain '
      'breaks silently at any step.',
    )
    ..blank()
    ..line('```mermaid')
    ..line('flowchart TD')
    ..line('    A["main() calls initPushNotifications()"] --> B')
    ..line('    B["SDK initialised — deliberately no permission prompt"] --> C')
    ..line('    C{"OS notification permission granted?"}')
    ..line('    C -- "only ever asked by the reminders flow" --> D')
    ..line('    C -- "never asked" --> X["Device is never addressable"]')
    ..line('    D["_nudgeOneSignalRegister() — no second dialog"] --> E')
    ..line('    E["Push subscription observer fires with a token"] --> F')
    ..line('    F{"Does an identity exist?"}')
    ..line(
      '    F -- no --> Y["Registration skipped; retried when identity arrives"]',
    )
    ..line('    F -- yes --> G["POST /api/push/register"]')
    ..line('    Y -.-> G')
    ..line('    G --> H["external_id = profileId, else trackingId"]')
    ..line('```')
    ..blank()
    ..line('| Link | Where | Note |')
    ..line('| --- | --- | --- |')
    ..line(
      '| SDK init | `initPushNotifications` in '
      '[push_notifications_service.dart](../../lib/services/push_notifications_service.dart) '
      '| No-ops entirely when `ONESIGNAL_APP_ID` is unset. |',
    )
    ..line(
      '| Permission | `ensureNotificationPermission` in '
      '[reminders_notifications.dart](../../lib/services/reminders_notifications.dart) '
      '| The single OS permission is shared with local reminders. Reminders own '
      'it; push borrows it. |',
    )
    ..line(
      '| Token | `_nudgeOneSignalRegister` | Calls '
      '`OneSignal.Notifications.requestPermission(false)`. Because the OS '
      'permission is already granted this shows no dialog — it just opts the '
      'subscription in. |',
    )
    ..line(
      '| Registration | `_registerPushWithServer` | Returns early with no '
      r'identity. De-duped on `subscriptionId\|externalId`, so it re-fires '
      'when the external id changes. |',
    )
    ..blank()
    ..line(
      'The external id is `profileId` when there is one and `trackingId` '
      'otherwise, so **signing up changes a device\'s push identity** — '
      '`OneSignal.login()` is called again and the server row is re-registered. '
      'Both ids are also written as tags so the switch is traceable if it races.',
    )
    ..blank()
    ..line('## Entry points that ask for notification permission')
    ..blank()
    ..line(
      'All of these reach the same helper, and all of them therefore also enable '
      'push:',
    )
    ..blank();

  for (final entry in permissionEntryPointAnchors) {
    b.line('- `${entry.symbol}` in [${entry.file}](${_up(entry.file)})');
  }
  return b.toString();
}

/// Places the OS notification permission is requested from. Public so
/// gen_architecture.dart can validate them like any
/// other anchor.
const permissionEntryPointAnchors = <Anchor>[
  Anchor(
    'lib/components/wizard/wizard_step_reminder.dart',
    'ensureNotificationPermission',
  ),
  Anchor(
    'lib/components/reminders/reminder_editor.dart',
    'ensureNotificationPermission',
  ),
  Anchor('lib/screens/reminders_screen.dart', 'promptEnableNotifications'),
  Anchor(
    'lib/screens/notification_permission_settings_screen.dart',
    'promptEnableNotifications',
  ),
  Anchor(
    'lib/components/notifications/enable_notifications_prompt.dart',
    'promptEnableNotifications',
  ),
  Anchor(
    'lib/components/widgets/news_signup_success.dart',
    'EnableNotificationsPrompt',
  ),
];

// ---------------------------------------------------------------------------
// data-layer.md
// ---------------------------------------------------------------------------

String _renderDataLayer(Facts facts) {
  final b = _Buf()
    ..line(_generatedBanner)
    ..blank()
    ..line('# Data layer inventory')
    ..blank()
    ..line(
      'Every table here is scanned out of `lib/`. If something is missing from '
      'it, it is missing from the code.',
    )
    ..blank()
    ..line('## Endpoints')
    ..blank()
    ..line(
      'All requests are built through `ApiConfig.buildUri`, which resolves '
      'the host from `--dart-define`, then `.env`, then the build flavour.',
    )
    ..blank()
    ..line('| Method | Path | Cached | TTL | Bg refresh | Built in |')
    ..line('| --- | --- | --- | --- | --- | --- |');

  for (final e in facts.endpoints) {
    final sites = e.sites.map((s) => '`${s.short}`').join('<br>');
    b.line(
      '| ${e.method} | `${e.path}` | ${e.isCached ? 'yes' : '—'} '
      '| ${_policyLabel(facts, e.ttlPolicy)} '
      '| ${_policyLabel(facts, e.refreshPolicy)} | $sites |',
    );
  }

  b
    ..blank()
    ..line(
      '`LINK` rows are URIs built for sharing or opening in a browser — they are '
      'never requested by the app.',
    )
    ..blank()
    ..line('## Which action touches which endpoint')
    ..blank()
    ..line(
      'The reverse index: change an endpoint, and these are the actions to '
      'retest.',
    )
    ..blank()
    ..line('| Endpoint | Actions |')
    ..line('| --- | --- |');

  for (final e in facts.endpoints.where((e) => e.isRequest)) {
    final users = actions
        .where((a) => a.steps.any((s) => s.endpoint == e.id))
        .map((a) => a.title)
        .toList();
    b.line(
      '| `${e.id}` | ${users.isEmpty ? '_not in the catalogue_' : users.join('; ')} |',
    );
  }

  b
    ..blank()
    ..line('## Cache policy')
    ..blank()
    ..line(
      'Every entry is a *soft* expiry: past it the app refetches, but a failed '
      'refetch still falls back to the expired copy, so an offline user keeps '
      'seeing what they last loaded.',
    )
    ..blank()
    ..line('| Field | Duration | Covers |')
    ..line('| --- | --- | --- |');
  for (final c in facts.cachePolicies) {
    b.line('| `${c.name}` | ${c.duration} | ${c.doc} |');
  }

  b
    ..blank()
    ..line('## Cache keys')
    ..blank()
    ..line('| Endpoint | Key expression |')
    ..line('| --- | --- |');
  for (final e in facts.endpoints.where((e) => e.isCached)) {
    b.line('| `${e.id}` | `${e.cacheKeyExpr ?? '?'}` |');
  }

  b
    ..blank()
    ..line(
      'Language is part of every content cache key, which is why switching '
      'language invalidates the content caches in effect.',
    )
    ..blank()
    ..line('## Persisted keys (SharedPreferences)')
    ..blank()
    ..line('| Key | Constant | Declared in | Written by |')
    ..line('| --- | --- | --- | --- |');
  for (final k in facts.prefsKeys) {
    final writers = actions
        .where(
          (a) => a.steps.any((s) => (s.writes ?? const []).contains(k.value)),
        )
        .map((a) => a.title)
        .toList();
    b.line(
      '| `${k.value}` | `${k.constName}` | '
      '[${k.file.split('/').last}:${k.line}](${_up(k.file)}#L${k.line}) | '
      '${writers.isEmpty ? '—' : writers.join('; ')} |',
    );
  }

  b
    ..blank()
    ..line(
      'Cached API responses are not in SharedPreferences — they are files under '
      'the response cache directory, swept at launch past '
      '`CachePolicy.maxResponseAge`.',
    )
    ..blank()
    ..line('## Routes')
    ..blank()
    ..line('| Name | Path |')
    ..line('| --- | --- |');
  for (final r in facts.routes) {
    b.line('| `${r.name}` | `${r.path}` |');
  }
  return b.toString();
}

String _policyLabel(Facts facts, String? name) {
  if (name == null) return '—';
  for (final c in facts.cachePolicies) {
    if (c.name == name) return '${c.duration} (`$name`)';
  }
  return '`$name`';
}

// ---------------------------------------------------------------------------
// helpers
// ---------------------------------------------------------------------------

/// Strips markup mermaid will not render and characters that break its parser.
String _label(String text) => text
    .replaceAll('**', '')
    .replaceAll('`', '')
    .replaceAll(';', ',')
    .replaceAll('<', '⟨')
    .replaceAll('>', '⟩')
    .replaceAll('#', 'no.')
    .replaceAll('"', "'")
    .replaceAll(RegExp(r'\s+'), ' ')
    .trim();

/// Docs live two directories below the repo root.
String _up(String repoRelative) => '../../$repoRelative';

String _slug(String title) => title
    .toLowerCase()
    .replaceAll(RegExp(r'[^a-z0-9 -]'), '')
    .replaceAll(' ', '-');

class _Buf {
  final _lines = <String>[];

  void line(String text) => _lines.add(text);
  void blank() => _lines.add('');

  @override
  String toString() {
    final body = _lines.join('\n');
    return body.endsWith('\n') ? body : '$body\n';
  }
}
