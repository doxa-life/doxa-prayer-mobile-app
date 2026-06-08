import 'package:doxa_prayer_mobile_app/components/misc/update_gate.dart';
import 'package:doxa_prayer_mobile_app/l10n/app_localizations.dart';
import 'package:doxa_prayer_mobile_app/services/update_controller.dart';
import 'package:doxa_prayer_mobile_app/services/version_check_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

const _info = AppVersionInfo(
  latestVersion: '1.2.0',
  minSupportedVersion: '1.1.0',
  iosAppStoreUrl: 'https://apps.apple.com/app/id1',
  androidPlayUrl:
      'https://play.google.com/store/apps/details?id=app.prayer.doxa',
);

Widget _wrap() => MaterialApp(
  localizationsDelegates: AppLocalizations.localizationsDelegates,
  supportedLocales: AppLocalizations.supportedLocales,
  home: const UpdateGate(child: Scaffold(body: Text('home content'))),
);

void main() {
  tearDown(() => updateController.value = UpdateStatus.none);

  testWidgets('state none → no banner, content visible', (tester) async {
    updateController.value = UpdateStatus.none;
    await tester.pumpWidget(_wrap());
    await tester.pumpAndSettle();

    expect(find.text('home content'), findsOneWidget);
    expect(find.text('Update available'), findsNothing);
    expect(find.text('Update required'), findsNothing);
  });

  testWidgets('optional → dismissible banner over the content', (tester) async {
    updateController.value = const UpdateStatus(UpdateState.optional, _info);
    await tester.pumpWidget(_wrap());
    await tester.pumpAndSettle();

    expect(find.text('Update available'), findsOneWidget);
    expect(find.text('UPDATE'), findsOneWidget); // action button (uppercase)
    expect(find.text('Not now'), findsOneWidget); // dismiss button (uppercase)
    expect(find.text('home content'), findsOneWidget); // app still behind it
  });

  testWidgets('forced → blocking modal, no dismiss', (tester) async {
    updateController.value = const UpdateStatus(UpdateState.forced, _info);
    await tester.pumpWidget(_wrap());
    await tester.pumpAndSettle();

    expect(find.text('Update required'), findsOneWidget);
    expect(find.text('UPDATE'), findsOneWidget);
    expect(find.text('Not now'), findsNothing); // cannot be dismissed
    expect(find.byType(ModalBarrier), findsWidgets); // blocking barrier present
  });

  testWidgets('switching state none → optional → none toggles the banner', (
    tester,
  ) async {
    updateController.value = UpdateStatus.none;
    await tester.pumpWidget(_wrap());
    await tester.pumpAndSettle();
    expect(find.text('Update available'), findsNothing);

    updateController.value = const UpdateStatus(UpdateState.optional, _info);
    await tester.pumpAndSettle();
    expect(find.text('Update available'), findsOneWidget);

    updateController.value = UpdateStatus.none;
    await tester.pumpAndSettle();
    expect(find.text('Update available'), findsNothing);
  });
}
