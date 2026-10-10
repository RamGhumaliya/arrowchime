import 'dart:convert';
import 'dart:io';

import 'package:arrowchime/core/level/engine/game_engine.dart';
import 'package:arrowchime/core/level/engine/rules.dart';
import 'package:arrowchime/core/level/models/board_state.dart';
import 'package:arrowchime/core/level/models/level.dart';
import 'package:arrowchime/core/level/solver/greedy_solver.dart';
import 'package:arrowchime/core/level/solver/hint.dart';
import 'package:arrowchime/core/level/solver/search_solver.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/fixtures.dart';

List<Level> sampleLevels() {
  final json = jsonDecode(
    File('assets/levels/sample_levels.json').readAsStringSync(),
  ) as Map<String, Object?>;
  return LevelPack.fromJson(json).levels;
}

/// Replays [ids] on a fresh engine; returns it.
GameEngine replay(Level level, List<int> ids) {
  final engine = GameEngine(level);
  for (final id in ids) {
    expect(engine.isFree(id), isTrue, reason: 'arrow $id must be free');
    engine.tap(id);
  }
  return engine;
}

void main() {
  group('GreedySolver', () {
    test('free trio: one wave, in level order', () {
      final r = GreedySolver.solveLevel(freeTrio());
      expect(r.solvable, isTrue);
      expect(r.depth, 1);
      expect(r.solution, [0, 1, 2]);
      expect(r.waveFreeCounts, [3]);
      expect(r.waveRemaining, [3]);
    });

    test('blocked pair: two waves', () {
      final r = GreedySolver.solveLevel(blockedPair());
      expect(r.solvable, isTrue);
      expect(r.depth, 2);
      expect(r.solution, [1, 0]);
      expect(r.waveFreeCounts, [1, 1]);
      expect(r.waveRemaining, [2, 1]);
    });

    test('detects mutual blocking', () {
      final level = buildLevel(
        arrows: [
          arrowJson(0, [
            [0, 0],
          ], 'R'),
          arrowJson(1, [
            [1, 0],
          ], 'L'),
        ],
      );
      final r = GreedySolver.solveLevel(level);
      expect(r.solvable, isFalse);
      expect(r.solution, isEmpty);
      expect(r.depth, 0);
    });

    test('a key trapped behind its own gate is unsolvable', () {
      final level = buildLevel(
        arrows: [
          arrowJson(
            0,
            [
              [0, 0],
            ],
            'R',
            kind: 'key',
            color: 'amber',
          ),
        ],
        gates: [gateJson(1, 0, 'amber')],
      );
      expect(GreedySolver.solveLevel(level).solvable, isFalse);
    });

    test('frozen counter larger than the arrows left is unsolvable', () {
      final level = buildLevel(
        arrows: [
          arrowJson(
            0,
            [
              [0, 0],
            ],
            'L',
            frozen: 5,
          ),
          arrowJson(1, [
            [2, 2],
          ], 'U'),
        ],
      );
      final r = GreedySolver.solveLevel(level);
      expect(r.solvable, isFalse);
      expect(r.solution, [1]);
    });

    test('gate + key, frozen and linked mechanics are solved', () {
      expect(GreedySolver.solveLevel(gateAndKey()).solution, [1, 0]);
      expect(GreedySolver.solveLevel(frozenTrio()).solvable, isTrue);
      expect(GreedySolver.solveLevel(linkedPair()).solvable, isTrue);
      expect(GreedySolver.solveLevel(portalLevel()).solvable, isTrue);
    });

    test('solving does not mutate the start state', () {
      final s = BoardState.initial(blockedPair());
      final key = s.key;
      GreedySolver.solveState(s);
      expect(s.key, key);
    });

    test('re-checks freedom inside a wave (misuse on non-monotone level)', () {
      // Removing arrow 0 turns the rotator toward arrow 2, so the rotator,
      // although in the wave snapshot, is skipped until the next wave.
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
            [4, 2],
          ], 'D'),
        ],
      );
      final r = GreedySolver.solveLevel(level);
      expect(r.solution, [0, 2, 1]);
      expect(r.waveFreeCounts, [3, 1]);
    });
  });

  group('SearchSolver', () {
    test('rotator pair has a solution that replays to a win', () {
      final level = rotatorPair();
      final r = SearchSolver().solveLevel(level);
      expect(r.solvable, isTrue);
      expect(r.depth, isNull);
      expect(replay(level, r.solution).status, GameStatus.won);
    });

    test('a rotator box is unsolvable', () {
      final level = buildLevel(arrows: deadlockBox());
      final r = SearchSolver().solveLevel(level);
      expect(r.solvable, isFalse);
      expect(r.tooComplex, isFalse);
    });

    test('rotator trap: backtracks and reports a trap ratio', () {
      final level = rotatorTrap();
      final r = SearchSolver().solveLevel(level);
      expect(r.solvable, isTrue);
      expect(replay(level, r.solution).status, GameStatus.won);
      expect(r.trapRatio, closeTo(0.2, 1e-9), reason: '1 trap in 5 moves');
      expect(r.statesExpanded, greaterThan(0));
    });

    test('monotone level has trap ratio 0', () {
      final r = SearchSolver().solveLevel(blockedPair());
      expect(r.solvable, isTrue);
      expect(r.trapRatio, 0);
    });

    test('state limit aborts as too complex', () {
      // Six free arrows next to an unsolvable core: the search must enumerate
      // many subsets before giving up.
      final level = buildLevel(
        width: 8,
        height: 8,
        arrows: [
          ...deadlockBox(),
          for (var i = 0; i < 6; i++)
            arrowJson(5 + i, [
              [i + 1, 7],
            ], 'D'),
        ],
      );
      final r = SearchSolver(stateLimit: 10).solveLevel(level);
      expect(r.solvable, isFalse);
      expect(r.tooComplex, isTrue);
    });

    test('linked pair counts as a single move', () {
      final level = linkedPair();
      final r = SearchSolver().solveLevel(level);
      expect(r.solvable, isTrue);
      expect(r.solution, [2, 0]);
    });

    test('trap sampling has its own budget per sampled move', () {
      final r = SearchSolver(stateLimit: 3).solveLevel(rotatorTrap());
      expect(r.solvable, isTrue);
      expect(r.tooComplex, isFalse);
      expect(r.trapRatio, closeTo(0.2, 1e-9));
    });

    test('trapDepth 0 skips sampling', () {
      final r = SearchSolver(trapDepth: 0).solveLevel(rotatorTrap());
      expect(r.solvable, isTrue);
      expect(r.trapRatio, 0);
    });

    test('splitter and switcher flags are honoured', () {
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
      final r = SearchSolver(config: const RulesConfig(enableSwitcher: true))
          .solveLevel(level);
      expect(r.solvable, isTrue);
    });
  });

  group('sample levels', () {
    for (final level in sampleLevels()) {
      test('${level.id}: greedy solves and meta.solution replays to a win', () {
        final r = GreedySolver.solveLevel(level);
        expect(r.solvable, isTrue, reason: 'greedy');
        expect(replay(level, r.solution).status, GameStatus.won);

        final engine = replay(level, level.meta.solution);
        expect(engine.status, GameStatus.won, reason: 'meta.solution');
        expect(
          level.meta.solution.length,
          lessThanOrEqualTo(level.arrows.length),
        );
      });

      test('${level.id}: search agrees', () {
        final r = SearchSolver().solveLevel(level);
        expect(r.solvable, isTrue);
        expect(replay(level, r.solution).status, GameStatus.won);
      });
    }
  });

  group('HintService (G12)', () {
    test('monotone: following hints always completes the level', () {
      for (final level in [...sampleLevels(), linkedPair(), frozenTrio()]) {
        final engine = GameEngine(level);
        final hints = HintService(engine);
        var guard = 0;
        while (engine.status == GameStatus.playing) {
          final id = hints.next();
          expect(id, isNotNull, reason: level.id);
          expect(engine.isFree(id!), isTrue, reason: 'hint must be free');
          engine.tap(id);
          expect(++guard, lessThan(100));
        }
        expect(engine.status, GameStatus.won, reason: level.id);
        expect(engine.hearts, level.hearts, reason: 'no heart lost');
      }
    });

    test('non-monotone: hints from any reachable state keep it solvable', () {
      final engine = GameEngine(rotatorTrap());
      final hints = HintService(engine);
      while (engine.status == GameStatus.playing) {
        engine.tap(hints.next()!);
      }
      expect(engine.status, GameStatus.won);
      expect(engine.hearts, 3);
    });

    test('caches per state and returns null when the level is over', () {
      final engine = GameEngine(blockedPair());
      final hints = HintService(engine);
      final first = hints.next();
      expect(hints.next(), first);
      engine
        ..tap(1)
        ..tap(0);
      expect(hints.next(), isNull);
    });

    test('returns null when the level cannot be solved from here', () {
      final engine = GameEngine(rotatorTrap())..tap(2);
      expect(HintService(engine).next(), isNull);
    });
  });

  group('isMonotone', () {
    test('rotators always break monotonicity; switchers only when enabled', () {
      final rot = BoardState.initial(rotatorPair());
      expect(isMonotone(rot, const RulesConfig()), isFalse);

      final sw = BoardState.initial(
        buildLevel(
          arrows: [
            arrowJson(
              0,
              [
                [2, 2],
              ],
              'U',
              kind: 'switcher',
            ),
          ],
        ),
      );
      expect(isMonotone(sw, const RulesConfig()), isTrue);
      expect(isMonotone(sw, const RulesConfig(enableSwitcher: true)), isFalse);
      expect(
        isMonotone(BoardState.initial(freeTrio()), const RulesConfig()),
        isTrue,
      );
    });
  });
}
