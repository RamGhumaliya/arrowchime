import 'package:arrowchime/core/level/models/cell.dart';
import 'package:arrowchime/core/level/models/level.dart';
import 'package:flutter/painting.dart';

/// World-space layout of a level's board: the tray (felt + wooden rim) with the
/// grid inside it. World units are unrelated to screen pixels: the camera
/// scales them.
class BoardGeometry {
  new(this.level, {this.cell = 40});

  final Level level;

  /// Edge of one grid cell in world units.
  final double cell;

  int get columns => level.width;
  int get rows => level.height;

  /// Space between the tray's outer edge and the grid (the wooden rim plus a
  /// little felt).
  double get trayPad => cell * 0.55;

  /// Outer edge of the tray, starting at the world origin.
  Size get worldSize =>
      Size(columns * cell + 2 * trayPad, rows * cell + 2 * trayPad);

  Rect get trayRect => Offset.zero & worldSize;

  /// The grid area inside the tray.
  Rect get gridRect =>
      Rect.fromLTWH(trayPad, trayPad, columns * cell, rows * cell);

  /// World position of the centre of [c].
  Offset center(Cell c) =>
      Offset(trayPad + (c.x + 0.5) * cell, trayPad + (c.y + 0.5) * cell);

  /// Top-left corner of [c] in world space.
  Offset topLeft(Cell c) => Offset(trayPad + c.x * cell, trayPad + c.y * cell);

  /// The cell containing [world], or `null` when outside the grid.
  Cell? cellAt(Offset world) {
    final local = world - gridRect.topLeft;
    if (local.dx < 0 || local.dy < 0) return null;
    final x = (local.dx / cell).floor();
    final y = (local.dy / cell).floor();
    if (x >= columns || y >= rows) return null;
    return Cell(x, y);
  }

  /// Like [cellAt], but clamps points outside the grid to the nearest cell.
  Cell nearestCell(Offset world) {
    final local = world - gridRect.topLeft;
    final x = (local.dx / cell).floor().clamp(0, columns - 1);
    final y = (local.dy / cell).floor().clamp(0, rows - 1);
    return Cell(x, y);
  }
}
