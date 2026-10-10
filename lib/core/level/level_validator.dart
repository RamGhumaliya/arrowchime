import 'package:arrowchime/core/level/engine/rules.dart';
import 'package:arrowchime/core/level/models/arrow.dart';
import 'package:arrowchime/core/level/models/board_state.dart';
import 'package:arrowchime/core/level/models/cell.dart';
import 'package:arrowchime/core/level/models/level.dart';

const _allKinds = RulesConfig(enableSwitcher: true, enableSplitter: true);

/// Checks the game rules of a schema-valid [level] (`docs/04` §1, `docs/03`
/// §2.2–2.3). Returns human-readable problems; empty = valid.
///
/// Solvability is **not** checked here: use the solvers.
List<String> validateLevel(Level level) {
  final issues = _structure(level);
  if (issues.isNotEmpty) return issues;

  // Ray rules need a consistent layout, so they run only on a sound structure.
  final state = BoardState.initial(level);
  for (var i = 0; i < level.arrows.length; i++) {
    final a = level.arrows[i];
    final own = {for (final c in state.layout.bodies[i]) c};
    for (final path in Rules.exitPaths(
      state,
      i,
      blocking: false,
      config: _allKinds,
    )) {
      if (path.any(own.contains)) {
        issues.add('arrow ${a.id}: exit ray crosses its own body');
      }
    }
    if (Rules.loopsForever(state, i, config: _allKinds)) {
      issues.add('arrow ${a.id}: exit ray loops through portals forever');
    }
  }
  return issues;
}

List<String> _structure(Level level) {
  final issues = <String>[];
  final w = level.width;
  final h = level.height;

  final mask = level.mask;
  if (mask != null) {
    if (mask.length != h) {
      issues.add('mask has ${mask.length} rows, expected $h');
    } else if (mask.any((r) => r.length != w)) {
      issues.add('every mask row must have length $w');
    }
    if (issues.isNotEmpty) return issues;
  }

  final ids = <int>{};
  final occupied = <Cell, int>{};
  final links = <String, int>{};

  for (final a in level.arrows) {
    if (!ids.add(a.id)) issues.add('duplicate arrow id ${a.id}');
    final label = 'arrow ${a.id}';

    final seen = <Cell>{};
    for (final c in a.body) {
      if (!level.isActive(c.x, c.y)) {
        issues.add('$label: cell $c is outside the board or masked out');
      }
      if (!seen.add(c)) issues.add('$label: body revisits cell $c');
      final other = occupied[c];
      if (other != null && other != a.id) {
        issues.add('$label overlaps arrow $other at $c');
      }
      occupied[c] = a.id;
    }
    for (var i = 1; i < a.body.length; i++) {
      if (!a.body[i - 1].isAdjacentTo(a.body[i])) {
        issues.add(
          '$label: cells ${a.body[i - 1]} and ${a.body[i]} are not adjacent',
        );
      }
    }
    if (a.body.length >= 2 && a.head.step(a.dir) == a.body[a.body.length - 2]) {
      issues.add('$label: head points back into its own body');
    }

    final singleCell =
        a.kind == ArrowKind.rotator || a.kind == ArrowKind.switcher;
    if (singleCell && a.body.length != 1) {
      issues.add('$label: ${a.kind.name} must have a single-cell body');
    }
    if (a.kind == ArrowKind.key && a.color == null) {
      issues.add('$label: key arrow needs a colour');
    }
    if (a.kind != ArrowKind.key && a.color != null) {
      issues.add('$label: only key arrows carry a colour');
    }
    final link = a.link;
    if (link != null) links[link] = (links[link] ?? 0) + 1;
  }

  for (final e in links.entries) {
    if (e.value != 2) {
      issues.add('link ${e.key} has ${e.value} arrows, expected exactly 2');
    }
  }

  final blocked = <Cell>{};
  for (final g in level.gates) {
    if (!level.isActive(g.cell.x, g.cell.y)) {
      issues.add('gate at ${g.cell} is outside the board or masked out');
    }
    if (occupied.containsKey(g.cell)) {
      issues.add('gate at ${g.cell} sits on arrow ${occupied[g.cell]}');
    }
    if (!blocked.add(g.cell)) issues.add('two gates at ${g.cell}');
  }

  final portalIds = <String>{};
  final portalCells = <Cell>{};
  for (final p in level.portals) {
    if (!portalIds.add(p.id)) issues.add('duplicate portal id ${p.id}');
    if (p.a == p.b) issues.add('portal ${p.id}: ends are the same cell');
    for (final c in [p.a, p.b]) {
      if (!level.isActive(c.x, c.y)) {
        issues.add('portal ${p.id}: $c is outside the board or masked out');
      }
      if (occupied.containsKey(c)) {
        issues.add('portal ${p.id}: $c sits on arrow ${occupied[c]}');
      }
      if (blocked.contains(c)) issues.add('portal ${p.id}: $c sits on a gate');
      if (!portalCells.add(c)) issues.add('portal ${p.id}: $c is reused');
    }
  }
  return issues;
}
