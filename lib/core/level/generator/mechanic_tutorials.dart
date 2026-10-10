import 'package:arrowchime/core/level/generator/chapter_plan.dart';
import 'package:arrowchime/core/level/generator/gen_params.dart';
import 'package:arrowchime/core/level/generator/generator.dart';
import 'package:arrowchime/core/level/models/arrow.dart';
import 'package:arrowchime/core/level/models/level.dart';
import 'package:arrowchime/core/level/prng.dart';

/// The mechanic a tutorial level introduces (`docs/03` §5).
enum Mechanic { rotator, gateKey, frozen, link, portal }

/// One small level per mechanic, at the place where the mechanic first
/// appears: it has **only that mechanic**, a small board and few arrows, so
/// the player meets exactly one new idea (`docs/03` §6: "never more than one
/// new idea per level").
///
/// Generated with tight constraints and a deterministic seed search, then
/// marked `tutorial-1.0` (exempt from the difficulty band, still validated and
/// solver-verified).
abstract final class MechanicTutorials {
  static const String version = 'tutorial-1.0';

  /// Where each mechanic is introduced: (chapter, level index).
  static const Map<(int, int), Mechanic> slots = {
    (2, 1): Mechanic.rotator,
    (3, 1): Mechanic.gateKey,
    (4, 1): Mechanic.frozen,
    (5, 1): Mechanic.link,
    (5, 20): Mechanic.portal,
  };

  /// The tutorial at [chapter] / [index], or `null`.
  static Mechanic? at(int chapter, int index) => slots[(chapter, index)];

  static ({GenParams params, int minArrows, int maxArrows}) _spec(Mechanic m) {
    GenParams p(int size, MechanicMix mix, {double singles = 0, int cap = 9}) =>
        GenParams(
          width: size,
          height: size,
          targetFill: 0.8,
          lenMax: 4,
          singleCellShare: singles,
          maxFailures: 3000,
          mix: mix,
          maxArrows: cap,
          trapMax: 1,
        );
    return switch (m) {
      Mechanic.rotator => (
        params: p(7, const MechanicMix(rotators: 1), singles: 0.15, cap: 12),
        minArrows: 6,
        maxArrows: 12,
      ),
      Mechanic.gateKey => (
        params: p(7, const MechanicMix(gates: 1)),
        minArrows: 6,
        maxArrows: 9,
      ),
      Mechanic.frozen => (
        params: p(7, const MechanicMix(frozen: 1)),
        minArrows: 6,
        maxArrows: 9,
      ),
      Mechanic.link => (
        params: p(7, const MechanicMix(links: 1)),
        minArrows: 6,
        maxArrows: 9,
      ),
      Mechanic.portal => (
        params: p(8, const MechanicMix(portalPairs: 1)),
        minArrows: 6,
        maxArrows: 9,
      ),
    };
  }

  /// The set of mechanics [level] contains.
  static Set<Mechanic> mechanicsOf(Level level) => {
    if (level.arrows.any((a) => a.kind == ArrowKind.rotator)) Mechanic.rotator,
    if (level.gates.isNotEmpty) Mechanic.gateKey,
    if (level.arrows.any((a) => a.frozen != null)) Mechanic.frozen,
    if (level.arrows.any((a) => a.link != null)) Mechanic.link,
    if (level.portals.isNotEmpty) Mechanic.portal,
  };

  /// Builds the tutorial level for [chapter] / [index].
  static Level build(int chapter, int index) {
    final mechanic = at(chapter, index);
    if (mechanic == null) {
      throw ArgumentError('no mechanic tutorial at ch$chapter level $index');
    }
    final spec = _spec(mechanic);
    final id = ChapterPlan.idFor(chapter, index);
    Level? best;
    for (var attempt = 0; attempt < 600; attempt++) {
      final level = LevelGenerator.generate(
        spec.params,
        fnv1a32('arrowchime-tutorial-v1:${mechanic.name}:$attempt'),
        id: id,
        chapter: chapter,
        index: index,
        melody: ChapterPlan.melodyFor(chapter, index),
      );
      final n = level.arrows.length;
      if (n < spec.minArrows || n > spec.maxArrows) continue;
      if (mechanicsOf(level).length != 1 ||
          !mechanicsOf(level).contains(mechanic)) {
        continue;
      }
      final current = best;
      if (current == null ||
          (level.meta.difficulty ?? 0) < (current.meta.difficulty ?? 0)) {
        best = level;
      }
      if (attempt > 120 && best != null) break;
    }
    if (best == null) {
      throw StateError('no ${mechanic.name} tutorial found for ch$chapter');
    }
    return best.withMeta(
      LevelMeta(
        seed: best.meta.seed,
        generatorVersion: version,
        difficulty: best.meta.difficulty,
        depth: best.meta.depth,
        solution: best.meta.solution,
        melody: best.meta.melody,
      ),
    );
  }
}
