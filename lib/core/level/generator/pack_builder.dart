import 'package:arrowchime/core/level/generator/chapter_plan.dart';
import 'package:arrowchime/core/level/generator/generator.dart';
import 'package:arrowchime/core/level/generator/mechanic_tutorials.dart';
import 'package:arrowchime/core/level/generator/onboarding.dart';
import 'package:arrowchime/core/level/models/level.dart';
import 'package:arrowchime/core/level/prng.dart';

/// A generated chapter level and how close it is to its target.
class BuiltLevel {
  const new({
    required this.level,
    required this.target,
    required this.attempts,
  });

  final Level level;

  /// Target difficulty score from the chapter plan.
  final double target;

  /// Seeds tried until this level was accepted (or the budget ran out).
  final int attempts;

  double get score => level.meta.difficulty ?? 0;

  double get error => (score - target).abs();

  bool get withinTolerance => error <= ChapterPlan.checkTolerance;
}

/// Builds chapter packs: for each level searches seeds (adapting the
/// generator parameters) until the difficulty score lands on the chapter
/// plan's target.
abstract final class PackBuilder {
  /// A level this close to its target is accepted immediately.
  static const double acceptError = 2.5;

  /// Seeds tried per level at most.
  static const int maxAttempts = 80;

  /// Seed of attempt [attempt] of a level: derived with FNV-1a so it is
  /// identical on every platform.
  static int seedFor(int baseSeed, int chapter, int index, int attempt) =>
      fnv1a32('arrowchime-level-v1:$baseSeed:$chapter:$index:$attempt');

  /// Builds level [index] (1–60) of [chapter] (1–5).
  static BuiltLevel buildLevel(int chapter, int index, int baseSeed) {
    final target = ChapterPlan.targetScore(chapter, index);
    final id = ChapterPlan.idFor(chapter, index);
    final melody = ChapterPlan.melodyFor(chapter, index);

    if (chapter == 1 && index <= OnboardingLevels.count) {
      final level = OnboardingLevels.build(index);
      return BuiltLevel(level: level, target: target, attempts: 1);
    }

    if (MechanicTutorials.at(chapter, index) != null) {
      return BuiltLevel(
        level: MechanicTutorials.build(chapter, index),
        target: target,
        attempts: 1,
      );
    }

    Level? best;
    var bestError = double.infinity;
    // Bisect the easy ↔ hard axis: a harder `adapt` gives a higher score.
    var lo = -ChapterPlan.maxAdapt;
    var hi = ChapterPlan.maxAdapt;
    var adapt = 0.0;
    var attempts = 0;
    for (var a = 0; a < maxAttempts; a++) {
      attempts = a + 1;
      final params = ChapterPlan.paramsFor(chapter, index, adapt: adapt);
      final level = LevelGenerator.generate(
        params,
        seedFor(baseSeed, chapter, index, a),
        id: id,
        chapter: chapter,
        index: index,
        melody: melody,
      );
      final score = level.meta.difficulty ?? 0;
      final error = (score - target).abs();
      if (error < bestError) {
        best = level;
        bestError = error;
      }
      if (error <= acceptError) break;
      if (score < target) {
        lo = adapt;
      } else {
        hi = adapt;
      }
      adapt = (lo + hi) / 2;
      // Seeds are noisy: once the bracket collapses, widen it again.
      if (hi - lo < 0.2) {
        lo = -ChapterPlan.maxAdapt;
        hi = ChapterPlan.maxAdapt;
      }
    }
    return BuiltLevel(level: best!, target: target, attempts: attempts);
  }

  /// Builds [count] levels of [chapter] starting at level 1.
  static List<BuiltLevel> buildChapter(
    int chapter,
    int baseSeed, {
    int count = ChapterPlan.levelsPerChapter,
  }) => [for (var i = 1; i <= count; i++) buildLevel(chapter, i, baseSeed)];
}
