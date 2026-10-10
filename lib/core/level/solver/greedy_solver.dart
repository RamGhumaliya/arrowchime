import 'package:arrowchime/core/level/engine/rules.dart';
import 'package:arrowchime/core/level/models/board_state.dart';
import 'package:arrowchime/core/level/models/level.dart';
import 'package:arrowchime/core/level/solver/solve_result.dart';

/// Solver for monotone mechanics (base, masks, gates, frozen, linked,
/// portals), where removing an arrow never makes another less free: removing
/// *any* free arrow keeps a solvable board solvable (`docs/04` §4.1).
///
/// Do not use it for levels with rotators or enabled switchers; use
/// `SearchSolver`.
abstract final class GreedySolver {
  static SolveResult solveLevel(
    Level level, [
    RulesConfig config = const RulesConfig(),
  ]) => solveState(BoardState.initial(level), config);

  /// Solves from [start] without modifying it.
  static SolveResult solveState(
    BoardState start, [
    RulesConfig config = const RulesConfig(),
  ]) {
    final s = start.copy();
    final solution = <int>[];
    final waveFree = <int>[];
    final waveRemaining = <int>[];
    while (s.remaining > 0) {
      final free = Rules.freeArrows(s, config);
      if (free.isEmpty) {
        return SolveResult(
          solvable: false,
          solution: solution,
          depth: waveFree.length,
          waveFreeCounts: waveFree,
          waveRemaining: waveRemaining,
        );
      }
      waveFree.add(free.length);
      waveRemaining.add(s.remaining);
      for (final i in free) {
        if (!s.isAlive(i) || !Rules.isFree(s, i, config)) continue;
        solution.add(s.layout.idOf(i));
        Rules.remove(s, i, config);
      }
    }
    return SolveResult(
      solvable: true,
      solution: solution,
      depth: waveFree.length,
      waveFreeCounts: waveFree,
      waveRemaining: waveRemaining,
    );
  }
}
