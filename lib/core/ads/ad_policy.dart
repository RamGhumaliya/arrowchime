import 'package:arrowchime/core/remote_config/app_config.dart';
import 'package:arrowchime/core/save/save_data.dart';

/// Why an interstitial may not be shown (or [allowed]).
enum AdDecision {
  allowed,
  adsRemoved,
  adHoliday,
  belowMinLevel,
  notAfterWin,
  retryOrFail,
  firstOpen,
  dailyKnot,
  tutorial,
  notEveryNthWin,
  hardGap,
  tooSoon,
  hourlyCap,
}

/// Where an interstitial would go.
enum AdMoment {
  /// The win → next-level transition: the only place one may appear.
  winToNext,
  retry,
  fail,
  other,
}

/// The situation an ad is being considered in.
class AdContext {
  const new({
    required this.moment,
    required this.levelNumber,
    this.isDaily = false,
    this.isTutorial = false,
    this.firstOpen = false,
    this.adsRemoved = false,
  });

  final AdMoment moment;

  /// 1-based position across all chapters.
  final int levelNumber;
  final bool isDaily;
  final bool isTutorial;

  /// Still in the very first session of the app.
  final bool firstOpen;
  final bool adsRemoved;
}

/// The fair-ads policy of `docs/08` §2, as pure functions of the saved
/// [AdState], the Remote Config numbers and the clock, so it is unit-tested
/// with a mocked time (`docs/09` §5). Hard rules cannot be turned off by
/// Remote Config.
class AdPolicy {
  const new(this.config);

  final AppConfig config;

  static const int _hourMs = 3600 * 1000;

  /// Whether an interstitial may be shown now.
  AdDecision interstitial(AdState state, AdContext ctx, {required int nowMs}) {
    if (ctx.adsRemoved) return AdDecision.adsRemoved;
    if (nowMs < state.holidayUntil) return AdDecision.adHoliday;
    // Hard rules: never on these, whatever the numbers say.
    if (ctx.moment == AdMoment.retry || ctx.moment == AdMoment.fail) {
      return AdDecision.retryOrFail;
    }
    if (ctx.moment != AdMoment.winToNext) return AdDecision.notAfterWin;
    if (ctx.firstOpen) return AdDecision.firstOpen;
    if (ctx.isDaily) return AdDecision.dailyKnot;
    if (ctx.isTutorial) return AdDecision.tutorial;
    if (ctx.levelNumber < config.interstitialMinLevel) {
      return AdDecision.belowMinLevel;
    }
    if (state.lastAdAt > 0 &&
        nowMs - state.lastAdAt < config.interstitialHardGapSeconds * 1000) {
      return AdDecision.hardGap;
    }
    if (state.winsSinceInterstitial < config.interstitialEveryNLevels) {
      return AdDecision.notEveryNthWin;
    }
    if (state.lastInterstitialAt > 0 &&
        nowMs - state.lastInterstitialAt <
            config.interstitialMinSeconds * 1000) {
      return AdDecision.tooSoon;
    }
    final inLastHour = state.recentInterstitials
        .where((t) => nowMs - t < _hourMs)
        .length;
    if (inLastHour >= config.maxInterstitialsPerHour) {
      return AdDecision.hourlyCap;
    }
    return AdDecision.allowed;
  }

  /// A level was won: counts towards "every Nth win" (call before asking).
  AdState onWin(AdState s) =>
      s.copyWith(winsSinceInterstitial: s.winsSinceInterstitial + 1);

  /// An interstitial was shown at [nowMs].
  AdState interstitialShown(AdState s, {required int nowMs}) => s.copyWith(
    lastAdAt: nowMs,
    lastInterstitialAt: nowMs,
    winsSinceInterstitial: 0,
    recentInterstitials: [
      ...s.recentInterstitials.where((t) => nowMs - t < _hourMs),
      nowMs,
    ],
  );

  /// A rewarded ad was shown (it still counts for the 90 s gap).
  AdState rewardedShown(AdState s, {required int nowMs}) =>
      s.copyWith(lastAdAt: nowMs);

  /// Any purchase starts the ad holiday ([AppConfig.adHolidayHours]).
  AdState purchaseMade(AdState s, {required int nowMs}) =>
      s.copyWith(holidayUntil: nowMs + config.adHolidayHours * _hourMs);

  // --- rewarded -------------------------------------------------------------

  /// "+1 heart" ad: at most [AppConfig.rewardedHeartCap] per level attempt.
  bool canOfferHeartAd(int heartAdsThisLevel) =>
      heartAdsThisLevel < config.rewardedHeartCap;

  /// "Double coins" on the win sheet: at most [AppConfig.doubleCoinsDailyCap]
  /// a day, and only when there are coins to double.
  bool canOfferDoubleCoins(
    AdState s, {
    required String today,
    required int coins,
  }) {
    if (coins <= 0) return false;
    final used = s.doubleCoinsDate == today ? s.doubleCoinsCount : 0;
    return used < config.doubleCoinsDailyCap;
  }

  AdState doubleCoinsUsed(AdState s, {required String today}) => s.copyWith(
    doubleCoinsDate: today,
    doubleCoinsCount: (s.doubleCoinsDate == today ? s.doubleCoinsCount : 0) + 1,
  );

  // --- iOS tracking pre-prompt (docs/08 §2) ----------------------------------

  /// The ATT pre-prompt shows once, after level [AppConfig.attPromptAfterLevel],
  /// and if postponed asks again after [AppConfig.attRetryDays].
  bool shouldAskAtt(
    AdState s, {
    required int levelsCleared,
    required int nowMs,
  }) {
    if (s.attState == 'asked') return false;
    if (levelsCleared < config.attPromptAfterLevel) return false;
    return s.attState.isEmpty || nowMs >= s.attRetryAt;
  }

  AdState attAsked(AdState s) => s.copyWith(attState: 'asked');

  /// "Maybe later": ask again in [AppConfig.attRetryDays] (only once more).
  AdState attPostponed(AdState s, {required int nowMs}) => s.attState == 'later'
      ? s.copyWith(attState: 'asked')
      : s.copyWith(
          attState: 'later',
          attRetryAt: nowMs + config.attRetryDays * 24 * _hourMs,
        );
}
