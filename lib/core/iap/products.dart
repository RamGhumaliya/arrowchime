import 'package:arrowchime/core/cosmetics/cosmetics.dart';
import 'package:arrowchime/core/remote_config/app_config.dart';

/// What a store product is (`docs/08` §3).
enum ProductKind { consumable, nonConsumable }

/// A real-money product and what it gives.
class IapProduct {
  const new({
    required this.id,
    required this.kind,
    this.coins = 0,
    this.removesAds = false,
    this.cosmetics = const [],
  });

  /// Store product id (the same on Google Play and the App Store).
  final String id;
  final ProductKind kind;
  final int coins;
  final bool removesAds;

  /// Inventory keys granted (`arrow:neon`).
  final List<String> cosmetics;
}

/// The catalogue of `docs/08` §3. Amounts come from Remote Config.
class Products {
  new(AppConfig config)
    : removeAds = IapProduct(
        id: 'remove_ads',
        kind: ProductKind.nonConsumable,
        coins: config.removeAdsBonusCoins,
        removesAds: true,
      ),
      starterBundle = IapProduct(
        id: 'starter_bundle',
        kind: ProductKind.nonConsumable,
        coins: config.starterBundleCoins,
        removesAds: true,
        cosmetics: [Cosmetics.key(CosmeticKind.arrow, 'neon')],
      ),
      coinPouch = IapProduct(
        id: 'coins_pouch',
        kind: ProductKind.consumable,
        coins: config.coinPouch,
      ),
      coinChest = IapProduct(
        id: 'coins_chest',
        kind: ProductKind.consumable,
        coins: config.coinChest,
      ),
      coinVault = IapProduct(
        id: 'coins_vault',
        kind: ProductKind.consumable,
        coins: config.coinVault,
      ),
      artPack = IapProduct(
        id: 'art_pack',
        kind: ProductKind.nonConsumable,
        cosmetics: [
          Cosmetics.key(CosmeticKind.trail, 'ribbons'),
          Cosmetics.key(CosmeticKind.instrument, 'marimba'),
          Cosmetics.key(CosmeticKind.arrow, 'paper'),
        ],
      );

  final IapProduct removeAds;
  final IapProduct starterBundle;
  final IapProduct coinPouch;
  final IapProduct coinChest;
  final IapProduct coinVault;

  /// "Chapter Art Pack": a skin, a trail and an instrument as a set.
  final IapProduct artPack;

  List<IapProduct> get all => [
    starterBundle,
    removeAds,
    coinPouch,
    coinChest,
    coinVault,
    artPack,
  ];

  IapProduct? byId(String id) {
    for (final p in all) {
      if (p.id == id) return p;
    }
    return null;
  }
}
