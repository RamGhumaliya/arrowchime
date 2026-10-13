import 'package:arrowchime/app/theme/tokens.dart';
import 'package:flutter/rendering.dart';

/// Flat butter plaque (`docs/10` §2, V2 "Clean Line"): star plaques, badges,
/// the flow-meter badge. Kept under its old name so callers do not change.
abstract final class Brass {
  /// Paints a plate in [rrect]. [elevation] draws the drop shadow (pass
  /// `const []` for none).
  static void paint(
    Canvas canvas,
    RRect rrect, {
    List<BoxShadow> elevation = TBElevation.e1,
  }) {
    for (final s in elevation) {
      canvas.drawRRect(
        rrect.shift(s.offset),
        Paint()
          ..color = s.color
          ..maskFilter = MaskFilter.blur(BlurStyle.normal, s.blurSigma),
      );
    }
    canvas
      ..drawRRect(rrect, Paint()..color = TBMaterials.brassDark)
      ..drawRRect(
        rrect.deflate(TBBevel.plaqueRim / 2),
        Paint()..color = TBMaterials.brassFace,
      );
  }
}

/// [CustomPainter] adapter for [Brass].
class BrassPainter extends CustomPainter {
  const new({this.radius = TBRadius.r12});

  final double radius;

  @override
  void paint(Canvas canvas, Size size) => Brass.paint(
    canvas,
    RRect.fromRectAndRadius(Offset.zero & size, Radius.circular(radius)),
  );

  @override
  bool shouldRepaint(BrassPainter old) => old.radius != radius;
}
