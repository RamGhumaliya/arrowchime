import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'gen/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[Locale('en')];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'Arrowchime'**
  String get appTitle;

  /// No description provided for @stubComingSoon.
  ///
  /// In en, this message translates to:
  /// **'Coming soon.'**
  String get stubComingSoon;

  /// No description provided for @devPlay.
  ///
  /// In en, this message translates to:
  /// **'Play Chapter 1'**
  String get devPlay;

  /// No description provided for @routeSplash.
  ///
  /// In en, this message translates to:
  /// **'Arrowchime'**
  String get routeSplash;

  /// No description provided for @routeHome.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get routeHome;

  /// No description provided for @routeChapterMap.
  ///
  /// In en, this message translates to:
  /// **'Chapters'**
  String get routeChapterMap;

  /// No description provided for @routeLevel.
  ///
  /// In en, this message translates to:
  /// **'Level {index}'**
  String routeLevel(String index);

  /// No description provided for @routeDaily.
  ///
  /// In en, this message translates to:
  /// **'Daily Knot'**
  String get routeDaily;

  /// No description provided for @routeShop.
  ///
  /// In en, this message translates to:
  /// **'Shop'**
  String get routeShop;

  /// No description provided for @routeCollection.
  ///
  /// In en, this message translates to:
  /// **'Collection'**
  String get routeCollection;

  /// No description provided for @routeAchievements.
  ///
  /// In en, this message translates to:
  /// **'Achievements'**
  String get routeAchievements;

  /// No description provided for @routeSettings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get routeSettings;

  /// No description provided for @routeDesignGallery.
  ///
  /// In en, this message translates to:
  /// **'Design Gallery'**
  String get routeDesignGallery;

  /// No description provided for @routeLevelLab.
  ///
  /// In en, this message translates to:
  /// **'Level Lab'**
  String get routeLevelLab;

  /// No description provided for @gameBack.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get gameBack;

  /// No description provided for @gameLevelTitle.
  ///
  /// In en, this message translates to:
  /// **'Level {index}'**
  String gameLevelTitle(int index);

  /// No description provided for @gameHeartsLabel.
  ///
  /// In en, this message translates to:
  /// **'{count} hearts left'**
  String gameHeartsLabel(int count);

  /// No description provided for @gameCoinsLabel.
  ///
  /// In en, this message translates to:
  /// **'{count} coins'**
  String gameCoinsLabel(int count);

  /// No description provided for @gameBoardLabel.
  ///
  /// In en, this message translates to:
  /// **'Puzzle board, {count} arrows left'**
  String gameBoardLabel(int count);

  /// No description provided for @gameUndo.
  ///
  /// In en, this message translates to:
  /// **'Undo'**
  String get gameUndo;

  /// No description provided for @gameUndoPrice.
  ///
  /// In en, this message translates to:
  /// **'Undo, {price} coins'**
  String gameUndoPrice(int price);

  /// No description provided for @gameHint.
  ///
  /// In en, this message translates to:
  /// **'Hint'**
  String get gameHint;

  /// No description provided for @gameHintPrice.
  ///
  /// In en, this message translates to:
  /// **'Hint, {price} coins'**
  String gameHintPrice(int price);

  /// No description provided for @gameGrid.
  ///
  /// In en, this message translates to:
  /// **'Grid lines'**
  String get gameGrid;

  /// No description provided for @gameFit.
  ///
  /// In en, this message translates to:
  /// **'Fit board'**
  String get gameFit;

  /// No description provided for @gameNoCoins.
  ///
  /// In en, this message translates to:
  /// **'Not enough coins'**
  String get gameNoCoins;

  /// No description provided for @gameNoHint.
  ///
  /// In en, this message translates to:
  /// **'No hint right now'**
  String get gameNoHint;

  /// No description provided for @gamePeekTip.
  ///
  /// In en, this message translates to:
  /// **'Hold to peek the path.'**
  String get gamePeekTip;

  /// No description provided for @gameFlowNice.
  ///
  /// In en, this message translates to:
  /// **'Nice flow!'**
  String get gameFlowNice;

  /// No description provided for @gameLoadError.
  ///
  /// In en, this message translates to:
  /// **'This level could not be opened.'**
  String get gameLoadError;

  /// No description provided for @gameLoading.
  ///
  /// In en, this message translates to:
  /// **'Setting up the board…'**
  String get gameLoading;

  /// No description provided for @winTitle.
  ///
  /// In en, this message translates to:
  /// **'Level {index}'**
  String winTitle(int index);

  /// No description provided for @winCoins.
  ///
  /// In en, this message translates to:
  /// **'+{count} coins'**
  String winCoins(int count);

  /// No description provided for @winXp.
  ///
  /// In en, this message translates to:
  /// **'+{count} XP'**
  String winXp(int count);

  /// No description provided for @winStars.
  ///
  /// In en, this message translates to:
  /// **'{count} of 3 stars'**
  String winStars(int count);

  /// No description provided for @companionTitle.
  ///
  /// In en, this message translates to:
  /// **'Chime Companion'**
  String get companionTitle;

  /// No description provided for @companionBody.
  ///
  /// In en, this message translates to:
  /// **'A kind nudge now and then? We\'ll cheer you on and remind you when a streak needs a play. One note a day at most, never at night.'**
  String get companionBody;

  /// No description provided for @companionYes.
  ///
  /// In en, this message translates to:
  /// **'Yes, please'**
  String get companionYes;

  /// No description provided for @companionLater.
  ///
  /// In en, this message translates to:
  /// **'Maybe later'**
  String get companionLater;

  /// No description provided for @noteAppreciationTitle.
  ///
  /// In en, this message translates to:
  /// **'A great day'**
  String get noteAppreciationTitle;

  /// No description provided for @noteAppreciationBody.
  ///
  /// In en, this message translates to:
  /// **'You cleared {n} levels yesterday, your best day yet.'**
  String noteAppreciationBody(int n);

  /// No description provided for @noteStreakTitle.
  ///
  /// In en, this message translates to:
  /// **'Your {n}-day streak'**
  String noteStreakTitle(int n);

  /// No description provided for @noteStreakBody.
  ///
  /// In en, this message translates to:
  /// **'It is safe until midnight. One quick puzzle keeps it going.'**
  String get noteStreakBody;

  /// No description provided for @noteDailyTitle.
  ///
  /// In en, this message translates to:
  /// **'Today\'s Daily Chime'**
  String get noteDailyTitle;

  /// No description provided for @noteDailyBody.
  ///
  /// In en, this message translates to:
  /// **'A fresh puzzle is ready. About four minutes.'**
  String get noteDailyBody;

  /// No description provided for @noteComeback3Title.
  ///
  /// In en, this message translates to:
  /// **'Your arrows are waiting'**
  String get noteComeback3Title;

  /// No description provided for @noteComeback3Body.
  ///
  /// In en, this message translates to:
  /// **'No pressure. Whenever you are ready.'**
  String get noteComeback3Body;

  /// No description provided for @noteComeback7Title.
  ///
  /// In en, this message translates to:
  /// **'We kept your place'**
  String get noteComeback7Title;

  /// No description provided for @noteComeback7Body.
  ///
  /// In en, this message translates to:
  /// **'A free hint is waiting. Come back whenever you like.'**
  String get noteComeback7Body;

  /// No description provided for @settingsCompanion.
  ///
  /// In en, this message translates to:
  /// **'Chime Companion'**
  String get settingsCompanion;

  /// No description provided for @settingsCompanionNormal.
  ///
  /// In en, this message translates to:
  /// **'Normal'**
  String get settingsCompanionNormal;

  /// No description provided for @settingsCompanionFewer.
  ///
  /// In en, this message translates to:
  /// **'Fewer'**
  String get settingsCompanionFewer;

  /// No description provided for @settingsCompanionOff.
  ///
  /// In en, this message translates to:
  /// **'Off'**
  String get settingsCompanionOff;

  /// No description provided for @settingsCompanionNote.
  ///
  /// In en, this message translates to:
  /// **'Kind notes, at most one a day, never at night.'**
  String get settingsCompanionNote;

  /// No description provided for @diaryTitle.
  ///
  /// In en, this message translates to:
  /// **'Chime Diary'**
  String get diaryTitle;

  /// No description provided for @diaryIntro.
  ///
  /// In en, this message translates to:
  /// **'Your best moments so far.'**
  String get diaryIntro;

  /// No description provided for @diaryLevels.
  ///
  /// In en, this message translates to:
  /// **'Levels cleared'**
  String get diaryLevels;

  /// No description provided for @diaryArrows.
  ///
  /// In en, this message translates to:
  /// **'Arrows freed'**
  String get diaryArrows;

  /// No description provided for @diaryBestChain.
  ///
  /// In en, this message translates to:
  /// **'Best chain'**
  String get diaryBestChain;

  /// No description provided for @diaryChainValue.
  ///
  /// In en, this message translates to:
  /// **'×{n}'**
  String diaryChainValue(int n);

  /// No description provided for @diaryStreakBest.
  ///
  /// In en, this message translates to:
  /// **'Longest streak'**
  String get diaryStreakBest;

  /// No description provided for @diaryDays.
  ///
  /// In en, this message translates to:
  /// **'{n} days'**
  String diaryDays(int n);

  /// No description provided for @diaryPerfect.
  ///
  /// In en, this message translates to:
  /// **'Perfect clears'**
  String get diaryPerfect;

  /// No description provided for @diaryBestDay.
  ///
  /// In en, this message translates to:
  /// **'Best day'**
  String get diaryBestDay;

  /// No description provided for @diaryLevelsCount.
  ///
  /// In en, this message translates to:
  /// **'{n} levels'**
  String diaryLevelsCount(int n);

  /// No description provided for @diaryTime.
  ///
  /// In en, this message translates to:
  /// **'Time played'**
  String get diaryTime;

  /// No description provided for @diaryMinutes.
  ///
  /// In en, this message translates to:
  /// **'{n} min'**
  String diaryMinutes(int n);

  /// No description provided for @winHeadline.
  ///
  /// In en, this message translates to:
  /// **'Beautifully done!'**
  String get winHeadline;

  /// No description provided for @winNext.
  ///
  /// In en, this message translates to:
  /// **'Next level'**
  String get winNext;

  /// No description provided for @winReplay.
  ///
  /// In en, this message translates to:
  /// **'Replay'**
  String get winReplay;

  /// No description provided for @failTitle.
  ///
  /// In en, this message translates to:
  /// **'Out of hearts'**
  String get failTitle;

  /// No description provided for @failCaption.
  ///
  /// In en, this message translates to:
  /// **'So close — try again?'**
  String get failCaption;

  /// No description provided for @failRetry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get failRetry;

  /// No description provided for @failHeartAd.
  ///
  /// In en, this message translates to:
  /// **'+1 heart'**
  String get failHeartAd;

  /// No description provided for @failHeartCoins.
  ///
  /// In en, this message translates to:
  /// **'+1 heart · {price}'**
  String failHeartCoins(int price);

  /// No description provided for @chapterName1.
  ///
  /// In en, this message translates to:
  /// **'levels 1–60'**
  String get chapterName1;

  /// No description provided for @chapterName2.
  ///
  /// In en, this message translates to:
  /// **'levels 61–120'**
  String get chapterName2;

  /// No description provided for @chapterName3.
  ///
  /// In en, this message translates to:
  /// **'levels 121–180'**
  String get chapterName3;

  /// No description provided for @chapterName4.
  ///
  /// In en, this message translates to:
  /// **'levels 181–240'**
  String get chapterName4;

  /// No description provided for @chapterName5.
  ///
  /// In en, this message translates to:
  /// **'levels 241–300'**
  String get chapterName5;

  /// No description provided for @homePlay.
  ///
  /// In en, this message translates to:
  /// **'PLAY · Level {n}'**
  String homePlay(int n);

  /// No description provided for @homeDaily.
  ///
  /// In en, this message translates to:
  /// **'Daily Knot'**
  String get homeDaily;

  /// No description provided for @homeDailyReady.
  ///
  /// In en, this message translates to:
  /// **'Play today'**
  String get homeDailyReady;

  /// No description provided for @homeDailyDone.
  ///
  /// In en, this message translates to:
  /// **'Done today'**
  String get homeDailyDone;

  /// No description provided for @homeStreak.
  ///
  /// In en, this message translates to:
  /// **'{count}-day streak'**
  String homeStreak(int count);

  /// No description provided for @homeStreakNone.
  ///
  /// In en, this message translates to:
  /// **'No streak yet'**
  String get homeStreakNone;

  /// No description provided for @homeChapterPlaque.
  ///
  /// In en, this message translates to:
  /// **'{name} · {percent}%'**
  String homeChapterPlaque(String name, int percent);

  /// No description provided for @homePlayerLevel.
  ///
  /// In en, this message translates to:
  /// **'Level {n}'**
  String homePlayerLevel(int n);

  /// No description provided for @homeShop.
  ///
  /// In en, this message translates to:
  /// **'Shop'**
  String get homeShop;

  /// No description provided for @homeCollection.
  ///
  /// In en, this message translates to:
  /// **'Collection'**
  String get homeCollection;

  /// No description provided for @homeQuests.
  ///
  /// In en, this message translates to:
  /// **'Quests'**
  String get homeQuests;

  /// No description provided for @homeSettings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get homeSettings;

  /// No description provided for @homeAchievements.
  ///
  /// In en, this message translates to:
  /// **'Achievements'**
  String get homeAchievements;

  /// No description provided for @mapTitle.
  ///
  /// In en, this message translates to:
  /// **'Chapters'**
  String get mapTitle;

  /// No description provided for @mapStars.
  ///
  /// In en, this message translates to:
  /// **'{stars} / {max} stars'**
  String mapStars(int stars, int max);

  /// No description provided for @mapPlay.
  ///
  /// In en, this message translates to:
  /// **'PLAY · Level {n}'**
  String mapPlay(int n);

  /// No description provided for @mapLocked.
  ///
  /// In en, this message translates to:
  /// **'Finish the chapter before it.'**
  String get mapLocked;

  /// No description provided for @mapPercent.
  ///
  /// In en, this message translates to:
  /// **'{percent}% restored'**
  String mapPercent(int percent);

  /// No description provided for @mapChapterSemantics.
  ///
  /// In en, this message translates to:
  /// **'{name}, {percent}% restored'**
  String mapChapterSemantics(String name, int percent);

  /// No description provided for @mapChapterLocked.
  ///
  /// In en, this message translates to:
  /// **'{name}, locked'**
  String mapChapterLocked(String name);

  /// No description provided for @mapLevelPip.
  ///
  /// In en, this message translates to:
  /// **'Level {n}, {stars} stars'**
  String mapLevelPip(int n, int stars);

  /// No description provided for @mapLevelNext.
  ///
  /// In en, this message translates to:
  /// **'Level {n}, next'**
  String mapLevelNext(int n);

  /// No description provided for @mapLevelLocked.
  ///
  /// In en, this message translates to:
  /// **'Level {n}, locked'**
  String mapLevelLocked(int n);

  /// No description provided for @dailyTitle.
  ///
  /// In en, this message translates to:
  /// **'Daily Knot #{n}'**
  String dailyTitle(int n);

  /// No description provided for @dailyInfo.
  ///
  /// In en, this message translates to:
  /// **'{size}×{size} · {arrows} arrows'**
  String dailyInfo(int size, int arrows);

  /// No description provided for @dailyBest.
  ///
  /// In en, this message translates to:
  /// **'Best'**
  String get dailyBest;

  /// No description provided for @dailyPlay.
  ///
  /// In en, this message translates to:
  /// **'PLAY TODAY'**
  String get dailyPlay;

  /// No description provided for @dailyShare.
  ///
  /// In en, this message translates to:
  /// **'Share result'**
  String get dailyShare;

  /// No description provided for @dailyCalendar.
  ///
  /// In en, this message translates to:
  /// **'Last 30 days'**
  String get dailyCalendar;

  /// No description provided for @dailyFreezes.
  ///
  /// In en, this message translates to:
  /// **'Freezes: {n}'**
  String dailyFreezes(int n);

  /// No description provided for @dailyBuyFreeze.
  ///
  /// In en, this message translates to:
  /// **'Buy a freeze · {price}'**
  String dailyBuyFreeze(int price);

  /// No description provided for @dailyReplayTitle.
  ///
  /// In en, this message translates to:
  /// **'Replay a missed day'**
  String get dailyReplayTitle;

  /// No description provided for @dailyReplayBody.
  ///
  /// In en, this message translates to:
  /// **'Costs {price} coins.'**
  String dailyReplayBody(int price);

  /// No description provided for @dailyReplayAction.
  ///
  /// In en, this message translates to:
  /// **'Replay · {price}'**
  String dailyReplayAction(int price);

  /// No description provided for @dailyShared.
  ///
  /// In en, this message translates to:
  /// **'Result ready to share.'**
  String get dailyShared;

  /// No description provided for @dailyDayPlayed.
  ///
  /// In en, this message translates to:
  /// **'{date}, played'**
  String dailyDayPlayed(String date);

  /// No description provided for @dailyDayMissed.
  ///
  /// In en, this message translates to:
  /// **'{date}, missed'**
  String dailyDayMissed(String date);

  /// No description provided for @dailyDayToday.
  ///
  /// In en, this message translates to:
  /// **'{date}, today'**
  String dailyDayToday(String date);

  /// No description provided for @dailyLoading.
  ///
  /// In en, this message translates to:
  /// **'Tying today’s knot…'**
  String get dailyLoading;

  /// No description provided for @weekday1.
  ///
  /// In en, this message translates to:
  /// **'M'**
  String get weekday1;

  /// No description provided for @weekday2.
  ///
  /// In en, this message translates to:
  /// **'T'**
  String get weekday2;

  /// No description provided for @weekday3.
  ///
  /// In en, this message translates to:
  /// **'W'**
  String get weekday3;

  /// No description provided for @weekday4.
  ///
  /// In en, this message translates to:
  /// **'T'**
  String get weekday4;

  /// No description provided for @weekday5.
  ///
  /// In en, this message translates to:
  /// **'F'**
  String get weekday5;

  /// No description provided for @weekday6.
  ///
  /// In en, this message translates to:
  /// **'S'**
  String get weekday6;

  /// No description provided for @weekday7.
  ///
  /// In en, this message translates to:
  /// **'S'**
  String get weekday7;

  /// No description provided for @dailyHearts.
  ///
  /// In en, this message translates to:
  /// **'{count} hearts left'**
  String dailyHearts(int count);

  /// No description provided for @winDone.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get winDone;

  /// No description provided for @winShare.
  ///
  /// In en, this message translates to:
  /// **'Share'**
  String get winShare;

  /// No description provided for @questsTitle.
  ///
  /// In en, this message translates to:
  /// **'Daily quests'**
  String get questsTitle;

  /// No description provided for @questClaim.
  ///
  /// In en, this message translates to:
  /// **'Claim'**
  String get questClaim;

  /// No description provided for @questChestOpen.
  ///
  /// In en, this message translates to:
  /// **'Open chest'**
  String get questChestOpen;

  /// No description provided for @questChestDone.
  ///
  /// In en, this message translates to:
  /// **'Chest opened'**
  String get questChestDone;

  /// No description provided for @questProgress.
  ///
  /// In en, this message translates to:
  /// **'{n}/{total}'**
  String questProgress(int n, int total);

  /// No description provided for @questReward.
  ///
  /// In en, this message translates to:
  /// **'+{n}'**
  String questReward(int n);

  /// No description provided for @quest_clear5.
  ///
  /// In en, this message translates to:
  /// **'Clear 5 levels'**
  String get quest_clear5;

  /// No description provided for @quest_clear10.
  ///
  /// In en, this message translates to:
  /// **'Clear 10 levels'**
  String get quest_clear10;

  /// No description provided for @quest_flow3.
  ///
  /// In en, this message translates to:
  /// **'Reach Flow ×3'**
  String get quest_flow3;

  /// No description provided for @quest_free100.
  ///
  /// In en, this message translates to:
  /// **'Free 100 arrows'**
  String get quest_free100;

  /// No description provided for @quest_perfect3.
  ///
  /// In en, this message translates to:
  /// **'Get 3 perfect clears'**
  String get quest_perfect3;

  /// No description provided for @quest_daily1.
  ///
  /// In en, this message translates to:
  /// **'Play the Daily Knot'**
  String get quest_daily1;

  /// No description provided for @achTitle.
  ///
  /// In en, this message translates to:
  /// **'Achievements'**
  String get achTitle;

  /// No description provided for @achTabAchievements.
  ///
  /// In en, this message translates to:
  /// **'Achievements'**
  String get achTabAchievements;

  /// No description provided for @achTabStats.
  ///
  /// In en, this message translates to:
  /// **'Stats'**
  String get achTabStats;

  /// No description provided for @achUnlocked.
  ///
  /// In en, this message translates to:
  /// **'Unlocked {date}'**
  String achUnlocked(String date);

  /// No description provided for @achProgress.
  ///
  /// In en, this message translates to:
  /// **'{n} / {total}'**
  String achProgress(int n, int total);

  /// No description provided for @statArrows.
  ///
  /// In en, this message translates to:
  /// **'Arrows freed'**
  String get statArrows;

  /// No description provided for @statLevels.
  ///
  /// In en, this message translates to:
  /// **'Levels cleared'**
  String get statLevels;

  /// No description provided for @statPerfect.
  ///
  /// In en, this message translates to:
  /// **'Perfect clears'**
  String get statPerfect;

  /// No description provided for @statFlow.
  ///
  /// In en, this message translates to:
  /// **'Best Flow'**
  String get statFlow;

  /// No description provided for @statTime.
  ///
  /// In en, this message translates to:
  /// **'Play time'**
  String get statTime;

  /// No description provided for @statStreak.
  ///
  /// In en, this message translates to:
  /// **'Longest streak'**
  String get statStreak;

  /// No description provided for @statDailies.
  ///
  /// In en, this message translates to:
  /// **'Daily Knots'**
  String get statDailies;

  /// No description provided for @statStars.
  ///
  /// In en, this message translates to:
  /// **'Stars'**
  String get statStars;

  /// No description provided for @statPlayerLevel.
  ///
  /// In en, this message translates to:
  /// **'Player level'**
  String get statPlayerLevel;

  /// No description provided for @statTimeValue.
  ///
  /// In en, this message translates to:
  /// **'{h}h {m}m'**
  String statTimeValue(int h, int m);

  /// No description provided for @statDays.
  ///
  /// In en, this message translates to:
  /// **'{n} days'**
  String statDays(int n);

  /// No description provided for @ach_first_note.
  ///
  /// In en, this message translates to:
  /// **'First Note'**
  String get ach_first_note;

  /// No description provided for @achDesc_first_note.
  ///
  /// In en, this message translates to:
  /// **'Clear your first level.'**
  String get achDesc_first_note;

  /// No description provided for @ach_levels_10.
  ///
  /// In en, this message translates to:
  /// **'Warming Up'**
  String get ach_levels_10;

  /// No description provided for @achDesc_levels_10.
  ///
  /// In en, this message translates to:
  /// **'Clear 10 levels.'**
  String get achDesc_levels_10;

  /// No description provided for @ach_levels_50.
  ///
  /// In en, this message translates to:
  /// **'In Tune'**
  String get ach_levels_50;

  /// No description provided for @achDesc_levels_50.
  ///
  /// In en, this message translates to:
  /// **'Clear 50 levels.'**
  String get achDesc_levels_50;

  /// No description provided for @ach_levels_100.
  ///
  /// In en, this message translates to:
  /// **'Composer'**
  String get ach_levels_100;

  /// No description provided for @achDesc_levels_100.
  ///
  /// In en, this message translates to:
  /// **'Clear 100 levels.'**
  String get achDesc_levels_100;

  /// No description provided for @ach_levels_200.
  ///
  /// In en, this message translates to:
  /// **'Virtuoso'**
  String get ach_levels_200;

  /// No description provided for @achDesc_levels_200.
  ///
  /// In en, this message translates to:
  /// **'Clear 200 levels.'**
  String get achDesc_levels_200;

  /// No description provided for @ach_levels_300.
  ///
  /// In en, this message translates to:
  /// **'Grand Finale'**
  String get ach_levels_300;

  /// No description provided for @achDesc_levels_300.
  ///
  /// In en, this message translates to:
  /// **'Clear all 300 levels.'**
  String get achDesc_levels_300;

  /// No description provided for @ach_untangler.
  ///
  /// In en, this message translates to:
  /// **'Untangler'**
  String get ach_untangler;

  /// No description provided for @achDesc_untangler.
  ///
  /// In en, this message translates to:
  /// **'Free 1,000 arrows.'**
  String get achDesc_untangler;

  /// No description provided for @ach_arrows_5000.
  ///
  /// In en, this message translates to:
  /// **'Knot Breaker'**
  String get ach_arrows_5000;

  /// No description provided for @achDesc_arrows_5000.
  ///
  /// In en, this message translates to:
  /// **'Free 5,000 arrows.'**
  String get achDesc_arrows_5000;

  /// No description provided for @ach_perfect_pitch.
  ///
  /// In en, this message translates to:
  /// **'Perfect Pitch'**
  String get ach_perfect_pitch;

  /// No description provided for @achDesc_perfect_pitch.
  ///
  /// In en, this message translates to:
  /// **'Get 10 three-star clears in a row.'**
  String get achDesc_perfect_pitch;

  /// No description provided for @ach_perfect_25.
  ///
  /// In en, this message translates to:
  /// **'Flawless'**
  String get ach_perfect_25;

  /// No description provided for @achDesc_perfect_25.
  ///
  /// In en, this message translates to:
  /// **'Get 25 three-star clears.'**
  String get achDesc_perfect_25;

  /// No description provided for @ach_perfect_100.
  ///
  /// In en, this message translates to:
  /// **'Crystal Clear'**
  String get ach_perfect_100;

  /// No description provided for @achDesc_perfect_100.
  ///
  /// In en, this message translates to:
  /// **'Get 100 three-star clears.'**
  String get achDesc_perfect_100;

  /// No description provided for @ach_flow_3.
  ///
  /// In en, this message translates to:
  /// **'In the Groove'**
  String get ach_flow_3;

  /// No description provided for @achDesc_flow_3.
  ///
  /// In en, this message translates to:
  /// **'Reach Flow ×3.'**
  String get achDesc_flow_3;

  /// No description provided for @ach_maestro.
  ///
  /// In en, this message translates to:
  /// **'Maestro'**
  String get ach_maestro;

  /// No description provided for @achDesc_maestro.
  ///
  /// In en, this message translates to:
  /// **'Reach Flow ×5.'**
  String get achDesc_maestro;

  /// No description provided for @ach_chapter_1.
  ///
  /// In en, this message translates to:
  /// **'Garden Restored'**
  String get ach_chapter_1;

  /// No description provided for @achDesc_chapter_1.
  ///
  /// In en, this message translates to:
  /// **'Restore Misty Garden.'**
  String get achDesc_chapter_1;

  /// No description provided for @ach_chapter_2.
  ///
  /// In en, this message translates to:
  /// **'Clockwork Wakes'**
  String get ach_chapter_2;

  /// No description provided for @achDesc_chapter_2.
  ///
  /// In en, this message translates to:
  /// **'Restore Clockwork Town.'**
  String get achDesc_chapter_2;

  /// No description provided for @ach_chapter_3.
  ///
  /// In en, this message translates to:
  /// **'Lanterns Lit'**
  String get ach_chapter_3;

  /// No description provided for @achDesc_chapter_3.
  ///
  /// In en, this message translates to:
  /// **'Restore Lantern Bazaar.'**
  String get achDesc_chapter_3;

  /// No description provided for @ach_chapter_4.
  ///
  /// In en, this message translates to:
  /// **'The Thaw'**
  String get ach_chapter_4;

  /// No description provided for @achDesc_chapter_4.
  ///
  /// In en, this message translates to:
  /// **'Restore Frost Peaks.'**
  String get achDesc_chapter_4;

  /// No description provided for @ach_chapter_5.
  ///
  /// In en, this message translates to:
  /// **'Stargazer'**
  String get ach_chapter_5;

  /// No description provided for @achDesc_chapter_5.
  ///
  /// In en, this message translates to:
  /// **'Restore Starlight Observatory.'**
  String get achDesc_chapter_5;

  /// No description provided for @ach_streak_3.
  ///
  /// In en, this message translates to:
  /// **'Three in a Row'**
  String get ach_streak_3;

  /// No description provided for @achDesc_streak_3.
  ///
  /// In en, this message translates to:
  /// **'Play 3 days in a row.'**
  String get achDesc_streak_3;

  /// No description provided for @ach_streak_7.
  ///
  /// In en, this message translates to:
  /// **'Week Warrior'**
  String get ach_streak_7;

  /// No description provided for @achDesc_streak_7.
  ///
  /// In en, this message translates to:
  /// **'Play 7 days in a row.'**
  String get achDesc_streak_7;

  /// No description provided for @ach_streak_30.
  ///
  /// In en, this message translates to:
  /// **'Habit'**
  String get ach_streak_30;

  /// No description provided for @achDesc_streak_30.
  ///
  /// In en, this message translates to:
  /// **'Play 30 days in a row.'**
  String get achDesc_streak_30;

  /// No description provided for @ach_streak_100.
  ///
  /// In en, this message translates to:
  /// **'Devoted'**
  String get ach_streak_100;

  /// No description provided for @achDesc_streak_100.
  ///
  /// In en, this message translates to:
  /// **'Play 100 days in a row.'**
  String get achDesc_streak_100;

  /// No description provided for @ach_daily_1.
  ///
  /// In en, this message translates to:
  /// **'Daily Knot'**
  String get ach_daily_1;

  /// No description provided for @achDesc_daily_1.
  ///
  /// In en, this message translates to:
  /// **'Finish a Daily Knot.'**
  String get achDesc_daily_1;

  /// No description provided for @ach_daily_7.
  ///
  /// In en, this message translates to:
  /// **'Regular'**
  String get ach_daily_7;

  /// No description provided for @achDesc_daily_7.
  ///
  /// In en, this message translates to:
  /// **'Finish 7 Daily Knots.'**
  String get achDesc_daily_7;

  /// No description provided for @ach_daily_30.
  ///
  /// In en, this message translates to:
  /// **'Calendar Keeper'**
  String get ach_daily_30;

  /// No description provided for @achDesc_daily_30.
  ///
  /// In en, this message translates to:
  /// **'Finish 30 Daily Knots.'**
  String get achDesc_daily_30;

  /// No description provided for @ach_night_owl.
  ///
  /// In en, this message translates to:
  /// **'Night Owl'**
  String get ach_night_owl;

  /// No description provided for @achDesc_night_owl.
  ///
  /// In en, this message translates to:
  /// **'Finish a Daily Knot after midnight.'**
  String get achDesc_night_owl;

  /// No description provided for @ach_stars_100.
  ///
  /// In en, this message translates to:
  /// **'Star Collector'**
  String get ach_stars_100;

  /// No description provided for @achDesc_stars_100.
  ///
  /// In en, this message translates to:
  /// **'Collect 100 stars.'**
  String get achDesc_stars_100;

  /// No description provided for @ach_stars_300.
  ///
  /// In en, this message translates to:
  /// **'Constellation'**
  String get ach_stars_300;

  /// No description provided for @achDesc_stars_300.
  ///
  /// In en, this message translates to:
  /// **'Collect 300 stars.'**
  String get achDesc_stars_300;

  /// No description provided for @ach_stars_600.
  ///
  /// In en, this message translates to:
  /// **'Galaxy'**
  String get ach_stars_600;

  /// No description provided for @achDesc_stars_600.
  ///
  /// In en, this message translates to:
  /// **'Collect 600 stars.'**
  String get achDesc_stars_600;

  /// No description provided for @ach_quest_chest.
  ///
  /// In en, this message translates to:
  /// **'Treasure'**
  String get ach_quest_chest;

  /// No description provided for @achDesc_quest_chest.
  ///
  /// In en, this message translates to:
  /// **'Open a quest chest.'**
  String get achDesc_quest_chest;

  /// No description provided for @toastLevelUp.
  ///
  /// In en, this message translates to:
  /// **'Level {n}! +{coins} coins'**
  String toastLevelUp(int n, int coins);

  /// No description provided for @toastAchievement.
  ///
  /// In en, this message translates to:
  /// **'Achievement: {title}'**
  String toastAchievement(String title);

  /// No description provided for @settingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsTitle;

  /// No description provided for @settingsSound.
  ///
  /// In en, this message translates to:
  /// **'Sound'**
  String get settingsSound;

  /// No description provided for @settingsMusic.
  ///
  /// In en, this message translates to:
  /// **'Music'**
  String get settingsMusic;

  /// No description provided for @settingsSoundFx.
  ///
  /// In en, this message translates to:
  /// **'Sound effects'**
  String get settingsSoundFx;

  /// No description provided for @settingsHaptics.
  ///
  /// In en, this message translates to:
  /// **'Haptics'**
  String get settingsHaptics;

  /// No description provided for @settingsPlay.
  ///
  /// In en, this message translates to:
  /// **'Play'**
  String get settingsPlay;

  /// No description provided for @settingsLeftHanded.
  ///
  /// In en, this message translates to:
  /// **'Left-handed layout'**
  String get settingsLeftHanded;

  /// No description provided for @settingsRelaxed.
  ///
  /// In en, this message translates to:
  /// **'Relaxed mode'**
  String get settingsRelaxed;

  /// No description provided for @settingsRelaxedNote.
  ///
  /// In en, this message translates to:
  /// **'No hearts lost; two stars at most.'**
  String get settingsRelaxedNote;

  /// No description provided for @settingsReduceMotion.
  ///
  /// In en, this message translates to:
  /// **'Reduce motion'**
  String get settingsReduceMotion;

  /// No description provided for @settingsReduceSystem.
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get settingsReduceSystem;

  /// No description provided for @settingsReduceOn.
  ///
  /// In en, this message translates to:
  /// **'On'**
  String get settingsReduceOn;

  /// No description provided for @settingsColorBlind.
  ///
  /// In en, this message translates to:
  /// **'Colour-blind palette'**
  String get settingsColorBlind;

  /// No description provided for @cbOff.
  ///
  /// In en, this message translates to:
  /// **'Off'**
  String get cbOff;

  /// No description provided for @cbDeutan.
  ///
  /// In en, this message translates to:
  /// **'Red-green'**
  String get cbDeutan;

  /// No description provided for @cbTritan.
  ///
  /// In en, this message translates to:
  /// **'Blue-yellow'**
  String get cbTritan;

  /// No description provided for @settingsAccount.
  ///
  /// In en, this message translates to:
  /// **'Account & info'**
  String get settingsAccount;

  /// No description provided for @settingsLanguage.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get settingsLanguage;

  /// No description provided for @settingsLanguageValue.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get settingsLanguageValue;

  /// No description provided for @settingsAccountRow.
  ///
  /// In en, this message translates to:
  /// **'Account'**
  String get settingsAccountRow;

  /// No description provided for @settingsPrivacy.
  ///
  /// In en, this message translates to:
  /// **'Privacy'**
  String get settingsPrivacy;

  /// No description provided for @settingsRestore.
  ///
  /// In en, this message translates to:
  /// **'Restore purchases'**
  String get settingsRestore;

  /// No description provided for @settingsCredits.
  ///
  /// In en, this message translates to:
  /// **'Credits'**
  String get settingsCredits;

  /// No description provided for @settingsComingSoon.
  ///
  /// In en, this message translates to:
  /// **'Coming soon.'**
  String get settingsComingSoon;

  /// No description provided for @settingsCreditsBody.
  ///
  /// In en, this message translates to:
  /// **'Arrowchime is made by Webazonic. Music and art by the Arrowchime team.'**
  String get settingsCreditsBody;

  /// No description provided for @settingsOn.
  ///
  /// In en, this message translates to:
  /// **'On'**
  String get settingsOn;

  /// No description provided for @settingsOff.
  ///
  /// In en, this message translates to:
  /// **'Off'**
  String get settingsOff;

  /// No description provided for @obTap.
  ///
  /// In en, this message translates to:
  /// **'Tap an arrow to free it.'**
  String get obTap;

  /// No description provided for @obBlocked.
  ///
  /// In en, this message translates to:
  /// **'Some arrows are blocked.'**
  String get obBlocked;

  /// No description provided for @obHearts.
  ///
  /// In en, this message translates to:
  /// **'Blocked taps cost a heart.'**
  String get obHearts;

  /// No description provided for @obBend.
  ///
  /// In en, this message translates to:
  /// **'Arrows bend. Tap any part.'**
  String get obBend;

  /// No description provided for @obPeek.
  ///
  /// In en, this message translates to:
  /// **'Hold to peek the path.'**
  String get obPeek;

  /// No description provided for @obZoom.
  ///
  /// In en, this message translates to:
  /// **'Pinch to zoom, drag to pan.'**
  String get obZoom;

  /// No description provided for @obKnot.
  ///
  /// In en, this message translates to:
  /// **'A knot! Take your time.'**
  String get obKnot;

  /// No description provided for @obRotator.
  ///
  /// In en, this message translates to:
  /// **'Arrows turn after each tap.'**
  String get obRotator;

  /// No description provided for @obGate.
  ///
  /// In en, this message translates to:
  /// **'Free the key arrow first.'**
  String get obGate;

  /// No description provided for @obFrozen.
  ///
  /// In en, this message translates to:
  /// **'Ice thaws as arrows leave.'**
  String get obFrozen;

  /// No description provided for @obLink.
  ///
  /// In en, this message translates to:
  /// **'Chained arrows leave together.'**
  String get obLink;

  /// No description provided for @obPortal.
  ///
  /// In en, this message translates to:
  /// **'Portals carry arrows across.'**
  String get obPortal;

  /// No description provided for @settingsDeveloper.
  ///
  /// In en, this message translates to:
  /// **'Developer (debug builds)'**
  String get settingsDeveloper;

  /// No description provided for @adUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Ad not available'**
  String get adUnavailable;

  /// No description provided for @winDoubleCoins.
  ///
  /// In en, this message translates to:
  /// **'×2 coins · ad'**
  String get winDoubleCoins;

  /// No description provided for @hintNoCoinsTitle.
  ///
  /// In en, this message translates to:
  /// **'Not enough coins'**
  String get hintNoCoinsTitle;

  /// No description provided for @hintWatchAd.
  ///
  /// In en, this message translates to:
  /// **'Watch ad for a free hint'**
  String get hintWatchAd;

  /// No description provided for @dailyUnlockAd.
  ///
  /// In en, this message translates to:
  /// **'Unlock with an ad'**
  String get dailyUnlockAd;

  /// No description provided for @shopTitle.
  ///
  /// In en, this message translates to:
  /// **'Shop'**
  String get shopTitle;

  /// No description provided for @shopStarterTitle.
  ///
  /// In en, this message translates to:
  /// **'Starter Bundle'**
  String get shopStarterTitle;

  /// No description provided for @shopStarterLeft.
  ///
  /// In en, this message translates to:
  /// **'{time} left'**
  String shopStarterLeft(String time);

  /// No description provided for @shopChipRemoveAds.
  ///
  /// In en, this message translates to:
  /// **'Remove Ads'**
  String get shopChipRemoveAds;

  /// No description provided for @shopChipCoins.
  ///
  /// In en, this message translates to:
  /// **'{n} coins'**
  String shopChipCoins(int n);

  /// No description provided for @shopChipSkin.
  ///
  /// In en, this message translates to:
  /// **'Neon skin'**
  String get shopChipSkin;

  /// No description provided for @shopRemoveAdsTitle.
  ///
  /// In en, this message translates to:
  /// **'Remove Ads'**
  String get shopRemoveAdsTitle;

  /// No description provided for @shopRemoveAdsNote.
  ///
  /// In en, this message translates to:
  /// **'No interstitials, ever. {n} coins too.'**
  String shopRemoveAdsNote(int n);

  /// No description provided for @shopOwned.
  ///
  /// In en, this message translates to:
  /// **'Owned'**
  String get shopOwned;

  /// No description provided for @shopCoinsSection.
  ///
  /// In en, this message translates to:
  /// **'Coins'**
  String get shopCoinsSection;

  /// No description provided for @shopCoinsAmount.
  ///
  /// In en, this message translates to:
  /// **'{n}'**
  String shopCoinsAmount(int n);

  /// No description provided for @shopBestValue.
  ///
  /// In en, this message translates to:
  /// **'Best value'**
  String get shopBestValue;

  /// No description provided for @shopArtPack.
  ///
  /// In en, this message translates to:
  /// **'Chapter Art Pack'**
  String get shopArtPack;

  /// No description provided for @shopArtPackNote.
  ///
  /// In en, this message translates to:
  /// **'A skin, a trail and an instrument.'**
  String get shopArtPackNote;

  /// No description provided for @shopRestore.
  ///
  /// In en, this message translates to:
  /// **'Restore purchases'**
  String get shopRestore;

  /// No description provided for @shopThanks.
  ///
  /// In en, this message translates to:
  /// **'Thank you!'**
  String get shopThanks;

  /// No description provided for @shopFailed.
  ///
  /// In en, this message translates to:
  /// **'The purchase didn’t go through.'**
  String get shopFailed;

  /// No description provided for @shopRestored.
  ///
  /// In en, this message translates to:
  /// **'Purchases restored.'**
  String get shopRestored;

  /// No description provided for @shopUnavailable.
  ///
  /// In en, this message translates to:
  /// **'The store isn’t available right now.'**
  String get shopUnavailable;

  /// No description provided for @shopBuyShort.
  ///
  /// In en, this message translates to:
  /// **'Buy'**
  String get shopBuyShort;

  /// No description provided for @shopBuy.
  ///
  /// In en, this message translates to:
  /// **'Buy {price}'**
  String shopBuy(String price);

  /// No description provided for @shopPriceLoading.
  ///
  /// In en, this message translates to:
  /// **'…'**
  String get shopPriceLoading;

  /// No description provided for @starterNotNow.
  ///
  /// In en, this message translates to:
  /// **'Not now'**
  String get starterNotNow;

  /// No description provided for @collectionTitle.
  ///
  /// In en, this message translates to:
  /// **'Collection'**
  String get collectionTitle;

  /// No description provided for @collTabArrows.
  ///
  /// In en, this message translates to:
  /// **'Arrows'**
  String get collTabArrows;

  /// No description provided for @collTabTrails.
  ///
  /// In en, this message translates to:
  /// **'Trails'**
  String get collTabTrails;

  /// No description provided for @collTabBoards.
  ///
  /// In en, this message translates to:
  /// **'Boards'**
  String get collTabBoards;

  /// No description provided for @collTabInstruments.
  ///
  /// In en, this message translates to:
  /// **'Instruments'**
  String get collTabInstruments;

  /// No description provided for @collEquip.
  ///
  /// In en, this message translates to:
  /// **'Equip'**
  String get collEquip;

  /// No description provided for @collEquipped.
  ///
  /// In en, this message translates to:
  /// **'Equipped'**
  String get collEquipped;

  /// No description provided for @collOwned.
  ///
  /// In en, this message translates to:
  /// **'Owned'**
  String get collOwned;

  /// No description provided for @collBuy.
  ///
  /// In en, this message translates to:
  /// **'Buy · {price}'**
  String collBuy(int price);

  /// No description provided for @collLockChapter.
  ///
  /// In en, this message translates to:
  /// **'Clear {name}'**
  String collLockChapter(String name);

  /// No description provided for @collLockStars.
  ///
  /// In en, this message translates to:
  /// **'{n} stars in one chapter'**
  String collLockStars(int n);

  /// No description provided for @collLockBundle.
  ///
  /// In en, this message translates to:
  /// **'Comes in a bundle'**
  String get collLockBundle;

  /// No description provided for @collPreviewHint.
  ///
  /// In en, this message translates to:
  /// **'Tap the board to replay.'**
  String get collPreviewHint;

  /// No description provided for @cos_arrow_candy.
  ///
  /// In en, this message translates to:
  /// **'Enamel Candy'**
  String get cos_arrow_candy;

  /// No description provided for @cos_arrow_bamboo.
  ///
  /// In en, this message translates to:
  /// **'Bamboo'**
  String get cos_arrow_bamboo;

  /// No description provided for @cos_arrow_brass.
  ///
  /// In en, this message translates to:
  /// **'Brass'**
  String get cos_arrow_brass;

  /// No description provided for @cos_arrow_silk.
  ///
  /// In en, this message translates to:
  /// **'Lantern Silk'**
  String get cos_arrow_silk;

  /// No description provided for @cos_arrow_crystal.
  ///
  /// In en, this message translates to:
  /// **'Crystal'**
  String get cos_arrow_crystal;

  /// No description provided for @cos_arrow_galaxy.
  ///
  /// In en, this message translates to:
  /// **'Galaxy'**
  String get cos_arrow_galaxy;

  /// No description provided for @cos_arrow_neon.
  ///
  /// In en, this message translates to:
  /// **'Neon Tube'**
  String get cos_arrow_neon;

  /// No description provided for @cos_arrow_paper.
  ///
  /// In en, this message translates to:
  /// **'Paper-craft'**
  String get cos_arrow_paper;

  /// No description provided for @cos_arrow_pixel.
  ///
  /// In en, this message translates to:
  /// **'Pixel'**
  String get cos_arrow_pixel;

  /// No description provided for @cos_trail_none.
  ///
  /// In en, this message translates to:
  /// **'No trail'**
  String get cos_trail_none;

  /// No description provided for @cos_trail_sparkle.
  ///
  /// In en, this message translates to:
  /// **'Sparkle'**
  String get cos_trail_sparkle;

  /// No description provided for @cos_trail_petals.
  ///
  /// In en, this message translates to:
  /// **'Petals'**
  String get cos_trail_petals;

  /// No description provided for @cos_trail_snow.
  ///
  /// In en, this message translates to:
  /// **'Snow'**
  String get cos_trail_snow;

  /// No description provided for @cos_trail_ribbons.
  ///
  /// In en, this message translates to:
  /// **'Ribbons'**
  String get cos_trail_ribbons;

  /// No description provided for @cos_board_auto.
  ///
  /// In en, this message translates to:
  /// **'Chapter felt'**
  String get cos_board_auto;

  /// No description provided for @cos_board_night.
  ///
  /// In en, this message translates to:
  /// **'Night felt'**
  String get cos_board_night;

  /// No description provided for @cos_board_sunset.
  ///
  /// In en, this message translates to:
  /// **'Sunset felt'**
  String get cos_board_sunset;

  /// No description provided for @cos_board_constellation.
  ///
  /// In en, this message translates to:
  /// **'Constellation'**
  String get cos_board_constellation;

  /// No description provided for @cos_board_aurora.
  ///
  /// In en, this message translates to:
  /// **'Aurora'**
  String get cos_board_aurora;

  /// No description provided for @cos_instrument_auto.
  ///
  /// In en, this message translates to:
  /// **'Chapter instrument'**
  String get cos_instrument_auto;

  /// No description provided for @cos_instrument_piano.
  ///
  /// In en, this message translates to:
  /// **'Piano'**
  String get cos_instrument_piano;

  /// No description provided for @cos_instrument_marimba.
  ///
  /// In en, this message translates to:
  /// **'Marimba'**
  String get cos_instrument_marimba;

  /// No description provided for @cos_instrument_eightbit.
  ///
  /// In en, this message translates to:
  /// **'8-bit'**
  String get cos_instrument_eightbit;

  /// No description provided for @cos_instrument_choir.
  ///
  /// In en, this message translates to:
  /// **'Choir'**
  String get cos_instrument_choir;

  /// No description provided for @attTitle.
  ///
  /// In en, this message translates to:
  /// **'A quick note'**
  String get attTitle;

  /// No description provided for @attBody.
  ///
  /// In en, this message translates to:
  /// **'Allowing tracking keeps ads relevant and the game free. You can change this later in Settings.'**
  String get attBody;

  /// No description provided for @attContinue.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get attContinue;

  /// No description provided for @attLater.
  ///
  /// In en, this message translates to:
  /// **'Maybe later'**
  String get attLater;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
