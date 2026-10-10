// Freezed redirecting factories keep the type name; the `new` shorthand the
// lint suggests is not supported by freezed 4.
// ignore_for_file: unnecessary_type_name_in_constructor
import 'package:arrowchime/core/level/models/direction.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'cell.freezed.dart';

/// A board coordinate. Origin top-left.
@freezed
abstract class Cell with _$Cell {
  const factory Cell(int x, int y) = _Cell;

  const Cell._();

  /// The neighbouring cell one step in [dir].
  Cell step(Direction dir) => Cell(x + dir.dx, y + dir.dy);

  /// Whether [other] shares an edge with this cell.
  bool isAdjacentTo(Cell other) =>
      (x - other.x).abs() + (y - other.y).abs() == 1;

  @override
  String toString() => '($x,$y)';
}
