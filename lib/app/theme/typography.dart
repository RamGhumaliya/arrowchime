import 'package:arrowchime/app/theme/tokens.dart';
import 'package:flutter/painting.dart';

/// Bundled font families (`docs/10_DESIGN_SYSTEM.md` §4, B5).
abstract final class TBFonts {
  static const String display = 'Fredoka';
  static const String ui = 'Nunito';
}

/// Sticker-effect parameters (ink stroke + hard downward shadow).
///
/// Stubbed: the painting is implemented once in `TBText` in Phase 3.
class TBStickerSpec {
  const new({
    required this.strokeWidth,
    this.shadowOffsetY = 0,
    this.shadowColor = const Color(0x59121A2B), // ink900 @ 35%
  });

  /// Outline width, drawn in `ink900`.
  final double strokeWidth;

  /// Hard (zero-blur) downward shadow offset.
  final double shadowOffsetY;
  final Color shadowColor;
}

/// One typography style plus its sticker/stroke treatment.
class TBTextSpec {
  const new({required this.style, this.sticker, this.buttonStroke});

  final TextStyle style;
  final TBStickerSpec? sticker;

  /// `button` style: 1.5 dp stroke in the darker lip colour (set per button).
  final double? buttonStroke;
}

/// The six text styles of the design system.
abstract final class TBTypography {
  static const TBTextSpec display = TBTextSpec(
    style: TextStyle(
      fontFamily: TBFonts.display,
      fontSize: 44,
      fontWeight: FontWeight.w700,
      color: TBColors.ink900,
    ),
  );

  static const TBTextSpec title = TBTextSpec(
    style: TextStyle(
      fontFamily: TBFonts.display,
      fontSize: 28,
      fontWeight: FontWeight.w700,
      color: TBColors.ink900,
    ),
  );

  static const TBTextSpec counter = TBTextSpec(
    style: TextStyle(
      fontFamily: TBFonts.display,
      fontSize: 22,
      fontWeight: FontWeight.w700,
      color: TBColors.ink900,
      fontFeatures: [FontFeature.tabularFigures()],
    ),
  );

  static const TBTextSpec button = TBTextSpec(
    style: TextStyle(
      fontFamily: TBFonts.display,
      fontSize: 20,
      fontWeight: FontWeight.w600,
      letterSpacing: 0.2,
      color: TBColors.cream100,
    ),
  );

  static const TBTextSpec body = TBTextSpec(
    style: TextStyle(
      fontFamily: TBFonts.ui,
      fontSize: 16,
      fontWeight: FontWeight.w600,
      color: TBColors.ink900,
    ),
  );

  static const TBTextSpec caption = TBTextSpec(
    style: TextStyle(
      fontFamily: TBFonts.ui,
      fontSize: 13,
      fontWeight: FontWeight.w700,
      color: TBColors.ink500,
    ),
  );
}
