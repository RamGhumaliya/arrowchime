import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'rewarded_ads.g.dart';

/// Rewarded video, behind an interface so tests (and Phase 4, before the ad
/// SDK exists) can fake it. Only ever shown after the player chose it
/// (`docs/08` §2).
abstract interface class RewardedAds {
  /// Plays an ad; completes with `true` when the reward was earned.
  Future<bool> show();
}

/// Stand-in until the ad SDK lands (Phase 8): the reward is granted at once.
class StubRewardedAds implements RewardedAds {
  const new();

  @override
  Future<bool> show() async => true;
}

@Riverpod(keepAlive: true)
RewardedAds rewardedAds(Ref ref) => const StubRewardedAds();
