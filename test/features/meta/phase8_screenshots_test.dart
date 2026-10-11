import 'package:arrowchime/app/router.dart';
import 'package:arrowchime/core/ads/tracking_service.dart';
import 'package:arrowchime/core/level/engine/game_engine.dart';
import 'package:arrowchime/core/save/save_data.dart';
import 'package:arrowchime/features/game/state/game_session.dart';
import 'package:arrowchime/features/game/state/level_ref.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../core/ui/support/ui_harness.dart';
import '../game/support/game_harness.dart';
import 'meta_harness.dart';

/// Design review gate (`docs/10` §11) for the Phase 8 screens, at iPhone SE and
/// Pro Max (portrait) and an Android tablet (landscape), saved under
/// `docs/screenshots/phase8/`. Regenerate with
/// `flutter test --update-goldens test/features/meta/phase8_screenshots_test.dart`.
void main() {
  const devices = <String, Size>{
    'iphone_se': Size(375, 667),
    'iphone_pro_max': Size(430, 932),
    'android_tablet': Size(1280, 800),
  };

  SaveData player({
    int cleared = 20,
    int coins = 1800,
    List<String> inventory = const ['arrow:paper', 'trail:snow'],
    Map<String, String> equipped = const {'arrow': 'paper'},
    AdState ads = const AdState(starterShownDate: '2026-10-10'),
  }) => SaveData(
    stars: {
      for (var i = 1; i <= cleared; i++)
        'ch1_l${i.toString().padLeft(3, '0')}': 3,
    },
    currentLevel: {'1': cleared + 1},
    coins: coins,
    inventory: inventory,
    equipped: equipped,
    ads: ads,
    stats: PlayStats(levelsCleared: cleared),
    flags: const {'secondSession': true},
  );

  Future<void> shot(WidgetTester tester, String name) => expectLater(
    find.byKey(surfaceKey),
    matchesGoldenFile('../../../docs/screenshots/phase8/$name.png'),
  );

  for (final device in devices.entries) {
    group(device.key, () {
      testWidgets('shop with the Starter Bundle', (tester) async {
        await pumpApp(
          tester,
          size: device.value,
          location: AppRoutes.shop,
          save: player(),
        );
        await settle(tester, frames: 12);
        await shot(tester, 'shop_${device.key}');
      });

      testWidgets('shop after Remove Ads', (tester) async {
        await pumpApp(
          tester,
          size: device.value,
          location: AppRoutes.shop,
          save: player().copyWith(
            flags: const {'adsRemoved': true},
            purchases: const ['product:remove_ads'],
          ),
        );
        await settle(tester, frames: 12);
        await shot(tester, 'shop_owned_${device.key}');
      });

      for (final entry in {
        'arrows': 0,
        'trails': 1,
        'boards': 2,
        'instruments': 3,
      }.entries) {
        testWidgets('collection ${entry.key}', (tester) async {
          await pumpApp(
            tester,
            size: device.value,
            location: AppRoutes.collection,
            save: player(),
          );
          await settle(tester, frames: 20);
          if (entry.value > 0) {
            final labels = ['', 'Trails', 'Boards', 'Instruments'];
            await tester.tap(find.text(labels[entry.value]).last);
            await settle(tester);
          }
          await shot(tester, 'collection_${entry.key}_${device.key}');
        });
      }

      testWidgets('starter bundle sheet', (tester) async {
        await pumpApp(
          tester,
          size: device.value,
          save: player(ads: const AdState()),
        );
        await settle(tester, frames: 16);
        await shot(tester, 'starter_sheet_${device.key}');
      });

      testWidgets('ATT pre-prompt', (tester) async {
        await pumpApp(
          tester,
          size: device.value,
          save: player(cleared: 6),
          tracking: FakeTrackingService(),
        );
        await settle(tester, frames: 16);
        await shot(tester, 'att_sheet_${device.key}');
      });

      testWidgets('win sheet with double coins', (tester) async {
        final h = await pumpApp(
          tester,
          size: device.value,
          location: AppRoutes.levelPath('ch1', 21),
          save: player(),
        );
        await settle(tester, frames: 12);
        final s = h.container.read(
          gameSessionProvider(const LevelRef(1, 21)).notifier,
        );
        s.engine.level.meta.solution.forEach(s.tap);
        await settle(tester, frames: 50);
        await shot(tester, 'win_double_${device.key}');
      });

      testWidgets('fail sheet, ad not available', (tester) async {
        final h = await pumpApp(
          tester,
          size: device.value,
          location: AppRoutes.levelPath('ch1', 21),
          save: player(),
        );
        h.ads.rewardedAvailable = false;
        await settle(tester, frames: 12);
        final s = h.container.read(
          gameSessionProvider(const LevelRef(1, 21)).notifier,
        );
        final blocked = s.engine.remainingIds.firstWhere(
          (i) => !s.engine.isFree(i),
        );
        for (var i = 0; i < 3 && s.engine.status != GameStatus.lost; i++) {
          s.tap(blocked);
        }
        await settle(tester, frames: 50);
        await shot(tester, 'fail_no_ad_${device.key}');
      });
    });
  }
}
