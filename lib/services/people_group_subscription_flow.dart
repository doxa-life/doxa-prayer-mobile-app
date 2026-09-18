import 'dart:developer' as developer;

import 'package:flutter/material.dart';

import '../components/buttons/action_button.dart';
import '../components/misc/action_modal.dart';
import '../components/misc/remove_people_group_modal.dart';
import '../components/misc/swap_people_group_modal.dart';
import '../l10n/app_localizations.dart';
import 'anon_signup_service.dart';
import 'crash_reporting_service.dart';
import 'reminders_controller.dart';
import 'subscribed_people_groups_controller.dart';
import 'unsubscribe_service.dart';

/// Subscribes the user to a people group, asking first. At the cap this opens
/// the swap modal instead, so every route into a new subscription — the browse
/// list, a group's details page, an `/app/<slug>` share link — goes through the
/// same confirmation and the same limit.
///
/// Returns true when the user is subscribed to [slug] by the time it finishes.
Future<bool> addPeopleGroupFlow(
  BuildContext context, {
  required String slug,
  required String name,
  required String? imageUrl,
}) async {
  final l10n = AppLocalizations.of(context)!;
  final current = peopleGroupsController.value;
  if (current.contains(slug)) return false;

  if (current.isFull) {
    final dropped = await showSwapPeopleGroupModal(context, incomingName: name);
    if (dropped == null) return false;
    await _removePeopleGroup(dropped);
  } else {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => ActionModal(
        message: l10n.addPeopleGroupConfirm(name),
        actionButtons: [
          ActionButton(
            label: l10n.no,
            onPressed: () => Navigator.of(ctx).pop(false),
            color: ActionButtonColor.white,
          ),
          ActionButton(
            label: l10n.yes,
            onPressed: () => Navigator.of(ctx).pop(true),
            color: ActionButtonColor.secondaryLight,
            isOutlined: true,
          ),
        ],
      ),
    );
    if (confirmed != true) return false;
  }

  final added = await addPeopleGroup(
    SubscribedPeopleGroup(slug: slug, name: name, imageUrl: imageUrl),
  );
  if (!added) return false;

  // Register the commitment server-side. Fire-and-forget: the subscription is
  // already the user's locally, and the deferred listener retries groups that
  // never got a subscription id.
  submitAnonSignup(slug: slug).catchError((Object e, StackTrace s) {
    developer.log(
      'anon-signup failed for $slug',
      name: 'people_group_subscription_flow',
      error: e,
      stackTrace: s,
    );
    reportError(e, s, reason: 'anon-signup failed');
  });
  return true;
}

/// Stops praying for a people group, after confirming and naming the reminders
/// that go with it. Returns true when the user went through with it.
Future<bool> removePeopleGroupFlow(
  BuildContext context, {
  required String slug,
}) async {
  final group = peopleGroupsController.value.bySlug(slug);
  if (group == null) return false;

  final confirmed = await showRemovePeopleGroupModal(
    context,
    name: group.name,
    reminderCount: remindersController.value?.forGroup(slug).length ?? 0,
  );
  if (!confirmed) return false;

  await _removePeopleGroup(slug);
  return true;
}

/// The cascade, shared by an outright removal and by a swap: drop the group's
/// reminders (which reschedules notifications), forget the subscription, and
/// tell the server. Reminders go first so a failure leaves the user with a
/// group they can still see rather than alarms for one they cannot.
Future<void> _removePeopleGroup(String slug) async {
  final group = peopleGroupsController.value.bySlug(slug);
  if (group == null) return;
  await deleteRemindersForGroup(slug);
  await removePeopleGroup(slug);
  submitUnsubscribe(group).catchError((Object e, StackTrace s) {
    developer.log(
      'unsubscribe failed for $slug',
      name: 'people_group_subscription_flow',
      error: e,
      stackTrace: s,
    );
    // Non-fatal for the user, but it leaves them counted as praying on the
    // server, so it is worth reporting.
    reportError(e, s, reason: 'unsubscribe failed');
  });
}
