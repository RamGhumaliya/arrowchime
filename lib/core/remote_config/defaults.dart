/// Every tunable of economy, ads and shop with its shipped default
/// (`docs/05` §9, `docs/08`). Firebase Remote Config (Phase 9) overrides any of
/// these by key; until then, and whenever it is offline, these are the values.
abstract final class RemoteDefaults {
  static const String heartsPerLevel = 'hearts_per_level';
  static const String hintPrice = 'hint_price';
  static const String undoPrice = 'undo_price';
  static const String freeUndos = 'free_undos';
  static const String heartPrice = 'heart_price';
  static const String hintsFreeBelowLevel = 'hints_free_below_level';
  static const String freeHintsPerLevel = 'free_hints_per_level';
  static const String streakFreezePrice = 'streak_freeze_price';
  static const String missedDailyPrice = 'missed_daily_price';
  static const String dailyRewardCoins = 'daily_reward_coins';
  static const String dailyRewardPerTier = 'daily_reward_per_tier';
  static const String peekShowsVerdict = 'peek_shows_verdict';

  // Ads (docs/08 §2).
  static const String interstitialMinLevel = 'interstitial_min_level';
  static const String interstitialEveryNLevels = 'interstitial_every_n_levels';
  static const String interstitialMinSecondsBetween =
      'interstitial_min_seconds_between';
  static const String interstitialHardGapSeconds =
      'interstitial_hard_gap_seconds';
  static const String maxInterstitialsPerHour = 'max_interstitials_per_hour';
  static const String rewardedHeartCap = 'rewarded_heart_cap';
  static const String doubleCoinsDailyCap = 'double_coins_daily_cap';
  static const String adHolidayHours = 'ad_holiday_hours';
  static const String attPromptAfterLevel = 'att_prompt_after_level';
  static const String attRetryDays = 'att_retry_days';

  // Shop (docs/08 §3).
  static const String removeAdsSku = 'remove_ads_sku';
  static const String removeAdsBonusCoins = 'remove_ads_bonus_coins';
  static const String starterBundleEnabled = 'starter_bundle_enabled';
  static const String starterBundleMinLevel = 'starter_bundle_min_level';
  static const String starterBundleHours = 'starter_bundle_hours';
  static const String starterBundleCoins = 'starter_bundle_coins';
  static const String coinPouchAmount = 'coin_pouch_amount';
  static const String coinChestAmount = 'coin_chest_amount';
  static const String coinVaultAmount = 'coin_vault_amount';
  static const String cosmeticPriceCommon = 'cosmetic_price_common';
  static const String cosmeticPriceRare = 'cosmetic_price_rare';
  static const String cosmeticPriceEpic = 'cosmetic_price_epic';
  static const String eventTangleTowerEnabled = 'event_tangle_tower_enabled';

  /// Key → default value.
  static const Map<String, Object> values = {
    heartsPerLevel: 3,
    hintPrice: 50,
    undoPrice: 30,
    freeUndos: 2,
    heartPrice: 100,
    hintsFreeBelowLevel: 20,
    freeHintsPerLevel: 1,
    streakFreezePrice: 200,
    missedDailyPrice: 100,
    dailyRewardCoins: 50,
    dailyRewardPerTier: 25,
    peekShowsVerdict: false,
    interstitialMinLevel: 12,
    interstitialEveryNLevels: 3,
    interstitialMinSecondsBetween: 150,
    interstitialHardGapSeconds: 90,
    maxInterstitialsPerHour: 6,
    rewardedHeartCap: 2,
    doubleCoinsDailyCap: 5,
    adHolidayHours: 24,
    attPromptAfterLevel: 5,
    attRetryDays: 7,
    removeAdsSku: 'remove_ads',
    removeAdsBonusCoins: 500,
    starterBundleEnabled: true,
    starterBundleMinLevel: 15,
    starterBundleHours: 48,
    starterBundleCoins: 2000,
    coinPouchAmount: 1000,
    coinChestAmount: 5500,
    coinVaultAmount: 15000,
    cosmeticPriceCommon: 500,
    cosmeticPriceRare: 1500,
    cosmeticPriceEpic: 4000,
    eventTangleTowerEnabled: false,
  };
}
