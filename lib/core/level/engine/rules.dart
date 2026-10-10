import 'package:arrowchime/core/level/models/arrow.dart';
import 'package:arrowchime/core/level/models/board_state.dart';
import 'package:arrowchime/core/level/models/direction.dart';

/// Feature flags for the v1.1 mechanics (`docs/03` §5). With a flag off, the
/// corresponding arrow kind behaves like a `normal` arrow.
class RulesConfig {
  const new({this.enableSwitcher = false, this.enableSplitter = false});

  /// Removing a switcher flips adjacent single-cell arrows 180°.
  final bool enableSwitcher;

  /// A splitter is free only if both perpendicular rays are clear.
  final bool enableSplitter;
}

/// What stops an exit ray.
enum BlockerType {
  /// Another arrow's body.
  arrow,

  /// A closed gate.
  gate,

  /// A portal cycle: the ray never leaves the board.
  loop,

  /// The linked partner is still frozen.
  frozenPartner,
}

/// The first obstacle on an exit ray.
class RayHit {
  const new({
    required this.type,
    required this.distance,
    this.arrowIndex = -1,
    this.cell = -1,
  });

  final BlockerType type;

  /// Blocking arrow index (for [BlockerType.arrow] / `frozenPartner`), or -1.
  final int arrowIndex;

  /// Blocking cell index (arrow cell or gate cell), or -1.
  final int cell;

  /// Cells travelled from the head to the obstacle (1 = adjacent).
  final int distance;
}

/// Result of [Rules.check].
enum FreedomStatus {
  /// The arrow can exit.
  free,

  /// The arrow is frozen: tapping only shakes it (no heart lost).
  frozen,

  /// The arrow (or its partner) is obstructed.
  blocked,
}

class Freedom {
  const new _(this.status, this.hit, this.blockedIndex);

  const new free() : this._(FreedomStatus.free, null, -1);

  const new frozen() : this._(FreedomStatus.frozen, null, -1);

  const new blocked(RayHit hit, int blockedIndex)
    : this._(FreedomStatus.blocked, hit, blockedIndex);

  final FreedomStatus status;

  /// Set when [status] is `blocked`.
  final RayHit? hit;

  /// Which arrow's ray is obstructed: the tapped arrow, or its linked partner.
  final int blockedIndex;

  bool get isFree => status == FreedomStatus.free;
}

/// Everything that changed when an arrow was removed.
class RemovalEffects {
  const new({
    required this.removed,
    required this.frozenTicked,
    required this.rotated,
    required this.openedGates,
    required this.flipped,
  });

  /// Removed arrow indices: the tapped arrow, then its partner if linked.
  final List<int> removed;

  /// Frozen arrows whose counter went down by one.
  final List<int> frozenTicked;

  /// Rotators that turned 90° clockwise.
  final List<int> rotated;

  /// Newly opened gate colours → gate cell indices.
  final Map<GateColor, List<int>> openedGates;

  /// Arrows flipped 180° by a removed switcher.
  final List<int> flipped;
}

/// The game rules of `docs/03` §2/§5 and `docs/04` §2 as pure functions over
/// [BoardState].
abstract final class Rules {
  /// Whether arrow [index] is free, frozen or blocked.
  static Freedom check(
    BoardState s,
    int index, [
    RulesConfig config = const RulesConfig(),
  ]) {
    if (s.frozen[index] > 0) return const Freedom.frozen();
    final partner = s.layout.partner[index];
    if (partner >= 0 && s.frozen[partner] > 0) {
      return Freedom.blocked(
        RayHit(
          type: BlockerType.frozenPartner,
          distance: 0,
          arrowIndex: partner,
        ),
        partner,
      );
    }
    final own = _firstHit(s, index, partner, config);
    if (own != null) return Freedom.blocked(own, index);
    if (partner >= 0) {
      final theirs = _firstHit(s, partner, index, config);
      if (theirs != null) return Freedom.blocked(theirs, partner);
    }
    return const Freedom.free();
  }

  /// Shorthand for `check(...).isFree`.
  static bool isFree(
    BoardState s,
    int index, [
    RulesConfig config = const RulesConfig(),
  ]) => check(s, index, config).isFree;

  /// All arrow indices that are currently free, ascending.
  static List<int> freeArrows(
    BoardState s, [
    RulesConfig config = const RulesConfig(),
  ]) => [
    for (var i = 0; i < s.alive.length; i++)
      if (s.alive[i] == 1 && isFree(s, i, config)) i,
  ];

  /// Exit-ray cell indices of arrow [index] (one list per ray; splitters have
  /// two). Follows portals; portal cells appear as `entry, exit` pairs. With
  /// [blocking] false, nothing stops the ray (used to detect self-crossing);
  /// a portal cycle ends the list early.
  static List<List<int>> exitPaths(
    BoardState s,
    int index, {
    bool blocking = true,
    RulesConfig config = const RulesConfig(),
  }) {
    final partner = s.layout.partner[index];
    return [
      for (final d in _rayDirs(s, index, config))
        (() {
          final path = <int>[];
          _walk(
            s,
            index,
            blocking ? partner : -1,
            s.layout.headCell(index),
            d,
            path,
            blocking: blocking,
          );
          return path;
        })(),
    ];
  }

  /// Whether a ray of arrow [index] cycles through portals forever, ignoring
  /// every obstacle.
  static bool loopsForever(
    BoardState s,
    int index, {
    RulesConfig config = const RulesConfig(),
  }) => _rayDirs(s, index, config).any(
    (d) =>
        _walk(
          s,
          index,
          -1,
          s.layout.headCell(index),
          d,
          null,
          blocking: false,
        )?.type ==
        BlockerType.loop,
  );

  /// Removes arrow [index] (and its linked partner) and applies every
  /// side effect, in this order: freeze counters, rotators, key gates,
  /// switchers.
  static RemovalEffects remove(
    BoardState s,
    int index, [
    RulesConfig config = const RulesConfig(),
  ]) {
    final layout = s.layout;
    final partner = layout.partner[index];
    final removed = [index, if (partner >= 0 && s.alive[partner] == 1) partner];
    for (final r in removed) {
      for (final c in layout.bodies[r]) {
        s.occupant[c] = -1;
      }
      s.alive[r] = 0;
    }
    s.remaining -= removed.length;

    final frozenTicked = <int>[];
    final rotated = <int>[];
    for (var j = 0; j < s.alive.length; j++) {
      if (s.alive[j] == 0) continue;
      if (s.frozen[j] > 0) {
        s.frozen[j]--;
        frozenTicked.add(j);
      }
      if (layout.arrow(j).kind == ArrowKind.rotator) {
        s.dirs[j] = s.dirOf(j).clockwise.index;
        rotated.add(j);
      }
    }

    final opened = <GateColor, List<int>>{};
    for (final r in removed) {
      final a = layout.arrow(r);
      final color = a.color;
      if (a.kind != ArrowKind.key || color == null) continue;
      if (s.isGateOpen(color.index)) continue;
      s.openGates |= 1 << color.index;
      final cells = [
        for (final g in layout.level.gates)
          if (g.color == color) g.cell.y * layout.width + g.cell.x,
      ];
      if (cells.isNotEmpty) opened[color] = cells;
    }

    final flipped = <int>[];
    if (config.enableSwitcher) {
      for (final r in removed) {
        if (layout.arrow(r).kind != ArrowKind.switcher) continue;
        final cell = layout.bodies[r].first;
        final x = cell % layout.width;
        final y = cell ~/ layout.width;
        for (final d in Direction.values) {
          final nx = x + d.dx;
          final ny = y + d.dy;
          if (nx < 0 || ny < 0 || nx >= layout.width || ny >= layout.height) {
            continue;
          }
          final j = s.occupant[ny * layout.width + nx];
          if (j >= 0 && layout.bodies[j].length == 1) {
            s.dirs[j] = s.dirOf(j).opposite.index;
            flipped.add(j);
          }
        }
      }
    }

    return RemovalEffects(
      removed: removed,
      frozenTicked: frozenTicked,
      rotated: rotated,
      openedGates: opened,
      flipped: flipped,
    );
  }

  static List<Direction> _rayDirs(BoardState s, int index, RulesConfig config) {
    final dir = s.dirOf(index);
    if (config.enableSplitter &&
        s.layout.arrow(index).kind == ArrowKind.splitter) {
      return dir.perpendicular;
    }
    return [dir];
  }

  static RayHit? _firstHit(
    BoardState s,
    int index,
    int ignore,
    RulesConfig config,
  ) {
    for (final d in _rayDirs(s, index, config)) {
      final hit = _walk(s, index, ignore, s.layout.headCell(index), d, null);
      if (hit != null) return hit;
    }
    return null;
  }

  /// Walks a ray from [from] (exclusive) in [dir]. Returns the first
  /// obstacle, or `null` if the ray leaves the board.
  static RayHit? _walk(
    BoardState s,
    int self,
    int ignore,
    int from,
    Direction dir,
    List<int>? path, {
    bool blocking = true,
  }) {
    final layout = s.layout;
    final w = layout.width;
    final h = layout.height;
    var x = from % w;
    var y = from ~/ w;
    var steps = 0;
    Set<int>? entered;
    while (true) {
      x += dir.dx;
      y += dir.dy;
      if (x < 0 || y < 0 || x >= w || y >= h) return null;
      steps++;
      final c = y * w + x;
      final other = layout.portalOther[c];
      if (other >= 0) {
        entered ??= <int>{};
        if (!entered.add(c)) {
          return RayHit(type: BlockerType.loop, distance: steps, cell: c);
        }
        path?.add(c);
        path?.add(other);
        x = other % w;
        y = other ~/ w;
        continue;
      }
      if (blocking) {
        final o = s.occupant[c];
        if (o >= 0 && o != self && o != ignore) {
          return RayHit(
            type: BlockerType.arrow,
            distance: steps,
            arrowIndex: o,
            cell: c,
          );
        }
        final g = layout.gateColor[c];
        if (g >= 0 && !s.isGateOpen(g)) {
          return RayHit(type: BlockerType.gate, distance: steps, cell: c);
        }
      }
      path?.add(c);
    }
  }
}
