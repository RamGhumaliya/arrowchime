/// Board shapes (`docs/03` §5 "Shaped boards"). Each function returns a mask:
/// `height` strings of `width` chars, `'1'` = playable cell, `'0'` = void.
///
/// Cell centres are sampled in normalised coordinates `u, v ∈ (-1, 1)` (v
/// grows downwards). Only `+ - *` are used, so the result is bit-identical on
/// every platform.
abstract final class Masks {
  /// The kinds the chapter plans cycle through.
  static const List<String> kinds = [
    'heart',
    'star',
    'circle',
    'cat',
    'flower',
    'triangle',
    'moon',
    'house',
    'drop',
    'hexagon',
    'clover',
    'mushroom',
    'tree',
    'leaf',
    'cloud',
    'fish',
    'bolt',
    'arrow',
    'diamond',
    'ring',
    'cross',
  ];

  static List<String> byName(String name, int width, int height) =>
      switch (name) {
        'heart' => heart(width, height),
        'ring' => ring(width, height),
        'diamond' => diamond(width, height),
        'star' => star(width, height),
        'cross' => cross(width, height),
        'circle' => circle(width, height),
        'triangle' => triangle(width, height),
        'hexagon' => hexagon(width, height),
        'moon' => moon(width, height),
        'flower' => flower(width, height),
        'leaf' => leaf(width, height),
        'house' => house(width, height),
        'drop' => drop(width, height),
        'arrow' => arrow(width, height),
        'clover' => clover(width, height),
        'bolt' => bolt(width, height),
        'cat' => cat(width, height),
        'mushroom' => mushroom(width, height),
        'tree' => tree(width, height),
        'cloud' => cloud(width, height),
        'fish' => fish(width, height),
        _ => throw ArgumentError.value(name, 'name', 'unknown mask'),
      };

  static List<String> heart(int w, int h) => _build(w, h, (u, v) {
    final x = u * 1.25;
    final y = -v * 1.25 + 0.15;
    final a = x * x + y * y - 1;
    return a * a * a - x * x * y * y * y <= 0;
  });

  static List<String> ring(int w, int h) => _build(w, h, (u, v) {
    final d = u * u + v * v;
    return d <= 1.0 && d >= 0.2;
  });

  static List<String> circle(int w, int h) =>
      _build(w, h, (u, v) => u * u + v * v <= 1.0);

  static List<String> diamond(int w, int h) =>
      _build(w, h, (u, v) => _abs(u) + _abs(v) <= 1.0);

  static List<String> cross(int w, int h) =>
      _build(w, h, (u, v) => _abs(u) <= 0.4 || _abs(v) <= 0.4);

  static List<String> star(int w, int h) => _build(
    w,
    h,
    (u, v) => _inPolygon(u * 1.05, v * 1.05 + 0.05, _starPoints),
  );

  static bool _disc(double u, double v, double cx, double cy, double r) =>
      (u - cx) * (u - cx) + (v - cy) * (v - cy) <= r * r;

  static List<String> triangle(int w, int h) => _build(
    w,
    h,
    (u, v) => v >= -0.92 && v <= 0.92 && _abs(u) <= (v + 0.92) * 0.54,
  );

  static List<String> hexagon(int w, int h) => _build(
    w,
    h,
    (u, v) => _abs(v) <= 0.9 && _abs(u) * 0.9 + _abs(v) * 0.52 <= 0.9,
  );

  static List<String> moon(int w, int h) => _build(
    w,
    h,
    (u, v) => _disc(u, v, 0, 0, 0.98) && !_disc(u, v, 0.5, -0.05, 0.78),
  );

  static List<String> flower(int w, int h) => _build(
    w,
    h,
    (u, v) =>
        _disc(u, v, 0, 0, 0.32) ||
        _disc(u, v, 0, -0.62, 0.36) ||
        _disc(u, v, 0.59, -0.19, 0.36) ||
        _disc(u, v, 0.36, 0.5, 0.36) ||
        _disc(u, v, -0.36, 0.5, 0.36) ||
        _disc(u, v, -0.59, -0.19, 0.36),
  );

  static List<String> leaf(int w, int h) => _build(w, h, (u, v) {
    // A lens along the diagonal.
    final a = (u + v) * 0.7071;
    final b = (u - v) * 0.7071;
    return (a - 0.0) * (a - 0.0) / 1.0 + b * b / 0.16 <= 1.0 && _abs(a) <= 1.0;
  });

  static List<String> house(int w, int h) => _build(
    w,
    h,
    (u, v) =>
        (_abs(u) <= 0.72 && v >= -0.1 && v <= 0.92) ||
        (v < -0.1 && v >= -0.95 && _abs(u) <= (v + 0.95) * 1.02),
  );

  static List<String> drop(int w, int h) => _build(
    w,
    h,
    (u, v) =>
        _disc(u, v, 0, 0.32, 0.64) ||
        (v >= -0.95 && v <= 0.32 && _abs(u) <= (v + 0.95) * 0.5),
  );

  static List<String> arrow(int w, int h) => _build(
    w,
    h,
    (u, v) =>
        (v <= 0.0 && v >= -0.95 && _abs(u) <= (v + 0.95) * 0.95) ||
        (v > 0.0 && v <= 0.95 && _abs(u) <= 0.3),
  );

  static List<String> clover(int w, int h) => _build(
    w,
    h,
    (u, v) =>
        _disc(u, v, 0, -0.45, 0.5) ||
        _disc(u, v, -0.45, 0.2, 0.5) ||
        _disc(u, v, 0.45, 0.2, 0.5) ||
        (_abs(u) <= 0.12 && v >= 0.2 && v <= 0.95),
  );

  static const List<(double, double)> _boltPoints = [
    (0.4, -1.0),
    (-0.8, 0.2),
    (-0.1, 0.2),
    (-0.45, 1.0),
    (0.8, -0.3),
    (0.15, -0.3),
  ];

  static List<String> bolt(int w, int h) =>
      _build(w, h, (u, v) => _inPolygon(u, v, _boltPoints));

  static const List<(double, double)> _earLeft = [
    (-0.8, -0.1),
    (-0.72, -0.98),
    (-0.08, -0.6),
  ];
  static const List<(double, double)> _earRight = [
    (0.8, -0.1),
    (0.72, -0.98),
    (0.08, -0.6),
  ];

  static List<String> cat(int w, int h) => _build(
    w,
    h,
    (u, v) =>
        _disc(u, v, 0, 0.18, 0.82) ||
        _inPolygon(u, v, _earLeft) ||
        _inPolygon(u, v, _earRight),
  );

  static List<String> mushroom(int w, int h) => _build(
    w,
    h,
    (u, v) =>
        (v <= 0.15 && u * u + (v - 0.15) * (v - 0.15) * 1.3 <= 0.98) ||
        (_abs(u) <= 0.28 && v > 0.1 && v <= 0.95),
  );

  static List<String> tree(int w, int h) => _build(
    w,
    h,
    (u, v) =>
        (v >= -0.95 && v <= -0.2 && _abs(u) <= (v + 0.95) * 0.7) ||
        (v >= -0.5 && v <= 0.3 && _abs(u) <= (v + 0.5) * 0.85 + 0.12) ||
        (v >= 0.0 && v <= 0.7 && _abs(u) <= v * 0.78 + 0.2 + 0.0) ||
        (_abs(u) <= 0.14 && v > 0.65 && v <= 0.95),
  );

  static List<String> cloud(int w, int h) => _build(
    w,
    h,
    (u, v) =>
        _disc(u, v, -0.45, 0.15, 0.42) ||
        _disc(u, v, 0.02, -0.12, 0.52) ||
        _disc(u, v, 0.5, 0.15, 0.42) ||
        (_abs(u) <= 0.62 && v >= 0.15 && v <= 0.57),
  );

  static const List<(double, double)> _fishTail = [
    (0.55, 0.0),
    (1.0, -0.55),
    (1.0, 0.55),
  ];

  static List<String> fish(int w, int h) => _build(
    w,
    h,
    (u, v) =>
        (((u + 0.15) * (u + 0.15)) / 0.72 + (v * v) / 0.34 <= 1.0) ||
        _inPolygon(u, v, _fishTail),
  );

  /// Number of playable cells in [mask] (or `width * height` when `null`).
  static int playable(List<String>? mask, int width, int height) {
    if (mask == null) return width * height;
    var n = 0;
    for (final row in mask) {
      for (var i = 0; i < row.length; i++) {
        if (row[i] == '1') n++;
      }
    }
    return n;
  }

  static List<String> _build(
    int w,
    int h,
    bool Function(double u, double v) inside,
  ) {
    return [
      for (var y = 0; y < h; y++)
        [
          for (var x = 0; x < w; x++)
            if (inside((2 * x + 1 - w) / w, (2 * y + 1 - h) / h)) '1' else '0',
        ].join(),
    ];
  }

  static double _abs(double v) => v < 0 ? -v : v;

  /// Five-point star, outer radius 1, inner radius 0.42, point up.
  static const List<(double, double)> _starPoints = [
    (0.0, -1.0),
    (0.2469, -0.3398),
    (0.9511, -0.309),
    (0.3994, 0.1298),
    (0.5878, 0.809),
    (0.0, 0.42),
    (-0.5878, 0.809),
    (-0.3994, 0.1298),
    (-0.9511, -0.309),
    (-0.2469, -0.3398),
  ];

  /// Even-odd point-in-polygon test.
  static bool _inPolygon(double px, double py, List<(double, double)> poly) {
    var inside = false;
    var j = poly.length - 1;
    for (var i = 0; i < poly.length; i++) {
      final (xi, yi) = poly[i];
      final (xj, yj) = poly[j];
      if ((yi > py) != (yj > py) &&
          px < (xj - xi) * (py - yi) / (yj - yi) + xi) {
        inside = !inside;
      }
      j = i;
    }
    return inside;
  }
}
