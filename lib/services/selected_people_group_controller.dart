import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SelectedPeopleGroup {
  const SelectedPeopleGroup({required this.slug, required this.name});

  final String slug;
  final String name;
}

const _slugKey = 'selected_people_group_slug';
const _nameKey = 'selected_people_group_name';

final ValueNotifier<SelectedPeopleGroup?> selectedPeopleGroupController =
    ValueNotifier<SelectedPeopleGroup?>(null);

Future<void> loadSelectedPeopleGroup() async {
  final prefs = await SharedPreferences.getInstance();
  final slug = prefs.getString(_slugKey);
  final name = prefs.getString(_nameKey);
  if (slug != null && name != null) {
    selectedPeopleGroupController.value =
        SelectedPeopleGroup(slug: slug, name: name);
  }
}

Future<void> setSelectedPeopleGroup(SelectedPeopleGroup group) async {
  selectedPeopleGroupController.value = group;
  final prefs = await SharedPreferences.getInstance();
  await prefs.setString(_slugKey, group.slug);
  await prefs.setString(_nameKey, group.name);
}
