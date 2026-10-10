import 'package:arrowchime/core/economy/pricing.dart';
import 'package:arrowchime/core/economy/wallet.dart';
import 'package:arrowchime/core/level/engine/game_engine.dart';
import 'package:arrowchime/core/level/models/level.dart';
import 'package:arrowchime/features/game/state/game_session.dart';
import 'package:arrowchime/features/game/state/level_ref.dart';
import 'package:arrowchime/features/game/state/level_repository.dart';
import 'package:arrowchime/features/game/state/session_event.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../core/level/support/fixtures.dart';

ProviderContainer containerFor(
  Level level,
  LevelRef id, {
  Duration Function()? clock,
}) {
  final c = ProviderContainer(
    overrides: [
      levelProvider(id).overrideWith((ref) => level),
      if (clock != null) flowClockProvider.overrideWithValue(clock),
    ],
  );
  addTearDown(c.dispose);
  return c;
}

void main() {
  const early = LevelRef(1, 3);
  const late = LevelRef(1, 25);

  Future<GameSession> open(ProviderContainer c, LevelRef id) async {
    await c.read(levelProvider(id).future);
    c.listen(gameSessionProvider(id), (_, _) {});
    final session = c.read(gameSessionProvider(id).notifier);
    return session;
  }

  group('LevelRef', () {
    test('parses route parameters', () {
      expect(LevelRef.parse('ch2', '7'), const LevelRef(2, 7));
      expect(LevelRef.parse('ch2', '7')!.globalIndex, 67);
      expect(const LevelRef(2, 7).chapterSlug, 'ch2');
      expect(LevelRef.parse('ch9', '1'), isNull);
      expect(LevelRef.parse('ch1', '61'), isNull);
      expect(LevelRef.parse('x', 'y'), isNull);
      expect(LevelRef.parse(null, null), isNull);
      expect(const LevelRef(1, 1).hashCode, const LevelRef(1, 1).hashCode);
      expect(const LevelRef(1, 1).toString(), contains('ch1'));
    });
  });

  group('GameSession', () {
    test('tap frees an arrow and a win pays once (G4)', () async {
      final c = containerFor(freeTrio(), early);
      final s = await open(c, early);
      final seen = <SessionEvent>[];
      s.events.listen(seen.add);

      s
        ..tap(0)
        ..tap(1);
      expect(c.read(gameSessionProvider(early)).remaining, 1);
      expect(c.read(walletProvider), 0);
      s.tap(2);
      final state = c.read(gameSessionProvider(early));
      expect(state.status, GameStatus.won);
      expect(state.stars, 3);
      expect(state.reward!.coins, 25);
      // 25 for the level + 50 for the "First Note" achievement.
      expect(c.read(walletProvider), 25 + 50);
      expect(state.outcome!.achievements, ['first_note']);
      // Tapping after the win changes nothing and pays nothing more.
      s.tap(2);
      expect(c.read(walletProvider), 75);
      await Future<void>.delayed(Duration.zero);
      expect(seen.whereType<EnginePlayed>(), hasLength(3));
    });

    test('blocked taps cost hearts; losing is final until retry', () async {
      final c = containerFor(blockedPair(hearts: 1), early);
      final s = await open(c, early);
      s.tap(0);
      final state = c.read(gameSessionProvider(early));
      expect(state.status, GameStatus.lost);
      expect(state.hearts, 0);
      expect(state.blockedTaps, 1);
      s.tap(1);
      expect(c.read(gameSessionProvider(early)).remaining, 2);
    });

    test('retry is free, resets everything and shows no ad (G3)', () async {
      final c = containerFor(blockedPair(hearts: 1), early);
      final s = await open(c, early);
      final seen = <SessionEvent>[];
      s.events.listen(seen.add);
      s
        ..tap(0)
        ..retry();
      final state = c.read(gameSessionProvider(early));
      expect(state.status, GameStatus.playing);
      expect(state.hearts, 1);
      expect(state.remaining, 2);
      expect(state.freeUndosLeft, Pricing.freeUndos);
      await Future<void>.delayed(Duration.zero);
      expect(seen.last, isA<BoardReset>());
    });

    test(
      'undo: two free, then 30 coins, then refused without coins (G6)',
      () async {
        final c = containerFor(freeTrio(), early);
        final s = await open(c, early);
        expect(s.undo(), PurchaseResult.unavailable);
        s.tap(0);
        expect(s.undo(), PurchaseResult.free);
        s.tap(0);
        expect(s.undo(), PurchaseResult.free);
        s.tap(0);
        expect(c.read(gameSessionProvider(early)).freeUndosLeft, 0);
        expect(s.undo(), PurchaseResult.noCoins);
        expect(c.read(gameSessionProvider(early)).remaining, 2);
        c.read(walletProvider.notifier).add(100);
        expect(s.undo(), PurchaseResult.done);
        expect(c.read(walletProvider), 100 - Pricing.undo);
        expect(c.read(gameSessionProvider(early)).remaining, 3);
      },
    );

    test(
      'hints are free on early levels, then 1 free + 50 coins (G12)',
      () async {
        final c1 = containerFor(freeTrio(), early);
        final s1 = await open(c1, early);
        final seen = <SessionEvent>[];
        s1.events.listen(seen.add);
        expect(s1.hint(), PurchaseResult.free);
        expect(s1.hint(), PurchaseResult.free);
        expect(c1.read(gameSessionProvider(early)).hintArrowId, isNotNull);
        await Future<void>.delayed(Duration.zero);
        expect(seen.whereType<HintGiven>(), hasLength(2));
        s1.tap(c1.read(gameSessionProvider(early)).hintArrowId!);
        expect(c1.read(gameSessionProvider(early)).hintArrowId, isNull);

        final c2 = containerFor(freeTrio(), late);
        final s2 = await open(c2, late);
        expect(s2.hint(), PurchaseResult.free);
        expect(s2.hint(), PurchaseResult.noCoins);
        c2.read(walletProvider.notifier).add(60);
        expect(s2.hint(), PurchaseResult.done);
        expect(c2.read(walletProvider), 10);
      },
    );

    test('hint is unavailable once the level is over', () async {
      final c = containerFor(blockedPair(hearts: 1), early);
      final s = await open(c, early);
      s.tap(0);
      expect(s.hint(), PurchaseResult.unavailable);
    });

    test('hearts: grant on a lost level, buy for 100 coins', () async {
      final c = containerFor(blockedPair(hearts: 1), early);
      final s = await open(c, early);
      expect(s.buyHeart(), PurchaseResult.unavailable);
      s.tap(0);
      expect(s.buyHeart(), PurchaseResult.noCoins);
      c.read(walletProvider.notifier).add(Pricing.heart);
      expect(s.buyHeart(), PurchaseResult.done);
      expect(c.read(walletProvider), 0);
      var state = c.read(gameSessionProvider(early));
      expect(state.status, GameStatus.playing);
      expect(state.hearts, 1);
      // Stars still reflect the heart that was lost.
      s
        ..tap(1)
        ..tap(0);
      state = c.read(gameSessionProvider(early));
      expect(state.status, GameStatus.won);
      expect(state.stars, 2);
      s.grantHeart();
      expect(c.read(gameSessionProvider(early)).status, GameStatus.won);
    });

    test(
      'flow: streak raises the multiplier and lapses on the clock',
      () async {
        var t = Duration.zero;
        final c = containerFor(freeTrio(), early, clock: () => t);
        final s = await open(c, early);
        for (final id in [0, 1, 2]) {
          t += const Duration(milliseconds: 300);
          s.tap(id);
        }
        final state = c.read(gameSessionProvider(early));
        expect(state.flowMultiplier, 2);
        expect(state.bestFlow, 2);
        expect(state.reward!.xp, 30 + 5);
        t += const Duration(seconds: 2);
        s.tickFlow();
        expect(c.read(gameSessionProvider(early)).flowMultiplier, 1);
        expect(c.read(gameSessionProvider(early)).bestFlow, 2);
      },
    );

    test('flow clock default runs', () {
      final c = ProviderContainer();
      addTearDown(c.dispose);
      expect(c.read(flowClockProvider)(), isA<Duration>());
    });
  });
}
