import 'dart:ui' as ui;

import 'package:arrowchime/app/theme/tokens.dart';
import 'package:arrowchime/core/ui/painters/inset_painter.dart';
import 'package:arrowchime/core/ui/painters/knob_painter.dart';
import 'package:arrowchime/core/ui/painters/shade.dart';
import 'package:arrowchime/core/ui/support/tb_haptics.dart';
import 'package:flutter/widgets.dart';

/// Recessed groove with a teal filled part and a ceramic knob; a light haptic
/// tick fires every 10% (`docs/10` §5). Value is `0..1`.
class TBSlider extends StatelessWidget {
  const new({
    required this.value,
    required this.onChanged,
    required this.semanticLabel,
    super.key,
  });

  /// 0–1.
  final double value;

  /// `null` disables the slider.
  final ValueChanged<double>? onChanged;
  final String semanticLabel;

  static const double _step = 0.1;

  void _update(double dx, double width) {
    final cb = onChanged;
    if (cb == null) return;
    const inset = TBSizes.sliderKnob / 2;
    final v = ((dx - inset) / (width - 2 * inset)).clamp(0.0, 1.0);
    if ((v / _step).floor() != (value / _step).floor()) TBHaptics.tick();
    cb(v);
  }

  @override
  Widget build(BuildContext context) {
    final enabled = onChanged != null;
    return Semantics(
      slider: true,
      enabled: enabled,
      label: semanticLabel,
      value: '${(value * 100).round()}%',
      increasedValue: '${((value + _step).clamp(0, 1) * 100).round()}%',
      decreasedValue: '${((value - _step).clamp(0, 1) * 100).round()}%',
      onIncrease: enabled
          ? () => onChanged!((value + _step).clamp(0.0, 1.0))
          : null,
      onDecrease: enabled
          ? () => onChanged!((value - _step).clamp(0.0, 1.0))
          : null,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final width = constraints.maxWidth;
          return GestureDetector(
            behavior: HitTestBehavior.opaque,
            onHorizontalDragUpdate: (d) => _update(d.localPosition.dx, width),
            onTapDown: (d) => _update(d.localPosition.dx, width),
            child: SizedBox(
              // At least the 44 dp tap target, taller if the knob ever grows.
              height: TBSizes.sliderKnob + TBSpacing.s12,
              width: width,
              child: CustomPaint(
                painter: _SliderPainter(value: value, enabled: enabled),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _SliderPainter extends CustomPainter {
  const new({required this.value, required this.enabled});

  final double value;
  final bool enabled;

  @override
  void paint(Canvas canvas, Size size) {
    const track = TBSizes.sliderTrack;
    const knob = TBSizes.sliderKnob;
    final cy = size.height / 2;
    final groove = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, cy - track / 2, size.width, track),
      const Radius.circular(TBRadius.pill),
    );
    Inset.paint(canvas, groove, fill: TBColors.ink700, shadowOpacity: 0.5);

    final travel = size.width - knob;
    final x = knob / 2 + travel * value.clamp(0.0, 1.0);
    final fillColor = enabled
        ? TBColors.teal
        : TBShade.desaturate(TBColors.teal, TBBevel.disabledDesaturation);
    final fillRect = RRect.fromRectAndRadius(
      Rect.fromLTRB(
        0,
        cy - track / 2,
        x,
        cy + track / 2,
      ).deflate(TBBevel.rimLight),
      const Radius.circular(TBRadius.pill),
    );
    if (x > knob / 2) {
      canvas.drawRRect(
        fillRect,
        Paint()
          ..shader = ui.Gradient.linear(
            fillRect.outerRect.topCenter,
            fillRect.outerRect.bottomCenter,
            [TBShade.lighten(fillColor, TBBevel.faceTopLightness), fillColor],
          ),
      );
    }
    Knob.paint(
      canvas,
      Offset(x - knob / 2, cy - knob / 2 - Knob.lip / 2),
      knob,
      face: enabled
          ? TBColors.cream100
          : TBShade.desaturate(TBColors.cream100, TBBevel.disabledDesaturation),
    );
  }

  @override
  bool shouldRepaint(_SliderPainter old) =>
      old.value != value || old.enabled != enabled;
}
