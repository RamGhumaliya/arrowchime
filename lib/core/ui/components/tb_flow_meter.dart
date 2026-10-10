import 'dart:ui' as ui;

import 'package:arrowchime/app/theme/tokens.dart';
import 'package:arrowchime/core/ui/components/tb_text.dart';
import 'package:arrowchime/core/ui/painters/brass_painter.dart';
import 'package:arrowchime/core/ui/painters/inset_painter.dart';
import 'package:arrowchime/core/ui/painters/shade.dart';
import 'package:arrowchime/core/ui/support/tb_motion_scope.dart';
import 'package:flutter/widgets.dart';

/// Segmented glass tube along the top of the board (`docs/10` §5). Segments
/// light up in the chapter colour as the Flow streak builds; a brass ×N badge
/// pops when the multiplier rises.
class TBFlowMeter extends StatelessWidget {
  const new({
    required this.fill,
    required this.color,
    this.multiplier = 1,
    this.segments = 10,
    super.key,
  });

  /// 0–1, how much of the tube is lit.
  final double fill;

  /// Chapter arrow colour of the lit segments.
  final Color color;

  /// Flow multiplier (1 = none, up to 5); the badge shows from ×2.
  final int multiplier;
  final int segments;

  static const double _badgeWidth = TBSizes.flowMeterHeight + TBSpacing.s16;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Flow ×$multiplier',
      value: '${(fill * 100).round()}%',
      excludeSemantics: true,
      child: SizedBox(
        height: TBSizes.flowMeterHeight + TBSpacing.s8,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Positioned.fill(
              top: TBSpacing.s4,
              bottom: TBSpacing.s4,
              // Room for the x-N badge so it never leaves the box.
              right: _badgeWidth - TBSpacing.s8,
              child: CustomPaint(
                painter: _TubePainter(
                  fill: fill.clamp(0.0, 1.0),
                  color: color,
                  segments: segments,
                ),
              ),
            ),
            if (multiplier >= 2)
              Positioned(
                right: 0,
                top: 0,
                bottom: 0,
                child: _Badge(multiplier: multiplier),
              ),
          ],
        ),
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  const new({required this.multiplier});

  final int multiplier;

  @override
  Widget build(BuildContext context) {
    final pop = TBMotionScope.reduced(context);
    return TweenAnimationBuilder<double>(
      key: ValueKey(multiplier),
      tween: Tween(begin: pop ? 1 : 1.5, end: 1),
      duration: TBMotionScope.duration(context, TBMotion.celebrateMin),
      curve: TBMotion.releaseCurve,
      builder: (context, scale, child) =>
          Transform.scale(scale: scale, child: child),
      child: SizedBox(
        width: TBFlowMeter._badgeWidth,
        child: CustomPaint(
          painter: const BrassPainter(radius: TBRadius.pill),
          child: Center(
            child: TBText.counter('×$multiplier', color: TBColors.cream100),
          ),
        ),
      ),
    );
  }
}

class _TubePainter extends CustomPainter {
  const new({required this.fill, required this.color, required this.segments});

  final double fill;
  final Color color;
  final int segments;

  @override
  void paint(Canvas canvas, Size size) {
    final tube = RRect.fromRectAndRadius(
      Offset.zero & size,
      const Radius.circular(TBRadius.pill),
    );
    Inset.paint(canvas, tube, fill: TBColors.ink700, shadowOpacity: 0.5);

    final inner = tube.deflate(TBBevel.rimLight * 1.5);
    const gap = TBSpacing.s4;
    final segW = (inner.width - gap * (segments - 1)) / segments;
    final lit = (fill * segments).ceil();
    for (var i = 0; i < segments; i++) {
      final left = inner.left + i * (segW + gap);
      final seg = RRect.fromRectAndRadius(
        Rect.fromLTWH(left, inner.top, segW, inner.height),
        const Radius.circular(TBRadius.r12 / 2),
      );
      final on = i < lit;
      canvas.drawRRect(
        seg,
        Paint()
          ..shader = ui.Gradient.linear(
            seg.outerRect.topCenter,
            seg.outerRect.bottomCenter,
            on
                ? [TBShade.lighten(color, 0.14), color]
                : [TBShade.white(0.12), TBShade.white(0.05)],
          ),
      );
      if (on) {
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromLTWH(
              left + 2,
              inner.top + 2,
              segW - 4,
              TBBevel.specularThickness / 1.5,
            ),
            const Radius.circular(TBRadius.pill),
          ),
          Paint()..color = TBShade.white(0.5),
        );
      }
    }
    // Glass sheen across the top of the tube.
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(
          tube.left + size.height / 2,
          tube.top + TBBevel.rimLight,
          size.width - size.height,
          size.height * 0.28,
        ),
        const Radius.circular(TBRadius.pill),
      ),
      Paint()..color = TBShade.white(0.16),
    );
  }

  @override
  bool shouldRepaint(_TubePainter old) =>
      old.fill != fill || old.color != color || old.segments != segments;
}
