import 'package:arrowchime/app/theme/tokens.dart';
import 'package:arrowchime/app/theme/typography.dart';
import 'package:arrowchime/core/ui/components/tb_text.dart';
import 'package:arrowchime/core/ui/painters/ceramic_painter.dart';
import 'package:arrowchime/core/ui/painters/shade.dart';
import 'package:arrowchime/core/ui/support/tb_layout.dart';
import 'package:arrowchime/core/ui/support/tb_pressable.dart';
import 'package:flutter/widgets.dart';

/// Which of the three button styles (`docs/10` §5, B12).
enum TBButtonKind {
  /// Tangerine. **One per screen**: the primary action.
  primary,

  /// Teal: secondary action, "free" route.
  secondary,

  /// Cream: tertiary action.
  tertiary,
}

/// The ceramic button. Height 64 (primary) / 52 / 44 including the 6 dp lip.
///
/// Pressed: the face moves down 4 dp, the lip shrinks to 2 dp, the shadow
/// tightens to `e1`, a selection haptic fires (`mTap`); release pops back
/// with overshoot (`mRelease`). Disabled: desaturated, no lip.
class TBButton extends StatelessWidget {
  const new({
    required this.label,
    required this.onPressed,
    this.kind = TBButtonKind.primary,
    this.icon,
    this.expand = false,
    this.semanticLabel,
    this.forcePressed = false,
    this.forceFocused = false,
    super.key,
  });

  const new primary({
    required String label,
    required VoidCallback? onPressed,
    Widget? icon,
    bool expand = false,
    String? semanticLabel,
    bool forcePressed = false,
    bool forceFocused = false,
    Key? key,
  }) : this(
         label: label,
         onPressed: onPressed,
         icon: icon,
         expand: expand,
         semanticLabel: semanticLabel,
         forcePressed: forcePressed,
         forceFocused: forceFocused,
         key: key,
       );

  const new secondary({
    required String label,
    required VoidCallback? onPressed,
    Widget? icon,
    bool expand = false,
    String? semanticLabel,
    bool forcePressed = false,
    bool forceFocused = false,
    Key? key,
  }) : this(
         label: label,
         onPressed: onPressed,
         kind: TBButtonKind.secondary,
         icon: icon,
         expand: expand,
         semanticLabel: semanticLabel,
         forcePressed: forcePressed,
         forceFocused: forceFocused,
         key: key,
       );

  const new tertiary({
    required String label,
    required VoidCallback? onPressed,
    Widget? icon,
    bool expand = false,
    String? semanticLabel,
    bool forcePressed = false,
    bool forceFocused = false,
    Key? key,
  }) : this(
         label: label,
         onPressed: onPressed,
         kind: TBButtonKind.tertiary,
         icon: icon,
         expand: expand,
         semanticLabel: semanticLabel,
         forcePressed: forcePressed,
         forceFocused: forceFocused,
         key: key,
       );

  final String label;

  /// `null` disables the button.
  final VoidCallback? onPressed;
  final TBButtonKind kind;

  /// Optional left icon (a 32 dp `TBIcon`).
  final Widget? icon;

  /// Fill the available width instead of hugging the label.
  final bool expand;
  final String? semanticLabel;

  /// Freeze the pressed / focused look (gallery and goldens).
  final bool forcePressed;
  final bool forceFocused;

  double get _baseHeight => switch (kind) {
    TBButtonKind.primary => TBSizes.buttonPrimaryHeight,
    TBButtonKind.secondary => TBSizes.buttonSecondaryHeight,
    TBButtonKind.tertiary => TBSizes.buttonTertiaryHeight,
  };

  /// The nominal height, grown when the user scales text up so the label
  /// always fits on the face (docs/09 section 7: text scaling 1.3x).
  double _heightFor(BuildContext context) =>
      _baseHeight +
      TBLayout.extraLine(context, TBTypography.button.style.fontSize!);

  (Color, Color) get _colors => switch (kind) {
    TBButtonKind.primary => (TBColors.tangerine, TBColors.tangerineLip),
    TBButtonKind.secondary => (TBColors.teal, TBColors.tealLip),
    TBButtonKind.tertiary => (TBColors.cream100, TBColors.cream300),
  };

  @override
  Widget build(BuildContext context) {
    final (face, lip) = _colors;
    final height = _heightFor(context);
    final tertiary = kind == TBButtonKind.tertiary;
    return TBPressable(
      onPressed: onPressed,
      semanticLabel: semanticLabel ?? label,
      forcePressed: forcePressed,
      forceFocused: forceFocused,
      minSize: Size(TBSizes.minTapTarget, height),
      builder: (context, state) {
        final press = state.press;
        final disabled = state.disabled;
        final focused = state.focused;
        final depth = disabled ? 0.0 : press * TBSizes.buttonPressDepth;
        final textColor = disabled
            ? TBShade.desaturate(
                tertiary ? TBColors.ink500 : TBColors.cream100,
                TBBevel.disabledDesaturation,
              )
            : (tertiary ? TBColors.ink900 : TBColors.cream100);
        final content = Row(
          mainAxisSize: expand ? MainAxisSize.max : MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (icon != null) ...[icon!, const SizedBox(width: TBSpacing.s8)],
            Flexible(
              child: TBText.button(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                color: textColor,
                strokeColor: disabled
                    ? TBColors.cream300
                    : (tertiary ? face : lip),
              ),
            ),
          ],
        );
        return CustomPaint(
          painter: CeramicPainter(
            face: face,
            lip: lip,
            radius: TBRadius.r20,
            press: press.clamp(-0.25, 1.0),
            disabled: disabled,
            focused: focused,
          ),
          child: SizedBox(
            height: height,
            width: expand ? double.infinity : null,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: TBSpacing.s24),
              child: Transform.translate(
                offset: Offset(0, depth),
                child: Padding(
                  padding: const EdgeInsets.only(bottom: TBSizes.buttonLip),
                  child: Center(widthFactor: expand ? null : 1, child: content),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
