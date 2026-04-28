import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SelectedPeopleGroup {
  const SelectedPeopleGroup({
    required this.slug,
    required this.name,
    required this.imageUrl,
  });

  final String slug;
  final String name;
  final String? imageUrl;
}

const _slugKey = 'selected_people_group_slug';
const _nameKey = 'selected_people_group_name';
const _imageUrlKey = 'selected_people_group_image_url';

final ValueNotifier<SelectedPeopleGroup?> selectedPeopleGroupController =
    ValueNotifier<SelectedPeopleGroup?>(null);

Future<void> loadSelectedPeopleGroup() async {
  final prefs = SharedPreferencesAsync();
  final slug = await prefs.getString(_slugKey);
  final name = await prefs.getString(_nameKey);
  final imageUrl = await prefs.getString(_imageUrlKey);
  if (slug != null && name != null && imageUrl != null) {
    selectedPeopleGroupController.value = SelectedPeopleGroup(
      slug: slug,
      name: name,
      imageUrl: imageUrl,
    );
  }
}

Future<void> setSelectedPeopleGroup(SelectedPeopleGroup group) async {
  selectedPeopleGroupController.value = group;
  final prefs = SharedPreferencesAsync();
  await prefs.setString(_slugKey, group.slug);
  await prefs.setString(_nameKey, group.name);
  if (group.imageUrl != null) {
    await prefs.setString(_imageUrlKey, group.imageUrl!);
  }
}
