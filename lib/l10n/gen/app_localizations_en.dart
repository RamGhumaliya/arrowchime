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
  String get devPlay => 'Play Chapter 1';

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

  @override
  String get chapterName1 => 'Misty Garden';

  @override
  String get chapterName2 => 'Clockwork Town';

  @override
  String get chapterName3 => 'Lantern Bazaar';

  @override
  String get chapterName4 => 'Frost Peaks';

  @override
  String get chapterName5 => 'Starlight Observatory';

  @override
  String homePlay(int n) {
    return 'PLAY · Level $n';
  }

  @override
  String get homeDaily => 'Daily Knot';

  @override
  String get homeDailyReady => 'Play today';

  @override
  String get homeDailyDone => 'Done today';

  @override
  String homeStreak(int count) {
    return '$count-day streak';
  }

  @override
  String get homeStreakNone => 'No streak yet';

  @override
  String homeChapterPlaque(String name, int percent) {
    return '$name · $percent%';
  }

  @override
  String homePlayerLevel(int n) {
    return 'Level $n';
  }

  @override
  String get homeShop => 'Shop';

  @override
  String get homeCollection => 'Collection';

  @override
  String get homeQuests => 'Quests';

  @override
  String get homeSettings => 'Settings';

  @override
  String get homeAchievements => 'Achievements';

  @override
  String get mapTitle => 'Chapters';

  @override
  String mapStars(int stars, int max) {
    return '$stars / $max stars';
  }

  @override
  String mapPlay(int n) {
    return 'PLAY · Level $n';
  }

  @override
  String get mapLocked => 'Finish the chapter before it.';

  @override
  String mapPercent(int percent) {
    return '$percent% restored';
  }

  @override
  String mapChapterSemantics(String name, int percent) {
    return '$name, $percent% restored';
  }

  @override
  String mapChapterLocked(String name) {
    return '$name, locked';
  }

  @override
  String mapLevelPip(int n, int stars) {
    return 'Level $n, $stars stars';
  }

  @override
  String mapLevelNext(int n) {
    return 'Level $n, next';
  }

  @override
  String mapLevelLocked(int n) {
    return 'Level $n, locked';
  }

  @override
  String dailyTitle(int n) {
    return 'Daily Knot #$n';
  }

  @override
  String dailyInfo(int size, int arrows) {
    return '$size×$size · $arrows arrows';
  }

  @override
  String get dailyBest => 'Best';

  @override
  String get dailyPlay => 'PLAY TODAY';

  @override
  String get dailyShare => 'Share result';

  @override
  String get dailyCalendar => 'Last 30 days';

  @override
  String dailyFreezes(int n) {
    return 'Freezes: $n';
  }

  @override
  String dailyBuyFreeze(int price) {
    return 'Buy a freeze · $price';
  }

  @override
  String get dailyReplayTitle => 'Replay a missed day';

  @override
  String dailyReplayBody(int price) {
    return 'Costs $price coins.';
  }

  @override
  String dailyReplayAction(int price) {
    return 'Replay · $price';
  }

  @override
  String get dailyShared => 'Result ready to share.';

  @override
  String dailyDayPlayed(String date) {
    return '$date, played';
  }

  @override
  String dailyDayMissed(String date) {
    return '$date, missed';
  }

  @override
  String dailyDayToday(String date) {
    return '$date, today';
  }

  @override
  String get dailyLoading => 'Tying today’s knot…';

  @override
  String get weekday1 => 'M';

  @override
  String get weekday2 => 'T';

  @override
  String get weekday3 => 'W';

  @override
  String get weekday4 => 'T';

  @override
  String get weekday5 => 'F';

  @override
  String get weekday6 => 'S';

  @override
  String get weekday7 => 'S';

  @override
  String dailyHearts(int count) {
    return '$count hearts left';
  }

  @override
  String get winDone => 'Done';

  @override
  String get winShare => 'Share';

  @override
  String get questsTitle => 'Daily quests';

  @override
  String get questClaim => 'Claim';

  @override
  String get questChestOpen => 'Open chest';

  @override
  String get questChestDone => 'Chest opened';

  @override
  String questProgress(int n, int total) {
    return '$n/$total';
  }

  @override
  String questReward(int n) {
    return '+$n';
  }

  @override
  String get quest_clear5 => 'Clear 5 levels';

  @override
  String get quest_clear10 => 'Clear 10 levels';

  @override
  String get quest_flow3 => 'Reach Flow ×3';

  @override
  String get quest_free100 => 'Free 100 arrows';

  @override
  String get quest_perfect3 => 'Get 3 perfect clears';

  @override
  String get quest_daily1 => 'Play the Daily Knot';

  @override
  String get achTitle => 'Achievements';

  @override
  String get achTabAchievements => 'Achievements';

  @override
  String get achTabStats => 'Stats';

  @override
  String achUnlocked(String date) {
    return 'Unlocked $date';
  }

  @override
  String achProgress(int n, int total) {
    return '$n / $total';
  }

  @override
  String get statArrows => 'Arrows freed';

  @override
  String get statLevels => 'Levels cleared';

  @override
  String get statPerfect => 'Perfect clears';

  @override
  String get statFlow => 'Best Flow';

  @override
  String get statTime => 'Play time';

  @override
  String get statStreak => 'Longest streak';

  @override
  String get statDailies => 'Daily Knots';

  @override
  String get statStars => 'Stars';

  @override
  String get statPlayerLevel => 'Player level';

  @override
  String statTimeValue(int h, int m) {
    return '${h}h ${m}m';
  }

  @override
  String statDays(int n) {
    return '$n days';
  }

  @override
  String get ach_first_note => 'First Note';

  @override
  String get achDesc_first_note => 'Clear your first level.';

  @override
  String get ach_levels_10 => 'Warming Up';

  @override
  String get achDesc_levels_10 => 'Clear 10 levels.';

  @override
  String get ach_levels_50 => 'In Tune';

  @override
  String get achDesc_levels_50 => 'Clear 50 levels.';

  @override
  String get ach_levels_100 => 'Composer';

  @override
  String get achDesc_levels_100 => 'Clear 100 levels.';

  @override
  String get ach_levels_200 => 'Virtuoso';

  @override
  String get achDesc_levels_200 => 'Clear 200 levels.';

  @override
  String get ach_levels_300 => 'Grand Finale';

  @override
  String get achDesc_levels_300 => 'Clear all 300 levels.';

  @override
  String get ach_untangler => 'Untangler';

  @override
  String get achDesc_untangler => 'Free 1,000 arrows.';

  @override
  String get ach_arrows_5000 => 'Knot Breaker';

  @override
  String get achDesc_arrows_5000 => 'Free 5,000 arrows.';

  @override
  String get ach_perfect_pitch => 'Perfect Pitch';

  @override
  String get achDesc_perfect_pitch => 'Get 10 three-star clears in a row.';

  @override
  String get ach_perfect_25 => 'Flawless';

  @override
  String get achDesc_perfect_25 => 'Get 25 three-star clears.';

  @override
  String get ach_perfect_100 => 'Crystal Clear';

  @override
  String get achDesc_perfect_100 => 'Get 100 three-star clears.';

  @override
  String get ach_flow_3 => 'In the Groove';

  @override
  String get achDesc_flow_3 => 'Reach Flow ×3.';

  @override
  String get ach_maestro => 'Maestro';

  @override
  String get achDesc_maestro => 'Reach Flow ×5.';

  @override
  String get ach_chapter_1 => 'Garden Restored';

  @override
  String get achDesc_chapter_1 => 'Restore Misty Garden.';

  @override
  String get ach_chapter_2 => 'Clockwork Wakes';

  @override
  String get achDesc_chapter_2 => 'Restore Clockwork Town.';

  @override
  String get ach_chapter_3 => 'Lanterns Lit';

  @override
  String get achDesc_chapter_3 => 'Restore Lantern Bazaar.';

  @override
  String get ach_chapter_4 => 'The Thaw';

  @override
  String get achDesc_chapter_4 => 'Restore Frost Peaks.';

  @override
  String get ach_chapter_5 => 'Stargazer';

  @override
  String get achDesc_chapter_5 => 'Restore Starlight Observatory.';

  @override
  String get ach_streak_3 => 'Three in a Row';

  @override
  String get achDesc_streak_3 => 'Play 3 days in a row.';

  @override
  String get ach_streak_7 => 'Week Warrior';

  @override
  String get achDesc_streak_7 => 'Play 7 days in a row.';

  @override
  String get ach_streak_30 => 'Habit';

  @override
  String get achDesc_streak_30 => 'Play 30 days in a row.';

  @override
  String get ach_streak_100 => 'Devoted';

  @override
  String get achDesc_streak_100 => 'Play 100 days in a row.';

  @override
  String get ach_daily_1 => 'Daily Knot';

  @override
  String get achDesc_daily_1 => 'Finish a Daily Knot.';

  @override
  String get ach_daily_7 => 'Regular';

  @override
  String get achDesc_daily_7 => 'Finish 7 Daily Knots.';

  @override
  String get ach_daily_30 => 'Calendar Keeper';

  @override
  String get achDesc_daily_30 => 'Finish 30 Daily Knots.';

  @override
  String get ach_night_owl => 'Night Owl';

  @override
  String get achDesc_night_owl => 'Finish a Daily Knot after midnight.';

  @override
  String get ach_stars_100 => 'Star Collector';

  @override
  String get achDesc_stars_100 => 'Collect 100 stars.';

  @override
  String get ach_stars_300 => 'Constellation';

  @override
  String get achDesc_stars_300 => 'Collect 300 stars.';

  @override
  String get ach_stars_600 => 'Galaxy';

  @override
  String get achDesc_stars_600 => 'Collect 600 stars.';

  @override
  String get ach_quest_chest => 'Treasure';

  @override
  String get achDesc_quest_chest => 'Open a quest chest.';

  @override
  String toastLevelUp(int n, int coins) {
    return 'Level $n! +$coins coins';
  }

  @override
  String toastAchievement(String title) {
    return 'Achievement: $title';
  }

  @override
  String get settingsTitle => 'Settings';

  @override
  String get settingsSound => 'Sound';

  @override
  String get settingsMusic => 'Music';

  @override
  String get settingsSoundFx => 'Sound effects';

  @override
  String get settingsHaptics => 'Haptics';

  @override
  String get settingsPlay => 'Play';

  @override
  String get settingsLeftHanded => 'Left-handed layout';

  @override
  String get settingsRelaxed => 'Relaxed mode';

  @override
  String get settingsRelaxedNote => 'No hearts lost; two stars at most.';

  @override
  String get settingsReduceMotion => 'Reduce motion';

  @override
  String get settingsReduceSystem => 'System';

  @override
  String get settingsReduceOn => 'On';

  @override
  String get settingsColorBlind => 'Colour-blind palette';

  @override
  String get cbOff => 'Off';

  @override
  String get cbDeutan => 'Red-green';

  @override
  String get cbTritan => 'Blue-yellow';

  @override
  String get settingsAccount => 'Account & info';

  @override
  String get settingsLanguage => 'Language';

  @override
  String get settingsLanguageValue => 'English';

  @override
  String get settingsAccountRow => 'Account';

  @override
  String get settingsPrivacy => 'Privacy';

  @override
  String get settingsRestore => 'Restore purchases';

  @override
  String get settingsCredits => 'Credits';

  @override
  String get settingsComingSoon => 'Coming soon.';

  @override
  String get settingsCreditsBody =>
      'Arrowchime is made by Webazonic. Music and art by the Arrowchime team.';

  @override
  String get settingsOn => 'On';

  @override
  String get settingsOff => 'Off';

  @override
  String get obTap => 'Tap an arrow to free it.';

  @override
  String get obBlocked => 'Some arrows are blocked.';

  @override
  String get obHearts => 'Blocked taps cost a heart.';

  @override
  String get obBend => 'Arrows bend. Tap any part.';

  @override
  String get obPeek => 'Hold to peek the path.';

  @override
  String get obZoom => 'Pinch to zoom, drag to pan.';

  @override
  String get obKnot => 'A knot! Take your time.';

  @override
  String get obRotator => 'Arrows turn after each tap.';

  @override
  String get obGate => 'Free the key arrow first.';

  @override
  String get obFrozen => 'Ice thaws as arrows leave.';

  @override
  String get obLink => 'Chained arrows leave together.';

  @override
  String get obPortal => 'Portals carry arrows across.';

  @override
  String get settingsDeveloper => 'Developer (debug builds)';

  @override
  String get adUnavailable => 'Ad not available';

  @override
  String get winDoubleCoins => '×2 coins · ad';

  @override
  String get hintNoCoinsTitle => 'Not enough coins';

  @override
  String get hintWatchAd => 'Watch ad for a free hint';

  @override
  String get dailyUnlockAd => 'Unlock with an ad';

  @override
  String get shopTitle => 'Shop';

  @override
  String get shopStarterTitle => 'Starter Bundle';

  @override
  String shopStarterLeft(String time) {
    return '$time left';
  }

  @override
  String get shopChipRemoveAds => 'Remove Ads';

  @override
  String shopChipCoins(int n) {
    return '$n coins';
  }

  @override
  String get shopChipSkin => 'Neon skin';

  @override
  String get shopRemoveAdsTitle => 'Remove Ads';

  @override
  String shopRemoveAdsNote(int n) {
    return 'No interstitials, ever. $n coins too.';
  }

  @override
  String get shopOwned => 'Owned';

  @override
  String get shopCoinsSection => 'Coins';

  @override
  String shopCoinsAmount(int n) {
    return '$n';
  }

  @override
  String get shopBestValue => 'Best value';

  @override
  String get shopArtPack => 'Chapter Art Pack';

  @override
  String get shopArtPackNote => 'A skin, a trail and an instrument.';

  @override
  String get shopRestore => 'Restore purchases';

  @override
  String get shopThanks => 'Thank you!';

  @override
  String get shopFailed => 'The purchase didn’t go through.';

  @override
  String get shopRestored => 'Purchases restored.';

  @override
  String get shopUnavailable => 'The store isn’t available right now.';

  @override
  String get shopBuyShort => 'Buy';

  @override
  String shopBuy(String price) {
    return 'Buy $price';
  }

  @override
  String get shopPriceLoading => '…';

  @override
  String get starterNotNow => 'Not now';

  @override
  String get collectionTitle => 'Collection';

  @override
  String get collTabArrows => 'Arrows';

  @override
  String get collTabTrails => 'Trails';

  @override
  String get collTabBoards => 'Boards';

  @override
  String get collTabInstruments => 'Instruments';

  @override
  String get collEquip => 'Equip';

  @override
  String get collEquipped => 'Equipped';

  @override
  String get collOwned => 'Owned';

  @override
  String collBuy(int price) {
    return 'Buy · $price';
  }

  @override
  String collLockChapter(String name) {
    return 'Restore $name';
  }

  @override
  String collLockStars(int n) {
    return '$n stars in one chapter';
  }

  @override
  String get collLockBundle => 'Comes in a bundle';

  @override
  String get collPreviewHint => 'Tap the board to replay.';

  @override
  String get cos_arrow_candy => 'Enamel Candy';

  @override
  String get cos_arrow_bamboo => 'Bamboo';

  @override
  String get cos_arrow_brass => 'Brass';

  @override
  String get cos_arrow_silk => 'Lantern Silk';

  @override
  String get cos_arrow_crystal => 'Crystal';

  @override
  String get cos_arrow_galaxy => 'Galaxy';

  @override
  String get cos_arrow_neon => 'Neon Tube';

  @override
  String get cos_arrow_paper => 'Paper-craft';

  @override
  String get cos_arrow_pixel => 'Pixel';

  @override
  String get cos_trail_none => 'No trail';

  @override
  String get cos_trail_sparkle => 'Sparkle';

  @override
  String get cos_trail_petals => 'Petals';

  @override
  String get cos_trail_snow => 'Snow';

  @override
  String get cos_trail_ribbons => 'Ribbons';

  @override
  String get cos_board_auto => 'Chapter felt';

  @override
  String get cos_board_night => 'Night felt';

  @override
  String get cos_board_sunset => 'Sunset felt';

  @override
  String get cos_board_constellation => 'Constellation';

  @override
  String get cos_board_aurora => 'Aurora';

  @override
  String get cos_instrument_auto => 'Chapter instrument';

  @override
  String get cos_instrument_piano => 'Piano';

  @override
  String get cos_instrument_marimba => 'Marimba';

  @override
  String get cos_instrument_eightbit => '8-bit';

  @override
  String get cos_instrument_choir => 'Choir';

  @override
  String get attTitle => 'A quick note';

  @override
  String get attBody =>
      'Allowing tracking keeps ads relevant and the game free. You can change this later in Settings.';

  @override
  String get attContinue => 'Continue';

  @override
  String get attLater => 'Maybe later';
}
