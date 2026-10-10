import 'dart:typed_data';

import 'package:arrowchime/core/level/models/board_layout.dart';
import 'package:arrowchime/core/level/models/direction.dart';
import 'package:arrowchime/core/level/models/level.dart';

/// Mutable runtime state of a board. All game-rule changes go through
/// `Rules`; the engine snapshots this class for undo.
class BoardState {
  /// Initial state of [level].
  factory initial(Level level) => BoardState.fromLayout(BoardLayout(level));

  /// Initial state for an existing [layout].
  factory fromLayout(BoardLayout layout) {
    final n = layout.arrowCount;
    final occupant = Int16List(layout.cellCount)
      ..fillRange(0, layout.cellCount, -1);
    for (var i = 0; i < n; i++) {
      for (final c in layout.bodies[i]) {
        occupant[c] = i;
      }
    }
    return BoardState._(
      layout: layout,
      occupant: occupant,
      dirs: layout.initialDirs(),
      frozen: Int16List.fromList([
        for (final a in layout.level.arrows) a.frozen ?? 0,
      ]),
      alive: Uint8List(n)..fillRange(0, n, 1),
      openGates: 0,
      remaining: n,
    );
  }

  new _({
    required this.layout,
    required this.occupant,
    required this.dirs,
    required this.frozen,
    required this.alive,
    required this.openGates,
    required this.remaining,
  });

  final BoardLayout layout;

  /// Arrow index occupying each cell, or `-1`.
  final Int16List occupant;

  /// Current [Direction] index per arrow (rotators / switchers change it).
  final Uint8List dirs;

  /// Remaining freeze counter per arrow (0 = thawed / never frozen).
  final Int16List frozen;

  /// `1` while the arrow is still on the board.
  final Uint8List alive;

  /// Bit mask over `GateColor.index`: set bit = that colour's gates are open.
  int openGates;

  /// Number of arrows still on the board.
  int remaining;

  /// Independent deep copy (used for undo snapshots and solver search).
  BoardState copy() => BoardState._(
    layout: layout,
    occupant: Int16List.fromList(occupant),
    dirs: Uint8List.fromList(dirs),
    frozen: Int16List.fromList(frozen),
    alive: Uint8List.fromList(alive),
    openGates: openGates,
    remaining: remaining,
  );

  bool isAlive(int arrowIndex) => alive[arrowIndex] == 1;

  Direction dirOf(int arrowIndex) => Direction.values[dirs[arrowIndex]];

  bool isGateOpen(int colorIndex) => (openGates >> colorIndex) & 1 == 1;

  /// Indices of arrows still on the board, ascending.
  List<int> get aliveIndices => [
    for (var i = 0; i < alive.length; i++)
      if (alive[i] == 1) i,
  ];

  /// Compact identity of this state for solver memoisation: which arrows are
  /// left plus every direction (rotators / switchers) and open-gate bits.
  String get key {
    final b = StringBuffer();
    var word = 0;
    for (var i = 0; i < alive.length; i++) {
      word |= alive[i] << (i % 30);
      if (i % 30 == 29) {
        b
          ..write(word.toRadixString(36))
          ..write('.');
        word = 0;
      }
    }
    b
      ..write(word.toRadixString(36))
      ..write('|')
      ..write(openGates);
    final dirChars = StringBuffer();
    for (var i = 0; i < dirs.length; i++) {
      if (alive[i] == 1) dirChars.write(dirs[i]);
    }
    return '$b|$dirChars';
  }
}
