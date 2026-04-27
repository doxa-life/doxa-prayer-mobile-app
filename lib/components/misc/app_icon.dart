import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

enum AppIconName {
  home('home.svg'),
  homeSolid('home-solid.svg'),
  pray('pray.svg'),
  praySolid('pray-solid.svg'),
  bell('bell.svg'),
  bellSolid('bell-solid.svg'),
  person('person.svg'),
  peopleGroup('people-group.svg'),
  peopleGroupSolid('people-group-solid.svg'),
  search('search.svg'),
  searchSolid('search-solid.svg'),
  gear('gear.svg'),
  share('share-fill.svg'),
  linkOut('link-out.svg'),
  link('link-45deg.svg'),
  calendar('calendar-week.svg'),
  fullscreen('arrows-fullscreen.svg'),
  download('download.svg'),
  trash('trash-can.svg'),
  sun('sun-2.svg');

  const AppIconName(this.fileName);
  final String fileName;

  String get assetPath => 'assets/icons/$fileName';
}

class AppIcon extends StatelessWidget {
  const AppIcon(this.name, {super.key, this.size = 24, this.color});

  final AppIconName name;
  final double size;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final tint =
        color ?? IconTheme.of(context).color ?? const Color(0xFF000000);
    return SvgPicture.asset(
      name.assetPath,
      width: size,
      height: size,
      colorFilter: ColorFilter.mode(tint, BlendMode.srcIn),
    );
  }
}
