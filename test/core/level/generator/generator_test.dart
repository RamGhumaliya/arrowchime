import 'dart:convert';

import 'package:arrowchime/core/level/engine/game_engine.dart';
import 'package:arrowchime/core/level/engine/rules.dart';
import 'package:arrowchime/core/level/generator/chapter_plan.dart';
import 'package:arrowchime/core/level/generator/gen_params.dart';
import 'package:arrowchime/core/level/generator/generator.dart';
import 'package:arrowchime/core/level/generator/masks.dart';
import 'package:arrowchime/core/level/level_validator.dart';
import 'package:arrowchime/core/level/models/arrow.dart';
import 'package:arrowchime/core/level/models/board_state.dart';
import 'package:arrowchime/core/level/models/level.dart';
import 'package:arrowchime/core/level/solver/greedy_solver.dart';
import 'package:arrowchime/core/level/solver/hint.dart';
import 'package:arrowchime/core/level/solver/search_solver.dart';
import 'package:flutter_test/flutter_test.dart';

/// Asserts the generator's promises about [level]: valid, solvable, and its
/// `meta.solution` clears the board in the engine.
void expectSound(Level level, {String? reason}) {
  expect(validateLevel(level), isEmpty, reason: reason);
  final start = BoardState.initial(level);
  final solvable = isMonotone(start, const RulesConfig())
      ? GreedySolver.solveState(start).solvable
      : SearchSolver().solveState(start).solvable;
  expect(solvable, isTrue, reason: reason);

  final engine = GameEngine(level);
  for (final id in level.meta.solution) {
    expect(engine.isFree(id), isTrue, reason: '$reason: arrow $id not free');
    engine.tap(id);
  }
  expect(engine.status, GameStatus.won, reason: reason);
  expect(engine.hearts, level.hearts, reason: '$reason: no heart lost');
}

void main() {
  group('acceptance: 1,000 random seeds per chapter are 100% solvable', () {
    for (final chapter in ChapterPlan.bands.keys) {
      test('chapter $chapter', () {
        for (var seed = 1; seed <= 1000; seed++) {
          // Cover the whole chapter: sizes, masks, mechanics, adapt range.
          final index = (seed * 7) % ChapterPlan.levelsPerChapter + 1;
          final adapt = (seed % 7 - 3).toDouble();
          final params = ChapterPlan.paramsFor(chapter, index, adapt: adapt);
          final level = LevelGenerator.generate(
            params,
            seed * 2654435761 % 0xFFFFFFFF,
            chapter: chapter,
            index: index,
          );
          expectSound(level, reason: 'ch$chapter index $index seed $seed');
        }
      });
    }
  });

  group('base boards are solvable by construction', () {
    test('1,000 seeds across sizes, fills, lengths, windiness', () {
      for (var seed = 1; seed <= 1000; seed++) {
        final size = 5 + seed % 18;
        final p = GenParams(
          width: size,
          height: size,
          targetFill: 0.5 + (seed % 4) * 0.1,
          lenMin: 1 + seed % 3,
          lenMax: 3 + seed % 9,
          lenSkew: seed % 5 - 2,
          windiness: (seed % 10) / 10,
          centerBias: (seed % 3) / 3,
          clusterBias: (seed % 4) / 4,
        );
        final level = LevelGenerator.generate(p, seed);
        expectSound(level, reason: 'seed $seed ${p.width}x${p.height}');
        // Reverse construction: reverse placement order is a solution, i.e.
        // the greedy solver always finishes in few waves.
        expect(GreedySolver.solveLevel(level).solvable, isTrue);
      }
    });

    test('rectangular boards work too', () {
      final level = LevelGenerator.generate(
        const GenParams(width: 12, height: 6),
        3,
      );
      expect(level.width, 12);
      expect(level.height, 6);
      expectSound(level);
    });
  });

  group('determinism', () {
    test('same seed gives identical JSON', () {
      const p = GenParams(
        width: 10,
        height: 10,
        mix: MechanicMix(gates: 1, frozen: 1, links: 1),
      );
      for (final seed in [1, 2, 3, 0xFFFFFFFF]) {
        final a = jsonEncode(LevelGenerator.generate(p, seed).toJson());
        final b = jsonEncode(LevelGenerator.generate(p, seed).toJson());
        expect(a, b, reason: 'seed $seed');
      }
    });

    test('different seeds give different levels', () {
      const p = GenParams(width: 10, height: 10);
      final seen = <String>{
        for (var s = 1; s <= 20; s++)
          jsonEncode(LevelGenerator.generate(p, s).toJson()),
      };
      expect(seen.length, 20);
    });

    test('records its seed and version in meta', () {
      final level = LevelGenerator.generate(
        const GenParams(width: 6, height: 6),
        77,
        id: 'x',
        chapter: 1,
        index: 3,
        melody: 'ch1_m03',
      );
      expect(level.meta.seed, 77);
      expect(level.meta.generatorVersion, LevelGenerator.version);
      expect(level.meta.melody, 'ch1_m03');
      expect(level.id, 'x');
      expect(level.chapter, 1);
      expect(level.index, 3);
      expect(level.meta.difficulty, isNotNull);
      expect(level.meta.depth, greaterThan(0));
    });
  });

  group('parameters', () {
    test('maxArrows caps the arrow count', () {
      for (final cap in [1, 3, 6]) {
        final level = LevelGenerator.generate(
          GenParams(width: 8, height: 8, targetFill: 0.95, maxArrows: cap),
          5,
        );
        expect(level.arrows.length, lessThanOrEqualTo(cap));
        expectSound(level);
      }
    });

    test('lenMin / lenMax bound every body', () {
      final level = LevelGenerator.generate(
        const GenParams(width: 12, height: 12, lenMin: 3, lenMax: 5),
        9,
      );
      for (final a in level.arrows) {
        expect(a.body.length, inInclusiveRange(3, 5));
      }
    });

    test('length skew shifts the mean length', () {
      double mean(int skew) {
        var sum = 0;
        var n = 0;
        for (var seed = 1; seed <= 30; seed++) {
          final l = LevelGenerator.generate(
            GenParams(
              width: 12,
              height: 12,
              lenMax: 9,
              lenSkew: skew,
              targetFill: 0.6,
            ),
            seed,
          );
          for (final a in l.arrows) {
            sum += a.body.length;
            n++;
          }
        }
        return sum / n;
      }

      expect(mean(2), lessThan(mean(0)));
      expect(mean(-2), greaterThan(mean(0)));
    });

    test('single-cell share creates single-cell arrows', () {
      final level = LevelGenerator.generate(
        const GenParams(width: 10, height: 10, lenMin: 3, singleCellShare: 0.3),
        4,
      );
      final singles = level.arrows.where((a) => a.body.length == 1).length;
      expect(singles, greaterThan(0));
      expect(
        level.arrows
            .where((a) => a.body.length > 1)
            .every((a) => a.body.length >= 3),
        isTrue,
      );
    });

    test('target fill is respected (up to the failure budget)', () {
      final level = LevelGenerator.generate(
        const GenParams(width: 12, height: 12, targetFill: 0.5),
        6,
      );
      var occupied = 0;
      for (final a in level.arrows) {
        occupied += a.body.length;
      }
      expect(occupied / 144, greaterThanOrEqualTo(0.5));
      expect(occupied / 144, lessThan(0.7));
    });

    test('masks keep every arrow on playable cells', () {
      for (final kind in [...Masks.kinds, 'circle']) {
        final level = LevelGenerator.generate(
          GenParams(width: 12, height: 12, mask: Masks.byName(kind, 12, 12)),
          11,
        );
        expect(level.mask, isNotNull, reason: kind);
        for (final a in level.arrows) {
          for (final c in a.body) {
            expect(level.isActive(c.x, c.y), isTrue, reason: kind);
          }
        }
        expectSound(level, reason: kind);
      }
    });

    test('too tight parameters raise a clear error', () {
      expect(
        () => LevelGenerator.generate(
          const GenParams(
            width: 6,
            height: 6,
            mask: ['000000', '000000', '000000', '000000', '000000', '000000'],
          ),
          1,
        ),
        throwsStateError,
      );
    });
  });

  group('mechanics', () {
    Iterable<Level> levels(GenParams p, {int count = 40}) sync* {
      for (var seed = 1; seed <= count; seed++) {
        yield LevelGenerator.generate(p, seed * 101);
      }
    }

    test('gates come with a key of the same colour', () {
      var withGate = 0;
      for (final level in levels(
        const GenParams(
          width: 10,
          height: 10,
          targetFill: 0.8,
          lenMax: 7,
          mix: MechanicMix(gates: 2),
        ),
      )) {
        expectSound(level);
        if (level.gates.isNotEmpty) withGate++;
        for (final g in level.gates) {
          expect(
            level.arrows.any(
              (a) => a.kind == ArrowKind.key && a.color == g.color,
            ),
            isTrue,
            reason: 'gate ${g.color} needs a key',
          );
        }
        // Distinct colours, never more than the palette.
        expect(
          level.gates.map((g) => g.color).toSet().length,
          level.gates.length,
        );
      }
      expect(withGate, greaterThan(30));
    });

    test('frozen counters never exceed the solution position', () {
      var withFrozen = 0;
      for (final level in levels(
        const GenParams(
          width: 10,
          height: 10,
          targetFill: 0.8,
          mix: MechanicMix(frozen: 3),
        ),
      )) {
        expectSound(level);
        final frozen = level.arrows.where((a) => a.frozen != null).toList();
        if (frozen.isNotEmpty) withFrozen++;
        for (final a in frozen) {
          final pos = level.meta.solution.indexOf(a.id);
          expect(pos, greaterThanOrEqualTo(a.frozen!), reason: 'arrow ${a.id}');
        }
      }
      expect(withFrozen, greaterThan(30));
    });

    test('linked pairs have exactly two arrows and one solution entry', () {
      var withLinks = 0;
      for (final level in levels(
        const GenParams(
          width: 10,
          height: 10,
          targetFill: 0.8,
          mix: MechanicMix(links: 2),
        ),
      )) {
        expectSound(level);
        final byLink = <String, List<int>>{};
        for (final a in level.arrows) {
          if (a.link != null) (byLink[a.link!] ??= []).add(a.id);
        }
        if (byLink.isNotEmpty) withLinks++;
        for (final ids in byLink.values) {
          expect(ids.length, 2);
          final inSolution = ids.where(level.meta.solution.contains).length;
          expect(inSolution, 1, reason: 'one tap clears the pair');
        }
        expect(level.meta.solution.length, level.arrows.length - byLink.length);
      }
      expect(withLinks, greaterThan(30));
    });

    test('portal levels route at least one ray through a portal', () {
      var through = 0;
      for (final level in levels(
        const GenParams(
          width: 9,
          height: 9,
          targetFill: 0.75,
          mix: MechanicMix(portalPairs: 1),
        ),
      )) {
        expectSound(level);
        expect(level.portals, hasLength(1));
        final s = BoardState.initial(level);
        final crosses = [
          for (var i = 0; i < s.layout.arrowCount; i++)
            Rules.exitPaths(
              s,
              i,
              blocking: false,
            ).any((p) => p.any((c) => s.layout.portalOther[c] >= 0)),
        ].any((x) => x);
        if (crosses) through++;
      }
      expect(through, greaterThan(30));
    });

    test('rotator levels are solvable and within the trap band', () {
      var withRotators = 0;
      for (final level in levels(
        const GenParams(
          width: 8,
          height: 8,
          targetFill: 0.75,
          singleCellShare: 0.2,
          mix: MechanicMix(rotators: 3),
        ),
        count: 25,
      )) {
        expectSound(level);
        final rotators = level.arrows
            .where((a) => a.kind == ArrowKind.rotator)
            .toList();
        if (rotators.isNotEmpty) withRotators++;
        for (final a in rotators) {
          expect(a.body.length, 1);
        }
        final r = SearchSolver().solveLevel(level);
        expect(r.trapRatio, inInclusiveRange(0, 0.5));
      }
      expect(withRotators, greaterThan(15));
    });

    test('a full mix still produces a sound level', () {
      for (var seed = 1; seed <= 30; seed++) {
        final level = LevelGenerator.generate(
          const GenParams(
            width: 12,
            height: 12,
            targetFill: 0.8,
            singleCellShare: 0.15,
            mix: MechanicMix(
              gates: 2,
              frozen: 2,
              links: 1,
              portalPairs: 1,
              rotators: 2,
            ),
          ),
          seed,
        );
        expectSound(level, reason: 'seed $seed');
      }
    });
  });
}
