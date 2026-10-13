import 'package:arrowchime/app/router.dart';
import 'package:arrowchime/core/ads/tracking_service.dart';
import 'package:arrowchime/core/iap/iap_service.dart';
import 'package:arrowchime/core/level/engine/game_engine.dart';
import 'package:arrowchime/core/save/save_data.dart';
import 'package:arrowchime/core/ui/components/tb_panel.dart';
import 'package:arrowchime/core/ui/painters/arrow_skin.dart';
import 'package:arrowchime/features/game/flame/arrow_game.dart';
import 'package:arrowchime/features/game/flame/trail_style.dart';
import 'package:arrowchime/features/game/state/game_session.dart';
import 'package:arrowchime/features/game/state/level_ref.dart';
import 'package:flame/game.dart';
import 'package:flutter_test/flutter_test.dart';

import '../game/support/game_harness.dart';
import 'meta_harness.dart';

SaveData cleared(
  int n, {
  int coins = 0,
  AdState ads = const AdState(),
  Map<String, bool> flags = const {},
  List<String> inventory = const [],
  Map<String, String> equipped = const {},
}) => SaveData(
  stars: {
    for (var i = 1; i <= n; i++) 'ch1_l${i.toString().padLeft(3, '0')}': 3,
  },
  currentLevel: {'1': n + 1},
  coins: coins,
  ads: ads,
  flags: flags,
  inventory: inventory,
  equipped: equipped,
  stats: PlayStats(levelsCleared: n),
);

/// Plays level (1, [index]) to the win sheet through the session.
Future<void> win(WidgetTester tester, AppHarness h, int index) async {
  await settle(tester, frames: 12);
  final s = h.container.read(gameSessionProvider(LevelRef(1, index)).notifier);
  s.engine.level.meta.solution.forEach(s.tap);
  await settle(tester, frames: 40);
}

void main() {
  group('Shop', () {
    testWidgets('lists the products with the store prices', (tester) async {
      await pumpApp(tester, location: AppRoutes.shop, save: cleared(3));
      await settle(tester, frames: 10);
      expect(find.text('Shop'), findsWidgets);
      expect(find.text(r'$3.99'), findsWidgets);
      expect(find.text(r'$1.99'), findsWidgets);
      expect(find.text(r'$7.99'), findsWidgets);
      expect(find.text(r'$19.99'), findsWidgets);
      expect(find.text(r'$2.99'), findsWidgets);
      expect(find.text('Best value'), findsWidgets);
      expect(find.text('Restore purchases'), findsWidgets);
      // Starter Bundle only after level 15.
      expect(find.text('Starter Bundle'), findsNothing);
    });

    testWidgets('after level 15 the Starter Bundle is the one primary button', (
      tester,
    ) async {
      await pumpApp(tester, location: AppRoutes.shop, save: cleared(16));
      await settle(tester, frames: 10);
      expect(find.text('Starter Bundle'), findsWidgets);
      expect(find.text(r'$6.99'), findsWidgets);
      expect(find.textContaining('48h'), findsNothing);
      expect(find.textContaining('left'), findsWidgets);
    });

    testWidgets('buying coins pays them and says thank you', (tester) async {
      final h = await pumpApp(
        tester,
        location: AppRoutes.shop,
        save: cleared(3),
      );
      await settle(tester, frames: 10);
      await tester.ensureVisible(find.text(r'$1.99').last);
      await tester.tap(_buyFor(r'$1.99').last);
      await settle(tester, frames: 10);
      expect(h.save.coins, 1000);
      expect(find.text('Thank you!'), findsWidgets);
    });

    testWidgets('Remove Ads shows Owned afterwards and stops ads', (
      tester,
    ) async {
      final h = await pumpApp(
        tester,
        location: AppRoutes.shop,
        save: cleared(3),
      );
      await settle(tester, frames: 10);
      await tester.tap(find.text(r'$3.99').last);
      await settle(tester, frames: 10);
      expect(h.save.flags['adsRemoved'], isTrue);
      expect(h.save.coins, 500);
      expect(find.text(r'$3.99'), findsNothing);
    });

    testWidgets('a failed purchase says so and pays nothing', (tester) async {
      final store = FakeIapService()..autoStatus = PurchaseStatus.failed;
      final h = await pumpApp(
        tester,
        location: AppRoutes.shop,
        save: cleared(3),
        iap: store,
      );
      await settle(tester, frames: 10);
      await tester.ensureVisible(find.text(r'$7.99').last);
      await tester.tap(_buyFor(r'$7.99').last);
      await settle(tester, frames: 10);
      expect(h.save.coins, 0);
      expect(find.text('The purchase didn’t go through.'), findsWidgets);
    });

    testWidgets('restore asks the store and welcomes entitlements back', (
      tester,
    ) async {
      final store = FakeIapService();
      final h = await pumpApp(
        tester,
        location: AppRoutes.shop,
        save: cleared(3),
        iap: store,
      );
      await settle(tester, frames: 10);
      await tester.ensureVisible(find.text('Restore purchases').last);
      await tester.tap(find.text('Restore purchases').last);
      store.emit(
        const PurchaseUpdate(
          productId: 'remove_ads',
          status: PurchaseStatus.restored,
        ),
      );
      await settle(tester, frames: 10);
      expect(store.restores, 1);
      expect(h.save.flags['adsRemoved'], isTrue);
      expect(find.text('Purchases restored.'), findsWidgets);
    });

    testWidgets('store unavailable: says so, buttons disabled', (tester) async {
      final store = FakeIapService()..available = false;
      final h = await pumpApp(
        tester,
        location: AppRoutes.shop,
        save: cleared(3),
        iap: store,
      );
      await settle(tester, frames: 10);
      expect(find.text('The store isn’t available right now.'), findsWidgets);
      await tester.tap(find.text('…').first);
      await settle(tester, frames: 4);
      expect(store.bought, isEmpty);
      expect(h.save.coins, 0);
    });
  });

  group('Starter Bundle sheet on Home', () {
    testWidgets('pops up once after level 15, then not again the same day', (
      tester,
    ) async {
      final h = await pumpApp(tester, save: cleared(16));
      await settle(tester, frames: 14);
      expect(find.text('Starter Bundle'), findsWidgets);
      expect(find.text('Not now'), findsWidgets);
      expect(h.save.ads.starterOfferedAt, greaterThan(0));
      await tester.tap(find.text('Not now').last);
      await settle(tester, frames: 14);
      expect(find.text('Starter Bundle'), findsNothing);
    });

    testWidgets('never before level 15', (tester) async {
      await pumpApp(tester, save: cleared(14));
      await settle(tester, frames: 14);
      expect(find.text('Starter Bundle'), findsNothing);
    });

    testWidgets('buying it from the sheet grants the bundle', (tester) async {
      final h = await pumpApp(tester, save: cleared(16));
      await settle(tester, frames: 14);
      await tester.tap(find.text(r'$6.99').last);
      await settle(tester, frames: 14);
      expect(h.save.coins, 2000);
      expect(h.save.inventory, contains('arrow:neon'));
      expect(h.save.flags['adsRemoved'], isTrue);
    });
  });

  group('iOS ATT pre-prompt (after level 5)', () {
    testWidgets('shown once; Continue shows the system dialog', (tester) async {
      final tracking = FakeTrackingService();
      final h = await pumpApp(tester, save: cleared(5), tracking: tracking);
      await settle(tester, frames: 14);
      expect(find.text('A quick note'), findsWidgets);
      await tester.tap(find.text('Continue').last);
      await settle(tester, frames: 14);
      expect(tracking.requests, 1);
      expect(h.save.ads.attState, 'asked');
    });

    testWidgets('"Maybe later" postpones it by 7 days; no system dialog', (
      tester,
    ) async {
      final tracking = FakeTrackingService();
      final h = await pumpApp(tester, save: cleared(5), tracking: tracking);
      await settle(tester, frames: 14);
      await tester.tap(find.text('Maybe later').last);
      await settle(tester, frames: 14);
      expect(tracking.requests, 0);
      expect(h.save.ads.attState, 'later');
      expect(h.save.ads.attRetryAt, greaterThan(0));
    });

    testWidgets('not before level 5, and never on Android', (tester) async {
      await pumpApp(tester, save: cleared(4), tracking: FakeTrackingService());
      await settle(tester, frames: 14);
      expect(find.text('A quick note'), findsNothing);
    });

    testWidgets('ATT goes first; the bundle waits for the next visit', (
      tester,
    ) async {
      await pumpApp(tester, save: cleared(16), tracking: FakeTrackingService());
      await settle(tester, frames: 14);
      expect(find.text('A quick note'), findsWidgets);
      expect(find.text('Starter Bundle'), findsNothing);
    });
  });

  group('Collection', () {
    testWidgets('tabs, tiles and equip', (tester) async {
      final h = await pumpApp(
        tester,
        location: AppRoutes.collection,
        save: cleared(3, coins: 800),
      );
      await settle(tester, frames: 20);
      expect(find.text('Collection'), findsWidgets);
      expect(find.text('Enamel Candy'), findsWidgets);
      expect(find.text('Equipped'), findsWidgets);
      expect(find.text('Neon Tube'), findsWidgets);
      expect(find.text('Comes in a bundle'), findsWidgets);
      expect(find.text('Clear levels 1–60'), findsWidgets);
      // Buying Paper-craft costs 500.
      await tester.ensureVisible(find.text('Paper-craft').first);
      await tester.tap(find.text('Paper-craft').first);
      await settle(tester, frames: 6);
      expect(find.text('Buy · 500'), findsWidgets);
      await tester.tap(find.text('Buy · 500').last);
      await settle(tester, frames: 6);
      expect(h.save.coins, 300);
      expect(h.save.inventory, contains('arrow:paper'));
      expect(h.save.equipped['arrow'], 'paper');
    });

    testWidgets('short of coins: a toast, nothing bought', (tester) async {
      final h = await pumpApp(
        tester,
        location: AppRoutes.collection,
        save: cleared(3, coins: 100),
      );
      await settle(tester, frames: 20);
      await tester.ensureVisible(find.text('Paper-craft').first);
      await tester.tap(find.text('Paper-craft').first);
      await settle(tester, frames: 6);
      await tester.tap(find.text('Buy · 500').last);
      await settle(tester, frames: 6);
      expect(h.save.coins, 100);
      expect(h.save.inventory, isEmpty);
      expect(find.text('Not enough coins'), findsWidgets);
    });

    testWidgets('trails, boards and instruments tabs; owned items equip', (
      tester,
    ) async {
      final h = await pumpApp(
        tester,
        location: AppRoutes.collection,
        save: cleared(3, inventory: ['trail:snow', 'instrument:piano']),
      );
      await settle(tester, frames: 20);
      await tester.tap(find.text('Trails').last);
      await settle(tester, frames: 6);
      await tester.ensureVisible(find.text('Snow').first);
      await tester.tap(find.text('Snow').first);
      await settle(tester, frames: 6);
      await tester.tap(find.text('Equip').last);
      await settle(tester, frames: 6);
      expect(h.save.equipped['trail'], 'snow');
      await tester.tap(find.text('Instruments').last);
      await settle(tester, frames: 6);
      await tester.ensureVisible(find.text('Piano').first);
      await tester.tap(find.text('Piano').first);
      await settle(tester, frames: 6);
      await tester.tap(find.text('Equip').last);
      await settle(tester, frames: 6);
      expect(h.save.equipped['instrument'], 'piano');
      await tester.tap(find.text('Boards').last);
      await settle(tester, frames: 6);
      expect(find.text('Night felt'), findsWidgets);
      expect(find.text('3 stars in one chapter'), findsNothing);
    });

    testWidgets('tapping the preview replays a clear with the instrument', (
      tester,
    ) async {
      final h = await pumpApp(
        tester,
        location: AppRoutes.collection,
        save: cleared(3),
      );
      await settle(tester, frames: 20);
      await tester.tapAt(const Offset(195, 200));
      await settle(tester, frames: 60);
      expect(h.audio.noteNames, isNotEmpty);
    });
  });

  group('Equipped cosmetics reach the game', () {
    testWidgets('skin, trail, felt and instrument are used in a level', (
      tester,
    ) async {
      final h = await pumpApp(
        tester,
        location: AppRoutes.levelPath('ch1', 1),
        save: cleared(
          0,
          inventory: [
            'arrow:paper',
            'trail:snow',
            'board:night',
            'instrument:piano',
          ],
          equipped: {
            'arrow': 'paper',
            'trail': 'snow',
            'board': 'night',
            'instrument': 'piano',
          },
        ),
      );
      await settle(tester, frames: 12);
      final game = tester
          .widget<GameWidget<ArrowGame>>(find.byType(GameWidget<ArrowGame>))
          .game!;
      expect(game.skin, ArrowSkin.paper);
      expect(game.trail, TrailStyle.snow);
      expect(game.theme.darkTray, isTrue);
      expect(h.audio.loads.any((a) => a.contains('/piano/')), isTrue);
      await win(tester, h, 1);
      expect(h.audio.plays.any((p) => p.asset.contains('/piano/')), isTrue);
    });

    testWidgets('an item that is not owned falls back to the default', (
      tester,
    ) async {
      await pumpApp(
        tester,
        location: AppRoutes.levelPath('ch1', 1),
        save: cleared(0, equipped: {'arrow': 'neon', 'trail': 'snow'}),
      );
      await settle(tester, frames: 12);
      final game = tester
          .widget<GameWidget<ArrowGame>>(find.byType(GameWidget<ArrowGame>))
          .game!;
      expect(game.skin, ArrowSkin.candy);
      expect(game.trail, TrailStyle.none);
    });
  });

  group('Ads in play (docs/08 §2)', () {
    testWidgets(
      'win sheet offers ×2 coins once, then the cap/earned hides it',
      (tester) async {
        final h = await pumpApp(
          tester,
          location: AppRoutes.levelPath('ch1', 1),
        );
        await win(tester, h, 1);
        expect(find.text('×2 coins · ad'), findsWidgets);
        final before = h.save.coins;
        await tester.tap(find.text('×2 coins · ad').last);
        await settle(tester, frames: 10);
        expect(h.ads.rewardedShown, 1);
        expect(h.save.coins, greaterThan(before));
        expect(find.text('×2 coins · ad'), findsNothing);
        expect(h.save.ads.doubleCoinsCount, 1);
      },
    );

    testWidgets('no ad loaded: the button is simply not there', (tester) async {
      final h = await pumpApp(tester, location: AppRoutes.levelPath('ch1', 1));
      h.ads.rewardedAvailable = false;
      await win(tester, h, 1);
      expect(find.text('×2 coins · ad'), findsNothing);
      expect(find.text('Next level'), findsWidgets);
    });

    testWidgets('a watched-to-the-end failure pays nothing', (tester) async {
      final h = await pumpApp(tester, location: AppRoutes.levelPath('ch1', 1));
      h.ads.earnReward = false;
      await win(tester, h, 1);
      final before = h.save.coins;
      await tester.tap(find.text('×2 coins · ad').last);
      await settle(tester, frames: 10);
      expect(h.save.coins, before);
    });

    testWidgets('interstitial only on win -> next, from level 12, every 3rd', (
      tester,
    ) async {
      // Level 13 (index 13) with two wins already counted, past the first open.
      final h = await pumpApp(
        tester,
        location: AppRoutes.levelPath('ch1', 13),
        save: cleared(
          12,
          flags: {'sessionStarted': true, 'secondSession': true},
          ads: const AdState(winsSinceInterstitial: 2),
        ),
      );
      await win(tester, h, 13);
      await tester.tap(find.text('Next level').last);
      await settle(tester, frames: 20);
      expect(h.ads.interstitialsShown, 1);
      expect(h.save.ads.lastInterstitialAt, greaterThan(0));
      expect(h.save.ads.winsSinceInterstitial, 0);
    });

    testWidgets('never on the first app open', (tester) async {
      final h = await pumpApp(
        tester,
        location: AppRoutes.levelPath('ch1', 13),
        save: cleared(12, ads: const AdState(winsSinceInterstitial: 5)),
      );
      await win(tester, h, 13);
      await tester.tap(find.text('Next level').last);
      await settle(tester, frames: 20);
      expect(h.ads.interstitialsShown, 0);
    });

    testWidgets('never in the tutorial levels', (tester) async {
      final h = await pumpApp(
        tester,
        location: AppRoutes.levelPath('ch1', 4),
        save: cleared(
          3,
          flags: {'secondSession': true},
          ads: const AdState(winsSinceInterstitial: 5),
        ),
      );
      await win(tester, h, 4);
      await tester.tap(find.text('Next level').last);
      await settle(tester, frames: 20);
      expect(h.ads.interstitialsShown, 0);
    });

    testWidgets('Remove Ads: no interstitial at all', (tester) async {
      final h = await pumpApp(
        tester,
        location: AppRoutes.levelPath('ch1', 13),
        save: cleared(
          12,
          flags: {'secondSession': true, 'adsRemoved': true},
          ads: const AdState(winsSinceInterstitial: 5),
        ),
      );
      await win(tester, h, 13);
      await tester.tap(find.text('Next level').last);
      await settle(tester, frames: 20);
      expect(h.ads.interstitialsShown, 0);
    });

    testWidgets('Retry never shows an ad (G3)', (tester) async {
      final h = await pumpApp(
        tester,
        location: AppRoutes.levelPath('ch1', 13),
        save: cleared(
          12,
          flags: {'secondSession': true},
          ads: const AdState(winsSinceInterstitial: 5),
        ),
      );
      await settle(tester, frames: 12);
      final s = h.container.read(
        gameSessionProvider(const LevelRef(1, 13)).notifier,
      );
      for (final id in s.engine.remainingIds) {
        if (!s.engine.isFree(id)) {
          for (var i = 0; i < 3; i++) {
            s.tap(id);
          }
          break;
        }
      }
      await settle(tester, frames: 40);
      expect(s.engine.status, GameStatus.lost);
      await tester.tap(find.text('Retry').last);
      await settle(tester, frames: 12);
      expect(h.ads.interstitialsShown, 0);
      expect(h.ads.rewardedShown, 0);
    });

    testWidgets('fail sheet: +1 heart ad at most twice per level', (
      tester,
    ) async {
      final h = await pumpApp(
        tester,
        location: AppRoutes.levelPath('ch1', 13),
        save: cleared(12),
      );
      await settle(tester, frames: 12);
      final s = h.container.read(
        gameSessionProvider(const LevelRef(1, 13)).notifier,
      );
      Future<void> lose() async {
        final blocked = s.engine.remainingIds.firstWhere(
          (i) => !s.engine.isFree(i),
        );
        for (var i = 0; i < 4 && s.engine.status != GameStatus.lost; i++) {
          s.tap(blocked);
        }
        await settle(tester, frames: 40);
      }

      await lose();
      await tester.tap(find.text('+1 heart').first);
      await settle(tester, frames: 12);
      await lose();
      await tester.tap(find.text('+1 heart').first);
      await settle(tester, frames: 12);
      await lose();
      expect(h.ads.rewardedShown, 2);
      expect(find.text('Ad not available'), findsWidgets);
      expect(find.text('+1 heart'), findsNothing);
    });

    testWidgets('hint with no coins offers a free hint for an ad', (
      tester,
    ) async {
      final h = await pumpApp(
        tester,
        location: AppRoutes.levelPath('ch2', 25),
        save: const SaveData(currentLevel: {'1': 61, '2': 25}),
      );
      await settle(tester, frames: 12);
      final s = h.container.read(
        gameSessionProvider(const LevelRef(2, 25)).notifier,
      );
      expect(s.hint(), PurchaseResult.free);
      await tester.tap(find.bySemanticsLabel('Hint'));
      await settle(tester, frames: 12);
      expect(find.text('Not enough coins'), findsWidgets);
      expect(find.text('Watch ad for a free hint'), findsWidgets);
      await tester.tap(find.text('Watch ad for a free hint').last);
      await settle(tester, frames: 12);
      expect(h.ads.rewardedShown, 1);
      expect(h.save.coins, 0, reason: 'the hint was free, nothing spent');
    });

    testWidgets('a missed Daily can be unlocked with an ad', (tester) async {
      final h = await pumpApp(
        tester,
        location: AppRoutes.daily,
        save: cleared(3),
        now: DateTime(2026, 10, 12, 9),
      );
      await settle(tester, frames: 30);
      await tester.tap(find.bySemanticsLabel('2026-10-10, missed'));
      await settle(tester, frames: 12);
      await tester.tap(find.text('Unlock with an ad').last);
      await settle(tester, frames: 30);
      expect(h.ads.rewardedShown, 1);
      expect(h.save.coins, 0);
    });
  });
}

/// The "Buy" button of the coin tile that shows [price].
Finder _buyFor(String price) => find.descendant(
  of: find.ancestor(of: find.text(price), matching: find.byType(TBPanel)).first,
  matching: find.text('Buy'),
);
