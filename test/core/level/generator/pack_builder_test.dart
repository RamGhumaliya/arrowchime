import 'dart:convert';

import 'package:arrowchime/core/level/engine/rules.dart';
import 'package:arrowchime/core/level/generator/chapter_plan.dart';
import 'package:arrowchime/core/level/generator/gen_params.dart';
import 'package:arrowchime/core/level/generator/mechanics_pass.dart';
import 'package:arrowchime/core/level/generator/pack_builder.dart';
import 'package:arrowchime/core/level/models/arrow.dart';
import 'package:arrowchime/core/level/models/board_state.dart';
import 'package:arrowchime/core/level/models/direction.dart';
import 'package:arrowchime/core/level/prng.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/fixtures.dart';

void main() {
  group('PackBuilder', () {
    test('seeds are derived deterministically and differ per attempt', () {
      expect(
        PackBuilder.seedFor(1001, 1, 25, 0),
        PackBuilder.seedFor(1001, 1, 25, 0),
      );
      final seeds = {
        for (var a = 0; a < 20; a++) PackBuilder.seedFor(1001, 1, 25, a),
      };
      expect(seeds.length, 20);
      expect(
        PackBuilder.seedFor(1001, 1, 25, 0),
        fnv1a32('arrowchime-level-v1:1001:1:25:0'),
      );
      expect(
        PackBuilder.seedFor(1001, 1, 25, 0),
        isNot(PackBuilder.seedFor(1002, 1, 25, 0)),
      );
    });

    test('levels land within tolerance of their target (every chapter)', () {
      for (final chapter in ChapterPlan.bands.keys) {
        for (final index in [11, 23, 35, 47, 58, 60]) {
          final built = PackBuilder.buildLevel(chapter, index, 1001);
          expect(
            built.withinTolerance,
            isTrue,
            reason:
                'ch$chapter L$index score ${built.score} target ${built.target}',
          );
          expect(built.level.id, ChapterPlan.idFor(chapter, index));
          expect(built.level.chapter, chapter);
          expect(built.level.index, index);
          expect(
            built.level.meta.melody,
            ChapterPlan.melodyFor(chapter, index),
          );
          expect(built.attempts, inInclusiveRange(1, PackBuilder.maxAttempts));
          expect(built.error, (built.score - built.target).abs());
        }
      }
    });

    test('same inputs give identical JSON; another base seed differs', () {
      final a = PackBuilder.buildLevel(2, 30, 1001);
      final b = PackBuilder.buildLevel(2, 30, 1001);
      final c = PackBuilder.buildLevel(2, 30, 4242);
      expect(jsonEncode(a.level.toJson()), jsonEncode(b.level.toJson()));
      expect(jsonEncode(a.level.toJson()), isNot(jsonEncode(c.level.toJson())));
    });

    test('chapter 1 levels 1-10 are the onboarding levels', () {
      for (var i = 1; i <= 10; i++) {
        final built = PackBuilder.buildLevel(1, i, 1001);
        expect(built.level.meta.generatorVersion, startsWith('onboarding'));
        expect(built.attempts, 1);
      }
    });

    test('buildChapter honours count', () {
      final built = PackBuilder.buildChapter(1, 1001, count: 12);
      expect(built.map((b) => b.level.index), [
        for (var i = 1; i <= 12; i++) i,
      ]);
    });
  });

  group('MechanicsPass (units)', () {
    final rng = Mulberry32(1);

    test('apply refuses to return an unsolvable level', () {
      final unsolvable = buildLevel(arrows: deadlockBox());
      expect(
        () => MechanicsPass.apply(
          unsolvable,
          [0],
          const GenParams(width: 5, height: 5),
          Mulberry32(1),
        ),
        throwsStateError,
      );
    });

    test('addGate needs two rays crossing an empty cell', () {
      // A single arrow: no cell lies on two rays.
      final level = buildLevel(
        arrows: [
          arrowJson(0, [
            [0, 0],
            [1, 0],
          ], 'R'),
        ],
      );
      expect(MechanicsPass.addGate(level, [0], 0, rng), isNull);
    });

    test('addGate fails when no earlier arrow can be the key', () {
      // Cell (3,2) is on both rays but both arrows are first in the solution.
      final level = buildLevel(
        arrows: [
          arrowJson(0, [
            [0, 2],
            [1, 2],
          ], 'R'),
          arrowJson(1, [
            [3, 0],
            [3, 1],
          ], 'D'),
        ],
      );
      expect(MechanicsPass.addGate(level, [0, 1], 0, Mulberry32(5)), isNull);
    });

    test('addGate turns an earlier arrow into the key', () {
      final level = buildLevel(
        arrows: [
          arrowJson(0, [
            [0, 2],
            [1, 2],
          ], 'R'),
          arrowJson(1, [
            [3, 0],
            [3, 1],
          ], 'D'),
          arrowJson(2, [
            [4, 4],
          ], 'D'),
        ],
      );
      final next = MechanicsPass.addGate(level, [2, 0, 1], 1, Mulberry32(5))!;
      expect(next.gates, hasLength(1));
      expect(next.gates.single.color, GateColor.jade);
      final key = next.arrows.singleWhere((a) => a.kind == ArrowKind.key);
      expect(key.id, 2);
      expect(key.color, GateColor.jade);
    });

    test('addLink returns null without two adjacent free arrows', () {
      final level = buildLevel(
        arrows: [
          arrowJson(0, [
            [0, 0],
            [1, 0],
          ], 'R'),
          arrowJson(1, [
            [3, 0],
            [3, 1],
          ], 'D'),
        ],
      );
      // Arrow 1 is free first; arrow 0 only after it: no pair free together
      // at the same point.
      expect(MechanicsPass.addLink(level, [1, 0], 1, rng), isNull);
    });

    test('addLink joins a pair and drops the partner from the solution', () {
      final next = MechanicsPass.addLink(
        freeTrio(),
        [0, 1, 2],
        1,
        Mulberry32(3),
      )!;
      final linked = next.$1.arrows.where((a) => a.link == 'L1').toList();
      expect(linked, hasLength(2));
      expect(next.$2, hasLength(2));
      expect(
        next.$2.toSet().containsAll({...linked.map((a) => a.id)}),
        isFalse,
      );
    });

    test('addFrozen leaves very short solutions alone', () {
      final level = blockedPair();
      expect(MechanicsPass.addFrozen(level, 3, rng), same(level));
    });

    test('addFrozen sets counters no larger than the solution position', () {
      final level = buildLevel(
        arrows: [
          for (var i = 0; i < 5; i++)
            arrowJson(i, [
              [i, 0],
            ], 'U'),
        ],
      );
      final next = MechanicsPass.addFrozen(level, 2, Mulberry32(2));
      final frozen = next.arrows.where((a) => a.frozen != null).toList();
      expect(frozen, hasLength(2));
      for (final a in frozen) {
        expect(a.frozen, inInclusiveRange(1, 4));
      }
    });

    test('addRotators needs single-cell arrows', () {
      final level = buildLevel(
        arrows: [
          arrowJson(0, [
            [0, 0],
            [1, 0],
          ], 'R'),
        ],
      );
      expect(
        MechanicsPass.addRotators(
          level,
          const GenParams(width: 5, height: 5, mix: MechanicMix(rotators: 2)),
          rng,
        ),
        isNull,
      );
    });

    test('addRotators gives up when no variant is solvable in the band', () {
      // Every single-cell arrow boxed in => every rotator variant is a trap.
      final level = buildLevel(arrows: deadlockBox());
      expect(
        MechanicsPass.addRotators(
          level,
          const GenParams(
            width: 5,
            height: 5,
            rotatorTries: 5,
            mix: MechanicMix(rotators: 1),
          ),
          Mulberry32(4),
        ),
        isNull,
      );
    });

    test('addRotators returns a solved variant with a trap ratio', () {
      final level = buildLevel(
        arrows: [
          arrowJson(0, [
            [2, 2],
          ], 'U'),
          arrowJson(1, [
            [3, 2],
          ], 'L'),
          arrowJson(2, [
            [0, 0],
          ], 'L'),
        ],
      );
      final r = MechanicsPass.addRotators(
        level,
        const GenParams(
          width: 5,
          height: 5,
          trapMax: 1,
          mix: MechanicMix(rotators: 1),
        ),
        Mulberry32(8),
      )!;
      expect(
        r.$1.arrows.where((a) => a.kind == ArrowKind.rotator),
        hasLength(1),
      );
      expect(r.$2, isNotEmpty);
      expect(r.$3, inInclusiveRange(0, 1));
      final s = BoardState.initial(r.$1);
      expect(s.dirOf(0), isA<Direction>());
      expect(Rules.freeArrows(s), isNotNull);
    });
  });
}
