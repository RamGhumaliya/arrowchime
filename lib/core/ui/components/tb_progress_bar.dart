import 'dart:ui' as ui;

import 'package:arrowchime/app/theme/tokens.dart';
import 'package:arrowchime/core/ui/painters/inset_painter.dart';
import 'package:arrowchime/core/ui/painters/shade.dart';
import 'package:arrowchime/core/ui/support/tb_motion_scope.dart';
import 'package:flutter/widgets.dart';

/// Recessed tube filled with butter "liquid" and a moving highlight band
/// (`docs/10` §5). Progress fills are the one thing allowed to animate
/// linearly.
class TBProgressBar extends StatefulWidget {
  const new({
    required this.value,
    this.semanticLabel,
    this.shimmer = true,
    super.key,
  });

  /// 0–1.
  final double value;
  final String? semanticLabel;

  /// Run the idle highlight band (off in goldens and under Reduce Motion).
  final bool shimmer;

  @override
  State<TBProgressBar> createState() => _TBProgressBarState();
}

class _TBProgressBarState extends State<TBProgressBar>
    with SingleTickerProviderStateMixin {
  late final AnimationController _shimmer = AnimationController(
    vsync: this,
    duration: TBMotion.shimmer,
  );

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final run = widget.shimmer && !TBMotionScope.reduced(context);
    if (run && !_shimmer.isAnimating) {
      _shimmer.repeat();
    } else if (!run) {
      _shimmer.stop();
    }
  }

  @override
  void dispose() {
    _shimmer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: widget.semanticLabel,
      value: '${(widget.value * 100).round()}%',
      child: TweenAnimationBuilder<double>(
        tween: Tween(end: widget.value.clamp(0.0, 1.0)),
        duration: TBMotionScope.duration(context, TBMotion.enter),
        builder: (context, value, _) => AnimatedBuilder(
          animation: _shimmer,
          builder: (context, _) => SizedBox(
            height: TBSizes.progressHeight,
            width: double.infinity,
            child: CustomPaint(
              painter: _ProgressPainter(value: value, shimmer: _shimmer.value),
            ),
          ),
        ),
      ),
    );
  }
}

class _ProgressPainter extends CustomPainter {
  const new({required this.value, required this.shimmer});

  final double value;
  final double shimmer;

  @override
  void paint(Canvas canvas, Size size) {
    final tube = RRect.fromRectAndRadius(
      Offset.zero & size,
      const Radius.circular(TBRadius.pill),
    );
    Inset.paint(canvas, tube, fill: TBColors.ink700, shadowOpacity: 0.5);

    final inner = tube.deflate(TBBevel.rimLight * 1.5);
    final w = inner.width * value;
    if (w <= 0) return;
    final liquid = RRect.fromRectAndRadius(
      Rect.fromLTWH(inner.left, inner.top, w, inner.height),
      Radius.circular(inner.height / 2),
    );
    canvas
      ..save()
      ..clipRRect(liquid)
      ..drawRRect(
        liquid,
        Paint()
          ..shader = ui.Gradient.linear(
            liquid.outerRect.topCenter,
            liquid.outerRect.bottomCenter,
            [
              TBShade.lighten(TBColors.butter, 0.12),
              TBColors.butter,
              TBColors.butterLip,
            ],
            const [0, 0.5, 1],
          ),
      );
    // Moving highlight band.
    final band = inner.height * 2;
    final x = inner.left - band + (w + band * 2) * shimmer;
    canvas
      ..drawPath(
        Path()
          ..moveTo(x, inner.bottom)
          ..lineTo(x + band * 0.5, inner.top)
          ..lineTo(x + band, inner.top)
          ..lineTo(x + band * 0.5, inner.bottom)
          ..close(),
        Paint()..color = TBShade.white(0.28),
      )
      // Top gloss.
      ..drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(
            inner.left + inner.height / 2,
            inner.top + TBBevel.rimLight,
            (w - inner.height).clamp(0.0, double.infinity),
            TBBevel.specularThickness,
          ),
          const Radius.circular(TBRadius.pill),
        ),
        Paint()..color = TBShade.white(0.5),
      )
      ..restore();
  }

  @override
  bool shouldRepaint(_ProgressPainter old) =>
      old.value != value || old.shimmer != shimmer;
}
