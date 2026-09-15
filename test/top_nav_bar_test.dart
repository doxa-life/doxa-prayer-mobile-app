import 'package:doxa_prayer_mobile_app/components/nav/top_nav_bar.dart';
import 'package:doxa_prayer_mobile_app/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Future<void> _pump(
  WidgetTester tester, {
  Widget? trailing,
  bool withDebug = true,
}) async {
  await tester.pumpWidget(
    MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Builder(
        builder: (context) => Scaffold(
          appBar: TopNavBar(
            context: context,
            onSettings: () {},
            onDebug: withDebug ? () {} : null,
            trailing: trailing,
          ),
          body: const SizedBox.shrink(),
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('the debug button sits in the leading slot, opposite settings', (
    tester,
  ) async {
    await _pump(tester);

    final debug = tester.getCenter(find.byIcon(Icons.bug_report_outlined));
    final settings = tester.getCenter(find.byTooltip('Settings'));
    expect(debug.dx, lessThan(settings.dx));
    // Leading means the far side of the bar, not merely left of settings.
    expect(debug.dx, lessThan(tester.getSize(find.byType(AppBar)).width / 2));
  });

  testWidgets('the Kitchen Sink button is gone', (tester) async {
    await _pump(tester);
    expect(find.byIcon(Icons.widgets_outlined), findsNothing);
    expect(find.byTooltip('Kitchen Sink'), findsNothing);
  });

  testWidgets('a trailing action renders ahead of settings', (tester) async {
    await _pump(tester, trailing: const Icon(Icons.circle, key: Key('avatar')));

    final avatar = tester.getCenter(find.byKey(const Key('avatar')));
    final settings = tester.getCenter(find.byTooltip('Settings'));
    expect(avatar.dx, lessThan(settings.dx));
  });

  testWidgets('no trailing action means no empty slot', (tester) async {
    await _pump(tester);
    expect(find.byKey(const Key('avatar')), findsNothing);
  });
}
