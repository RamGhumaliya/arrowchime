import 'package:arrowchime/core/level/engine/rules.dart';
import 'package:arrowchime/core/level/models/arrow.dart';
import 'package:arrowchime/core/level/models/cell.dart';
import 'package:arrowchime/core/level/models/direction.dart';

/// Something that happened because of a player action. The engine never waits
/// for animations: Flame components, audio and haptics replay these.
sealed class GameEvent {
  const new();
}

/// An arrow left the board. Emitted immediately on tap; the exit animation is
/// cosmetic.
final class ArrowFreed extends GameEvent {
  const new({
    required this.arrowId,
    required this.dir,
    required this.paths,
    this.viaLink = false,
  });

  final int arrowId;

  /// Facing of the arrow when it was tapped.
  final Direction dir;

  /// Exit-ray cells (head excluded) up to the board edge. One list per ray
  /// (two for a splitter). Portal traversals appear as `entry, exit` cells.
  final List<List<Cell>> paths;

  /// `true` for the partner of a tapped linked pair.
  final bool viaLink;
}

/// A tap on an arrow that cannot leave.
final class BlockedTap extends GameEvent {
  const new({
    required this.arrowId,
    required this.blockedArrowId,
    required this.blockerType,
    required this.distance,
    this.blockerArrowId,
    this.blockerCell,
  });

  /// The tapped arrow.
  final int arrowId;

  /// The arrow whose ray is obstructed: [arrowId], or its linked partner.
  final int blockedArrowId;
  final BlockerType blockerType;

  /// The arrow that blocks, for [BlockerType.arrow] / `frozenPartner`.
  final int? blockerArrowId;

  /// The blocking cell (arrow cell or gate cell), if any.
  final Cell? blockerCell;

  /// Cells from the blocked head to the blocker (lurch distance).
  final int distance;
}

/// A tap on a frozen arrow: gentle shake, **no heart lost**.
final class FrozenTapped extends GameEvent {
  const new({required this.arrowId, required this.counter});

  final int arrowId;

  /// Removals still needed before it thaws.
  final int counter;
}

/// A heart was spent on a blocked tap.
final class HeartLost extends GameEvent {
  const new({required this.heartsLeft});

  final int heartsLeft;
}

/// Frozen arrows ticked down: arrow id → new counter.
final class FrozenTicked extends GameEvent {
  const new({required this.counters});

  final Map<int, int> counters;
}

/// Rotators turned 90° clockwise: arrow id → new direction.
final class RotatorsTurned extends GameEvent {
  const new({required this.dirs});

  final Map<int, Direction> dirs;
}

/// Single-cell arrows flipped 180° by a removed switcher.
final class ArrowsFlipped extends GameEvent {
  const new({required this.dirs});

  final Map<int, Direction> dirs;
}

/// A key arrow left: all gates of [color] opened.
final class GateOpened extends GameEvent {
  const new({required this.color, required this.cells});

  final GateColor color;
  final List<Cell> cells;
}

/// Last arrow freed.
final class LevelWon extends GameEvent {
  const new({required this.stars, required this.heartsLeft});

  final int stars;
  final int heartsLeft;
}

/// Hearts reached zero.
final class LevelLost extends GameEvent {
  const new();
}

/// The last removal was undone; these arrows are back on the board.
final class UndoApplied extends GameEvent {
  const new({required this.restoredArrowIds});

  final List<int> restoredArrowIds;
}
