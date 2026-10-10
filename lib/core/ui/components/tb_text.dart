import 'package:arrowchime/app/theme/tokens.dart';
import 'package:arrowchime/app/theme/typography.dart';
import 'package:flutter/widgets.dart';

/// The six text styles of `docs/10` §4.
enum TBTextVariant { display, title, counter, button, body, caption }

/// All player-facing text. Implements the "sticker" treatment (B10) once:
/// an `ink900` stroke around the glyphs and a hard, unblurred downward shadow.
///
/// Never use `Text` with ad-hoc styles in player UI.
class TBText extends StatelessWidget {
  const new(
    this.data, {
    this.variant = TBTextVariant.body,
    this.color,
    this.strokeColor,
    this.textAlign,
    this.maxLines,
    this.overflow,
    super.key,
  });

  const new display(
    String data, {
    Color? color,
    TextAlign? textAlign,
    int? maxLines,
    Key? key,
  }) : this(
         data,
         variant: TBTextVariant.display,
         color: color,
         textAlign: textAlign,
         maxLines: maxLines,
         key: key,
       );

  const new title(
    String data, {
    Color? color,
    TextAlign? textAlign,
    int? maxLines,
    Key? key,
  }) : this(
         data,
         variant: TBTextVariant.title,
         color: color,
         textAlign: textAlign,
         maxLines: maxLines,
         key: key,
       );

  const new counter(
    String data, {
    Color? color,
    int? maxLines,
    TextOverflow? overflow,
    Key? key,
  }) : this(
         data,
         variant: TBTextVariant.counter,
         color: color,
         maxLines: maxLines,
         overflow: overflow,
         key: key,
       );

  /// `button`: stroked in [strokeColor] (the button's lip colour).
  const new button(
    String data, {
    Color? color,
    Color? strokeColor,
    int? maxLines,
    TextOverflow? overflow,
    Key? key,
  }) : this(
         data,
         variant: TBTextVariant.button,
         color: color,
         strokeColor: strokeColor,
         maxLines: maxLines,
         overflow: overflow,
         key: key,
       );

  const new body(
    String data, {
    Color? color,
    TextAlign? textAlign,
    int? maxLines,
    Key? key,
  }) : this(
         data,
         variant: TBTextVariant.body,
         color: color,
         textAlign: textAlign,
         maxLines: maxLines,
         key: key,
       );

  const new caption(
    String data, {
    Color? color,
    TextAlign? textAlign,
    int? maxLines,
    Key? key,
  }) : this(
         data,
         variant: TBTextVariant.caption,
         color: color,
         textAlign: textAlign,
         maxLines: maxLines,
         key: key,
       );

  final String data;
  final TBTextVariant variant;

  /// Fill colour; defaults to the variant's own.
  final Color? color;

  /// Stroke colour of the `button` variant (default `ink900`).
  final Color? strokeColor;
  final TextAlign? textAlign;
  final int? maxLines;
  final TextOverflow? overflow;

  TBTextSpec get _spec => switch (variant) {
    TBTextVariant.display => TBTypography.display,
    TBTextVariant.title => TBTypography.title,
    TBTextVariant.counter => TBTypography.counter,
    TBTextVariant.button => TBTypography.button,
    TBTextVariant.body => TBTypography.body,
    TBTextVariant.caption => TBTypography.caption,
  };

  @override
  Widget build(BuildContext context) {
    final spec = _spec;
    final fillStyle = spec.style.copyWith(color: color ?? spec.style.color);
    final sticker = spec.sticker;
    final buttonStroke = spec.buttonStroke;

    Text text(TextStyle style) => Text(
      data,
      style: style,
      textAlign: textAlign,
      maxLines: maxLines,
      overflow: overflow,
    );

    final strokeWidth = sticker?.strokeWidth ?? buttonStroke;
    if (strokeWidth == null) {
      return text(fillStyle);
    }
    final outline = strokeColor ?? TBColors.ink900;
    // A TextStyle cannot carry both a colour and a foreground paint, so the
    // stroke layers are rebuilt from the spec's font fields.
    TextStyle stroked(Color c) => TextStyle(
      fontFamily: spec.style.fontFamily,
      fontSize: spec.style.fontSize,
      fontWeight: spec.style.fontWeight,
      letterSpacing: spec.style.letterSpacing,
      fontFeatures: spec.style.fontFeatures,
      foreground: Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth * 2
        ..strokeJoin = StrokeJoin.round
        ..color = c,
    );

    final shadow = sticker;
    return Semantics(
      label: data,
      excludeSemantics: true,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          if (shadow != null && shadow.shadowOffsetY > 0)
            Positioned.fill(
              child: Transform.translate(
                offset: Offset(0, shadow.shadowOffsetY),
                child: text(stroked(shadow.shadowColor)),
              ),
            ),
          Positioned.fill(child: text(stroked(outline))),
          text(fillStyle),
        ],
      ),
    );
  }
}
