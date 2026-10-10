import 'package:arrowchime/core/level/engine/rules.dart';
import 'package:arrowchime/core/level/models/arrow.dart';
import 'package:arrowchime/core/level/models/board_state.dart';
import 'package:arrowchime/core/level/models/level.dart';
import 'package:arrowchime/core/level/solver/greedy_solver.dart';
import 'package:arrowchime/core/level/solver/hint.dart';
import 'package:arrowchime/core/level/solver/search_solver.dart';

/// Wave structure of a solution: how many arrows were free / left at the start
/// of each wave (`docs/04` §4.1).
class WaveStats {
  const new({required this.freeCounts, required this.remaining});

  /// Replays [solution] (arrow ids in tap order) on a fresh board. A wave is
  /// the longest run of the remaining solution whose arrows were all free at
  /// the wave's start. For a greedy solution this equals the greedy waves.
  factory fromSolution(Level level, List<int> solution) {
    final s = BoardState.initial(level);
    final freeCounts = <int>[];
    final remaining = <int>[];
    var next = 0;
    while (next < solution.length) {
      final free = Rules.freeArrows(s).toSet();
      freeCounts.add(free.length);
      remaining.add(s.remaining);
      var consumed = 0;
      for (var k = next; k < solution.length; k++) {
        final i = s.layout.indexById[solution[k]]!;
        if (!free.contains(i) || !s.isAlive(i) || !Rules.isFree(s, i)) break;
        Rules.remove(s, i);
        consumed++;
      }
      if (consumed == 0) break;
      next += consumed;
    }
    return WaveStats(freeCounts: freeCounts, remaining: remaining);
  }

  final List<int> freeCounts;
  final List<int> remaining;

  int get depth => freeCounts.length;

  /// Mean of `free / remaining` over all waves.
  double get freeRatio {
    var sum = 0.0;
    for (var i = 0; i < freeCounts.length; i++) {
      sum += freeCounts[i] / remaining[i];
    }
    return freeCounts.isEmpty ? 1 : sum / freeCounts.length;
  }

  int get minFree =>
      freeCounts.isEmpty ? 0 : freeCounts.reduce((a, b) => a < b ? a : b);
}

/// Every ingredient of the difficulty score plus the score itself.
class DifficultyReport {
  const new({
    required this.solvable,
    required this.depth,
    required this.freeRatio,
    required this.minFree,
    required this.density,
    required this.avgLen,
    required this.turns,
    required this.deception,
    required this.mechanics,
    required this.trapRatio,
    required this.score,
    required this.solution,
  });

  /// Greedy / search found a solution. If `false` the other numbers are 0.
  final bool solvable;
  final int depth;
  final double freeRatio;
  final int minFree;
  final double density;
  final double avgLen;
  final double turns;
  final double deception;
  final double mechanics;
  final double trapRatio;

  /// 0–100, rounded to one decimal.
  final double score;

  /// The solution the numbers were derived from.
  final List<int> solution;
}

/// Difficulty score 0–100 (`docs/04` §5):
///
/// ```text
/// score = 4.0*depth + 30*(1 - freeRatio) + 8*(1/max(minFree,1)) + 10*density
///       + 0.6*avgLen + 3*turns + 15*deception + mechanics + 25*trapRatio
/// score = clamp(score * 0.9, 0, 100)
/// ```
///
/// `mechanics` adds each mechanic **type** present in the level once
/// (rotator 6, switcher 6, gate 4, frozen 3, link 3, portal 5).
abstract final class Difficulty {
  static const double rotatorWeight = 6;
  static const double switcherWeight = 6;
  static const double gateWeight = 4;
  static const double frozenWeight = 3;
  static const double linkWeight = 3;
  static const double portalWeight = 5;

  /// Analyses [level]. Pass [solution] (and [trapRatio]) to avoid re-solving
  /// when the caller already has them; otherwise the right solver runs.
  static DifficultyReport analyze(
    Level level, {
    List<int>? solution,
    double? trapRatio,
    RulesConfig config = const RulesConfig(),
  }) {
    final start = BoardState.initial(level);
    var sol = solution;
    var trap = trapRatio ?? 0;
    if (sol == null) {
      if (isMonotone(start, config)) {
        final r = GreedySolver.solveState(start, config);
        sol = r.solvable ? r.solution : null;
      } else {
        final r = SearchSolver(config: config).solveState(start);
        sol = r.solvable ? r.solution : null;
        trap = r.trapRatio;
      }
    }
    if (sol == null) return _unsolvable;

    // Wave structure comes from the greedy order whenever greedy can finish
    // the level (always for monotone levels), so it does not depend on which
    // solution a solver happened to find. Rotator levels that greedy cannot
    // finish fall back to replaying the given solution.
    final greedy = GreedySolver.solveState(start, config);
    final waves = greedy.solvable
        ? WaveStats(
            freeCounts: greedy.waveFreeCounts,
            remaining: greedy.waveRemaining,
          )
        : WaveStats.fromSolution(level, sol);
    final density = _density(level);
    final avgLen = _mean([for (final a in level.arrows) a.body.length]);
    final turns = _mean([for (final a in level.arrows) _turns(a)]);
    final deception = _deception(start);
    final mechanics = _mechanics(level, config);

    final raw =
        4.0 * waves.depth +
        30 * (1 - waves.freeRatio) +
        8 * (1 / (waves.minFree < 1 ? 1 : waves.minFree)) +
        10 * density +
        0.6 * avgLen +
        3 * turns +
        15 * deception +
        mechanics +
        25 * trap;
    final clamped = (raw * 0.9).clamp(0.0, 100.0);
    return DifficultyReport(
      solvable: true,
      depth: waves.depth,
      freeRatio: waves.freeRatio,
      minFree: waves.minFree,
      density: density,
      avgLen: avgLen,
      turns: turns,
      deception: deception,
      mechanics: mechanics,
      trapRatio: trap,
      score: (clamped * 10).round() / 10,
      solution: sol,
    );
  }

  static const DifficultyReport _unsolvable = DifficultyReport(
    solvable: false,
    depth: 0,
    freeRatio: 0,
    minFree: 0,
    density: 0,
    avgLen: 0,
    turns: 0,
    deception: 0,
    mechanics: 0,
    trapRatio: 0,
    score: 0,
    solution: [],
  );

  static double _mean(List<num> values) => values.isEmpty
      ? 0
      : values.fold<double>(0, (a, b) => a + b) / values.length;

  static double _density(Level level) {
    var playable = 0;
    for (var y = 0; y < level.height; y++) {
      for (var x = 0; x < level.width; x++) {
        if (level.isActive(x, y)) playable++;
      }
    }
    var occupied = 0;
    for (final a in level.arrows) {
      occupied += a.body.length;
    }
    return playable == 0 ? 0 : occupied / playable;
  }

  /// Number of direction changes along the body.
  static int _turns(Arrow a) {
    var turns = 0;
    for (var i = 2; i < a.body.length; i++) {
      final dx1 = a.body[i - 1].x - a.body[i - 2].x;
      final dy1 = a.body[i - 1].y - a.body[i - 2].y;
      final dx2 = a.body[i].x - a.body[i - 1].x;
      final dy2 = a.body[i].y - a.body[i - 1].y;
      if (dx1 != dx2 || dy1 != dy2) turns++;
    }
    return turns;
  }

  /// Share of initially blocked arrows that "look free": exactly one cell of
  /// their ray is blocking, and it is at least 4 cells from the head.
  static double _deception(BoardState s) {
    var blocked = 0;
    var deceptive = 0;
    for (var i = 0; i < s.alive.length; i++) {
      if (Rules.isFree(s, i) || s.frozen[i] > 0) continue;
      blocked++;
      final path = Rules.exitPaths(s, i, blocking: false).first;
      var blockers = 0;
      var firstIndex = -1;
      for (var k = 0; k < path.length; k++) {
        final c = path[k];
        final o = s.occupant[c];
        final closedGate =
            s.layout.gateColor[c] >= 0 && !s.isGateOpen(s.layout.gateColor[c]);
        if ((o >= 0 && o != i) || closedGate) {
          blockers++;
          firstIndex = k;
        }
      }
      if (blockers == 1 && firstIndex + 1 >= 4) deceptive++;
    }
    return blocked == 0 ? 0 : deceptive / blocked;
  }

  static double _mechanics(Level level, RulesConfig config) {
    var sum = 0.0;
    final kinds = {for (final a in level.arrows) a.kind};
    if (kinds.contains(ArrowKind.rotator)) sum += rotatorWeight;
    if (kinds.contains(ArrowKind.switcher) && config.enableSwitcher) {
      sum += switcherWeight;
    }
    if (level.gates.isNotEmpty) sum += gateWeight;
    if (level.arrows.any((a) => a.frozen != null)) sum += frozenWeight;
    if (level.arrows.any((a) => a.link != null)) sum += linkWeight;
    if (level.portals.isNotEmpty) sum += portalWeight;
    return sum;
  }
}
