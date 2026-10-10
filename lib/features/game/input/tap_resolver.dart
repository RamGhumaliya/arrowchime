import 'package:arrowchime/core/level/models/cell.dart';
import 'package:arrowchime/features/game/model/board_geometry.dart';
import 'package:flutter/painting.dart';

/// What sits on a board cell, as far as tapping is concerned.
class CellArrow {
  const new(this.arrowId, {required this.isHead});

  final int arrowId;
  final bool isHead;
}

/// Turns a tap position into an arrow id, with **tap assist** (`docs/03` §3):
///
/// * A tap on an occupied cell, away from its edges, takes that cell's arrow.
/// * A tap within 30% of a cell edge, or on an empty cell next to arrows,
///   takes the arrow whose body cell centre is nearest (within 0.8 cell).
/// * On dense boards (cells under 28 dp on screen) the radius grows to 1.0 cell
///   and head cells are preferred.
class TapResolver {
  new(this.geometry);

  final BoardGeometry geometry;

  /// Cells that currently hold an arrow.
  final Map<Cell, CellArrow> occupied = {};

  /// Fraction of a cell, from each edge, that counts as "near the edge".
  static const double edgeZone = 0.3;

  /// Assist radius in cells.
  static const double assistRadius = 0.8;
  static const double denseAssistRadius = 1;

  /// Below this on-screen cell size (dp) the board counts as dense.
  static const double denseCellDp = 28;

  /// How much closer a head cell counts on dense boards (in cells).
  static const double headPreference = 0.12;

  /// The arrow tapped at world position [world], or `null`. [screenCell] is
  /// the current on-screen size of one cell in dp.
  int? resolve(Offset world, {required double screenCell}) {
    final own = geometry.cellAt(world);
    if (own != null) {
      final hit = occupied[own];
      if (hit != null && !_nearEdge(world, own)) return hit.arrowId;
    }

    final dense = screenCell < denseCellDp;
    final radius = (dense ? denseAssistRadius : assistRadius) * geometry.cell;
    final around = geometry.nearestCell(world);
    int? best;
    var bestScore = double.infinity;
    for (var dy = -1; dy <= 1; dy++) {
      for (var dx = -1; dx <= 1; dx++) {
        final c = Cell(around.x + dx, around.y + dy);
        final hit = occupied[c];
        if (hit == null) continue;
        final d = (world - geometry.center(c)).distance;
        if (d > radius) continue;
        final score =
            d - (dense && hit.isHead ? headPreference * geometry.cell : 0);
        if (score < bestScore) {
          bestScore = score;
          best = hit.arrowId;
        }
      }
    }
    return best;
  }

  bool _nearEdge(Offset world, Cell c) {
    final tl = geometry.topLeft(c);
    final fx = (world.dx - tl.dx) / geometry.cell;
    final fy = (world.dy - tl.dy) / geometry.cell;
    final nearest = [fx, 1 - fx, fy, 1 - fy].reduce((a, b) => a < b ? a : b);
    return nearest < edgeZone;
  }
}
