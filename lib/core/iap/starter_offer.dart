import 'package:arrowchime/core/iap/purchase_fulfillment.dart';
import 'package:arrowchime/core/remote_config/app_config.dart';
import 'package:arrowchime/core/save/save_data.dart';

/// The Starter Bundle window (`docs/08` §3): offered after level 15 for 48
/// hours, hidden once bought, expired, or when Remove Ads is already owned.
/// The only timer is this real window: no fake countdowns.
class StarterOffer {
  const new({
    required this.open,
    required this.remaining,
    required this.promptToday,
  });

  /// The bundle can be bought now.
  final bool open;

  /// Time left in the window (zero when closed).
  final Duration remaining;

  /// The sheet should pop up now: open, and not yet shown today.
  final bool promptToday;

  static const StarterOffer closed = StarterOffer(
    open: false,
    remaining: Duration.zero,
    promptToday: false,
  );

  static const String productId = 'starter_bundle';

  /// Where the player stands at [nowMs] (epoch ms) on local day [today].
  // ignore: prefer_constructors_over_static_methods
  static StarterOffer of(
    SaveData d,
    AppConfig config, {
    required int nowMs,
    required String today,
  }) {
    if (!config.starterBundleEnabled) return closed;
    if (d.stats.levelsCleared < config.starterBundleMinLevel) return closed;
    if (d.flags['adsRemoved'] ?? false) return closed;
    if (d.purchases.contains(PurchaseFulfillment.marker(productId))) {
      return closed;
    }
    final started = d.ads.starterOfferedAt;
    final window = Duration(hours: config.starterBundleHours);
    if (started == 0) {
      // Not opened yet: it opens (and the clock starts) at the first prompt.
      return StarterOffer(open: true, remaining: window, promptToday: true);
    }
    final left = Duration(
      milliseconds: started + window.inMilliseconds - nowMs,
    );
    if (left <= Duration.zero) return closed;
    return StarterOffer(
      open: true,
      remaining: left,
      promptToday: d.ads.starterShownDate != today,
    );
  }

  /// The save after the sheet was shown: starts the clock the first time.
  static SaveData shown(
    SaveData d, {
    required int nowMs,
    required String today,
  }) => d.copyWith(
    ads: d.ads.copyWith(
      starterOfferedAt: d.ads.starterOfferedAt == 0
          ? nowMs
          : d.ads.starterOfferedAt,
      starterShownDate: today,
    ),
  );
}
