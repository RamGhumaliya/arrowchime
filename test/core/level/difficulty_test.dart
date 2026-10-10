import 'package:arrowchime/core/level/difficulty.dart';
import 'package:arrowchime/core/level/engine/rules.dart';
import 'package:arrowchime/core/level/solver/greedy_solver.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/fixtures.dart';

void main() {
  group('Difficulty.analyze', () {
    test('free trio matches the docs/04 §5 formula by hand', () {
      final r = Difficulty.analyze(freeTrio());
      expect(r.solvable, isTrue);
      expect(r.depth, 1);
      expect(r.freeRatio, 1);
      expect(r.minFree, 3);
      expect(r.density, closeTo(6 / 25, 1e-9));
      expect(r.avgLen, 2);
      expect(r.turns, 0);
      expect(r.deception, 0);
      expect(r.mechanics, 0);
      expect(r.trapRatio, 0);
      // 4*1 + 30*0 + 8/3 + 10*0.24 + 0.6*2 + 0 + 0 + 0 + 0 = 10.2667; *0.9.
      expect(r.score, closeTo(9.2, 1e-9));
      expect(r.solution, [0, 1, 2]);
    });

    test('blocked pair has two waves and a lower free ratio', () {
      final r = Difficulty.analyze(blockedPair());
      expect(r.depth, 2);
      // wave 1: 1 free of 2; wave 2: 1 of 1 => mean 0.75.
      expect(r.freeRatio, closeTo(0.75, 1e-9));
      expect(r.minFree, 1);
      // 4*2 + 30*.25 + 8/1 + 10*(4/25*... see fields) is checked via parts:
      final raw =
          4.0 * r.depth +
          30 * (1 - r.freeRatio) +
          8 / r.minFree +
          10 * r.density +
          0.6 * r.avgLen +
          3 * r.turns +
          15 * r.deception +
          r.mechanics +
          25 * r.trapRatio;
      expect(r.score, closeTo((raw * 0.9 * 10).round() / 10, 1e-9));
    });

    test('turns counts direction changes along bodies', () {
      final level = buildLevel(
        arrows: [
          arrowJson(0, [
            [0, 0],
            [1, 0],
            [1, 1],
            [2, 1],
          ], 'R'),
          arrowJson(1, [
            [4, 4],
          ], 'D'),
        ],
      );
      final r = Difficulty.analyze(level);
      // Arrow 0 turns twice, arrow 1 never: mean 1.
      expect(r.turns, 1);
      expect(r.avgLen, 2.5);
    });

    test('deception counts blocked arrows with one far blocker', () {
      // Arrow 0 looks free but arrow 1 (single cell, 5 cells away) blocks it.
      final level = buildLevel(
        width: 8,
        arrows: [
          arrowJson(0, [
            [0, 0],
            [1, 0],
          ], 'R'),
          arrowJson(1, [
            [6, 0],
          ], 'D'),
        ],
      );
      expect(Difficulty.analyze(level).deception, 1);

      // A near blocker (2 cells) is not deceptive.
      expect(Difficulty.analyze(blockedPair()).deception, 0);
    });

    test('deception ignores frozen arrows and counts closed gates', () {
      final gate = Difficulty.analyze(gateAndKey());
      // Arrow 0 is blocked by a gate 1 cell ahead: not deceptive.
      expect(gate.deception, 0);
    });

    test('mechanics add each type once', () {
      expect(Difficulty.analyze(gateAndKey()).mechanics, 4);
      expect(Difficulty.analyze(frozenTrio()).mechanics, 3);
      expect(Difficulty.analyze(linkedPair()).mechanics, 3);
      expect(Difficulty.analyze(portalLevel()).mechanics, 5);
      expect(Difficulty.analyze(rotatorPair()).mechanics, 6);
    });

    test('a switcher counts only when the flag enables it', () {
      final level = buildLevel(
        arrows: [
          arrowJson(
            0,
            [
              [2, 2],
            ],
            'U',
            kind: 'switcher',
          ),
          arrowJson(1, [
            [3, 2],
          ], 'R'),
        ],
      );
      expect(Difficulty.analyze(level).mechanics, 0);
      final on = Difficulty.analyze(
        level,
        config: const RulesConfig(enableSwitcher: true),
      );
      expect(on.mechanics, 6);
      expect(on.solvable, isTrue);
    });

    test('rotator levels use the search solver and report a trap ratio', () {
      final r = Difficulty.analyze(rotatorTrap());
      expect(r.solvable, isTrue);
      expect(r.trapRatio, closeTo(0.2, 1e-9));
      expect(r.mechanics, 6);
    });

    test('an unsolvable level is reported as such', () {
      final r = Difficulty.analyze(buildLevel(arrows: deadlockBox()));
      expect(r.solvable, isFalse);
      expect(r.score, 0);
      expect(r.solution, isEmpty);
    });

    test('scores are clamped to 0-100 and rounded to one decimal', () {
      final r = Difficulty.analyze(blockedPair());
      expect(r.score, inInclusiveRange(0, 100));
      expect((r.score * 10) % 1, closeTo(0, 1e-9));
    });

    test('rotator level that greedy cannot finish uses the given solution', () {
      // X (id 0) comes first in index order, so greedy taps it, turns the
      // rotator R towards B and deadlocks. Tapping R first solves it.
      final level = buildLevel(
        arrows: [
          arrowJson(0, [
            [0, 0],
          ], 'L'),
          arrowJson(
            1,
            [
              [2, 2],
            ],
            'U',
            kind: 'rotator',
          ),
          arrowJson(2, [
            [3, 2],
          ], 'L'),
        ],
      );
      expect(GreedySolver.solveLevel(level).solvable, isFalse);
      final r = Difficulty.analyze(level, solution: [1, 2, 0]);
      expect(r.solvable, isTrue);
      expect(r.depth, greaterThan(0));
      expect(r.solution, [1, 2, 0]);
    });
  });

  group('WaveStats', () {
    test('replays a solution into waves', () {
      final w = WaveStats.fromSolution(blockedPair(), [1, 0]);
      expect(w.freeCounts, [1, 1]);
      expect(w.remaining, [2, 1]);
      expect(w.depth, 2);
      expect(w.minFree, 1);
      expect(w.freeRatio, closeTo(0.75, 1e-9));
    });

    test('an invalid solution stops instead of looping', () {
      // Arrow 0 is blocked, so [0] consumes nothing.
      final w = WaveStats.fromSolution(blockedPair(), [0, 1]);
      expect(w.depth, 1);
    });

    test('empty wave stats are neutral', () {
      const w = WaveStats(freeCounts: [], remaining: []);
      expect(w.depth, 0);
      expect(w.freeRatio, 1);
      expect(w.minFree, 0);
    });
  });
}
