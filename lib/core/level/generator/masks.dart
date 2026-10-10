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
    'ring',
    'diamond',
    'star',
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
