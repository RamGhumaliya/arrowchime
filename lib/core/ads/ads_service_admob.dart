import 'dart:async';
import 'dart:io';

import 'package:arrowchime/core/ads/ads_service.dart';
import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

/// [AdsService] on AdMob with Google's UMP consent form (`docs/08` §2).
///
/// **Test ad units only**: these are Google's public sample IDs. Real IDs go
/// into `AdUnits.release*` and the app IDs into `AndroidManifest.xml` /
/// `Info.plist` before release.
class AdMobAdsService implements AdsService {
  InterstitialAd? _interstitial;
  RewardedAd? _rewarded;
  bool _started = false;
  bool _canRequest = false;

  @override
  bool get canRequestAds => _canRequest;

  @override
  bool get rewardedReady => _canRequest && _rewarded != null;

  @override
  bool get interstitialReady => _canRequest && _interstitial != null;

  @override
  Future<void> init() async {
    if (_started) return;
    _started = true;
    try {
      await _gatherConsent();
      _canRequest = await ConsentInformation.instance.canRequestAds();
      if (!_canRequest) return;
      await MobileAds.instance.updateRequestConfiguration(
        RequestConfiguration(maxAdContentRating: MaxAdContentRating.g),
      );
      await MobileAds.instance.initialize();
      _loadInterstitial();
      _loadRewarded();
    } on Object catch (e) {
      // An ad failure must never break the game.
      debugPrint('AdMob: not available ($e)');
    }
  }

  Future<void> _gatherConsent() {
    final done = Completer<void>();
    ConsentInformation.instance.requestConsentInfoUpdate(
      ConsentRequestParameters(),
      () async {
        await ConsentForm.loadAndShowConsentFormIfRequired((error) {
          if (error != null) debugPrint('UMP: ${error.message}');
        });
        if (!done.isCompleted) done.complete();
      },
      (error) {
        debugPrint('UMP: ${error.message}');
        if (!done.isCompleted) done.complete();
      },
    );
    return done.future;
  }

  void _loadInterstitial() {
    unawaited(
      InterstitialAd.load(
        adUnitId: AdUnits.interstitial,
        request: const AdRequest(),
        adLoadCallback: InterstitialAdLoadCallback(
          onAdLoaded: (ad) => _interstitial = ad,
          onAdFailedToLoad: (e) {
            _interstitial = null;
            debugPrint('Interstitial failed: ${e.message}');
          },
        ),
      ),
    );
  }

  void _loadRewarded() {
    unawaited(
      RewardedAd.load(
        adUnitId: AdUnits.rewarded,
        request: const AdRequest(),
        rewardedAdLoadCallback: RewardedAdLoadCallback(
          onAdLoaded: (ad) => _rewarded = ad,
          onAdFailedToLoad: (e) {
            _rewarded = null;
            debugPrint('Rewarded failed: ${e.message}');
          },
        ),
      ),
    );
  }

  @override
  Future<bool> showInterstitial() async {
    final ad = _interstitial;
    if (ad == null || !_canRequest) return false;
    _interstitial = null;
    final done = Completer<bool>();
    ad.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (a) {
        unawaited(a.dispose());
        _loadInterstitial();
        if (!done.isCompleted) done.complete(true);
      },
      onAdFailedToShowFullScreenContent: (a, e) {
        unawaited(a.dispose());
        _loadInterstitial();
        if (!done.isCompleted) done.complete(false);
      },
    );
    unawaited(ad.show());
    return await done.future;
  }

  @override
  Future<bool> showRewarded() async {
    final ad = _rewarded;
    if (ad == null || !_canRequest) return false;
    _rewarded = null;
    final done = Completer<bool>();
    var earned = false;
    ad.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (a) {
        unawaited(a.dispose());
        _loadRewarded();
        if (!done.isCompleted) done.complete(earned);
      },
      onAdFailedToShowFullScreenContent: (a, e) {
        unawaited(a.dispose());
        _loadRewarded();
        if (!done.isCompleted) done.complete(false);
      },
    );
    unawaited(ad.show(onUserEarnedReward: (_, _) => earned = true));
    return await done.future;
  }
}

/// Ad unit IDs. Google's public **test** units until real ones exist.
abstract final class AdUnits {
  static String get interstitial => Platform.isIOS
      ? 'ca-app-pub-3940256099942544/4411468910'
      : 'ca-app-pub-3940256099942544/1033173712';

  static String get rewarded => Platform.isIOS
      ? 'ca-app-pub-3940256099942544/1712485313'
      : 'ca-app-pub-3940256099942544/5224354917';
}
