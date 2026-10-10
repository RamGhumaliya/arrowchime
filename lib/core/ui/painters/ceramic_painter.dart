import 'dart:ui' as ui;

import 'package:arrowchime/app/theme/tokens.dart';
import 'package:arrowchime/core/ui/painters/shade.dart';
import 'package:flutter/rendering.dart';

/// Glazed ceramic (`docs/10` §2 / §5): buttons, pills, icon buttons.
///
/// Recipe: a lip in the lip colour (6 dp, 2 dp pressed), a face with a +8%
/// lighter top, a 1.5 dp inner highlight on the top-left edges, a thin
/// specular streak, and the `e2` shadow (tightening to `e1` when pressed).
/// Light comes from the top-left.
abstract final class Ceramic {
  /// Height of the face for a slab of [totalHeight] (the lip is below it).
  static double faceHeight(double totalHeight) =>
      totalHeight - TBSizes.buttonLip;

  /// Paints a ceramic slab filling [size].
  ///
  /// [press] runs 0 (resting) to 1 (fully pressed): the face moves down by
  /// [TBSizes.buttonPressDepth], the lip shrinks to
  /// [TBSizes.buttonLipPressed] and the shadow tightens. A [disabled] slab is
  /// desaturated and has no lip. [radius] is a radius token.
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
    // A pill radius (999) is capped to half the face height.
    final r = radius > faceHeight(size.height) / 2
        ? faceHeight(size.height) / 2
        : radius;
    final faceColor = disabled
        ? TBShade.desaturate(face, TBBevel.disabledDesaturation)
        : face;
    final lipColor = disabled
        ? TBShade.desaturate(lip, TBBevel.disabledDesaturation)
        : lip;
    final depth = disabled ? 0.0 : press * TBSizes.buttonPressDepth;
    final faceH = faceHeight(size.height);
    final lipH = disabled ? 0.0 : TBSizes.buttonLip;

    final faceRect = Rect.fromLTWH(0, depth, size.width, faceH);
    final faceRRect = RRect.fromRectAndRadius(faceRect, Radius.circular(r));
    // Face plus visible lip: the bottom edge never moves, so the lip shows
    // 6 dp at rest and 2 dp when the face is pressed down 4 dp.
    final slabRRect = RRect.fromRectAndRadius(
      Rect.fromLTRB(0, depth, size.width, faceH + lipH),
      Radius.circular(r),
    );

    // Shadow: e2 at rest, e1 pressed.
    final shadows = BoxShadow.lerpList(
      TBElevation.e2,
      TBElevation.e1,
      disabled ? 1 : press,
    )!;
    for (final s in shadows) {
      canvas.drawRRect(
        slabRRect.shift(s.offset),
        Paint()
          ..color = s.color
          ..maskFilter = MaskFilter.blur(BlurStyle.normal, s.blurSigma),
      );
    }

    // Lip.
    if (!disabled) canvas.drawRRect(slabRRect, Paint()..color = lipColor);

    // Face: lighter top fading into the face colour.
    canvas.drawRRect(
      faceRRect,
      Paint()
        ..shader = ui.Gradient.linear(
          faceRect.topCenter,
          faceRect.bottomCenter,
          [TBShade.lighten(faceColor, TBBevel.faceTopLightness), faceColor],
        ),
    );

    // Inner highlight on the top-left edges only (gradient stroke).
    final inner = faceRRect.deflate(TBBevel.innerHighlight / 2);
    canvas.drawRRect(
      inner,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = TBBevel.innerHighlight
        ..shader = ui.Gradient.linear(
          faceRect.topLeft,
          faceRect.bottomRight,
          [TBShade.white(TBBevel.innerHighlightOpacity), TBShade.white(0)],
          const [0, 0.55],
        ),
    );

    // Specular streak near the top-left.
    var streakW = size.width * 0.28;
    final maxStreak = size.width - r * 2;
    if (streakW > maxStreak) streakW = maxStreak;
    if (streakW < TBBevel.specularThickness) {
      streakW = TBBevel.specularThickness;
    }
    final streak = RRect.fromRectAndRadius(
      Rect.fromLTWH(
        r * 0.9,
        depth + faceH * 0.16,
        streakW,
        TBBevel.specularThickness,
      ),
      const Radius.circular(TBRadius.pill),
    );
    canvas.drawRRect(
      streak,
      Paint()..color = TBShade.white(disabled ? 0.25 : TBBevel.specularOpacity),
    );

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
