import 'package:arrowchime/core/level/engine/game_engine.dart';
import 'package:arrowchime/core/level/engine/rules.dart';
import 'package:arrowchime/core/level/models/arrow.dart';
import 'package:arrowchime/core/level/models/board_state.dart';
import 'package:arrowchime/core/level/solver/greedy_solver.dart';
import 'package:arrowchime/core/level/solver/search_solver.dart';

/// Whether removals can only ever free space under [config], so the greedy
/// solver is exact.
bool isMonotone(BoardState s, RulesConfig config) => !s.layout.level.arrows.any(
  (a) =>
      a.kind == ArrowKind.rotator ||
      (a.kind == ArrowKind.switcher && config.enableSwitcher),
);

/// Hint: the first arrow of a solution computed from the **current** state
/// (greedy for monotone levels, search otherwise), cached per state
/// (`docs/04` §4.3).
class HintService {
  new(this.engine);

  final GameEngine engine;
  final Map<String, int?> _cache = {};

  /// Id of a free arrow that keeps the level solvable, or `null` when the
  /// level is over or cannot be solved from here.
  int? next() {
    if (engine.status != GameStatus.playing) return null;
    final state = engine.state;
    return _cache.putIfAbsent(state.key, () => _compute(state));
  }

  int? _compute(BoardState state) {
    final config = engine.options.rules;
    final result = isMonotone(state, config)
        ? GreedySolver.solveState(state, config)
        : SearchSolver(config: config).solveState(state);
    return result.solvable ? result.solution.first : null;
  }
}
