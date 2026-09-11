import 'dart:developer' as developer;

import 'package:http/http.dart' as http;

import 'api_config.dart';
import 'identity_service.dart';
import 'subscribed_people_groups_controller.dart';

/// Tells the server the user has stopped praying for [group].
///
/// Always names the exact subscription via `sid`. The endpoint also accepts
/// `all=true`, which would unsubscribe *every* subscription this person has for
/// the group — including any email reminders they signed up for on the web,
/// which stopping in the app must not touch.
///
/// Needs a `profile_id`, which only exists once anon-signup has landed. Without
/// one there is nothing on the server to unsubscribe from yet, so this logs and
/// returns rather than failing the removal the user just confirmed.
Future<void> submitUnsubscribe(SubscribedPeopleGroup group) async {
  final profileId = identityController.value?.profileId;
  if (profileId == null || profileId.isEmpty) {
    developer.log(
      'skipping unsubscribe for ${group.slug}: no profile id yet',
      name: 'unsubscribe_service',
    );
    return;
  }
  final subscriptionId = group.subscriptionId;
  if (subscriptionId == null) {
    developer.log(
      'skipping unsubscribe for ${group.slug}: no subscription id',
      name: 'unsubscribe_service',
    );
    return;
  }

  final slug = group.slug;
  final uri = ApiConfig.buildUri('/api/people-groups/$slug/unsubscribe')
      .replace(
        queryParameters: {'id': profileId, 'sid': subscriptionId.toString()},
      );

  developer.log('POST unsubscribe\nURL: $uri', name: 'unsubscribe_service');
  final response = await http.post(uri);
  // 404 means the server already has no active subscription for this group —
  // the user's intent is satisfied, so it is not an error worth surfacing.
  if (response.statusCode != 200 && response.statusCode != 404) {
    throw Exception('unsubscribe failed (${response.statusCode})');
  }
}
