import 'package:flutter/foundation.dart';

enum AppTab { home, pray, peopleGroups, reminders }

final ValueNotifier<AppTab> selectedTabController = ValueNotifier<AppTab>(
  AppTab.home,
);
