import 'package:arrowchime/app/theme/tokens.dart';
import 'package:arrowchime/core/ui/support/tb_haptics.dart';
import 'package:arrowchime/core/ui/support/tb_motion_scope.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

/// What a pressable component draws: how far it is pressed, whether it has
/// keyboard focus, whether it is disabled.
class TBPressState {
  const new({
    required this.press,
    required this.focused,
    required this.disabled,
  });

  /// 0 resting … 1 pressed; briefly < 0 on the release overshoot.
  final double press;
  final bool focused;
  final bool disabled;
}

/// Builds the visual of a pressable component for the current [TBPressState].
typedef TBPressableBuilder = Widget Function(
  BuildContext context,
  TBPressState state,
);

/// The shared press physics (`docs/10` §5 `TBButton`): pressing animates in
/// `mTap` (easeOut), releasing in `mRelease` with the 1.4 overshoot; a
/// selection haptic fires on press. Handles keyboard focus + activation and
/// the semantics of a button, and guarantees a 44 dp tap target.
class TBPressable extends StatefulWidget {
  const new({
    required this.builder,
    required this.onPressed,
    this.semanticLabel,
    this.forcePressed = false,
    this.forceFocused = false,
    this.hapticOnPress = true,
    this.minSize = const Size.square(TBSizes.minTapTarget),
    super.key,
  });

  final TBPressableBuilder builder;

  /// `null` disables the component.
  final VoidCallback? onPressed;
  final String? semanticLabel;

  /// Freezes the pressed / focused look (Design Gallery and golden tests).
  final bool forcePressed;
  final bool forceFocused;
  final bool hapticOnPress;
  final Size minSize;

  @override
  State<TBPressable> createState() => _TBPressableState();
}

class _TBPressableState extends State<TBPressable>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: TBMotion.tap,
    reverseDuration: TBMotion.release,
  );
  bool _focused = false;

  bool get _enabled => widget.onPressed != null;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _down() {
    if (!_enabled) return;
    if (widget.hapticOnPress) TBHaptics.selection();
    _controller.duration = TBMotionScope.duration(context, TBMotion.tap);
    _controller.forward();
  }

  void _up() {
    _controller.reverseDuration = TBMotionScope.duration(
      context,
      TBMotion.release,
    );
    _controller.reverse();
  }

  double get _press {
    if (widget.forcePressed) return 1;
    final v = _controller.value;
    if (_controller.status == AnimationStatus.reverse) {
      // Release overshoots past rest: the face pops up a hair, then settles.
      // Reduce Motion: settle without the overshoot.
      final curve = TBMotionScope.reduced(context)
          ? TBMotion.tapCurve
          : TBMotion.releaseCurve;
      final t = curve.transform(1 - v);
      return (1 - t).clamp(-0.25, 1.0);
    }
    return TBMotion.tapCurve.transform(v);
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      enabled: _enabled,
      label: widget.semanticLabel,
      onTap: widget.onPressed,
      focusable: _enabled,
      // The inner gesture / focus nodes would be unlabeled duplicates.
      child: ExcludeSemantics(
        child: FocusableActionDetector(
          enabled: _enabled,
          onShowFocusHighlight: (v) => setState(() => _focused = v),
          shortcuts: const {
            SingleActivator(LogicalKeyboardKey.enter): ActivateIntent(),
            SingleActivator(LogicalKeyboardKey.space): ActivateIntent(),
          },
          actions: {
            ActivateIntent: CallbackAction<ActivateIntent>(
              onInvoke: (_) {
                widget.onPressed?.call();
                return null;
              },
            ),
          },
          // Press visuals follow raw pointer events: `onTapDown` is delayed by
          // ~100 ms, which would make a tactile button feel mushy.
          child: Listener(
            behavior: HitTestBehavior.opaque,
            onPointerDown: (_) => _down(),
            onPointerUp: (_) => _up(),
            onPointerCancel: (_) => _up(),
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: widget.onPressed,
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minWidth: widget.minSize.width,
                  minHeight: widget.minSize.height,
                ),
                child: AnimatedBuilder(
                  animation: _controller,
                  builder: (context, _) => widget.builder(
                    context,
                    TBPressState(
                      press: _press,
                      focused: _focused || widget.forceFocused,
                      disabled: !_enabled,
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
