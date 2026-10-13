import 'package:arrowchime/app/theme/tokens.dart';
import 'package:arrowchime/core/ui/painters/shade.dart';
import 'package:flutter/rendering.dart';

/// Flat ice block (`docs/10` §2, V2): the frozen mechanic. A pale blue face
/// with a darker outline.
abstract final class Crystal {
  static void paint(Canvas canvas, RRect rrect) {
    canvas
      ..drawRRect(
        rrect,
        Paint()..color = TBShade.lighten(TBMaterials.crystalFace, 0.22),
      )
      ..drawRRect(
        rrect.deflate(1),
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2
          ..color = TBMaterials.crystalFace,
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
