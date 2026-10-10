import 'package:arrowchime/core/level/engine/rules.dart';
import 'package:arrowchime/core/level/generator/gen_params.dart';
import 'package:arrowchime/core/level/models/arrow.dart';
import 'package:arrowchime/core/level/models/board_state.dart';
import 'package:arrowchime/core/level/models/direction.dart';
import 'package:arrowchime/core/level/models/gate.dart';
import 'package:arrowchime/core/level/models/level.dart';
import 'package:arrowchime/core/level/prng.dart';
import 'package:arrowchime/core/level/solver/greedy_solver.dart';
import 'package:arrowchime/core/level/solver/search_solver.dart';
import 'package:meta/meta.dart';

/// A level after the mechanics pass, with a verified solution.
class MechanicsResult {
  const new(this.level, this.solution, this.trapRatio);

  final Level level;

  /// Arrow ids in a valid tap order.
  final List<int> solution;

  /// 0 for monotone levels.
  final double trapRatio;
}

/// Adds mechanics to a solvable base board (`docs/04` §3.3). Every step is
/// verified by a solver and silently skipped when it cannot be done validly,
/// so the result is always solvable.
abstract final class MechanicsPass {
  static const int maxGates = 4;

  /// [solution] must be a valid tap order of [level] (the base solution).
  static MechanicsResult apply(
    Level level,
    List<int> solution,
    GenParams p,
    Mulberry32 rng,
  ) {
    var cur = level;
    var sol = solution;

    final gates = p.mix.gates < maxGates ? p.mix.gates : maxGates;
    for (var g = 0; g < gates; g++) {
      final next = addGate(cur, sol, g, rng);
      if (next == null) break;
      cur = next;
    }

    for (var k = 1; k <= p.mix.links; k++) {
      final next = addLink(cur, sol, k, rng);
      if (next == null) break;
      cur = next.$1;
      sol = next.$2;
    }

    if (p.mix.frozen > 0) cur = addFrozen(cur, p.mix.frozen, rng);

    if (p.mix.rotators > 0) {
      final r = addRotators(cur, p, rng);
      if (r != null) return MechanicsResult(r.$1, r.$2, r.$3);
    }

    final solved = GreedySolver.solveLevel(cur);
    if (!solved.solvable) {
      throw StateError('mechanics pass produced an unsolvable level');
    }
    return MechanicsResult(cur, solved.solution, 0);
  }

  /// Puts a gate on an empty cell that lies on ≥ 2 arrows' rays and makes an
  /// arrow that is removed **earlier** than all of those arrows its key.
  /// Returns `null` when no valid placement exists.
  @visibleForTesting
  static Level? addGate(
    Level level,
    List<int> solution,
    int colorIndex,
    Mulberry32 rng,
  ) {
    final state = BoardState.initial(level);
    final layout = state.layout;
    final crossing = <int, List<int>>{};
    for (var i = 0; i < layout.arrowCount; i++) {
      final seen = <int>{};
      for (final path in Rules.exitPaths(state, i, blocking: false)) {
        for (final c in path) {
          if (layout.portalOther[c] >= 0) continue;
          if (seen.add(c)) (crossing[c] ??= []).add(layout.idOf(i));
        }
      }
    }
    final cells = <int>[
      for (final e in crossing.entries)
        if (e.value.length >= 2 &&
            state.occupant[e.key] < 0 &&
            layout.gateColor[e.key] < 0 &&
            level.isActive(e.key % level.width, e.key ~/ level.width))
          e.key,
    ]..sort();
    if (cells.isEmpty) return null;

    final pos = <int, int>{
      for (var k = 0; k < solution.length; k++) solution[k]: k,
    };
    final color = GateColor.values[colorIndex];
    for (var attempt = 0; attempt < 12; attempt++) {
      final cell = rng.pick(cells);
      final blockers = crossing[cell]!;
      var minPos = solution.length;
      for (final id in blockers) {
        final at = pos[id] ?? solution.length;
        if (at < minPos) minPos = at;
      }
      final keys = <int>[
        for (final a in level.arrows)
          if (a.kind == ArrowKind.normal &&
              a.color == null &&
              a.frozen == null &&
              a.link == null &&
              !blockers.contains(a.id) &&
              (pos[a.id] ?? solution.length) < minPos)
            a.id,
      ];
      if (keys.isEmpty) continue;
      final keyId = rng.pick(keys);
      final next = level.copyWith(
        arrows: [
          for (final a in level.arrows)
            if (a.id == keyId)
              a.copyWith(kind: ArrowKind.key, color: color)
            else
              a,
        ],
        gates: [
          ...level.gates,
          Gate(cell: layout.cellAt(cell), color: color),
        ],
      );
      if (GreedySolver.solveLevel(next).solvable) return next;
    }
    return null;
  }

  /// Links two arrows that are adjacent in [solution] and both free at that
  /// point. Returns the new level and the solution without the partner.
  @visibleForTesting
  static (Level, List<int>)? addLink(
    Level level,
    List<int> solution,
    int linkNo,
    Mulberry32 rng,
  ) {
    final s = BoardState.initial(level);
    final layout = s.layout;
    bool eligible(int i) {
      final a = layout.arrow(i);
      return a.kind == ArrowKind.normal &&
          a.link == null &&
          a.frozen == null &&
          a.color == null;
    }

    final positions = <int>[];
    for (var k = 0; k + 1 < solution.length; k++) {
      final a = layout.indexById[solution[k]]!;
      final b = layout.indexById[solution[k + 1]]!;
      if (eligible(a) &&
          eligible(b) &&
          Rules.isFree(s, a) &&
          Rules.isFree(s, b)) {
        positions.add(k);
      }
      Rules.remove(s, a);
    }
    if (positions.isEmpty) return null;

    final k = rng.pick(positions);
    final first = solution[k];
    final second = solution[k + 1];
    final tag = 'L$linkNo';
    final next = level.copyWith(
      arrows: [
        for (final a in level.arrows)
          if (a.id == first || a.id == second) a.copyWith(link: tag) else a,
      ],
    );
    if (!GreedySolver.solveLevel(next).solvable) return null;
    return (next, [...solution]..removeAt(k + 1));
  }

  /// Freezes up to [count] arrows that come late in a solution: an arrow at
  /// tap position `p` gets a counter `k ≤ p`, so that solution stays valid.
  @visibleForTesting
  static Level addFrozen(Level level, int count, Mulberry32 rng) {
    final solved = GreedySolver.solveLevel(level);
    if (!solved.solvable) return level;
    final pos = <int, int>{
      for (var k = 0; k < solved.solution.length; k++) solved.solution[k]: k,
    };
    final cands = <int>[
      for (final a in level.arrows)
        if (a.kind == ArrowKind.normal &&
            a.link == null &&
            a.frozen == null &&
            a.color == null &&
            (pos[a.id] ?? 0) >= 2)
          a.id,
    ];
    rng.shuffle(cands);
    final counters = <int, int>{};
    for (final id in cands.take(count)) {
      final p = pos[id]!;
      counters[id] = rng.nextRange(1, p < 5 ? p : 5);
    }
    if (counters.isEmpty) return level;
    final next = level.copyWith(
      arrows: [
        for (final a in level.arrows)
          if (counters.containsKey(a.id))
            a.copyWith(frozen: counters[a.id])
          else
            a,
      ],
    );
    return GreedySolver.solveLevel(next).solvable ? next : level;
  }

  /// Rotator generate-and-test (non-monotone): turns up to `mix.rotators`
  /// single-cell arrows into rotators with random starting directions and
  /// keeps the first variant the search solver can solve whose trap ratio is
  /// inside `[trapMin, trapMax]`. Returns `(level, solution, trapRatio)`.
  @visibleForTesting
  static (Level, List<int>, double)? addRotators(
    Level level,
    GenParams p,
    Mulberry32 rng,
  ) {
    final cands = <int>[
      for (final a in level.arrows)
        if (a.body.length == 1 &&
            a.kind == ArrowKind.normal &&
            a.link == null &&
            a.frozen == null &&
            a.color == null)
          a.id,
    ];
    final want = p.mix.rotators < cands.length ? p.mix.rotators : cands.length;
    if (want == 0) return null;

    for (var t = 0; t < p.rotatorTries; t++) {
      final chosen = rng.shuffle([...cands]).take(want).toSet();
      final next = level.copyWith(
        arrows: [
          for (final a in level.arrows)
            if (chosen.contains(a.id))
              a.copyWith(
                kind: ArrowKind.rotator,
                dir: rng.pick(Direction.values),
              )
            else
              a,
        ],
      );
      final r = SearchSolver(stateLimit: p.searchStateLimit).solveLevel(next);
      if (r.solvable &&
          !r.tooComplex &&
          r.trapRatio >= p.trapMin &&
          r.trapRatio <= p.trapMax) {
        return (next, r.solution, r.trapRatio);
      }
    }
    return null;
  }
}
