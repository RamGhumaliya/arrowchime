import 'package:arrowchime/app/theme/tokens.dart';
import 'package:arrowchime/core/ui/components/tb_text.dart';
import 'package:arrowchime/core/ui/painters/brass_painter.dart';
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
    // A thin track with a solid fill; the segment count only sets how many
    // notches the progress snaps to.
    final h = size.height * 0.28;
    final track = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, (size.height - h) / 2, size.width, h),
      const Radius.circular(TBRadius.pill),
    );
    canvas.drawRRect(track, Paint()..color = TBColors.cream300);
    final lit = (fill * segments).ceil() / segments;
    if (lit <= 0) return;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(0, track.top, size.width * lit, h),
        const Radius.circular(TBRadius.pill),
      ),
      Paint()..color = color,
    );
  }

  @override
  bool shouldRepaint(_TubePainter old) =>
      old.fill != fill || old.color != color || old.segments != segments;
}
