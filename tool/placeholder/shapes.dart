import 'dart:math' as math;

import 'pixmap.dart';

/// Signed distance function over normalised coordinates (`-1..1`, y down):
/// negative inside the shape.
typedef Sdf = double Function(double x, double y);

/// Placeholder icon shapes. Deliberately generic: the point is a consistent
/// 3-tone, top-left-lit silhouette, not the final 3D artwork.
abstract final class Shapes {
  static double _len(double x, double y) => math.sqrt(x * x + y * y);

  static Sdf disc([double r = 0.8]) =>
      (x, y) => _len(x, y) - r;

  static Sdf ring([double r = 0.6, double w = 0.2]) =>
      (x, y) => (_len(x, y) - r).abs() - w;

  static Sdf roundRect(double hx, double hy, [double r = 0.25]) => (x, y) {
    final qx = x.abs() - hx + r;
    final qy = y.abs() - hy + r;
    final ox = qx > 0 ? qx : 0.0;
    final oy = qy > 0 ? qy : 0.0;
    final inside = math.max(qx, qy);
    return _len(ox, oy) + (inside < 0 ? inside : 0.0) - r;
  };

  static Sdf frame(double hx, double hy, [double r = 0.2, double w = 0.14]) {
    final base = roundRect(hx, hy, r);
    return (x, y) => base(x, y).abs() - w;
  }

  static Sdf diamond([double r = 0.85]) =>
      (x, y) => (x.abs() + y.abs() - r) * 0.7071;

  /// Five-point star (after Inigo Quilez).
  static Sdf star([double r = 0.85, double rf = 0.45]) {
    const k1x = 0.809016994375;
    const k1y = -0.587785252292;
    const k2x = -k1x;
    const k2y = k1y;
    final bax = rf * -k1y;
    final bay = rf * k1x - 1;
    return (px, py) {
      var x = px.abs();
      var y = -py;
      var d = k1x * x + k1y * y;
      if (d > 0) {
        x -= 2 * d * k1x;
        y -= 2 * d * k1y;
      }
      d = k2x * x + k2y * y;
      if (d > 0) {
        x -= 2 * d * k2x;
        y -= 2 * d * k2y;
      }
      x = x.abs();
      y -= r;
      final h = ((x * bax + y * bay) / (bax * bax + bay * bay)).clamp(0.0, r);
      final dx = x - bax * h;
      final dy = y - bay * h;
      final s = y * bax - x * bay;
      return _len(dx, dy) * (s < 0 ? -1 : 1);
    };
  }

  /// Heart (after Inigo Quilez), scaled to fill the unit square.
  static Sdf heart([double scale = 0.95]) => (px, py) {
    final x = (px / scale).abs() * 0.62;
    final y = (-py / scale) * 0.62 + 0.52;
    double d2(double a, double b) => a * a + b * b;
    double d;
    if (y + x > 1) {
      d = math.sqrt(d2(x - 0.25, y - 0.75)) - math.sqrt(2) / 4;
    } else {
      final m = 0.5 * math.max(x + y, 0.0);
      d =
          math.sqrt(math.min(d2(x, y - 1), d2(x - m, y - m))) *
          ((x - y) < 0 ? -1 : 1);
    }
    return d * scale / 0.62;
  };

  static Sdf hexagon([double r = 0.8]) => (px, py) {
    const kx = -0.866025404;
    const ky = 0.5;
    const kz = 0.577350269;
    var x = px.abs();
    var y = py.abs();
    final dot = kx * x + ky * y;
    final m = math.min(dot, 0);
    x -= 2 * m * kx;
    y -= 2 * m * ky;
    final cx = x - (x.clamp(-kz * r, kz * r));
    final cy = y - r;
    return _len(cx, cy) * (cy < 0 ? -1 : 1);
  };
}

/// Paints [sdf] into a [size]² pixmap with the Toybox 3D light rules
/// (`docs/10` §2): face, a lit top-left rim (+lightness), a shaded
/// bottom-right rim (−lightness) and a specular streak top-left.
Pixmap paintIcon(Sdf sdf, int face, int size) {
  final pm = Pixmap(size, size);
  final ps = 2 / size;
  final light = mixColor(face, 0xFFFFFF, 0.28);
  final dark = mixColor(face, 0x000000, 0.30);
  const rim = 0.16;
  // Light from the top-left: the outward normal pointing there is lit.
  const lx = -0.7071;
  const ly = -0.7071;
  for (var j = 0; j < size; j++) {
    final y = (j + 0.5) * ps - 1;
    for (var i = 0; i < size; i++) {
      final x = (i + 0.5) * ps - 1;
      final d = sdf(x, y);
      final cover = (0.5 - d / ps).clamp(0.0, 1.0);
      if (cover <= 0) continue;

      final gx = sdf(x + ps, y) - sdf(x - ps, y);
      final gy = sdf(x, y + ps) - sdf(x, y - ps);
      final gl = math.sqrt(gx * gx + gy * gy);
      final facing = gl == 0 ? 0.0 : (gx * lx + gy * ly) / gl;

      var c = face;
      final depth = -d;
      if (depth < rim) {
        final t = 1 - (depth / rim).clamp(0.0, 1.0);
        c = facing >= 0
            ? mixColor(face, light, t * facing)
            : mixColor(face, dark, t * -facing);
      } else {
        // Gentle top-left to bottom-right face gradient.
        c = mixColor(face, light, 0.10 * (1 - (x + y + 2) / 4));
      }

      // Specular streak: thin ellipse near the top-left.
      final sx = (x + 0.38) / 0.22;
      final sy = (y + 0.42) / 0.07;
      // Rotate the streak ~ -35° to follow the surface.
      final rx = sx * 0.82 + sy * 0.57;
      final ry = -sx * 0.57 + sy * 0.82;
      final spec = 1 - (rx * rx + ry * ry);
      if (spec > 0 && depth > rim * 0.5) {
        c = mixColor(c, 0xFFFFFF, (spec * 0.65).clamp(0.0, 0.65));
      }

      pm.setPixel(
        i,
        j,
        (c >> 16) & 0xFF,
        (c >> 8) & 0xFF,
        c & 0xFF,
        (cover * 255).round(),
      );
    }
  }
  return pm;
}
