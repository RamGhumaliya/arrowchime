import 'dart:math' as math;
import 'dart:ui';

import 'package:arrowchime/app/theme/tokens.dart';
import 'package:arrowchime/core/ui/painters/glow_shader.dart';
import 'package:arrowchime/core/ui/painters/shade.dart';

/// The arrow skins (`docs/06` §6). Every skin keeps the five-pass tube
/// structure of `docs/10` §8 and changes its materials: [candy] is the
/// default enamel; the others recolour the body and add a pass of detail.
enum ArrowSkin {
  candy,
  bamboo,
  brass,
  silk,
  crystal,
  galaxy,
  neon,
  paper,
  pixel;

  /// The skin named [id] (`candy` when unknown).
  static ArrowSkin fromId(String id) => ArrowSkin.values.firstWhere(
    (s) => s.name == id,
    orElse: () => ArrowSkin.candy,
  );

  /// The body colour of an arrow whose colour is [base] in this skin.
  Color body(Color base) => switch (this) {
    ArrowSkin.candy ||
    ArrowSkin.silk ||
    ArrowSkin.paper ||
    ArrowSkin.pixel => base,
    ArrowSkin.bamboo => Color.lerp(
      Color.lerp(TBColors.butter, TBColors.teal, 0.45),
      base,
      0.25,
    )!,
    ArrowSkin.brass => TBMaterials.brassFace,
    ArrowSkin.crystal => TBShade.lighten(base, 0.2),
    ArrowSkin.galaxy => Color.lerp(TBColors.ink700, base, 0.3)!,
    ArrowSkin.neon => TBColors.ink900,
  };

  /// Whether the skin glows behind the tube (drawn before the body).
  bool get glows => this == ArrowSkin.neon || this == ArrowSkin.galaxy;

  /// Paints the glow of the tube along [body].
  void paintGlow(Canvas canvas, Path body, double c, Color base) {
    if (!glows) return;
    final blur = this == ArrowSkin.neon ? 0.16 : 0.1;
    // Galaxy uses the glow.frag shader when it is available.
    final shader = this == ArrowSkin.galaxy
        ? GlowShader.shader(body.getBounds().size, base)
        : null;
    if (shader != null) {
      canvas.drawPath(
        body,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeCap = StrokeCap.round
          ..strokeJoin = StrokeJoin.round
          ..strokeWidth = c * 0.62
          ..shader = shader
          ..maskFilter = MaskFilter.blur(BlurStyle.normal, c * blur),
      );
      shader.dispose();
      return;
    }
    canvas.drawPath(
      body,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round
        ..strokeWidth = c * 0.62
        ..color = base.withValues(alpha: 0.5)
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, c * blur),
    );
  }

  /// Paints this skin's detail pass over the tube (after the body and band).
  void paintDetail(Canvas canvas, Path body, double c, Color base) {
    switch (this) {
      case ArrowSkin.candy:
        break;
      case ArrowSkin.bamboo:
        // Nodes: short dark rings across the stem every 1.1 cells.
        _ticks(canvas, body, c * 1.1, c * 0.3, c * 0.05, TBShade.ink(0.35));
      case ArrowSkin.brass:
        // A second, thinner highlight: polished metal.
        canvas.drawPath(
          body.shift(Offset(c * 0.07, c * 0.05)),
          _line(TBShade.white(0.25), c * 0.04),
        );
      case ArrowSkin.silk:
        // Fabric sheen: fine light threads across the weave.
        _ticks(canvas, body, c * 0.16, c * 0.34, c * 0.02, TBShade.white(0.3));
      case ArrowSkin.crystal:
        canvas
          ..drawPath(body, _line(TBShade.white(0.45), c * 0.1))
          ..drawPath(
            body.shift(Offset(-c * 0.04, -c * 0.05)),
            _line(TBShade.white(0.7), c * 0.025),
          );
      case ArrowSkin.galaxy:
        _stars(canvas, body, c);
      case ArrowSkin.neon:
        // The lit tube on the dark core: coloured, then a white heart.
        canvas
          ..drawPath(body, _line(base, c * 0.16))
          ..drawPath(body, _line(TBShade.white(0.85), c * 0.05));
      case ArrowSkin.paper:
        // Folded paper: creases at an angle, no gloss.
        _ticks(
          canvas,
          body,
          c * 1.6,
          c * 0.4,
          c * 0.035,
          TBShade.ink(0.22),
          slant: 0.5,
        );
      case ArrowSkin.pixel:
        _pixels(canvas, body, c, base);
    }
  }

  static Paint _line(Color color, double width) => Paint()
    ..style = PaintingStyle.stroke
    ..strokeCap = StrokeCap.round
    ..strokeJoin = StrokeJoin.round
    ..strokeWidth = width
    ..color = color;

  /// Short strokes across [body] every [spacing], [length] long. [slant] > 0
  /// tilts them along the stem.
  static void _ticks(
    Canvas canvas,
    Path body,
    double spacing,
    double length,
    double width,
    Color color, {
    double slant = 0,
  }) {
    final paint = _line(color, width)..strokeCap = StrokeCap.butt;
    for (final metric in body.computeMetrics()) {
      for (var d = spacing / 2; d < metric.length; d += spacing) {
        final t = metric.getTangentForOffset(d);
        if (t == null) continue;
        final n = Offset(-t.vector.dy, t.vector.dx);
        final along = t.vector * (slant * length);
        canvas.drawLine(
          t.position - n * (length / 2) - along,
          t.position + n * (length / 2) + along,
          paint,
        );
      }
    }
  }

  /// Star dust along the body, placed by a fixed pattern so the picture is
  /// the same every time it is drawn.
  static void _stars(Canvas canvas, Path body, double c) {
    final paint = Paint()..color = TBShade.white(0.9);
    for (final metric in body.computeMetrics()) {
      var i = 0;
      for (var d = c * 0.3; d < metric.length; d += c * 0.42) {
        final t = metric.getTangentForOffset(d);
        if (t == null) continue;
        final n = Offset(-t.vector.dy, t.vector.dx);
        final side = math.sin(i * 12.9898) * 0.14;
        canvas.drawCircle(
          t.position + n * (c * side),
          c * (i.isEven ? 0.025 : 0.04),
          paint,
        );
        i++;
      }
    }
  }

  /// 8-bit look: the stem rebuilt from chunky squares in two shades.
  static void _pixels(Canvas canvas, Path body, double c, Color base) {
    final step = c * 0.2;
    final light = Paint()..color = TBShade.lighten(base, 0.15);
    final dark = Paint()..color = TBShade.lighten(base, -0.1);
    for (final metric in body.computeMetrics()) {
      var i = 0;
      for (var d = 0.0; d < metric.length; d += step) {
        final t = metric.getTangentForOffset(d);
        if (t == null) continue;
        final p = Offset(
          (t.position.dx / step).round() * step,
          (t.position.dy / step).round() * step,
        );
        canvas.drawRect(
          Rect.fromCenter(center: p, width: step * 1.5, height: step * 1.5),
          i.isEven ? light : dark,
        );
        i++;
      }
    }
  }
}
