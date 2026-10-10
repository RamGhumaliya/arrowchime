import 'package:arrowchime/core/level/engine/rules.dart';
import 'package:arrowchime/core/level/models/board_state.dart';
import 'package:arrowchime/core/level/models/level.dart';
import 'package:arrowchime/core/level/solver/solve_result.dart';

/// Memoised depth-first solver for non-monotone mechanics (rotators,
/// switchers), where removals can also *block* arrows (`docs/04` §4.2).
///
/// Dead states are remembered by `BoardState.key`. Search aborts with
/// `tooComplex` after [stateLimit] expanded states.
class SearchSolver {
  new({
    this.stateLimit = 200000,
    this.config = const RulesConfig(),
    this.trapDepth = 4,
  });

  final int stateLimit;
  final RulesConfig config;

  /// How many solution positions `trapRatio` samples.
  final int trapDepth;

  final Set<String> _dead = {};
  int _expanded = 0;
  bool _overflow = false;

  SolveResult solveLevel(Level level) => solveState(BoardState.initial(level));

  /// Solves from [start] without modifying it.
  SolveResult solveState(BoardState start) {
    _dead.clear();
    _expanded = 0;
    _overflow = false;
    final path = <int>[];
    final solved = _dfs(start.copy(), path, const {});
    if (_overflow) {
      return SolveResult(
        solvable: false,
        tooComplex: true,
        statesExpanded: _expanded,
      );
    }
    if (!solved) return SolveResult(solvable: false, statesExpanded: _expanded);

    // Sampling may exhaust the budget; the solution itself is still valid.
    final searched = _expanded;
    final trap = _trapRatio(start, path);
    return SolveResult(
      solvable: true,
      solution: path,
      statesExpanded: searched,
      tooComplex: _overflow,
      trapRatio: trap,
    );
  }

  bool _dfs(BoardState s, List<int> path, Set<int> previouslyFree) {
    if (s.remaining == 0) return true;
    final key = s.key;
    if (_dead.contains(key)) return false;
    if (++_expanded > stateLimit) {
      _overflow = true;
      return false;
    }
    final moves = _moves(s, previouslyFree);
    final free = {...moves};
    for (final i in moves) {
      final child = s.copy();
      Rules.remove(child, i, config);
      path.add(s.layout.idOf(i));
      if (_dfs(child, path, free)) return true;
      path.removeLast();
      if (_overflow) return false;
    }
    _dead.add(key);
    return false;
  }

  /// Distinct legal moves, most recently freed first. A linked pair is one
  /// move (its lower-index arrow).
  List<int> _moves(BoardState s, Set<int> previouslyFree) {
    final fresh = <int>[];
    final old = <int>[];
    for (final i in Rules.freeArrows(s, config)) {
      final p = s.layout.partner[i];
      if (p >= 0 && p < i) continue;
      (previouslyFree.contains(i) ? old : fresh).add(i);
    }
    return [...fresh, ...old];
  }

  /// Share of legal moves, over the first [trapDepth] positions of the found
  /// [solution], that lead to an unsolvable board.
  double _trapRatio(BoardState start, List<int> solution) {
    var legal = 0;
    var traps = 0;
    final s = start.copy();
    for (var step = 0; step < trapDepth && step < solution.length; step++) {
      for (final i in _moves(s, const {})) {
        final child = s.copy();
        Rules.remove(child, i, config);
        legal++;
        _expanded = 0;
        if (!_dfs(child, [], const {}) && !_overflow) traps++;
      }
      Rules.remove(s, s.layout.indexById[solution[step]]!, config);
    }
    return legal == 0 ? 0 : traps / legal;
  }
}
