import 'package:doxa_prayer_mobile_app/models/people_group.dart';
import 'package:doxa_prayer_mobile_app/services/people_groups_service.dart';
import 'package:doxa_prayer_mobile_app/services/response_cache.dart';
import 'package:doxa_prayer_mobile_app/services/wizard_controller.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences_platform_interface/in_memory_shared_preferences_async.dart';
import 'package:shared_preferences_platform_interface/shared_preferences_async_platform_interface.dart';

PeopleGroup _g(String slug, {required int praying, int? resources}) =>
    PeopleGroup(
      name: slug,
      slug: slug,
      imageUrl: null,
      countryLabel: null,
      religionLabel: null,
      peoplePraying: 0,
      peopleCommitted: praying,
      resourcesAvailable: resources,
      population: 100,
    );

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(() => dotenv.testLoad());
  setUp(() {
    clearMemoryCache();
    // Following a group persists it; keep that in memory.
    SharedPreferencesAsyncPlatform.instance =
        InMemorySharedPreferencesAsync.empty();
  });
  tearDown(clearMemoryCache);

  test('picks from the cached list, then walks down the ranking', () async {
    // Out of order on purpose: the pick must rank the whole cached list.
    seedMemoryCache(peopleGroupListCacheKey('en'), [
      _g('many-praying', praying: 9, resources: 0),
      _g('none-praying-more-resources', praying: 0, resources: 5),
      _g('none-praying-fewest-resources', praying: 0, resources: 1),
    ]);
    final controller = WizardController();
    addTearDown(controller.dispose);
    controller.next(); // welcome -> group intro
    expect(controller.step, WizardStep.groupIntro);

    await controller.skipPeopleGroup();
    expect(controller.step, WizardStep.groupPicked);
    expect(controller.pickedGroup?.slug, 'none-praying-fewest-resources');

    await controller.rerollPickedGroup();
    expect(controller.pickedGroup?.slug, 'none-praying-more-resources');

    await controller.rerollPickedGroup();
    expect(controller.pickedGroup?.slug, 'many-praying');

    // Every group offered: starts again from the top.
    await controller.rerollPickedGroup();
    expect(controller.pickedGroup?.slug, 'none-praying-fewest-resources');

    controller.back();
    expect(controller.step, WizardStep.groupIntro);
  });

  test('going back after Continue keeps the chosen group', () async {
    seedMemoryCache(peopleGroupListCacheKey('en'), [
      _g('first', praying: 0, resources: 0),
      _g('second', praying: 0, resources: 1),
    ]);
    final controller = WizardController();
    addTearDown(controller.dispose);
    controller.next(); // -> group intro
    await controller.skipPeopleGroup();
    await controller.rerollPickedGroup();
    expect(controller.pickedGroup?.slug, 'second');

    await controller.continueWithPickedGroup();
    expect(controller.step, WizardStep.reminder);

    controller.back();
    expect(controller.step, WizardStep.groupPicked);
    expect(controller.pickedGroup?.slug, 'second');

    // All the way back to the intro and "Pick a group for me" again: still
    // the group they continued with, not a fresh top-ranked pick.
    controller.back();
    expect(controller.step, WizardStep.groupIntro);
    await controller.skipPeopleGroup();
    expect(controller.step, WizardStep.groupPicked);
    expect(controller.pickedGroup?.slug, 'second');
  });
}
