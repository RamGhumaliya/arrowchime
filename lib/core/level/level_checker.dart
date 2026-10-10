import 'package:arrowchime/core/level/difficulty.dart';
import 'package:arrowchime/core/level/engine/game_engine.dart';
import 'package:arrowchime/core/level/engine/rules.dart';
import 'package:arrowchime/core/level/generator/chapter_plan.dart';
import 'package:arrowchime/core/level/level_validator.dart';
import 'package:arrowchime/core/level/models/board_state.dart';
import 'package:arrowchime/core/level/models/daily_pack.dart';
import 'package:arrowchime/core/level/models/level.dart';
import 'package:arrowchime/core/level/solver/greedy_solver.dart';
import 'package:arrowchime/core/level/solver/hint.dart';
import 'package:arrowchime/core/level/solver/search_solver.dart';

/// Result of checking one level.
class LevelCheckResult {
  const new({required this.errors, this.score});

  /// Human-readable problems; empty = the level passes.
  final List<String> errors;

  /// Recomputed difficulty score, when the level is solvable.
  final double? score;

  bool get ok => errors.isEmpty;
}

/// Everything `tool/level_check.dart` verifies (`docs/04` §7, `docs/09` §3):
/// schema-valid (done by parsing), rules, solvable, stored solution replays,
/// stored difficulty current, and difficulty within ±6 of the chapter target.
abstract final class LevelChecker {
  /// Levels whose `generatorVersion` starts with one of these are hand-made
  /// or hand-curated: rules and solvability are checked, the difficulty band
  /// and stored score are not.
  static const List<String> exemptVersions = [
    'handmade',
    'proto',
    'onboarding',
    'tutorial',
  ];

  static bool isBandExempt(Level level) {
    final v = level.meta.generatorVersion;
    return v != null && exemptVersions.any(v.startsWith);
  }

  /// [searchStateLimit] bounds the search solver used for rotator levels
  /// (`docs/04` §4.2: 200,000).
  static LevelCheckResult checkLevel(
    Level level, {
    int searchStateLimit = 200000,
  }) {
    final errors = <String>[];
    final rules = validateLevel(level);
    if (rules.isNotEmpty) return LevelCheckResult(errors: rules);

    final start = BoardState.initial(level);
    List<int>? solution;
    if (isMonotone(start, const RulesConfig())) {
      final r = GreedySolver.solveState(start);
      if (r.solvable) solution = r.solution;
    } else {
      final r = SearchSolver(stateLimit: searchStateLimit).solveState(start);
      if (r.tooComplex) {
        errors.add('search solver exceeded its state limit (too complex)');
      } else if (r.solvable) {
        solution = r.solution;
      }
    }
    if (solution == null) {
      if (errors.isEmpty) errors.add('level is not solvable');
      return LevelCheckResult(errors: errors);
    }

    if (level.meta.solution.isNotEmpty) {
      final engine = GameEngine(level);
      for (final id in level.meta.solution) {
        if (!engine.isFree(id)) {
          errors.add('meta.solution: arrow $id is not free when tapped');
          break;
        }
        engine.tap(id);
      }
      if (errors.isEmpty && engine.status != GameStatus.won) {
        errors.add('meta.solution does not clear the board');
      }
    }

    final report = Difficulty.analyze(level, solution: solution);
    final stored = level.meta.difficulty;
    if (!isBandExempt(level)) {
      if (stored != null && (stored - report.score).abs() > 0.1) {
        errors.add(
          'meta.difficulty $stored is stale (recomputed ${report.score})',
        );
      }
      final chapter = level.chapter;
      final index = level.index;
      if (chapter != null &&
          index != null &&
          ChapterPlan.bands.containsKey(chapter) &&
          index >= 1 &&
          index <= ChapterPlan.levelsPerChapter) {
        final target = ChapterPlan.targetScore(chapter, index);
        if ((report.score - target).abs() > ChapterPlan.checkTolerance) {
          errors.add(
            'difficulty ${report.score} is not within '
            '±${ChapterPlan.checkTolerance} of the target $target',
          );
        }
      }
    }
    return LevelCheckResult(errors: errors, score: report.score);
  }

  /// Checks every level of a chapter pack plus pack-level rules: unique ids,
  /// matching chapter, indexes `1..n`. Returns `"<id>: <problem>"` lines.
  static List<String> checkPack(LevelPack pack, {int? expectedChapter}) {
    final problems = <String>[];
    final seen = <String>{};
    for (var i = 0; i < pack.levels.length; i++) {
      final level = pack.levels[i];
      if (!seen.add(level.id)) problems.add('${level.id}: duplicate id');
      if (expectedChapter != null && level.chapter != expectedChapter) {
        problems.add(
          '${level.id}: chapter ${level.chapter} != pack chapter '
          '$expectedChapter',
        );
      }
      if (expectedChapter != null && level.index != i + 1) {
        problems.add('${level.id}: index ${level.index} should be ${i + 1}');
      }
      for (final e in checkLevel(level).errors) {
        problems.add('${level.id}: $e');
      }
    }
    return problems;
  }

  /// Checks a daily pack: every level valid and solvable, keys are
  /// consecutive dates, ids match their date.
  static List<String> checkDailyPack(DailyPack pack) {
    final problems = <String>[];
    DateTime? previous;
    for (final e in pack.levels.entries) {
      final date = DateTime.tryParse('${e.key}T00:00:00Z');
      if (date == null) {
        problems.add('${e.key}: not a valid date');
        continue;
      }
      if (previous != null && date.difference(previous).inDays != 1) {
        problems.add('${e.key}: gap after ${previous.toIso8601String()}');
      }
      previous = date;
      final expectedId = 'daily_${e.key.replaceAll('-', '')}';
      if (e.value.id != expectedId) {
        problems.add('${e.key}: id ${e.value.id} should be $expectedId');
      }
      for (final err in checkLevel(e.value).errors) {
        problems.add('${e.key}: $err');
      }
    }
    return problems;
  }
}
