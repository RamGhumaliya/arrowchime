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

/// Plays Chapter 1, levels 1-20, through the real UI on a device or emulator
/// (`docs/09` Phase 4 acceptance): every arrow is tapped on screen in the
/// solution order, each level must reach the win sheet, and "Next level" must
/// open the following one. Run with
/// `flutter test integration_test/play_chapter1_test.dart --flavor dev`.
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Chapter 1 levels 1-20 are playable by tapping', (tester) async {
    await tester.pumpWidget(const ProviderScope(child: ArrowchimeApp()));
    await tester.pump(const Duration(milliseconds: 500));
    // Jump straight to level 1 (the home screen is a stub until Phase 7).
    final context = tester.element(find.byType(Navigator).first);
    final container = ProviderScope.containerOf(context);
    GoRouter.of(context).go(AppRoutes.levelPath('ch1', 1));
    await tester.pump(const Duration(seconds: 1));

    for (var index = 1; index <= 20; index++) {
      final level = await container.read(
        levelProvider(LevelRef(1, index)).future,
      );
      final gameFinder = find.byType(GameWidget<ArrowGame>);
      // The previous level's page may still be fading out: wait for this one.
      ArrowGame? game;
      for (var i = 0; i < 100 && game == null; i++) {
        await tester.pump(const Duration(milliseconds: 100));
        for (final w in tester.widgetList<GameWidget<ArrowGame>>(gameFinder)) {
          if (w.game?.engine.level.id == level.id) game = w.game;
        }
      }
      expect(game, isNotNull, reason: 'level $index did not open');
      final board = game!;
      final origin = tester.getTopLeft(gameFinder.last);

      await tester.pump(const Duration(milliseconds: 300));
      for (final id in level.meta.solution) {
        final comp = board.arrows[id];
        expect(comp, isNotNull, reason: 'level $index arrow $id missing');
        final at = origin + board.view.toScreen(comp!.headPoint);
        await tester.tapAt(at);
        await tester.pump(const Duration(milliseconds: 120));
      }

      await _waitFor(tester, find.text('Next level'));
      // Let the sheet finish sliding in before tapping it.
      await tester.pump(const Duration(milliseconds: 900));
      expect(find.text('Next level'), findsWidgets, reason: 'level $index');
      if (index < 20) {
        await tester.tap(find.text('Next level').last);
        await tester.pump(const Duration(milliseconds: 800));
      }
    }
  });
}

Future<void> _waitFor(WidgetTester tester, Finder finder) async {
  for (var i = 0; i < 100; i++) {
    if (finder.evaluate().isNotEmpty) return;
    await tester.pump(const Duration(milliseconds: 100));
  }
  fail('timed out waiting for $finder');
}
