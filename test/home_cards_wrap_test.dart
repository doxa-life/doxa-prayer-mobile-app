import 'package:doxa_prayer_mobile_app/components/cards/get_involved_card.dart';
import 'package:doxa_prayer_mobile_app/components/cards/people_group_card.dart';
import 'package:doxa_prayer_mobile_app/components/cards/people_group_list_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'helpers/pump_at_scale.dart';

// The cards embed action rows that overflowed as a fixed Row at large font
// scales; they now use a Wrap. These tests guard against regressions by
// asserting no RenderFlex overflow at 3x on a narrow phone.
void main() {
  const narrow = Size(320, 690);

  testWidgets('PeopleGroupCard action buttons wrap without overflow at 3x', (
    tester,
  ) async {
    await pumpAtScale(
      tester,
      const SingleChildScrollView(
        child: PeopleGroupCard(
          name: 'Kurds',
          imageUrl: null, // Placeholder, so no network image is loaded.
          onDetails: _noop,
          onShare: _noop,
          onShowQr: _noop,
        ),
      ),
      scale: 3.0,
      viewport: narrow,
    );

    expect(tester.takeException(), isNull);
    expect(find.byType(Wrap), findsOneWidget);
  });

  testWidgets('GetInvolvedCard buttons wrap without overflow at 3x', (
    tester,
  ) async {
    await pumpAtScale(
      tester,
      const SingleChildScrollView(
        child: GetInvolvedCard(onDonate: _noop, onFeedback: _noop),
      ),
      scale: 3.0,
      viewport: narrow,
    );

    expect(tester.takeException(), isNull);
    expect(find.byType(Wrap), findsOneWidget);
  });

  testWidgets('PeopleGroupListCard profile/select wrap without overflow at 3x', (
    tester,
  ) async {
    await pumpAtScale(
      tester,
      const SingleChildScrollView(
        child: PeopleGroupListCard(
          name: 'A very long people group name that pushes the layout',
          imageUrl: null,
          onSelect: _noop,
          onDetails: _noop,
        ),
      ),
      scale: 3.0,
      viewport: narrow,
    );

    expect(tester.takeException(), isNull);
    expect(find.byType(Wrap), findsOneWidget);
  });
}

void _noop() {}
