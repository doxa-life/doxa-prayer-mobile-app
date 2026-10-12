import 'package:doxa_prayer_mobile_app/components/buttons/action_button.dart';
import 'package:doxa_prayer_mobile_app/components/wizard/wizard_step_group_intro.dart';
import 'package:doxa_prayer_mobile_app/components/wizard/wizard_step_group_picked.dart';
import 'package:doxa_prayer_mobile_app/models/people_group.dart';
import 'package:doxa_prayer_mobile_app/services/people_groups_service.dart';
import 'package:doxa_prayer_mobile_app/services/response_cache.dart';
import 'package:doxa_prayer_mobile_app/services/wizard_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_test/flutter_test.dart';

import 'helpers/pump_at_scale.dart';

// The group intro and group-picked steps must fit on one screen with every
// button in view, never needing a scroll — checked on an iPhone SE's step
// area (screen minus safe area, back arrow and progress dots), at normal and
// doubled text.
void main() {
  setUpAll(() => dotenv.testLoad());
  setUp(clearMemoryCache);
  tearDown(clearMemoryCache);

  const seStepArea = Size(375, 558);

  for (final picked in [false, true]) {
    for (final scale in [1.0, 2.0]) {
      final name = picked ? 'group picked' : 'group intro';
      testWidgets('$name keeps its buttons on screen at ${scale}x', (
        tester,
      ) async {
        seedMemoryCache(peopleGroupListCacheKey('en'), [
          const PeopleGroup(
            name: 'Uncontacted of Rio Liberdade',
            slug: 'uncontacted-of-rio-liberdade',
            imageUrl: null,
            countryLabel: 'Brazil',
            countryCode: 'BRA',
            religionLabel: 'Ethnoreligion - Animism',
            primaryLanguageLabel: 'Unknown',
            population: 25,
            peoplePraying: 0,
            peopleCommitted: 0,
          ),
        ]);
        final controller = WizardController();
        addTearDown(controller.dispose);
        controller.next();
        if (picked) await controller.skipPeopleGroup();

        await pumpAtScale(
          tester,
          picked
              ? WizardStepGroupPicked(controller: controller)
              : WizardStepGroupIntro(controller: controller),
          scale: scale,
          viewport: seStepArea,
        );
        // Not pumpAndSettle: the hidden spinner keeps animating.
        await tester.pump(const Duration(seconds: 2));

        expect(tester.takeException(), isNull);
        expect(find.byType(Scrollable), findsNothing);
        final buttons = find.byType(ActionButton);
        expect(buttons, findsNWidgets(2));
        for (final button in buttons.evaluate()) {
          final rect = tester.getRect(find.byWidget(button.widget));
          expect(rect.bottom, lessThanOrEqualTo(seStepArea.height));
        }
      });
    }
  }
}
