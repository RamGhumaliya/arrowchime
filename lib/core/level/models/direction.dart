/// Facing of an arrow head. Coordinates: x → right, y ↓ down (`docs/03` §2.1).
enum Direction {
  up('U', 0, -1),
  right('R', 1, 0),
  down('D', 0, 1),
  left('L', -1, 0);

  new(this.code, this.dx, this.dy);

  /// JSON code: `U`, `D`, `L`, `R`.
  final String code;
  final int dx;
  final int dy;

  /// 90° clockwise (rotators). Declaration order is clockwise.
  Direction get clockwise => Direction.values[(index + 1) % 4];

  /// 180° (switchers).
  Direction get opposite => Direction.values[(index + 2) % 4];

  /// The two directions perpendicular to this one (splitters).
  List<Direction> get perpendicular => [
    Direction.values[(index + 1) % 4],
    Direction.values[(index + 3) % 4],
  ];

  /// Parses a JSON code; returns `null` when unknown.
  static Direction? fromCode(String code) {
    for (final d in Direction.values) {
      if (d.code == code) return d;
    }
    return null;
  }
}
