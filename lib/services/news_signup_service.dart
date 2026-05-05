import 'package:flutter/foundation.dart';

import '../components/widgets/news_signup.dart';

// TODO: wire to pray.doxa.life endpoint when one is defined.
Future<void> submitNewsSignup(NewsSignupData data) async {
  debugPrint(
    'news_signup_service stub: '
    'name=${data.name} email=${data.email} '
    'pg=${data.wantsPeopleGroupUpdates} doxa=${data.wantsDoxaUpdates}',
  );
  await Future<void>.delayed(const Duration(milliseconds: 300));
}
