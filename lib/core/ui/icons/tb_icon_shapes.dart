import 'dart:math' as math;

import 'package:arrowchime/app/theme/tokens.dart';
import 'package:arrowchime/core/ui/icons/tb_icon_id.dart';
import 'package:flutter/widgets.dart';

/// One filled part of a placeholder icon, in unit coordinates (0..1, y down).
class IconPart {
  const new(this.path, this.color, {this.bevel = true});

  final Path path;
  final Color color;

  /// `false` for flat details (engraved lines, slots) drawn without the
  /// 3-tone bevel.
  final bool bevel;
}

/// Simple silhouettes for the 24 placeholder icons. Deliberately generic: the
/// point is the 3-tone, top-left-lit material, not the final 3D artwork.
abstract final class TBIconShapes {
  static List<IconPart> partsFor(TBIconId id) => switch (id) {
    TBIconId.coin => [
      IconPart(_circle(0.5, 0.5, 0.42), TBColors.butter),
      IconPart(_ring(0.5, 0.5, 0.3, 0.035), TBColors.butterLip, bevel: false),
    ],
    TBIconId.gem => [
      IconPart(
        _poly(const [
          (0.5, 0.92),
          (0.06, 0.38),
          (0.24, 0.12),
          (0.76, 0.12),
          (0.94, 0.38),
        ]),
        TBColors.sky,
      ),
      IconPart(
        _poly(const [(0.06, 0.38), (0.94, 0.38), (0.5, 0.92)]),
        TBColors.sky.withValues(alpha: 0.55),
        bevel: false,
      ),
    ],
    TBIconId.heart => [IconPart(_heart(), TBColors.berry)],
    TBIconId.heartBroken => [
      IconPart(_heart(), TBColors.ink500),
      IconPart(
        _poly(const [
          (0.52, 0.16),
          (0.42, 0.4),
          (0.56, 0.52),
          (0.44, 0.92),
          (0.6, 0.55),
          (0.48, 0.42),
          (0.58, 0.18),
        ]),
        TBColors.ink900,
        bevel: false,
      ),
    ],
    TBIconId.star => [IconPart(_star(0.5, 0.55, 0.46, 0.2), TBColors.butter)],
    // ink500 (not ink700) so the empty star stays visible on dark surfaces.
    TBIconId.starEmpty => [
      IconPart(_star(0.5, 0.55, 0.46, 0.2), TBColors.ink500),
    ],
    TBIconId.chest => [
      IconPart(_rrect(0.08, 0.42, 0.92, 0.88, 0.1), TBMaterials.woodFace),
      IconPart(_rrect(0.08, 0.16, 0.92, 0.5, 0.18), TBMaterials.woodHighlight),
      IconPart(_rrect(0.42, 0.4, 0.58, 0.64, 0.04), TBMaterials.brassFace),
    ],
    TBIconId.key => [
      IconPart(_ring(0.3, 0.32, 0.2, 0.09), TBMaterials.brassFace),
      IconPart(
        Path.combine(
          PathOperation.union,
          _rrect(0.4, 0.4, 0.5, 0.92, 0.04),
          Path.combine(
            PathOperation.union,
            _rrect(0.5, 0.66, 0.68, 0.74, 0.02),
            _rrect(0.5, 0.8, 0.64, 0.88, 0.02),
          ),
        ),
        TBMaterials.brassFace,
      ),
    ],
    TBIconId.ice => [
      IconPart(
        _poly(const [
          (0.5, 0.06),
          (0.86, 0.3),
          (0.86, 0.7),
          (0.5, 0.94),
          (0.14, 0.7),
          (0.14, 0.3),
        ]),
        TBMaterials.crystalFace,
      ),
      IconPart(
        _poly(const [(0.5, 0.06), (0.5, 0.5), (0.14, 0.3)]),
        TBColors.cream100.withValues(alpha: 0.5),
        bevel: false,
      ),
    ],
    TBIconId.hint => [
      IconPart(_circle(0.5, 0.4, 0.3), TBColors.butter),
      IconPart(_rrect(0.36, 0.64, 0.64, 0.74, 0.04), TBMaterials.brassFace),
      IconPart(_rrect(0.4, 0.78, 0.6, 0.88, 0.05), TBMaterials.brassFace),
    ],
    TBIconId.undo => [
      IconPart(_sector(0.5, 0.55, 0.36, 0.2, -2.6, 4.2), TBColors.teal),
      IconPart(
        _poly(const [(0.12, 0.4), (0.42, 0.34), (0.26, 0.64)]),
        TBColors.teal,
      ),
    ],
    TBIconId.grid => [
      for (final (l, t) in const [
        (0.1, 0.1),
        (0.54, 0.1),
        (0.1, 0.54),
        (0.54, 0.54),
      ])
        IconPart(_rrect(l, t, l + 0.36, t + 0.36, 0.08), TBColors.cream300),
    ],
    TBIconId.fit => [
      for (final (cx, cy, sx, sy) in const [
        (0.1, 0.1, 1.0, 1.0),
        (0.9, 0.1, -1.0, 1.0),
        (0.1, 0.9, 1.0, -1.0),
        (0.9, 0.9, -1.0, -1.0),
      ])
        IconPart(
          _poly([
            (cx, cy),
            (cx + sx * 0.3, cy),
            (cx + sx * 0.3, cy + sy * 0.1),
            (cx + sx * 0.1, cy + sy * 0.1),
            (cx + sx * 0.1, cy + sy * 0.3),
            (cx, cy + sy * 0.3),
          ]),
          TBColors.teal,
        ),
    ],
    TBIconId.pause => [
      IconPart(_rrect(0.2, 0.14, 0.42, 0.86, 0.08), TBColors.ink500),
      IconPart(_rrect(0.58, 0.14, 0.8, 0.86, 0.08), TBColors.ink500),
    ],
    TBIconId.settings => [
      IconPart(
        Path.combine(
          PathOperation.difference,
          _gear(0.5, 0.5, 0.44, 0.34, 8),
          _circle(0.5, 0.5, 0.14),
        ),
        TBColors.ink500,
      ),
    ],
    TBIconId.shop => [
      IconPart(
        _sector(0.5, 0.34, 0.26, 0.17, math.pi, math.pi),
        TBMaterials.brassFace,
      ),
      IconPart(_rrect(0.16, 0.34, 0.84, 0.9, 0.1), TBColors.teal),
    ],
    TBIconId.trophy => [
      IconPart(
        Path()
          ..moveTo(0.24, 0.1)
          ..lineTo(0.76, 0.1)
          ..lineTo(0.7, 0.5)
          ..quadraticBezierTo(0.5, 0.74, 0.3, 0.5)
          ..close(),
        TBColors.butter,
      ),
      IconPart(
        _sector(0.24, 0.3, 0.2, 0.12, math.pi / 2, math.pi),
        TBMaterials.brassFace,
      ),
      IconPart(
        _sector(0.76, 0.3, 0.2, 0.12, -math.pi / 2, math.pi),
        TBMaterials.brassFace,
      ),
      IconPart(_rrect(0.44, 0.6, 0.56, 0.78, 0.02), TBMaterials.brassFace),
      IconPart(_rrect(0.3, 0.78, 0.7, 0.9, 0.04), TBMaterials.brassFace),
    ],
    TBIconId.calendar => [
      IconPart(_rrect(0.1, 0.18, 0.9, 0.9, 0.1), TBColors.cream300),
      IconPart(_rrect(0.1, 0.18, 0.9, 0.36, 0.1), TBColors.berry),
      IconPart(_rrect(0.26, 0.08, 0.34, 0.26, 0.03), TBColors.ink500),
      IconPart(_rrect(0.66, 0.08, 0.74, 0.26, 0.03), TBColors.ink500),
    ],
    TBIconId.flame => [
      IconPart(_flame(1), TBColors.berry),
      IconPart(
        Path()..addPath(_flame(0.55), const Offset(0.2, 0.4)),
        TBColors.butter,
        bevel: false,
      ),
    ],
    TBIconId.share => [
      IconPart(_rrect(0.14, 0.4, 0.86, 0.9, 0.1), TBColors.ink500),
      IconPart(
        _poly(const [
          (0.5, 0.06),
          (0.74, 0.3),
          (0.58, 0.3),
          (0.58, 0.6),
          (0.42, 0.6),
          (0.42, 0.3),
          (0.26, 0.3),
        ]),
        TBColors.teal,
      ),
    ],
    TBIconId.lock => [
      IconPart(
        _sector(0.5, 0.36, 0.26, 0.16, math.pi, math.pi),
        TBColors.ink500,
      ),
      IconPart(_rect(0.24, 0.34, 0.34, 0.5), TBColors.ink500),
      IconPart(_rect(0.66, 0.34, 0.76, 0.5), TBColors.ink500),
      IconPart(_rrect(0.16, 0.46, 0.84, 0.9, 0.1), TBMaterials.brassFace),
      IconPart(_circle(0.5, 0.64, 0.07), TBColors.ink900, bevel: false),
    ],
    TBIconId.bell => [
      IconPart(_bell(), TBMaterials.brassFace),
      IconPart(_circle(0.5, 0.84, 0.09), TBColors.butter),
      IconPart(_circle(0.5, 0.1, 0.06), TBMaterials.brassFace),
    ],
    TBIconId.quests => [
      IconPart(_rrect(0.2, 0.1, 0.8, 0.9, 0.1), TBColors.cream300),
      IconPart(_rrect(0.1, 0.06, 0.9, 0.24, 0.09), TBMaterials.woodFace),
      IconPart(_rrect(0.1, 0.76, 0.9, 0.94, 0.09), TBMaterials.woodFace),
      for (final y in const [0.38, 0.5, 0.62])
        IconPart(
          _rrect(0.3, y, 0.7, y + 0.05, 0.02),
          TBColors.ink500,
          bevel: false,
        ),
    ],
    TBIconId.collection => [
      IconPart(_rrect(0.1, 0.4, 0.9, 0.9, 0.1), TBColors.teal),
      IconPart(_rrect(0.06, 0.16, 0.94, 0.42, 0.1), TBColors.butter),
      IconPart(
        _rrect(0.4, 0.52, 0.6, 0.62, 0.04),
        TBColors.cream100,
        bevel: false,
      ),
    ],
  };

  // --- unit-space path builders ------------------------------------------

  static Path _circle(double cx, double cy, double r) =>
      Path()..addOval(Rect.fromCircle(center: Offset(cx, cy), radius: r));

  static Path _rect(double l, double t, double r, double b) =>
      Path()..addRect(Rect.fromLTRB(l, t, r, b));

  static Path _rrect(double l, double t, double r, double b, double rad) =>
      Path()..addRRect(RRect.fromLTRBR(l, t, r, b, Radius.circular(rad)));

  static Path _poly(List<(double, double)> pts) =>
      Path()..addPolygon([for (final (x, y) in pts) Offset(x, y)], true);

  /// A ring: outer radius `r + w`, inner radius `r - w`.
  static Path _ring(double cx, double cy, double r, double w) => Path.combine(
    PathOperation.difference,
    _circle(cx, cy, r + w),
    _circle(cx, cy, r - w),
  );

  /// Annular sector from [start] sweeping [sweep] radians.
  static Path _sector(
    double cx,
    double cy,
    double outer,
    double inner,
    double start,
    double sweep,
  ) {
    final path = Path()
      ..arcTo(
        Rect.fromCircle(center: Offset(cx, cy), radius: outer),
        start,
        sweep,
        true,
      )
      ..arcTo(
        Rect.fromCircle(center: Offset(cx, cy), radius: inner),
        start + sweep,
        -sweep,
        false,
      )
      ..close();
    return path;
  }

  static Path _star(double cx, double cy, double outer, double inner) {
    final pts = <Offset>[];
    for (var i = 0; i < 10; i++) {
      final r = i.isEven ? outer : inner;
      final a = -math.pi / 2 + i * math.pi / 5;
      pts.add(Offset(cx + r * math.cos(a), cy + r * math.sin(a)));
    }
    return Path()..addPolygon(pts, true);
  }

  static Path _gear(
    double cx,
    double cy,
    double outer,
    double inner,
    int teeth,
  ) {
    final pts = <Offset>[];
    final step = 2 * math.pi / teeth;
    for (var i = 0; i < teeth; i++) {
      final a = i * step;
      for (final (da, r) in [
        (-0.28, inner),
        (-0.16, outer),
        (0.16, outer),
        (0.28, inner),
      ]) {
        final ang = a + da * step * 1.6;
        pts.add(Offset(cx + r * math.cos(ang), cy + r * math.sin(ang)));
      }
    }
    return Path()..addPolygon(pts, true);
  }

  static Path _heart() => Path()
    ..moveTo(0.5, 0.92)
    ..cubicTo(0.12, 0.65, 0.04, 0.35, 0.22, 0.2)
    ..cubicTo(0.36, 0.08, 0.5, 0.18, 0.5, 0.3)
    ..cubicTo(0.5, 0.18, 0.64, 0.08, 0.78, 0.2)
    ..cubicTo(0.96, 0.35, 0.88, 0.65, 0.5, 0.92)
    ..close();

  static Path _flame(double scale) {
    final p = Path()
      ..moveTo(0.5, 0.05)
      ..cubicTo(0.55, 0.3, 0.85, 0.4, 0.85, 0.65)
      ..cubicTo(0.85, 0.85, 0.68, 0.95, 0.5, 0.95)
      ..cubicTo(0.32, 0.95, 0.15, 0.85, 0.15, 0.65)
      ..cubicTo(0.15, 0.5, 0.28, 0.4, 0.35, 0.3)
      ..cubicTo(0.38, 0.4, 0.42, 0.42, 0.45, 0.42)
      ..cubicTo(0.45, 0.25, 0.45, 0.15, 0.5, 0.05)
      ..close();
    return scale == 1
        ? p
        : p.transform(Matrix4.diagonal3Values(scale, scale, 1).storage);
  }

  static Path _bell() => Path()
    ..moveTo(0.5, 0.14)
    ..cubicTo(0.72, 0.14, 0.78, 0.34, 0.78, 0.5)
    ..lineTo(0.9, 0.74)
    ..lineTo(0.1, 0.74)
    ..lineTo(0.22, 0.5)
    ..cubicTo(0.22, 0.34, 0.28, 0.14, 0.5, 0.14)
    ..close();
}
