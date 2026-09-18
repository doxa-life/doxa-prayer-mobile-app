import 'package:doxa_prayer_mobile_app/components/prayer_content/praying_now_banner.dart';
import 'package:doxa_prayer_mobile_app/l10n/app_localizations.dart';
import 'package:doxa_prayer_mobile_app/services/prayer_stats_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Widget _host() => MaterialApp(
  localizationsDelegates: AppLocalizations.localizationsDelegates,
  supportedLocales: AppLocalizations.supportedLocales,
  home: const Scaffold(body: PrayingNowBanner()),
);

void main() {
  tearDown(() => prayingNowController.value = null);

  testWidgets('hidden before any fetch and at zero', (tester) async {
    prayingNowController.value = null;
    await tester.pumpWidget(_host());
    await tester.pumpAndSettle();
    expect(find.byType(Text), findsNothing);

    prayingNowController.value = 0;
    await tester.pumpAndSettle();
    expect(find.byType(Text), findsNothing);
  });

  testWidgets('updates in place when the count changes', (tester) async {
    prayingNowController.value = 1;
    await tester.pumpWidget(_host());
    await tester.pumpAndSettle();
    expect(find.text('1 person praying with you now'), findsOneWidget);

    // This is what used to be impossible: a new value with no remount.
    prayingNowController.value = 9;
    await tester.pumpAndSettle();
    expect(find.text('9 people praying with you now'), findsOneWidget);
    expect(find.text('1 person praying with you now'), findsNothing);

    prayingNowController.value = 0;
    await tester.pumpAndSettle();
    expect(find.byType(Text), findsNothing);
  });
}
