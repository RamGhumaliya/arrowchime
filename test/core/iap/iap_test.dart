import 'package:arrowchime/core/ads/ad_policy.dart';
import 'package:arrowchime/core/ads/ads_controller.dart';
import 'package:arrowchime/core/ads/ads_service.dart';
import 'package:arrowchime/core/cosmetics/cosmetics.dart';
import 'package:arrowchime/core/iap/iap_controller.dart';
import 'package:arrowchime/core/iap/iap_service.dart';
import 'package:arrowchime/core/iap/products.dart';
import 'package:arrowchime/core/iap/purchase_fulfillment.dart';
import 'package:arrowchime/core/remote_config/app_config.dart';
import 'package:arrowchime/core/save/save_controller.dart';
import 'package:arrowchime/core/save/save_data.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

PurchaseUpdate bought(String id, [String? tx = 'tx1']) => PurchaseUpdate(
  productId: id,
  status: PurchaseStatus.purchased,
  transactionId: tx,
);

PurchaseUpdate restored(String id) =>
    PurchaseUpdate(productId: id, status: PurchaseStatus.restored);

void main() {
  final config = AppConfig.defaults();
  final products = Products(config);
  final ads = AdPolicy(config);
  const now = 1000000000000;

  SaveData apply(SaveData d, PurchaseUpdate u) =>
      PurchaseFulfillment.apply(d, u, products, ads, nowMs: now);

  group('catalogue (docs/08 §3)', () {
    test('contents and Remote Config amounts', () {
      expect(products.all, hasLength(6));
      expect(products.removeAds.coins, 500);
      expect(products.removeAds.removesAds, isTrue);
      expect(products.starterBundle.coins, 2000);
      expect(products.starterBundle.cosmetics, ['arrow:neon']);
      expect(
        [
          products.coinPouch.coins,
          products.coinChest.coins,
          products.coinVault.coins,
        ],
        [1000, 5500, 15000],
      );
      expect(products.coinPouch.kind, ProductKind.consumable);
      expect(products.artPack.cosmetics, hasLength(3));
      expect(products.byId('nope'), isNull);
      expect(products.byId('coins_chest'), same(products.coinChest));
    });
  });

  group('fulfilment', () {
    test('coins are paid and the ad holiday starts', () {
      final d = apply(const SaveData(coins: 10), bought('coins_pouch'));
      expect(d.coins, 1010);
      expect(d.purchases, ['tx1']);
      expect(d.ads.holidayUntil, now + 24 * 3600 * 1000);
    });

    test('Remove Ads: flag + 500 coins; interstitials stop at once', () {
      final d = apply(const SaveData(), bought('remove_ads'));
      expect(d.flags['adsRemoved'], isTrue);
      expect(d.coins, 500);
      expect(d.purchases, containsAll(['tx1', 'product:remove_ads']));
    });

    test('Starter Bundle: Remove Ads + 2,000 coins + the Neon skin', () {
      final d = apply(const SaveData(), bought('starter_bundle'));
      expect(d.flags['adsRemoved'], isTrue);
      expect(d.coins, 2000);
      expect(d.inventory, ['arrow:neon']);
      expect(
        Cosmetics.isOwned(d, Cosmetics.find(CosmeticKind.arrow, 'neon')!),
        isTrue,
      );
    });

    test('Chapter Art Pack: skin + trail + instrument', () {
      final d = apply(const SaveData(), bought('art_pack'));
      expect(
        d.inventory,
        containsAll(['trail:ribbons', 'instrument:marimba', 'arrow:paper']),
      );
      expect(d.coins, 0);
    });

    test('purchases are idempotent: the same transaction pays once', () {
      var d = apply(const SaveData(), bought('coins_chest', 'tx9'));
      d = apply(d, bought('coins_chest', 'tx9'));
      expect(d.coins, 5500);
      // A new transaction of a consumable pays again.
      d = apply(d, bought('coins_chest', 'tx10'));
      expect(d.coins, 11000);
    });

    test(
      'a second purchase of a non-consumable never pays its coins twice',
      () {
        var d = apply(const SaveData(), bought('remove_ads', 'a'));
        d = apply(d, bought('remove_ads', 'b'));
        expect(d.coins, 500);
      },
    );

    test(
      'restore on a fresh install: entitlements back, no free repeat coins',
      () {
        // Fresh install: empty save, the store replays the non-consumables.
        var d = apply(const SaveData(), restored('remove_ads'));
        d = apply(d, restored('art_pack'));
        expect(d.flags['adsRemoved'], isTrue);
        expect(d.inventory, contains('arrow:paper'));
        // The one-time bonus is paid on the first restore only.
        expect(d.coins, 500);
        d = apply(d, restored('remove_ads'));
        expect(d.coins, 500);
        // Restoring does not start an ad holiday and ignores consumables.
        expect(d.ads.holidayUntil, 0);
        expect(
          apply(const SaveData(), restored('coins_pouch')),
          const SaveData(),
        );
      },
    );

    test('pending, failed, canceled and unknown products change nothing', () {
      const d = SaveData(coins: 5);
      for (final s in [
        PurchaseStatus.pending,
        PurchaseStatus.failed,
        PurchaseStatus.canceled,
      ]) {
        expect(apply(d, PurchaseUpdate(productId: 'remove_ads', status: s)), d);
      }
      expect(apply(d, bought('mystery')), d);
    });

    test('a purchase without a transaction id still pays', () {
      final d = apply(const SaveData(), bought('coins_pouch', null));
      expect(d.coins, 1000);
      expect(d.purchases, isEmpty);
    });
  });

  group('IapController', () {
    late FakeIapService store;
    late ProviderContainer c;

    setUp(() {
      store = FakeIapService();
      c = ProviderContainer(
        overrides: [
          saveDebounceProvider.overrideWithValue(null),
          iapServiceProvider.overrideWithValue(store),
          adsServiceProvider.overrideWithValue(FakeAdsService()),
          clockProvider.overrideWithValue(
            () => DateTime.fromMillisecondsSinceEpoch(now),
          ),
        ],
      );
      addTearDown(c.dispose);
    });

    test('buy -> thank you, coins in the save', () async {
      final ctl = c.read(iapControllerProvider);
      final outcomes = <PurchaseOutcome>[];
      ctl.outcomes.listen(outcomes.add);
      await ctl.buy(c.read(productsProvider).coinPouch);
      await Future<void>.delayed(Duration.zero);
      expect(store.bought, ['coins_pouch']);
      expect(c.read(saveControllerProvider).coins, 1000);
      expect(outcomes, [PurchaseOutcome.thankYou]);
    });

    test('a failed purchase says so and pays nothing', () async {
      store.autoStatus = PurchaseStatus.failed;
      final ctl = c.read(iapControllerProvider);
      final outcomes = <PurchaseOutcome>[];
      ctl.outcomes.listen(outcomes.add);
      await ctl.buy(c.read(productsProvider).removeAds);
      await Future<void>.delayed(Duration.zero);
      expect(outcomes, [PurchaseOutcome.failed]);
      expect(c.read(saveControllerProvider).coins, 0);
    });

    test(
      'restore asks the store; restored events grant entitlements',
      () async {
        final ctl = c.read(iapControllerProvider);
        final outcomes = <PurchaseOutcome>[];
        ctl.outcomes.listen(outcomes.add);
        await ctl.restore();
        expect(store.restores, 1);
        store.emit(restored('remove_ads'));
        await Future<void>.delayed(Duration.zero);
        expect(c.read(saveControllerProvider).flags['adsRemoved'], isTrue);
        expect(outcomes, [PurchaseOutcome.restored]);
      },
    );

    test('prices come from the store; none when it is unavailable', () async {
      final ctl = c.read(iapControllerProvider);
      expect((await ctl.prices())['remove_ads'], r'$3.99');
      store.available = false;
      expect(await ctl.prices(), isEmpty);
    });

    test('after Remove Ads the ad controller refuses interstitials', () async {
      final ctl = c.read(iapControllerProvider);
      await ctl.buy(c.read(productsProvider).removeAds);
      await Future<void>.delayed(Duration.zero);
      final adsCtl = c.read(adsControllerProvider);
      expect(adsCtl.adsRemoved, isTrue);
      expect(
        await adsCtl.maybeInterstitialAfterWin(
          levelNumber: 30,
          isDaily: false,
          isTutorial: false,
        ),
        isFalse,
      );
    });
  });

  group('Cosmetics', () {
    final neon = Cosmetics.find(CosmeticKind.arrow, 'neon')!;
    final paper = Cosmetics.find(CosmeticKind.arrow, 'paper')!;
    final bamboo = Cosmetics.find(CosmeticKind.arrow, 'bamboo')!;

    test('catalogue: nine skins, four trails, defaults free', () {
      expect(Cosmetics.of(CosmeticKind.arrow), hasLength(9));
      expect(
        Cosmetics.of(CosmeticKind.trail).where((c) => c.id != 'none'),
        hasLength(4),
      );
      for (final k in CosmeticKind.values) {
        expect(Cosmetics.of(k).where((c) => c.isDefault), hasLength(1));
      }
      expect(Cosmetics.find(CosmeticKind.arrow, 'x'), isNull);
      expect(Cosmetics.key(CosmeticKind.arrow, 'neon'), 'arrow:neon');
    });

    test('prices by tier from Remote Config; bundle and chapter items are not for sale', () {
      expect(Cosmetics.price(paper, config), 500);
      expect(
        Cosmetics.price(Cosmetics.find(CosmeticKind.arrow, 'pixel')!, config),
        1500,
      );
      expect(
        Cosmetics.price(
          Cosmetics.find(CosmeticKind.instrument, 'choir')!,
          config,
        ),
        4000,
      );
      expect(Cosmetics.price(neon, config), isNull);
      expect(Cosmetics.price(bamboo, config), isNull);
    });

    test('chapter skins are earned by restoring the chapter', () {
      expect(Cosmetics.isOwned(const SaveData(), bamboo), isFalse);
      const done = SaveData(currentLevel: {'1': 61});
      expect(Cosmetics.isOwned(done, bamboo), isTrue);
      expect(Cosmetics.requirement(bamboo), 'chapter:1');
    });

    test('Constellation items by stars in one chapter', () {
      final star = Cosmetics.find(CosmeticKind.board, 'constellation')!;
      const few = SaveData(stars: {'ch1_l001': 3});
      expect(Cosmetics.isOwned(few, star), isFalse);
      final many = SaveData(
        stars: {
          for (var i = 1; i <= 40; i++)
            'ch2_l${i.toString().padLeft(3, '0')}': 3,
        },
      );
      expect(Cosmetics.isOwned(many, star), isTrue);
    });

    test(
      'buy: coins spent once, inventory grows, not for sale / short of coins',
      () {
        const d = SaveData(coins: 600);
        final bought = Cosmetics.buy(d, paper, config)!;
        expect(bought.coins, 100);
        expect(bought.inventory, ['arrow:paper']);
        expect(Cosmetics.buy(bought, paper, config), isNull, reason: 'owned');
        expect(
          Cosmetics.buy(const SaveData(coins: 100), paper, config),
          isNull,
        );
        expect(Cosmetics.buy(d, neon, config), isNull);
      },
    );

    test(
      'equip only owned items; unowned equipped falls back to the default',
      () {
        expect(Cosmetics.equip(const SaveData(), paper), isNull);
        final d = Cosmetics.equip(
          Cosmetics.buy(const SaveData(coins: 500), paper, config)!,
          paper,
        )!;
        expect(Cosmetics.equipped(d, CosmeticKind.arrow), 'paper');
        expect(
          Cosmetics.equipped(const SaveData(), CosmeticKind.arrow),
          'candy',
        );
        const bad = SaveData(equipped: {'arrow': 'neon'});
        expect(Cosmetics.equipped(bad, CosmeticKind.arrow), 'candy');
        expect(
          Cosmetics.equipped(
            const SaveData(equipped: {'arrow': 'ghost'}),
            CosmeticKind.arrow,
          ),
          'candy',
        );
      },
    );

    test('grant skips what is already there', () {
      final d = Cosmetics.grant(const SaveData(inventory: ['arrow:neon']), [
        'arrow:neon',
        'trail:snow',
      ]);
      expect(d.inventory, ['arrow:neon', 'trail:snow']);
    });
  });
}
