import 'dart:async';

import 'package:arrowchime/core/ads/ad_policy.dart';
import 'package:arrowchime/core/ads/ads_service.dart';
import 'package:arrowchime/core/ads/ads_service_admob.dart';
import 'package:arrowchime/core/meta/date_key.dart';
import 'package:arrowchime/core/remote_config/app_config.dart';
import 'package:arrowchime/core/save/save_controller.dart';
import 'package:arrowchime/core/save/save_data.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'ads_controller.g.dart';

@Riverpod(keepAlive: true)
AdsService adsService(Ref ref) => AdMobAdsService();

@Riverpod(keepAlive: true)
AdPolicy adPolicy(Ref ref) => AdPolicy(ref.watch(appConfigProvider));

/// Joins the pure [AdPolicy], the saved [AdState] and the [AdsService]: the
/// one place that decides to show an ad and records that it was shown.
class AdsController {
  new(this._ref);

  final Ref _ref;

  AdsService get _service => _ref.read(adsServiceProvider);
  AdPolicy get _policy => _ref.read(adPolicyProvider);
  SaveController get _save => _ref.read(saveControllerProvider.notifier);
  SaveData get _data => _ref.read(saveControllerProvider);
  DateTime get _now => _ref.read(clockProvider)();
  int get _nowMs => _now.millisecondsSinceEpoch;

  void _setAds(AdState Function(AdState s) f) =>
      _save.update((d) => d.copyWith(ads: f(d.ads)));

  /// Starts consent + the SDK (call once at app start).
  Future<void> init() => _service.init();

  /// Remember that the app was opened. The very first session never shows an
  /// interstitial (`docs/08` §2); from the second one on it may.
  void markSessionStart() {
    final flags = _data.flags;
    if (flags['sessionStarted'] ?? false) {
      if (!(flags['secondSession'] ?? false)) {
        _save.update(
          (d) => d.copyWith(flags: {...d.flags, 'secondSession': true}),
        );
      }
    } else {
      _save.update(
        (d) => d.copyWith(flags: {...d.flags, 'sessionStarted': true}),
      );
    }
  }

  bool get adsRemoved => _data.flags['adsRemoved'] ?? false;

  bool get _firstOpen => !(_data.flags['secondSession'] ?? false);

  /// A level was won (counts towards "every Nth win").
  void onWin() => _setAds(_policy.onWin);

  /// The win → next transition: shows an interstitial if the policy allows
  /// it. Returns whether one was shown. Never throws, never blocks the game
  /// when no ad is ready.
  Future<bool> maybeInterstitialAfterWin({
    required int levelNumber,
    required bool isDaily,
    required bool isTutorial,
  }) async {
    final decision = _policy.interstitial(
      _data.ads,
      AdContext(
        moment: AdMoment.winToNext,
        levelNumber: levelNumber,
        isDaily: isDaily,
        isTutorial: isTutorial,
        firstOpen: _firstOpen,
        adsRemoved: adsRemoved,
      ),
      nowMs: _nowMs,
    );
    if (decision != AdDecision.allowed || !_service.interstitialReady) {
      return false;
    }
    final shown = await _service.showInterstitial();
    if (shown) _setAds((s) => _policy.interstitialShown(s, nowMs: _nowMs));
    return shown;
  }

  // --- rewarded ---------------------------------------------------------------

  /// Whether a rewarded ad can be played right now.
  bool get rewardedAvailable => _service.rewardedReady;

  bool canOfferHeartAd(int usedThisLevel) =>
      rewardedAvailable && _policy.canOfferHeartAd(usedThisLevel);

  bool canOfferDoubleCoins(int coins) =>
      rewardedAvailable &&
      _policy.canOfferDoubleCoins(
        _data.ads,
        today: DateKey.of(_now),
        coins: coins,
      );

  /// Plays a rewarded ad; `true` when the reward was earned.
  Future<bool> showRewarded() async {
    if (!_service.rewardedReady) return false;
    final earned = await _service.showRewarded();
    _setAds((s) => _policy.rewardedShown(s, nowMs: _nowMs));
    return earned;
  }

  /// "Double coins": plays the ad and, if earned, pays [coins] again.
  Future<bool> doubleCoins(int coins) async {
    if (!canOfferDoubleCoins(coins)) return false;
    final earned = await showRewarded();
    if (!earned) return false;
    _save.update(
      (d) => d.copyWith(
        coins: d.coins + coins,
        ads: _policy.doubleCoinsUsed(d.ads, today: DateKey.of(_now)),
      ),
    );
    return true;
  }

  /// Any purchase starts the 24 h ad holiday.
  void purchaseMade() => _setAds((s) => _policy.purchaseMade(s, nowMs: _nowMs));
}

@Riverpod(keepAlive: true)
AdsController adsController(Ref ref) => AdsController(ref);
