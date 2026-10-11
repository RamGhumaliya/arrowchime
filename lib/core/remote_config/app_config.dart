import 'package:arrowchime/core/remote_config/defaults.dart';
import 'package:arrowchime/core/remote_config/remote_config_service.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'app_config.g.dart';

/// The typed view of Remote Config the game reads: economy prices, ad rules
/// and shop numbers (`docs/05` §9, `docs/08`). Nothing else hard-codes them.
class AppConfig {
  new(RemoteConfigService rc)
    : heartsPerLevel = rc.getInt(RemoteDefaults.heartsPerLevel),
      hintPrice = rc.getInt(RemoteDefaults.hintPrice),
      undoPrice = rc.getInt(RemoteDefaults.undoPrice),
      freeUndos = rc.getInt(RemoteDefaults.freeUndos),
      heartPrice = rc.getInt(RemoteDefaults.heartPrice),
      hintsFreeBelowLevel = rc.getInt(RemoteDefaults.hintsFreeBelowLevel),
      freeHintsPerLevel = rc.getInt(RemoteDefaults.freeHintsPerLevel),
      streakFreezePrice = rc.getInt(RemoteDefaults.streakFreezePrice),
      missedDailyPrice = rc.getInt(RemoteDefaults.missedDailyPrice),
      dailyRewardCoins = rc.getInt(RemoteDefaults.dailyRewardCoins),
      dailyRewardPerTier = rc.getInt(RemoteDefaults.dailyRewardPerTier),
      interstitialMinLevel = rc.getInt(RemoteDefaults.interstitialMinLevel),
      interstitialEveryNLevels = rc.getInt(
        RemoteDefaults.interstitialEveryNLevels,
      ),
      interstitialMinSeconds = rc.getInt(
        RemoteDefaults.interstitialMinSecondsBetween,
      ),
      interstitialHardGapSeconds = rc.getInt(
        RemoteDefaults.interstitialHardGapSeconds,
      ),
      maxInterstitialsPerHour = rc.getInt(
        RemoteDefaults.maxInterstitialsPerHour,
      ),
      rewardedHeartCap = rc.getInt(RemoteDefaults.rewardedHeartCap),
      doubleCoinsDailyCap = rc.getInt(RemoteDefaults.doubleCoinsDailyCap),
      adHolidayHours = rc.getInt(RemoteDefaults.adHolidayHours),
      attPromptAfterLevel = rc.getInt(RemoteDefaults.attPromptAfterLevel),
      attRetryDays = rc.getInt(RemoteDefaults.attRetryDays),
      removeAdsBonusCoins = rc.getInt(RemoteDefaults.removeAdsBonusCoins),
      starterBundleEnabled = rc.getBool(RemoteDefaults.starterBundleEnabled),
      starterBundleMinLevel = rc.getInt(RemoteDefaults.starterBundleMinLevel),
      starterBundleHours = rc.getInt(RemoteDefaults.starterBundleHours),
      starterBundleCoins = rc.getInt(RemoteDefaults.starterBundleCoins),
      coinPouch = rc.getInt(RemoteDefaults.coinPouchAmount),
      coinChest = rc.getInt(RemoteDefaults.coinChestAmount),
      coinVault = rc.getInt(RemoteDefaults.coinVaultAmount),
      priceCommon = rc.getInt(RemoteDefaults.cosmeticPriceCommon),
      priceRare = rc.getInt(RemoteDefaults.cosmeticPriceRare),
      priceEpic = rc.getInt(RemoteDefaults.cosmeticPriceEpic);

  /// The shipped defaults (tests, previews).
  factory defaults() => AppConfig(const LocalRemoteConfig());

  final int heartsPerLevel;
  final int hintPrice;
  final int undoPrice;
  final int freeUndos;
  final int heartPrice;
  final int hintsFreeBelowLevel;
  final int freeHintsPerLevel;
  final int streakFreezePrice;
  final int missedDailyPrice;
  final int dailyRewardCoins;
  final int dailyRewardPerTier;
  final int interstitialMinLevel;
  final int interstitialEveryNLevels;
  final int interstitialMinSeconds;
  final int interstitialHardGapSeconds;
  final int maxInterstitialsPerHour;
  final int rewardedHeartCap;
  final int doubleCoinsDailyCap;
  final int adHolidayHours;
  final int attPromptAfterLevel;
  final int attRetryDays;
  final int removeAdsBonusCoins;
  final bool starterBundleEnabled;
  final int starterBundleMinLevel;
  final int starterBundleHours;
  final int starterBundleCoins;
  final int coinPouch;
  final int coinChest;
  final int coinVault;
  final int priceCommon;
  final int priceRare;
  final int priceEpic;
}

@Riverpod(keepAlive: true)
AppConfig appConfig(Ref ref) => AppConfig(ref.watch(remoteConfigProvider));
