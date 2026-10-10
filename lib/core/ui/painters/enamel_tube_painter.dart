import 'package:arrowchime/app/theme/tokens.dart';
import 'package:arrowchime/core/ui/painters/shade.dart';
import 'package:flutter/rendering.dart';

/// Glossy enamel arrow tube (`docs/10` §8): five passes per path.
///
/// 1. shadow (+0.06c, +0.10c), width 0.44c, ink 28%, blurred 0.08c
/// 2. dark rim, width 0.46c, colour −30% lightness
/// 3. body, width 0.40c
/// 4. light band, width 0.18c, +25% lightness, offset (−0.03c, −0.05c)
/// 5. specular, width 0.05c, white 70%, offset (−0.06c, −0.09c), only on
///    segments facing up / left
///
/// plus a rounded triangle head with the same passes and a darker "nock" ring
/// at the tail. `c` is the cell size. Used by the Design Gallery preview now
/// and by the Flame arrow component later (Phase 4).
abstract final class EnamelTube {
  static const double _shadowDx = 0.06;
  static const double _shadowDy = 0.10;
  static const double _shadowWidth = 0.44;
  static const double _shadowBlur = 0.08;
  static const double _rimWidth = 0.46;
  static const double _bodyWidth = 0.40;
  static const double _bandWidth = 0.18;
  static const double _specWidth = 0.05;
  static const double _cornerRadius = 0.45;
  static const double _headLength = 0.62;
  static const double _headHalfWidth = 0.40;
  static const double _headCorner = 0.08;
  static const double _nockRadius = 0.14;
  static const double _nockStroke = 0.06;

  static const double _rimDelta = -0.30;
  static const double _bandDelta = 0.25;

  /// Paints an arrow whose body runs through [points] (cell centres, tail →
  /// head) with cell size [c].
  static void paint(Canvas canvas, List<Offset> points, double c, Color color) {
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
    );
  }

  /// The smooth centre line through [points] (corners rounded to 0.45 c).
  static Path smoothPath(List<Offset> points, double c) =>
      _smoothPath(points, _cornerRadius * c);

  /// Paints an arrow along an existing centre-line [body] (any path, e.g. a
  /// sub-path of a longer travel path while the arrow slides out). [tail] and
  /// [head] are its end points and [dir] the unit direction the head faces.
  /// [blurShadow] false draws a hard shadow, much cheaper for arrows in motion.
  static void paintPath(
    Canvas canvas,
    Path body, {
    required Offset tail,
    required Offset head,
    required Offset dir,
    required double c,
    required Color color,
    bool blurShadow = true,
  }) {
    final headPath = _headPath(head, dir, c);

    // 1. Shadow.
    final shadowShift = Offset(_shadowDx * c, _shadowDy * c);
    final shadowPaint = Paint()
      ..color = TBShade.ink(0.28)
      ..style = PaintingStyle.stroke
      ..strokeWidth = _shadowWidth * c
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..maskFilter = blurShadow
          ? MaskFilter.blur(BlurStyle.normal, _shadowBlur * c)
          : null;
    canvas
      ..drawPath(body.shift(shadowShift), shadowPaint)
      ..drawPath(
        headPath.shift(shadowShift),
        shadowPaint..style = PaintingStyle.fill,
      );

    // 2. Dark rim.
    final rim = TBShade.lighten(color, _rimDelta);
    canvas
      ..drawPath(body, _stroke(rim, _rimWidth * c))
      ..drawPath(headPath, _headRim(rim, c))
      // 3. Body.
      ..drawPath(body, _stroke(color, _bodyWidth * c))
      ..drawPath(headPath, Paint()..color = color);

    // 4. Light band, nudged towards the key light.
    final band = TBShade.lighten(color, _bandDelta);
    final bandShift = Offset(-0.03 * c, -0.05 * c);
    canvas
      ..drawPath(body.shift(bandShift), _stroke(band, _bandWidth * c))
      ..drawPath(
        headPath.shift(bandShift * 1.5),
        Paint()..color = band.withValues(alpha: 0.55),
      );

    // 5. Specular, only where the body runs up or left.
    final specShift = Offset(-0.06 * c, -0.09 * c);
    final spec = _upLeftRuns(body, c * 0.12);
    canvas
      ..drawPath(
        spec.shift(specShift),
        _stroke(TBShade.white(TBBevel.specularOpacity), _specWidth * c),
      )
      // Tail nock.
      ..drawCircle(
        tail,
        _nockRadius * c,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = _nockStroke * c
          ..color = rim,
      );
  }

  static Paint _stroke(Color color, double width) => Paint()
    ..style = PaintingStyle.stroke
    ..strokeWidth = width
    ..strokeCap = StrokeCap.round
    ..strokeJoin = StrokeJoin.round
    ..color = color;

  /// A fill + round-joined stroke gives the head its rounded corners.
  static Paint _headRim(Color rim, double c) => Paint()
    ..color = rim
    ..style = PaintingStyle.stroke
    ..strokeWidth = (_headCorner * 2 + 0.06) * c
    ..strokeJoin = StrokeJoin.round;

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

  /// Triangle in front of [head], pointing along [dir], inset by its corner
  /// radius (the rounding stroke grows it back).
  static Path _headPath(Offset head, Offset dir, double c) {
    final side = Offset(-dir.dy, dir.dx);
    final inset = _headCorner * c;
    final base = head + dir * (_bodyWidth * c * 0.1);
    final tip = base + dir * (_headLength * c - inset);
    final left = base + side * (_headHalfWidth * c - inset);
    final right = base - side * (_headHalfWidth * c - inset);
    return Path()
      ..moveTo(tip.dx, tip.dy)
      ..lineTo(left.dx, left.dy)
      ..lineTo(right.dx, right.dy)
      ..close();
  }

  /// Sub-paths of [path] whose travel direction points up or left.
  static Path _upLeftRuns(Path path, double step) {
    final out = Path();
    for (final metric in path.computeMetrics()) {
      var run = false;
      var runStart = 0.0;
      for (var d = 0.0; d < metric.length; d += step) {
        final end = (d + step).clamp(0.0, metric.length);
        final tan = metric.getTangentForOffset((d + end) / 2);
        final facing =
            tan != null && (tan.vector.dx < -0.5 || tan.vector.dy < -0.5);
        if (facing && !run) {
          run = true;
          runStart = d;
        } else if (!facing && run) {
          run = false;
          out.addPath(metric.extractPath(runStart, d), Offset.zero);
        }
      }
      if (run) {
        out.addPath(metric.extractPath(runStart, metric.length), Offset.zero);
      }
    }
    return out;
  }

  static Offset _unit(Offset v) {
    final d = v.distance;
    return d == 0 ? Offset.zero : v / d;
  }
}

/// Paints an arrow preview (cells on a grid) scaled to fit its box.
class EnamelTubePainter extends CustomPainter {
  const new({required this.cells, required this.color});

  /// Grid cells `(x, y)`, tail → head.
  final List<(int, int)> cells;
  final Color color;

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
    );
  }

  @override
  bool shouldRepaint(EnamelTubePainter old) =>
      old.color != color || old.cells != cells;
}
