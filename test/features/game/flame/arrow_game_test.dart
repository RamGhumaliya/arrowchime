import 'dart:ui';

import 'package:arrowchime/app/theme/chapter_theme.dart';
import 'package:arrowchime/app/theme/tokens.dart';
import 'package:arrowchime/core/level/engine/events.dart';
import 'package:arrowchime/core/level/engine/game_engine.dart';
import 'package:arrowchime/core/level/models/arrow.dart';
import 'package:arrowchime/core/level/models/level.dart';
import 'package:arrowchime/features/game/flame/arrow_game.dart';
import 'package:arrowchime/features/game/flame/particle_pool.dart';
import 'package:flame/components.dart';
import 'package:flame_test/flame_test.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../core/level/support/fixtures.dart';

void main() {
  const size = Size(375, 667);
  var won = 0;
  var lost = 0;

  ArrowGame make(Level level, {bool reduceMotion = false}) => ArrowGame(
    engine: GameEngine(level),
    theme: ChapterTheme.mistyGarden,
    reduceMotion: reduceMotion,
    onWon: () => won++,
    onLost: () => lost++,
  );

  setUp(() {
    won = 0;
    lost = 0;
  });

  /// Runs [seconds] of game time in 1/60 s steps.
  void run(ArrowGame game, double seconds) {
    for (var t = 0.0; t < seconds; t += 1 / 60) {
      game.update(1 / 60);
    }
  }

  void gameTest(
    String name,
    Level Function() level,
    Future<void> Function(ArrowGame game) body, {
    bool reduceMotion = false,
  }) {
    testWithGame<ArrowGame>(
      name,
      () => make(level(), reduceMotion: reduceMotion),
      (game) async {
        await game.ready();
        game.onGameResize(Vector2(size.width, size.height));
        await body(game);
      },
    );
  }

  group('replaying engine events', () {
    gameTest('loads one component per arrow', freeTrio, (game) async {
      expect(game.arrows.keys, [0, 1, 2]);
      expect(game.resolver.occupied, isNotEmpty);
    });

    gameTest('a freed arrow flies off and disappears', freeTrio, (game) async {
      final comp = game.arrows[0]!;
      game.playEvents(game.engine.tap(0));
      expect(game.arrows.containsKey(0), isFalse);
      expect(comp.isLeaving, isTrue);
      expect(game.resolver.occupied.values.any((v) => v.arrowId == 0), isFalse);
      run(game, 0.6);
      game.processLifecycleEvents();
      expect(comp.isMounted, isFalse);
    });
  });

  group('blocked, win and loss', () {
    gameTest('a blocked tap bumps without removing anything', blockedPair, (
      game,
    ) async {
      game.playEvents(game.engine.tap(0));
      run(game, 0.5);
      expect(game.arrows.keys, [0, 1]);
    });

    gameTest('loss calls onLost after the fade', () => blockedPair(hearts: 1), (
      game,
    ) async {
      game.playEvents(game.engine.tap(0));
      run(game, 0.3);
      expect(lost, 0);
      run(game, 0.5);
      expect(lost, 1);
      game.resumeAfterLoss();
    });

    gameTest('win waits for the last arrow, then calls onWon once', freeTrio, (
      game,
    ) async {
      for (final id in [0, 1, 2]) {
        game.playEvents(game.engine.tap(id));
      }
      run(game, 0.2);
      expect(won, 0);
      run(game, 1.5);
      expect(won, 1);
      expect(game.particles.alive, greaterThan(0));
    });

    gameTest('Reduce Motion: no particles, no flight', freeTrio, (game) async {
      for (final id in [0, 1, 2]) {
        game.playEvents(game.engine.tap(id));
      }
      run(game, 1.2);
      expect(won, 1);
      expect(game.particles.alive, 0);
    }, reduceMotion: true);
  });

  group('undo and reset', () {
    gameTest('undo brings the arrow back', freeTrio, (game) async {
      game.playEvents(game.engine.tap(0));
      run(game, 0.6);
      game.playEvents(game.engine.undo());
      game.processLifecycleEvents();
      expect(game.arrows.keys.toSet(), {0, 1, 2});
      expect(
        game.resolver.occupied.values.where((v) => v.arrowId == 0),
        isNotEmpty,
      );
    });

    gameTest('resetBoard rebuilds everything', freeTrio, (game) async {
      game
        ..playEvents(game.engine.tap(0))
        ..playEvents(game.engine.tap(1));
      run(game, 0.6);
      game.engine.reset();
      game.resetBoard();
      expect(game.arrows.keys.toSet(), {0, 1, 2});
      expect(game.particles.alive, 0);
    });
  });

  group('mechanics', () {
    gameTest('rotators turn their head', rotatorPair, (game) async {
      final events = game.engine.tap(game.engine.freeArrowIds.first);
      game.playEvents(events);
      final turned = events.whereType<RotatorsTurned>().single;
      for (final e in turned.dirs.entries) {
        expect(game.arrows[e.key]!.dir, e.value);
      }
    });

    gameTest('frozen arrows shake and tick down', frozenTrio, (game) async {
      final events = game.engine.tap(game.engine.freeArrowIds.first);
      game.playEvents(events);
      run(game, 0.5);
      expect(game.arrows.isNotEmpty, isTrue);
    });

    gameTest('opening a gate and undoing it closes it again', gateAndKey, (
      game,
    ) async {
      final key = game.engine.level.arrows.firstWhere(
        (a) => a.kind == ArrowKind.key,
      );
      game.playEvents(game.engine.tap(key.id));
      run(game, 0.6);
      game.playEvents(game.engine.undo());
      game.processLifecycleEvents();
      expect(game.arrows.containsKey(key.id), isTrue);
    });

    gameTest('portal levels animate without errors', portalLevel, (game) async {
      for (final id in game.engine.freeArrowIds) {
        game.playEvents(game.engine.tap(id));
      }
      run(game, 1);
    });

    gameTest('linked pairs animate without errors', linkedPair, (game) async {
      for (final id in game.engine.freeArrowIds) {
        game.playEvents(game.engine.tap(id));
      }
      run(game, 1);
    });
  });

  group('camera and input', () {
    gameTest('tap assist, zoom, pan, fit and peek', blockedPair, (game) async {
      final head = game.view.toScreen(
        game.geometry.center(game.engine.level.arrows.first.body.last),
      );
      expect(game.arrowAt(head), 0);
      expect(game.arrowAt(const Offset(1, 1)), isNull);

      expect(game.atFit.value, isTrue);
      game.zoomBy(head, 3);
      expect(game.view.multiplier, closeTo(3, 1e-9));
      expect(game.atFit.value, isFalse);
      game
        ..panBy(const Offset(20, 10))
        ..fitBoard();
      run(game, 0.5);
      expect(game.view.multiplier, closeTo(1, 1e-6));
      expect(game.atFit.value, isTrue);

      game.toggleZoom(head);
      run(game, 0.5);
      expect(game.view.multiplier, closeTo(2.5, 1e-6));
      game.toggleZoom(head);
      run(game, 0.5);
      expect(game.view.multiplier, closeTo(1, 1e-6));

      game
        ..peekAt(head)
        ..peekAt(const Offset(1, 1))
        ..endPeek()
        ..setGridVisible(visible: true)
        ..showHint(0);
      run(game, 0.3);
    });

    gameTest('Reduce Motion zooms without animating', blockedPair, (
      game,
    ) async {
      game.toggleZoom(const Offset(100, 100));
      expect(game.view.multiplier, closeTo(2.5, 1e-9));
      game.fitBoard();
      expect(game.view.multiplier, 1);
    }, reduceMotion: true);
  });

  group('feedback visuals', () {
    gameTest('press, flow glow and the last-three zoom nudge', freeTrio, (
      game,
    ) async {
      game.pressArrow(0);
      run(game, 0.2);
      game.pressArrow(null);
      run(game, 0.2);
      game
        ..setFlow(3)
        ..nudgeZoom();
      run(game, 0.5);
      expect(game.view.multiplier, closeTo(TBFeedback.lastThreeZoom, 1e-6));
      game
        ..zoomBy(const Offset(100, 100), 2)
        ..nudgeZoom(); // ignored while zoomed in
      expect(game.view.multiplier, greaterThan(2));
    });

    gameTest('Reduce Motion: press is instant', freeTrio, (game) async {
      game.pressArrow(1);
      run(game, 0.01);
      game.pressArrow(null);
    }, reduceMotion: true);
  });

  group('ParticlePool', () {
    test('never exceeds its capacity', () {
      final pool = ParticlePool(seed: 1);
      for (var i = 0; i < 20; i++) {
        pool.burst(0, 0, const Color(0xFFFFFFFF), count: 30);
      }
      expect(pool.alive, ParticlePool.capacity);
      pool.update(10);
      expect(pool.alive, 0);
      pool.confetti(100, 0, const [Color(0xFFFFFFFF)], count: 500);
      expect(pool.alive, ParticlePool.capacity);
      pool.clear();
      expect(pool.alive, 0);
    });
  });
}
