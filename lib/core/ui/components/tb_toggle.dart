import 'package:arrowchime/app/theme/tokens.dart';
import 'package:arrowchime/core/ui/painters/inset_painter.dart';
import 'package:arrowchime/core/ui/painters/knob_painter.dart';
import 'package:arrowchime/core/ui/painters/shade.dart';
import 'package:arrowchime/core/ui/support/tb_haptics.dart';
import 'package:arrowchime/core/ui/support/tb_motion_scope.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

/// Physical rocker switch (`docs/10` §5): a recessed track (teal when on) and
/// a ceramic knob that rocks across with the `mRelease` overshoot.
class TBToggle extends StatefulWidget {
  const new({
    required this.value,
    required this.onChanged,
    required this.semanticLabel,
    this.forceFocused = false,
    super.key,
  });

  final bool value;

  /// `null` disables the toggle.
  final ValueChanged<bool>? onChanged;
  final String semanticLabel;
  final bool forceFocused;

  @override
  State<TBToggle> createState() => _TBToggleState();
}

class _TBToggleState extends State<TBToggle>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: TBMotion.release,
    value: widget.value ? 1 : 0,
    lowerBound: -0.2,
    upperBound: 1.2,
  );
  bool _focused = false;

  @override
  void didUpdateWidget(TBToggle old) {
    super.didUpdateWidget(old);
    if (old.value != widget.value) {
      final target = widget.value ? 1.0 : 0.0;
      if (TBMotionScope.reduced(context)) {
        _controller.value = target;
      } else {
        _controller.animateTo(
          target,
          duration: TBMotion.release,
          curve: TBMotion.releaseCurve,
        );
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _flip() {
    final cb = widget.onChanged;
    if (cb == null) return;
    TBHaptics.selection();
    cb(!widget.value);
  }

  @override
  Widget build(BuildContext context) {
    final enabled = widget.onChanged != null;
    return Semantics(
      toggled: widget.value,
      enabled: enabled,
      label: widget.semanticLabel,
      onTap: enabled ? _flip : null,
      focusable: enabled,
      // The inner gesture / focus nodes would be unlabeled duplicates.
      child: ExcludeSemantics(
        child: FocusableActionDetector(
          enabled: enabled,
          onShowFocusHighlight: (v) => setState(() => _focused = v),
          shortcuts: const {
            SingleActivator(LogicalKeyboardKey.enter): ActivateIntent(),
            SingleActivator(LogicalKeyboardKey.space): ActivateIntent(),
          },
          actions: {
            ActivateIntent: CallbackAction<ActivateIntent>(
              onInvoke: (_) {
                _flip();
                return null;
              },
            ),
          },
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: _flip,
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                minWidth: TBSizes.minTapTarget,
                minHeight: TBSizes.minTapTarget,
              ),
              child: Center(
                child: AnimatedBuilder(
                  animation: _controller,
                  builder: (context, _) => CustomPaint(
                    size: const Size(TBSizes.toggleWidth, TBSizes.toggleHeight),
                    painter: _TogglePainter(
                      t: _controller.value,
                      enabled: enabled,
                      focused: _focused || widget.forceFocused,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _TogglePainter extends CustomPainter {
  const new({required this.t, required this.enabled, required this.focused});

  final double t;
  final bool enabled;
  final bool focused;

  @override
  void paint(Canvas canvas, Size size) {
    final track = RRect.fromRectAndRadius(
      Offset.zero & size,
      const Radius.circular(TBRadius.pill),
    );
    final on = t.clamp(0.0, 1.0);
    var fill = Color.lerp(TBColors.cream300, TBColors.tangerine, on)!;
    if (!enabled) fill = TBShade.desaturate(fill, TBBevel.disabledDesaturation);
    Inset.paint(canvas, track, fill: fill, shadowOpacity: 0.45);

    const knob = TBSizes.toggleKnob;
    const pad = (TBSizes.toggleHeight - knob) / 2;
    final x = pad + (size.width - knob - pad * 2) * t;
    Knob.paint(
      canvas,
      Offset(x, pad - Knob.lip / 2),
      knob,
      face: enabled
          ? TBColors.cream100
          : TBShade.desaturate(TBColors.cream100, TBBevel.disabledDesaturation),
      focused: focused,
    );
  }

  @override
  bool shouldRepaint(_TogglePainter old) =>
      old.t != t || old.enabled != enabled || old.focused != focused;
}
