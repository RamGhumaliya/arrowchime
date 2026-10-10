import 'package:arrowchime/core/level/difficulty.dart';
import 'package:arrowchime/core/level/generator/chapter_plan.dart';
import 'package:arrowchime/core/level/generator/gen_params.dart';
import 'package:arrowchime/core/level/generator/generator.dart';
import 'package:arrowchime/core/level/generator/masks.dart';
import 'package:arrowchime/core/level/models/arrow.dart';
import 'package:arrowchime/core/level/models/level.dart';
import 'package:arrowchime/core/level/prng.dart';
import 'package:arrowchime/core/level/solver/greedy_solver.dart';

/// Chapter 1, levels 1–10: the onboarding table of `docs/03` §6. One new idea
/// per level, no mechanics.
///
/// L1 and L2 are hand-authored; L3–L10 come from the generator with tight
/// constraints (arrow count, bends, depth) and a deterministic seed search.
/// These levels are exempt from the difficulty-band check
/// (`generatorVersion` is [version]).
abstract final class OnboardingLevels {
  static const int count = 10;
  static const String version = 'onboarding-1.0';

  static Level build(int index) {
    if (index < 1 || index > count) {
      throw RangeError.range(index, 1, count, 'index');
    }
    final level = switch (index) {
      1 => _level1(),
      2 => _level2(),
      _ => _generated(index),
    };
    return _finish(level, index);
  }

  /// L1 — tap an arrow, it flies out: 3 straight arrows, all free.
  static Level _level1() => Level.fromJson({
    'schema': 1,
    'id': 'ch1_l001',
    'width': 5,
    'height': 5,
    'hearts': 3,
    'arrows': [
      _arrow(0, [
        [0, 1],
        [1, 1],
      ], 'R'),
      _arrow(1, [
        [2, 4],
        [2, 3],
      ], 'U'),
      _arrow(2, [
        [4, 4],
        [4, 3],
      ], 'U'),
    ],
  });

  /// L2 — some arrows are blocked: 4 arrows, exactly 1 blocked (arrow 1, by
  /// arrow 2 two cells ahead).
  static Level _level2() => Level.fromJson({
    'schema': 1,
    'id': 'ch1_l002',
    'width': 5,
    'height': 5,
    'hearts': 3,
    'arrows': [
      _arrow(0, [
        [0, 1],
        [1, 1],
      ], 'R'),
      _arrow(1, [
        [0, 3],
        [1, 3],
      ], 'R'),
      _arrow(2, [
        [3, 3],
        [3, 4],
      ], 'D'),
      _arrow(3, [
        [2, 0],
        [3, 0],
      ], 'R'),
    ],
  });

  static Map<String, Object?> _arrow(
    int id,
    List<List<int>> body,
    String dir,
  ) => {'id': id, 'body': body, 'dir': dir, 'kind': 'normal'};

  /// Per-level generator constraints.
  static ({GenParams params, int arrows, int minDepth, int minBent}) _spec(
    int index,
  ) {
    GenParams p(int size, int arrows, int lenMin, int lenMax, double wind) =>
        GenParams(
          width: size,
          height: size,
          targetFill: 0.95,
          lenMin: lenMin,
          lenMax: lenMax,
          windiness: wind,
          maxArrows: arrows,
          maxFailures: 3000,
        );
    return switch (index) {
      3 => (params: p(6, 6, 2, 3, 0.4), arrows: 6, minDepth: 2, minBent: 0),
      4 => (params: p(6, 5, 3, 5, 0.85), arrows: 5, minDepth: 2, minBent: 3),
      5 => (params: p(7, 8, 2, 5, 0.5), arrows: 8, minDepth: 3, minBent: 0),
      6 => (params: p(7, 10, 2, 5, 0.5), arrows: 10, minDepth: 3, minBent: 0),
      7 => (params: p(8, 12, 2, 6, 0.5), arrows: 12, minDepth: 3, minBent: 0),
      8 => (params: p(14, 14, 3, 9, 0.5), arrows: 14, minDepth: 3, minBent: 0),
      9 => (params: p(9, 12, 2, 6, 0.55), arrows: 12, minDepth: 3, minBent: 0),
      // L10 — first Knot level: heart shape.
      _ => (
        params: GenParams(
          width: 10,
          height: 10,
          mask: Masks.heart(10, 10),
          targetFill: 0.6,
          lenMax: 5,
          windiness: 0.5,
          maxFailures: 3000,
        ),
        arrows: 0,
        minDepth: 3,
        minBent: 0,
      ),
    };
  }

  /// The easiest (lowest-score) of the first [_candidates] seeds that meet the
  /// constraints, so the early levels stay gentle.
  static const int _candidates = 30;

  static Level _generated(int index) {
    final spec = _spec(index);
    Level? best;
    var found = 0;
    for (var attempt = 0; attempt < 1500 && found < _candidates; attempt++) {
      final level = LevelGenerator.generate(
        spec.params,
        fnv1a32('arrowchime-onboarding-v1:$index:$attempt'),
        id: ChapterPlan.idFor(1, index),
        chapter: 1,
        index: index,
      );
      if (spec.arrows != 0 && level.arrows.length != spec.arrows) continue;
      if (spec.arrows == 0 && level.arrows.length < 12) continue;
      if ((level.meta.depth ?? 0) < spec.minDepth) continue;
      if (_bent(level) < spec.minBent) continue;
      found++;
      if (best == null ||
          (level.meta.difficulty ?? 0) < (best.meta.difficulty ?? 0)) {
        best = level;
      }
    }
    assert(best != null, 'no onboarding level $index meets its constraints');
    return best!;
  }

  static int _bent(Level level) => level.arrows.where(_hasBend).length;

  static bool _hasBend(Arrow a) {
    for (var i = 2; i < a.body.length; i++) {
      final dx1 = a.body[i - 1].x - a.body[i - 2].x;
      final dy1 = a.body[i - 1].y - a.body[i - 2].y;
      final dx2 = a.body[i].x - a.body[i - 1].x;
      final dy2 = a.body[i].y - a.body[i - 1].y;
      if (dx1 != dx2 || dy1 != dy2) return true;
    }
    return false;
  }

  /// Fills in `chapter`, `index`, and `meta` for hand-authored levels.
  static Level _finish(Level level, int index) {
    final solved = GreedySolver.solveLevel(level);
    final report = Difficulty.analyze(level, solution: solved.solution);
    return level
        .copyWith(chapter: 1, index: index)
        .withMeta(
          LevelMeta(
            seed: level.meta.seed ?? 0,
            generatorVersion: version,
            difficulty: report.score,
            depth: report.depth,
            solution: solved.solution,
            melody: ChapterPlan.melodyFor(1, index),
          ),
        );
  }
}
