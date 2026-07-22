import 'package:doxa_prayer_mobile_app/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Pumps [body] inside a localized MaterialApp + Scaffold with the text scale
/// forced to [scale], on a phone-sized [viewport] (logical pixels, dpr 1.0).
///
/// Used by the accessibility tests that assert screens stay usable (no
/// overflow, buttons reachable) at large OS font sizes.
Future<void> pumpAtScale(
  WidgetTester tester,
  Widget body, {
  double scale = 2.0,
  Size viewport = const Size(360, 690),
  bool resizeToAvoidBottomInset = true,
}) async {
  tester.view.physicalSize = viewport;
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(
    MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      builder: (context, child) => MediaQuery(
        data: MediaQuery.of(
          context,
        ).copyWith(textScaler: TextScaler.linear(scale)),
        child: child!,
      ),
      home: Scaffold(
        resizeToAvoidBottomInset: resizeToAvoidBottomInset,
        body: body,
      ),
    ),
  );
}
