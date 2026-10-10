import 'package:arrowchime/app/theme/tokens.dart';
import 'package:arrowchime/core/ui/components/tb_text.dart';
import 'package:arrowchime/core/ui/icons/tb_icon.dart';
import 'package:arrowchime/core/ui/icons/tb_icon_id.dart';
import 'package:arrowchime/core/ui/painters/ceramic_painter.dart';
import 'package:arrowchime/core/ui/painters/shade.dart';
import 'package:arrowchime/core/ui/support/tb_pressable.dart';
import 'package:flutter/widgets.dart';

/// 56 dp round ceramic button for Undo / Hint / Grid / Fit, with a badge slot
/// (a count or a coin price) as a small butter pill on the top-right.
class TBIconButton extends StatelessWidget {
  const new({
    required this.icon,
    required this.onPressed,
    required this.semanticLabel,
    this.badge,
    this.selected = false,
    this.forcePressed = false,
    this.forceFocused = false,
    super.key,
  });

  final TBIconId icon;

  /// `null` disables the button.
  final VoidCallback? onPressed;

  /// Required: icon-only buttons need a screen-reader label.
  final String semanticLabel;

  /// Count or price shown top-right (e.g. `2`, `50`).
  final String? badge;

  /// Selected (toggled on) buttons use the teal glaze.
  final bool selected;
  final bool forcePressed;
  final bool forceFocused;

  @override
  Widget build(BuildContext context) {
    final face = selected ? TBColors.teal : TBColors.cream100;
    final lip = selected ? TBColors.tealLip : TBColors.cream300;
    return TBPressable(
      onPressed: onPressed,
      semanticLabel: semanticLabel,
      forcePressed: forcePressed,
      forceFocused: forceFocused,
      minSize: const Size.square(TBSizes.iconButton),
      builder: (context, state) {
        final press = state.press;
        final disabled = state.disabled;
        final focused = state.focused;
        final depth = disabled ? 0.0 : press * TBSizes.buttonPressDepth;
        return SizedBox.square(
          dimension: TBSizes.iconButton,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Positioned.fill(
                child: CustomPaint(
                  painter: CeramicPainter(
                    face: face,
                    lip: lip,
                    radius: TBRadius.pill,
                    press: press.clamp(-0.25, 1.0),
                    disabled: disabled,
                    focused: focused,
                  ),
                ),
              ),
              Positioned(
                left: 0,
                right: 0,
                top: depth,
                height: TBSizes.iconButton - TBSizes.buttonLip,
                child: Center(
                  child: Opacity(
                    opacity: disabled ? 0.45 : 1,
                    child: TBIcon(icon),
                  ),
                ),
              ),
              if (badge != null)
                Positioned(
                  top: -TBSpacing.s4,
                  right: -TBSpacing.s4,
                  child: TBBadge(badge!),
                ),
            ],
          ),
        );
      },
    );
  }
}

/// Small butter pill (count / price) used as a badge.
class TBBadge extends StatelessWidget {
  const new(this.text, {super.key});

  final String text;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: TBColors.butter,
        borderRadius: TBRadius.brPill,
        border: Border.all(color: TBColors.butterLip, width: TBBevel.rimLight),
        boxShadow: TBElevation.e1,
      ),
      child: ConstrainedBox(
        constraints: const BoxConstraints(
          minHeight: TBSizes.badgeHeight,
          minWidth: TBSizes.badgeHeight,
        ),
        child: Center(
          widthFactor: 1,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: TBSpacing.s8),
            child: TBText.caption(
              text,
              color: TBShade.bevelDark(TBColors.ink900),
            ),
          ),
        ),
      ),
    );
  }
}
