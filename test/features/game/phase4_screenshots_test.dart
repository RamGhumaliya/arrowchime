import 'package:arrowchime/core/level/models/level.dart';
import 'package:arrowchime/features/game/flame/arrow_game.dart';
import 'package:arrowchime/features/game/state/level_ref.dart';
import 'package:flame/game.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../core/level/support/fixtures.dart';
import '../../core/ui/support/ui_harness.dart';
import 'support/game_harness.dart';

/// Design review gate (`docs/10` §11) for the game screen: a normal board, the
/// densest shipped board at 1x and 4x, and both result sheets, at iPhone SE
/// and Pro Max (portrait) and on an Android tablet (landscape), saved under
/// `docs/screenshots/phase4/`. Regenerate with
/// `flutter test --update-goldens test/features/game/phase4_screenshots_test.dart`.
void main() {
  const devices = <String, Size>{
    'iphone_se': Size(375, 667),
    'iphone_pro_max': Size(430, 932),
    'android_tablet': Size(1280, 800),
  };
  const normal = LevelRef(1, 20);
  const dense = LevelRef(5, 60);

  Future<void> shot(WidgetTester tester, String name) => expectLater(
    find.byKey(surfaceKey),
    matchesGoldenFile('../../../docs/screenshots/phase4/$name.png'),
  );

  for (final device in devices.entries) {
    group(device.key, () {
      testWidgets('board', (tester) async {
        await pumpGame(tester, id: normal, size: device.value);
        await shot(tester, 'board_${device.key}');
      });

      testWidgets('dense board, fit and 4x', (tester) async {
        await pumpGame(tester, id: dense, size: device.value);
        await shot(tester, 'dense_${device.key}');
        final game = tester
            .widget<GameWidget<ArrowGame>>(find.byType(GameWidget<ArrowGame>))
            .game!;
        game.zoomBy(game.view.viewport.center(Offset.zero), 4);
        await settle(tester);
        await shot(tester, 'dense_4x_${device.key}');
      });

      testWidgets('win sheet', (tester) async {
        final h = await pumpGame(tester, id: normal, size: device.value);
        for (final id in h.session.engine.level.meta.solution) {
          h.session.tap(id);
          await settle(tester, frames: 2);
        }
        await settle(tester, frames: 40);
        await shot(tester, 'win_${device.key}');
      });

      testWidgets('fail sheet', (tester) async {
        final h = await pumpGame(tester, id: normal, size: device.value);
        final engine = h.session.engine;
        // Tap blocked arrows until the hearts run out.
        for (var guard = 0; guard < 40; guard++) {
          final blocked = [
            for (final id in engine.remainingIds)
              if (!engine.isFree(id)) id,
          ];
          if (blocked.isEmpty) break;
          h.session.tap(blocked.first);
          await settle(tester, frames: 2);
        }
        await settle(tester, frames: 40);
        await shot(tester, 'fail_${device.key}');
      });
    });
  }

  // The five mechanics on small boards (iPhone 15 Pro Max), for the review.
  final mechanics = <String, Level Function()>{
    'rotator': rotatorPair,
    'frozen': frozenTrio,
    'gate_key': gateAndKey,
    'linked': linkedPair,
    'portal': portalLevel,
  };
  for (final entry in mechanics.entries) {
    testWidgets('mechanic ${entry.key}', (tester) async {
      await pumpGame(
        tester,
        id: normal,
        level: entry.value(),
        size: devices['iphone_pro_max']!,
      );
      await shot(tester, 'mechanic_${entry.key}');
    });
  }
}
