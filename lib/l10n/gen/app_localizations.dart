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
