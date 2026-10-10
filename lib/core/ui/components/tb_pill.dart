import 'package:arrowchime/app/theme/tokens.dart';
import 'package:arrowchime/app/theme/typography.dart';
import 'package:arrowchime/core/ui/components/tb_text.dart';
import 'package:arrowchime/core/ui/icons/tb_icon.dart';
import 'package:arrowchime/core/ui/icons/tb_icon_id.dart';
import 'package:arrowchime/core/ui/painters/ceramic_painter.dart';
import 'package:arrowchime/core/ui/painters/inset_painter.dart';
import 'package:arrowchime/core/ui/support/tb_layout.dart';
import 'package:arrowchime/core/ui/support/tb_pressable.dart';
import 'package:flutter/widgets.dart';

/// Resource counter (hearts, coins): an `ink700` recessed pill, a 3D icon
/// overlapping its left edge by 30%, the value in `counter` type, and an
/// optional "+" mini button on the right.
class TBPill extends StatelessWidget {
  const new({
    required this.icon,
    required this.value,
    this.onAdd,
    this.semanticLabel,
    this.forcePressedAdd = false,
    super.key,
  });

  final TBIconId icon;

  /// Already-formatted value (`1,240`, `5/5`).
  final String value;

  /// Shows the teal "+" button when set.
  final VoidCallback? onAdd;
  final String? semanticLabel;

  /// Freeze the "+" button pressed (gallery / goldens).
  final bool forcePressedAdd;

  @override
  Widget build(BuildContext context) {
    const iconSize = TBSizes.buttonIcon;
    const overlap = iconSize * TBSizes.pillIconOverlap;
    final pillHeight =
        TBSizes.pillHeight +
        TBLayout.extraLine(context, TBTypography.counter.style.fontSize!);
    return Semantics(
      label: semanticLabel ?? '${icon.semanticLabel} $value',
      excludeSemantics: true,
      child: Padding(
        // The icon pokes out of the pill on the left; reserve that space.
        padding: const EdgeInsets.only(left: overlap),
        child: SizedBox(
          height: pillHeight,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Positioned.fill(child: CustomPaint(painter: _PillPainter())),
              Positioned(
                left: -overlap,
                top: (pillHeight - iconSize) / 2,
                child: TBIcon(icon),
              ),
              Padding(
                padding: EdgeInsets.only(
                  left: iconSize - overlap + TBSpacing.s8,
                  right: onAdd == null ? TBSpacing.s16 : TBSpacing.s4,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Flexible(
                      child: TBText.counter(
                        value,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (onAdd != null) ...[
                      const SizedBox(width: TBSpacing.s8),
                      _PlusButton(
                        onPressed: onAdd,
                        forcePressed: forcePressedAdd,
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PillPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    Inset.paint(
      canvas,
      RRect.fromRectAndRadius(
        Offset.zero & size,
        const Radius.circular(TBRadius.pill),
      ),
      fill: TBColors.ink700,
      shadowOpacity: 0.5,
      rimOpacity: 0.18,
    );
  }

  @override
  bool shouldRepaint(_PillPainter old) => false;
}

/// The teal "+" mini button of a [TBPill].
class _PlusButton extends StatelessWidget {
  const new({required this.onPressed, required this.forcePressed});

  final VoidCallback? onPressed;
  final bool forcePressed;

  @override
  Widget build(BuildContext context) {
    return TBPressable(
      onPressed: onPressed,
      semanticLabel: 'Add',
      forcePressed: forcePressed,
      builder: (context, state) {
        final depth = state.press * TBSizes.buttonPressDepth / 2;
        return SizedBox.square(
          dimension: TBSizes.pillPlusButton,
          child: CustomPaint(
            painter: _PlusPainter(press: state.press, focused: state.focused),
            child: Transform.translate(
              offset: Offset(0, depth),
              child: const SizedBox.expand(),
            ),
          ),
        );
      },
    );
  }
}

class _PlusPainter extends CustomPainter {
  const new({required this.press, required this.focused});

  final double press;
  final bool focused;

  @override
  void paint(Canvas canvas, Size size) {
    Ceramic.paint(
      canvas,
      size,
      face: TBColors.teal,
      lip: TBColors.tealLip,
      radius: TBRadius.pill,
      press: press.clamp(-0.25, 1.0),
      focused: focused,
    );
    // The plus sign: two cream bars centred on the face.
    final face = Ceramic.faceHeight(size.height);
    final c = Offset(
      size.width / 2,
      face / 2 + press * TBSizes.buttonPressDepth,
    );
    final arm = size.width * 0.2;
    const w = TBBevel.rimLight * 2;
    final paint = Paint()
      ..color = TBColors.cream100
      ..strokeWidth = w
      ..strokeCap = StrokeCap.round;
    canvas
      ..drawLine(c - Offset(arm, 0), c + Offset(arm, 0), paint)
      ..drawLine(c - Offset(0, arm), c + Offset(0, arm), paint);
  }

  @override
  bool shouldRepaint(_PlusPainter old) =>
      old.press != press || old.focused != focused;
}
