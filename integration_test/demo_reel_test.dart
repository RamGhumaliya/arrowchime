import 'package:arrowchime/app/app.dart';
import 'package:arrowchime/app/router.dart';
import 'package:arrowchime/features/game/flame/arrow_game.dart';
import 'package:arrowchime/features/game/state/level_ref.dart';
import 'package:arrowchime/features/game/state/level_repository.dart';
import 'package:flame/game.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:integration_test/integration_test.dart';

/// Paced walk-through for a screen recording (not a regression test):
/// splash, Home, three levels with human-speed taps, Shop, Collection.
/// Run while `adb shell screenrecord` is capturing.
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('demo reel', (tester) async {
    Future<void> hold(double seconds) async {
      final frames = (seconds * 30).round();
      for (var i = 0; i < frames; i++) {
        await tester.pump(const Duration(milliseconds: 33));
      }
    }

    await tester.pumpWidget(const ProviderScope(child: ArrowchimeApp()));
    await hold(4);
    final context = tester.element(find.byType(Navigator).first);
    final container = ProviderScope.containerOf(context);
    final router = GoRouter.of(context);

    router.go(AppRoutes.levelPath('ch1', 1));
    await hold(1.5);

    for (var index = 1; index <= 3; index++) {
      final level = await container.read(
        levelProvider(LevelRef(1, index)).future,
      );
      final gameFinder = find.byType(GameWidget<ArrowGame>);
      ArrowGame? game;
      for (var i = 0; i < 100 && game == null; i++) {
        await hold(0.1);
        for (final w in tester.widgetList<GameWidget<ArrowGame>>(gameFinder)) {
          if (w.game?.engine.level.id == level.id) game = w.game;
        }
      }
      final board = game!;
      final origin = tester.getTopLeft(gameFinder.last);
      await hold(1.2);
      for (final id in level.meta.solution) {
        final comp = board.arrows[id]!;
        await tester.tapAt(origin + board.view.toScreen(comp.headPoint));
        await hold(0.7);
      }
      for (
        var i = 0;
        i < 100 && find.text('Next level').evaluate().isEmpty;
        i++
      ) {
        await hold(0.1);
      }
      await hold(2.2);
      if (index < 3) {
        await tester.tap(find.text('Next level').last);
        await hold(1.5);
      }
    }

    router.go(AppRoutes.shop);
    await hold(3);
    router.go(AppRoutes.collection);
    await hold(3);
    await tester.tap(find.text('Trails').last);
    await hold(2);
    await tester.tap(find.text('Boards').last);
    await hold(2);
    await tester.tap(find.text('Instruments').last);
    await hold(2.5);
  });
}
