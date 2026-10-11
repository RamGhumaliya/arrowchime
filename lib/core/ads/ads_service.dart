/// Ads behind an interface (`docs/05` §2, `CLAUDE.md` rule 11): the real
/// implementation is AdMob + Google UMP consent; tests and dev use the fake.
abstract interface class AdsService {
  /// Gathers consent (UMP) and starts the SDK. Safe to call repeatedly.
  Future<void> init();

  /// Whether consent allows requesting ads at all.
  bool get canRequestAds;

  bool get rewardedReady;

  bool get interstitialReady;

  /// Shows a rewarded ad; completes with `true` when the reward was earned.
  Future<bool> showRewarded();

  /// Shows an interstitial; completes with `true` when it was shown.
  Future<bool> showInterstitial();
}

/// A scriptable [AdsService] for tests and development builds.
class FakeAdsService implements AdsService {
  new({
    this.canRequest = true,
    this.rewardedAvailable = true,
    this.interstitialAvailable = true,
    this.earnReward = true,
  });

  bool canRequest;
  bool rewardedAvailable;
  bool interstitialAvailable;

  /// Whether the player "watches to the end" in [showRewarded].
  bool earnReward;

  int initCalls = 0;
  int rewardedShown = 0;
  int interstitialsShown = 0;

  @override
  Future<void> init() async => initCalls++;

  @override
  bool get canRequestAds => canRequest;

  @override
  bool get rewardedReady => canRequest && rewardedAvailable;

  @override
  bool get interstitialReady => canRequest && interstitialAvailable;

  @override
  Future<bool> showRewarded() async {
    if (!rewardedReady) return false;
    rewardedShown++;
    return earnReward;
  }

  @override
  Future<bool> showInterstitial() async {
    if (!interstitialReady) return false;
    interstitialsShown++;
    return true;
  }
}
