// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Arrowchime';

  @override
  String get stubComingSoon => 'Coming soon.';

  @override
  String get routeSplash => 'Arrowchime';

  @override
  String get routeHome => 'Home';

  @override
  String get routeChapterMap => 'Chapters';

  @override
  String routeLevel(String index) {
    return 'Level $index';
  }

  @override
  String get routeDaily => 'Daily Knot';

  @override
  String get routeShop => 'Shop';

  @override
  String get routeCollection => 'Collection';

  @override
  String get routeAchievements => 'Achievements';

  @override
  String get routeSettings => 'Settings';

  @override
  String get routeDesignGallery => 'Design Gallery';

  @override
  String get routeLevelLab => 'Level Lab';
}
