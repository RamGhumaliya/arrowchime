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

  @override
  String get gameBack => 'Back';

  @override
  String gameLevelTitle(int index) {
    return 'Level $index';
  }

  @override
  String gameHeartsLabel(int count) {
    return '$count hearts left';
  }

  @override
  String gameCoinsLabel(int count) {
    return '$count coins';
  }

  @override
  String gameBoardLabel(int count) {
    return 'Puzzle board, $count arrows left';
  }

  @override
  String get gameUndo => 'Undo';

  @override
  String gameUndoPrice(int price) {
    return 'Undo, $price coins';
  }

  @override
  String get gameHint => 'Hint';

  @override
  String gameHintPrice(int price) {
    return 'Hint, $price coins';
  }

  @override
  String get gameGrid => 'Grid lines';

  @override
  String get gameFit => 'Fit board';

  @override
  String get gameNoCoins => 'Not enough coins';

  @override
  String get gameNoHint => 'No hint right now';

  @override
  String get gamePeekTip => 'Hold to peek the path.';

  @override
  String get gameFlowNice => 'Nice flow!';

  @override
  String get gameLoadError => 'This level could not be opened.';

  @override
  String get gameLoading => 'Setting up the board…';

  @override
  String winTitle(int index) {
    return 'Level $index';
  }

  @override
  String winCoins(int count) {
    return '+$count coins';
  }

  @override
  String winXp(int count) {
    return '+$count XP';
  }

  @override
  String winStars(int count) {
    return '$count of 3 stars';
  }

  @override
  String get winNext => 'Next level';

  @override
  String get winReplay => 'Replay';

  @override
  String get failTitle => 'Out of hearts';

  @override
  String get failCaption => 'So close — try again?';

  @override
  String get failRetry => 'Retry';

  @override
  String get failHeartAd => '+1 heart';

  @override
  String failHeartCoins(int price) {
    return '+1 heart · $price';
  }
}
