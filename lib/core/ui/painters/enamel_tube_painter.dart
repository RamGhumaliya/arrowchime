import 'package:arrowchime/core/ui/painters/arrow_skin.dart';
import 'package:flutter/rendering.dart';

/// The arrow itself (`docs/10` §8, V2 "Clean Line"): a thin rounded line with
/// a small solid arrowhead. The class keeps its old name so callers do not
/// change; there is no tube, bevel or shadow any more.
///
/// `c` is the cell size. A skin only recolours the line and may add a glow
/// behind it.
abstract final class EnamelTube {
  static const double _lineWidth = 0.17;
  static const double _cornerRadius = 0.3;
  static const double _headLength = 0.46;
  static const double _headHalfWidth = 0.26;

  /// Paints an arrow whose body runs through [points] (cell centres, tail →
  /// head) with cell size [c].
  static void paint(
    Canvas canvas,
    List<Offset> points,
    double c,
    Color color, {
    ArrowSkin skin = ArrowSkin.candy,
  }) {
    assert(points.isNotEmpty, 'an arrow has at least one cell');
    final dir = points.length > 1
        ? _unit(points.last - points[points.length - 2])
        : const Offset(1, 0);
    paintPath(
      canvas,
      smoothPath(points, c),
      tail: points.first,
      head: points.last,
      dir: dir,
      c: c,
      color: color,
      skin: skin,
    );
  }

  /// The smooth centre line through [points] (corners rounded).
  static Path smoothPath(List<Offset> points, double c) =>
      _smoothPath(points, _cornerRadius * c);

  /// Paints an arrow along an existing centre-line [body] (any path, e.g. a
  /// sub-path of a longer travel path while the arrow slides out). [tail] and
  /// [head] are its end points and [dir] the unit direction the head faces.
  /// [blurShadow] is kept for callers; a flat line has no shadow.
  static void paintPath(
    Canvas canvas,
    Path body, {
    required Offset tail,
    required Offset head,
    required Offset dir,
    required double c,
    required Color color,
    bool blurShadow = true,
    ArrowSkin skin = ArrowSkin.candy,
  }) {
    skin.paintGlow(canvas, body, c, color);
    final tint = skin.body(color);
    canvas
      ..drawPath(
        body,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = _lineWidth * c
          ..strokeCap = StrokeCap.round
          ..strokeJoin = StrokeJoin.round
          ..color = tint,
      )
      ..drawPath(headPath(head, dir, c), Paint()..color = tint);
  }

  /// The arrowhead triangle in front of [head], pointing along [dir].
  static Path headPath(Offset head, Offset dir, double c) {
    final side = Offset(-dir.dy, dir.dx);
    final base = head - dir * (_lineWidth * c * 0.3);
    final tip = head + dir * (_headLength * c);
    final left = base + side * (_headHalfWidth * c);
    final right = base - side * (_headHalfWidth * c);
    return Path()
      ..moveTo(tip.dx, tip.dy)
      ..lineTo(left.dx, left.dy)
      ..lineTo(right.dx, right.dy)
      ..close();
  }

  /// Path through [pts] with corners rounded to [radius].
  static Path _smoothPath(List<Offset> pts, double radius) {
    final path = Path()..moveTo(pts.first.dx, pts.first.dy);
    if (pts.length == 1) return path..lineTo(pts.first.dx, pts.first.dy);
    for (var i = 1; i < pts.length - 1; i++) {
      final prev = pts[i - 1];
      final cur = pts[i];
      final next = pts[i + 1];
      final inLen = (cur - prev).distance;
      final outLen = (next - cur).distance;
      final r = [radius, inLen / 2, outLen / 2].reduce((a, b) => a < b ? a : b);
      final a = cur - _unit(cur - prev) * r;
      final b = cur + _unit(next - cur) * r;
      path
        ..lineTo(a.dx, a.dy)
        ..quadraticBezierTo(cur.dx, cur.dy, b.dx, b.dy);
    }
    return path..lineTo(pts.last.dx, pts.last.dy);
  }

  static Offset _unit(Offset v) {
    final d = v.distance;
    return d == 0 ? Offset.zero : v / d;
  }
}

/// Paints an arrow preview (cells on a grid) scaled to fit its box.
class EnamelTubePainter extends CustomPainter {
  const new({
    required this.cells,
    required this.color,
    this.skin = ArrowSkin.candy,
  });

  /// Grid cells `(x, y)`, tail → head.
  final List<(int, int)> cells;
  final Color color;
  final ArrowSkin skin;

  @override
  void paint(Canvas canvas, Size size) {
    var minX = cells.first.$1;
    var maxX = minX;
    var minY = cells.first.$2;
    var maxY = minY;
    for (final (x, y) in cells) {
      if (x < minX) minX = x;
      if (x > maxX) maxX = x;
      if (y < minY) minY = y;
      if (y > maxY) maxY = y;
    }
    final cols = maxX - minX + 2;
    final rows = maxY - minY + 2;
    final c = (size.width / cols).clamp(0.0, size.height / rows);
    final origin = Offset(
      (size.width - (cols - 1) * c) / 2,
      (size.height - (rows - 1) * c) / 2,
    );
    EnamelTube.paint(
      canvas,
      [
        for (final (x, y) in cells)
          origin + Offset((x - minX) * c, (y - minY) * c),
      ],
      c,
      color,
      skin: skin,
    );
  }

  @override
  bool shouldRepaint(EnamelTubePainter old) =>
      old.color != color || old.cells != cells || old.skin != skin;
}
