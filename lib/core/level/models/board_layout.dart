import 'dart:typed_data';

import 'package:arrowchime/core/level/models/arrow.dart';
import 'package:arrowchime/core/level/models/cell.dart';
import 'package:arrowchime/core/level/models/level.dart';

/// The static, never-changing topology of a [Level], flattened into typed
/// lists for fast lookups. Shared by every `BoardState` of that level.
///
/// Cells are addressed by `index = y * width + x`; arrows by their position
/// in `level.arrows` (not by id).
class BoardLayout {
  /// Builds the layout. Assumes the level passed `validateLevel`: arrows are
  /// in bounds, link groups have exactly two members, and so on.
  factory(Level level) {
    final w = level.width;
    final n = level.arrows.length;
    final cellCount = w * level.height;

    final bodies = <Int16List>[
      for (final a in level.arrows)
        Int16List.fromList([for (final c in a.body) c.y * w + c.x]),
    ];

    final partner = Int16List(n)..fillRange(0, n, -1);
    final byLink = <String, int>{};
    for (var i = 0; i < n; i++) {
      final link = level.arrows[i].link;
      if (link == null) continue;
      final other = byLink[link];
      if (other == null) {
        byLink[link] = i;
      } else {
        partner[i] = other;
        partner[other] = i;
      }
    }

    final portalOther = Int16List(cellCount)..fillRange(0, cellCount, -1);
    for (final p in level.portals) {
      final a = p.a.y * w + p.a.x;
      final b = p.b.y * w + p.b.x;
      portalOther[a] = b;
      portalOther[b] = a;
    }

    final gateColor = Int8List(cellCount)..fillRange(0, cellCount, -1);
    for (final g in level.gates) {
      gateColor[g.cell.y * w + g.cell.x] = g.color.index;
    }

    return BoardLayout._(
      level: level,
      bodies: bodies,
      partner: partner,
      portalOther: portalOther,
      gateColor: gateColor,
      indexById: {for (var i = 0; i < n; i++) level.arrows[i].id: i},
    );
  }

  const new _({
    required this.level,
    required this.bodies,
    required this.partner,
    required this.portalOther,
    required this.gateColor,
    required this.indexById,
  });

  final Level level;

  /// Body cells (tail → head) per arrow index.
  final List<Int16List> bodies;

  /// Link partner arrow index per arrow index, or `-1`.
  final Int16List partner;

  /// Other end of the portal at a cell, or `-1`.
  final Int16List portalOther;

  /// [GateColor] index of the gate at a cell, or `-1`.
  final Int8List gateColor;

  /// Arrow id → arrow index.
  final Map<int, int> indexById;

  int get width => level.width;
  int get height => level.height;
  int get cellCount => width * height;
  int get arrowCount => level.arrows.length;

  Arrow arrow(int index) => level.arrows[index];

  /// Arrow id of the arrow at [index].
  int idOf(int index) => level.arrows[index].id;

  /// Head cell index of an arrow.
  int headCell(int index) => bodies[index].last;

  Cell cellAt(int cellIndex) => Cell(cellIndex % width, cellIndex ~/ width);

  /// Initial direction per arrow index.
  Uint8List initialDirs() =>
      Uint8List.fromList([for (final a in level.arrows) a.dir.index]);
}
