import 'dart:ui' as ui;

import 'package:arrowchime/app/theme/tokens.dart';
import 'package:arrowchime/core/ui/painters/shade.dart';
import 'package:flutter/rendering.dart';

/// Crystal / ice (`docs/10` §2): the frozen mechanic and the crystal skin.
///
/// A translucent face, internal facets (light and shade triangles), and a
/// bright rim, brightest on the top-left.
abstract final class Crystal {
  static void paint(Canvas canvas, RRect rrect) {
    final rect = rrect.outerRect;
    const face = TBMaterials.crystalFace;
    canvas
      ..drawRRect(
        rrect.shift(TBElevation.e1.first.offset),
        Paint()
          ..color = TBElevation.e1.first.color
          ..maskFilter = MaskFilter.blur(
            BlurStyle.normal,
            TBElevation.e1.first.blurSigma,
          ),
      )
      ..drawRRect(
        rrect,
        Paint()
          ..shader = ui.Gradient.linear(
            rect.topLeft,
            rect.bottomRight,
            [
              TBShade.lighten(face, 0.2).withValues(alpha: 0.85),
              face.withValues(alpha: 0.6),
              TBShade.bevelDark(face).withValues(alpha: 0.7),
            ],
            const [0, 0.5, 1],
          ),
      )
      ..save()
      ..clipRRect(rrect);
    // Facets: two light and two shaded triangles around an off-centre apex.
    final apex = Offset(
      rect.left + rect.width * 0.42,
      rect.top + rect.height * 0.4,
    );
    void facet(List<Offset> pts, Color c) =>
        canvas.drawPath(Path()..addPolygon(pts, true), Paint()..color = c);
    facet([rect.topLeft, rect.topRight, apex], TBShade.white(0.18));
    facet([rect.topLeft, apex, rect.bottomLeft], TBShade.white(0.1));
    facet([rect.topRight, rect.bottomRight, apex], TBShade.ink(0.1));
    facet([rect.bottomLeft, apex, rect.bottomRight], TBShade.ink(0.16));
    canvas
      ..restore()
      // Bright rim.
      ..drawRRect(
        rrect.deflate(TBBevel.rimLight / 2),
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = TBBevel.rimLight
          ..shader = ui.Gradient.linear(rect.topLeft, rect.bottomRight, [
            TBShade.white(0.9),
            TBShade.white(0.25),
          ]),
      );
  }
}

/// [CustomPainter] adapter for [Crystal].
class CrystalPainter extends CustomPainter {
  const new({this.radius = TBRadius.r12});

  final double radius;

  @override
  void paint(Canvas canvas, Size size) => Crystal.paint(
    canvas,
    RRect.fromRectAndRadius(Offset.zero & size, Radius.circular(radius)),
  );

  @override
  bool shouldRepaint(CrystalPainter old) => old.radius != radius;
}
