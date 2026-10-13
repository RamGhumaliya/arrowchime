import 'package:arrowchime/app/theme/tokens.dart';
import 'package:arrowchime/core/ui/painters/shade.dart';
import 'package:flutter/rendering.dart';

/// Flat pill / slab (`docs/10` §2, V2 "Clean Line"): buttons, pills, icon
/// buttons.
///
/// A solid face over a thin darker lip (4 dp, 1 dp pressed); pressing moves the
/// face down 2 dp. No gradient, highlight or blur shadow.
abstract final class Ceramic {
  /// Height of the face for a slab of [totalHeight] (the lip is below it).
  static double faceHeight(double totalHeight) =>
      totalHeight - TBSizes.buttonLip;

  /// Paints a slab filling [size]. [press] runs 0 (resting) to 1.
  static void paint(
    Canvas canvas,
    Size size, {
    required Color face,
    required Color lip,
    required double radius,
    double press = 0,
    bool disabled = false,
    bool focused = false,
  }) {
    final faceH = faceHeight(size.height);
    final r = radius > faceH / 2 ? faceH / 2 : radius;
    final faceColor = disabled
        ? TBShade.desaturate(face, TBBevel.disabledDesaturation)
        : face;
    final lipColor = disabled
        ? TBShade.desaturate(lip, TBBevel.disabledDesaturation)
        : lip;
    final depth = disabled ? 0.0 : press * TBSizes.buttonPressDepth;
    final lipH = disabled ? 0.0 : TBSizes.buttonLip;

    final faceRRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, depth, size.width, faceH),
      Radius.circular(r),
    );
    final slabRRect = RRect.fromRectAndRadius(
      Rect.fromLTRB(0, depth, size.width, faceH + lipH),
      Radius.circular(r),
    );
    if (!disabled) canvas.drawRRect(slabRRect, Paint()..color = lipColor);
    canvas.drawRRect(faceRRect, Paint()..color = faceColor);

    if (focused) {
      canvas.drawRRect(
        slabRRect.inflate(TBSizes.focusRing),
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = TBSizes.focusRing
          ..color = TBColors.sky,
      );
    }
  }
}

/// [CustomPainter] adapter for [Ceramic.paint].
class CeramicPainter extends CustomPainter {
  const new({
    required this.face,
    required this.lip,
    required this.radius,
    this.press = 0,
    this.disabled = false,
    this.focused = false,
  });

  final Color face;
  final Color lip;
  final double radius;
  final double press;
  final bool disabled;
  final bool focused;

  @override
  void paint(Canvas canvas, Size size) => Ceramic.paint(
    canvas,
    size,
    face: face,
    lip: lip,
    radius: radius,
    press: press,
    disabled: disabled,
    focused: focused,
  );

  @override
  bool shouldRepaint(CeramicPainter old) =>
      old.face != face ||
      old.lip != lip ||
      old.radius != radius ||
      old.press != press ||
      old.disabled != disabled ||
      old.focused != focused;
}
