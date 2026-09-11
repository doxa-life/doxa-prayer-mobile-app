import 'package:doxa_prayer_mobile_app/services/subscribed_people_groups_controller.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shared_preferences_platform_interface/in_memory_shared_preferences_async.dart';
import 'package:shared_preferences_platform_interface/shared_preferences_async_platform_interface.dart';

SubscribedPeopleGroup _group(String slug) =>
    SubscribedPeopleGroup(slug: slug, name: slug.toUpperCase());

Future<void> _reset([Map<String, Object> initial = const {}]) async {
  // The controller uses SharedPreferencesAsync, which setMockInitialValues
  // does not reach — it only backs the legacy synchronous API.
  SharedPreferencesAsyncPlatform.instance =
      InMemorySharedPreferencesAsync.withData(Map<String, Object>.of(initial));
  peopleGroupsController.value = SubscribedPeopleGroups.empty;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('migration from the single selection', () {
    test('the one selected group becomes the first subscription', () async {
      await _reset({
        'selected_people_group_slug': 'kurds',
        'selected_people_group_name': 'Kurds',
        'selected_people_group_image_url': 'https://example.test/kurds.jpg',
        'identity_subscription_id': 42,
      });

      await loadPeopleGroups();

      final groups = peopleGroupsController.value;
      expect(groups.list, hasLength(1));
      expect(groups.list.single.slug, 'kurds');
      expect(groups.list.single.name, 'Kurds');
      expect(groups.list.single.imageUrl, 'https://example.test/kurds.jpg');
      // Carried over so a later unsubscribe can name the existing server row.
      expect(groups.list.single.subscriptionId, 42);
      expect(groups.active?.slug, 'kurds');
    });

    test('the legacy keys are cleared so it cannot run twice', () async {
      await _reset({
        'selected_people_group_slug': 'kurds',
        'selected_people_group_name': 'Kurds',
      });
      await loadPeopleGroups();

      final prefs = SharedPreferencesAsync();
      expect(await prefs.getString('selected_people_group_slug'), isNull);
      expect(await prefs.getString('selected_people_group_name'), isNull);

      // A second load reads the new key and leaves the list as it was.
      await loadPeopleGroups();
      expect(peopleGroupsController.value.list, hasLength(1));
    });

    test('no previous selection leaves an empty list', () async {
      await _reset();
      await loadPeopleGroups();
      expect(peopleGroupsController.value.isEmpty, isTrue);
    });

    test('a corrupt blob is discarded rather than thrown', () async {
      await _reset({'people_group_subscriptions': 'not json'});
      await loadPeopleGroups();
      expect(peopleGroupsController.value.isEmpty, isTrue);
    });
  });

  group('adding and removing', () {
    setUp(() => _reset());

    test('added groups keep the order they were added in', () async {
      await addPeopleGroup(_group('kurds'));
      await addPeopleGroup(_group('fulani'));
      await addPeopleGroup(_group('somali'));

      expect(peopleGroupsController.value.list.map((g) => g.slug), [
        'kurds',
        'fulani',
        'somali',
      ]);
    });

    test('adding makes the new group active', () async {
      await addPeopleGroup(_group('kurds'));
      await addPeopleGroup(_group('fulani'));
      expect(peopleGroupsController.value.active?.slug, 'fulani');
    });

    test('the same group cannot be added twice', () async {
      expect(await addPeopleGroup(_group('kurds')), isTrue);
      expect(await addPeopleGroup(_group('kurds')), isFalse);
      expect(peopleGroupsController.value.list, hasLength(1));
    });

    test('the cap is refused rather than silently dropping a group', () async {
      for (var i = 0; i < kMaxPeopleGroups; i++) {
        expect(await addPeopleGroup(_group('group-$i')), isTrue);
      }
      expect(peopleGroupsController.value.isFull, isTrue);
      expect(await addPeopleGroup(_group('one-too-many')), isFalse);
      expect(peopleGroupsController.value.list, hasLength(kMaxPeopleGroups));
      expect(peopleGroupsController.value.contains('one-too-many'), isFalse);
    });

    test('removing the active group falls back to the first left', () async {
      await addPeopleGroup(_group('kurds'));
      await addPeopleGroup(_group('fulani'));
      expect(peopleGroupsController.value.active?.slug, 'fulani');

      await removePeopleGroup('fulani');

      expect(peopleGroupsController.value.active?.slug, 'kurds');
    });

    test('removing a non-active group leaves the active one alone', () async {
      await addPeopleGroup(_group('kurds'));
      await addPeopleGroup(_group('fulani'));
      await removePeopleGroup('kurds');
      expect(peopleGroupsController.value.active?.slug, 'fulani');
    });

    test('removing the last group leaves no active group', () async {
      await addPeopleGroup(_group('kurds'));
      await removePeopleGroup('kurds');
      expect(peopleGroupsController.value.isEmpty, isTrue);
      expect(peopleGroupsController.value.active, isNull);
    });

    test('the subscription id is stored against its group', () async {
      await addPeopleGroup(_group('kurds'));
      await addPeopleGroup(_group('fulani'));
      await setPeopleGroupSubscriptionId('fulani', 7);

      expect(peopleGroupsController.value.bySlug('fulani')?.subscriptionId, 7);
      expect(
        peopleGroupsController.value.bySlug('kurds')?.subscriptionId,
        isNull,
      );
    });

    test('everything survives a reload', () async {
      await addPeopleGroup(_group('kurds'));
      await addPeopleGroup(_group('fulani'));
      await setPeopleGroupSubscriptionId('kurds', 3);
      await setActivePeopleGroup('kurds');

      peopleGroupsController.value = SubscribedPeopleGroups.empty;
      await loadPeopleGroups();

      final groups = peopleGroupsController.value;
      expect(groups.list.map((g) => g.slug), ['kurds', 'fulani']);
      expect(groups.bySlug('kurds')?.subscriptionId, 3);
      expect(groups.activeSlug, 'kurds');
    });
  });
}
