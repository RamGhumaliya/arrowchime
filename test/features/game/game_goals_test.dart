import 'dart:ui';

import 'package:arrowchime/core/assets.dart';
import 'package:arrowchime/core/audio/chapter_sound.dart';
import 'package:arrowchime/core/audio/melodies.dart';
import 'package:arrowchime/core/economy/wallet.dart';
import 'package:arrowchime/core/level/engine/game_engine.dart';
import 'package:arrowchime/features/game/flame/arrow_game.dart';
import 'package:arrowchime/features/game/input/tap_resolver.dart';
import 'package:arrowchime/features/game/model/board_geometry.dart';
import 'package:arrowchime/features/game/state/game_session.dart';
import 'package:arrowchime/features/game/state/game_settings.dart';
import 'package:arrowchime/features/game/state/level_ref.dart';
import 'package:arrowchime/features/game/state/level_repository.dart';
import 'package:flame/game.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../core/level/support/fixtures.dart';
import 'support/game_harness.dart';

/// The UI-level goals of `docs/09` §2 (G2, G5, G12–G16) played through the
/// real game screen where the screen is what matters.
void main() {
  const id = LevelRef(1, 3);

  ArrowGame gameOf(WidgetTester tester) => tester
      .widget<GameWidget<ArrowGame>>(find.byType(GameWidget<ArrowGame>))
      .game!;

  Offset screenOf(WidgetTester tester, ArrowGame game, Offset world) =>
      tester.getTopLeft(find.byType(GameWidget<ArrowGame>)) +
      game.view.toScreen(world);

  testWidgets('G2: a blocked tap costs a heart and ends the Flow streak', (
    tester,
  ) async {
    final h = await pumpGame(tester, id: id, level: blockedPair());
    h.session.tap(0);
    final state = h.container.read(gameSessionProvider(id));
    expect(state.hearts, 2);
    expect(state.blockedTaps, 1);
    expect(state.flowMultiplier, 1);
    await settle(tester);
  });

  testWidgets('G5: two taps in quick succession stay consistent', (
    tester,
  ) async {
    final h = await pumpGame(tester, id: id, level: freeTrio());
    h.session
      ..tap(0)
      ..tap(1);
    await tester.pump(const Duration(milliseconds: 50));
    final state = h.container.read(gameSessionProvider(id));
    expect(state.remaining, 1);
    expect(gameOf(tester).arrows.keys, [2]);
    await settle(tester, frames: 20);
  });

  testWidgets('tapping the board frees the arrow under the finger', (
    tester,
  ) async {
    final h = await pumpGame(tester, id: id, level: freeTrio());
    final game = gameOf(tester);
    final arrow = game.engine.level.arrows.first;
    final at = screenOf(tester, game, game.geometry.center(arrow.body.last));
    await tester.tapAt(at);
    await settle(tester);
    expect(h.container.read(gameSessionProvider(id)).remaining, 2);
  });

  testWidgets('a tap on the board is heard and felt (Phase 5)', (tester) async {
    final h = await pumpGame(tester, id: id, level: freeTrio());
    final game = gameOf(tester);
    final arrow = game.engine.level.arrows.first;
    final at = screenOf(tester, game, game.geometry.center(arrow.body.last));
    final press = await tester.startGesture(at);
    await tester.pump(const Duration(milliseconds: 80));
    expect(h.haptics!.log, ['selection']);
    expect(h.audio!.sfxNames, contains('arrow_touch'));
    await press.up();
    await settle(tester);
    final first = chapterMelodies[1]![id.index - 1].first;
    expect(h.audio!.noteNames.first, ChapterSound.of(1).notes[first]);
    expect(h.haptics!.log, contains('light'));
    expect(h.audio!.loads, contains(AssetCatalog.musicPath(1)));
  });

  testWidgets('leaving the level stops the music and frees the notes', (
    tester,
  ) async {
    final h = await pumpGame(tester, id: id, level: freeTrio());
    await tester.pumpWidget(const SizedBox());
    await tester.pump();
    expect(h.audio!.stopped, isNotEmpty);
    expect(h.audio!.unloads, isNotEmpty);
  });

  testWidgets('G13: holding peeks the path and costs nothing', (tester) async {
    final h = await pumpGame(tester, id: id, level: blockedPair());
    final game = gameOf(tester);
    final arrow = game.engine.level.arrows.first;
    final at = screenOf(tester, game, game.geometry.center(arrow.body.last));
    final g = await tester.startGesture(at);
    await tester.pump(const Duration(milliseconds: 300));
    await tester.pump(const Duration(milliseconds: 200));
    await g.up();
    await settle(tester);
    final state = h.container.read(gameSessionProvider(id));
    expect(state.hearts, 3);
    expect(state.remaining, 2);
  });

  testWidgets('G14: pinch, double-tap and wheel zoom within 1x-4x', (
    tester,
  ) async {
    await pumpGame(tester, id: id, level: blockedPair());
    final game = gameOf(tester);
    final centre = tester.getCenter(find.byType(GameWidget<ArrowGame>));

    final a = await tester.startGesture(
      centre - const Offset(20, 0),
      pointer: 1,
    );
    final b = await tester.startGesture(
      centre + const Offset(20, 0),
      pointer: 2,
    );
    await a.moveTo(centre - const Offset(60, 0));
    await b.moveTo(centre + const Offset(60, 0));
    await a.up();
    await b.up();
    await tester.pump();
    expect(game.view.multiplier, greaterThan(1.5));
    expect(game.view.multiplier, lessThanOrEqualTo(4));

    final mouse = TestPointer(3, PointerDeviceKind.mouse)..hover(centre);
    for (var i = 0; i < 30; i++) {
      await tester.sendEventToBinding(mouse.scroll(const Offset(0, -20)));
    }
    expect(game.view.multiplier, 4);

    // Double tap on empty felt fits the board again.
    final origin = tester.getTopLeft(find.byType(GameWidget<ArrowGame>));
    Offset? empty;
    for (var y = 10.0; y < 300 && empty == null; y += 17) {
      for (var x = 10.0; x < 300 && empty == null; x += 17) {
        if (game.arrowAt(Offset(x, y)) == null) empty = origin + Offset(x, y);
      }
    }
    expect(empty, isNotNull);
    await tester.tapAt(empty!);
    await tester.pump(const Duration(milliseconds: 80));
    await tester.tapAt(empty);
    await settle(tester, frames: 10);
    expect(game.view.multiplier, closeTo(1, 0.01));
  });

  testWidgets('the Fit button zooms back out', (tester) async {
    await pumpGame(tester, id: id, level: blockedPair());
    final game = gameOf(tester)..zoomBy(const Offset(100, 100), 3);
    await tester.pump();
    expect(game.atFit.value, isFalse);
    await tester.tap(find.bySemanticsLabel('Fit board'));
    await settle(tester, frames: 12);
    expect(game.atFit.value, isTrue);
  });

  test('G15: taps near cell edges pick the intended arrow in >= 95%', () {
    final level = shippedLevel(const LevelRef(5, 60));
    final geometry = BoardGeometry(level);
    final resolver = TapResolver(geometry);
    for (final arrow in level.arrows) {
      for (var i = 0; i < arrow.body.length; i++) {
        resolver.occupied[arrow.body[i]] = CellArrow(
          arrow.id,
          isHead: i == arrow.body.length - 1,
        );
      }
    }
    // Scripted taps: the centre, then 0.4 of a cell towards each side and
    // corner of every arrow cell (inside the cell, but in the edge zone).
    const offsets = [
      Offset.zero,
      Offset(0.4, 0),
      Offset(-0.4, 0),
      Offset(0, 0.4),
      Offset(0, -0.4),
      Offset(0.35, 0.35),
      Offset(-0.35, -0.35),
    ];
    var total = 0;
    var right = 0;
    for (final arrow in level.arrows) {
      for (final cell in arrow.body) {
        for (final o in offsets) {
          total++;
          final p = geometry.center(cell) + o * geometry.cell;
          // The finger lands on a 12 dp cell (dense board on an iPhone SE).
          if (resolver.resolve(p, screenCell: 12) == arrow.id) right++;
        }
      }
    }
    final rate = right / total;
    // ignore: avoid_print, the number is the evidence for the review
    print(
      'G15 tap assist: $right / $total = ${(rate * 100).toStringAsFixed(1)}%',
    );
    expect(rate, greaterThanOrEqualTo(0.95));
  });

  test('G16: relaxed mode keeps hearts and caps stars at two', () async {
    final c = ProviderContainer(
      overrides: [levelProvider(id).overrideWith((ref) => blockedPair())],
    );
    addTearDown(c.dispose);
    c.read(gameSettingsControllerProvider.notifier).setRelaxed(value: true);
    await c.read(levelProvider(id).future);
    c.listen(gameSessionProvider(id), (_, _) {});
    final s = c.read(gameSessionProvider(id).notifier)..tap(0);
    expect(c.read(gameSessionProvider(id)).hearts, 3);
    s
      ..tap(1)
      ..tap(0);
    final state = c.read(gameSessionProvider(id));
    expect(state.status, GameStatus.won);
    expect(state.stars, 2);
  });

  test('G12: following only hints always completes the level', () async {
    final refs = [
      for (var i = 1; i <= 20; i++) LevelRef(1, i),
      for (var chapter = 2; chapter <= 5; chapter++)
        for (final i in [1, 15, 30, 45, 60]) LevelRef(chapter, i),
    ];
    for (final ref in refs) {
      final level = shippedLevel(ref);
      final c = ProviderContainer(
        overrides: [levelProvider(ref).overrideWith((r) => level)],
      );
      addTearDown(c.dispose);
      await c.read(levelProvider(ref).future);
      c.listen(gameSessionProvider(ref), (_, _) {});
      c.read(walletProvider.notifier).add(100000);
      final s = c.read(gameSessionProvider(ref).notifier);
      var guard = level.arrows.length + 5;
      while (c.read(gameSessionProvider(ref)).isPlaying && guard-- > 0) {
        expect(s.hint(), isNot(PurchaseResult.unavailable), reason: '$ref');
        s.tap(c.read(gameSessionProvider(ref)).hintArrowId!);
      }
      final state = c.read(gameSessionProvider(ref));
      expect(state.status, GameStatus.won, reason: '$ref');
      expect(state.hearts, state.initialHearts, reason: '$ref lost a heart');
    }
  });
}
