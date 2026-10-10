import 'package:flutter/animation.dart';
import 'package:flutter/painting.dart';

/// Design tokens — the single source of truth for `docs/10_DESIGN_SYSTEM.md` §3.
///
/// Feature code must never use a literal colour, spacing, radius, shadow or
/// duration; it reads from here.
abstract final class TBColors {
  // Ink (darks).
  static const Color ink900 = Color(0xFF121A2B);
  static const Color ink700 = Color(0xFF1E2A44);
  static const Color ink500 = Color(0xFF3A4A6B);

  // Cream (panels).
  static const Color cream100 = Color(0xFFFFF6E6);
  static const Color cream300 = Color(0xFFF3DFC1);

  // Primary CTA only.
  static const Color tangerine = Color(0xFFFF8A1F);
  static const Color tangerineLip = Color(0xFFC85A08);

  // Secondary CTA / success / "free" route.
  static const Color teal = Color(0xFF19B3A3);
  static const Color tealLip = Color(0xFF0E7D72);

  // Hearts, errors, blocked flash.
  static const Color berry = Color(0xFFE5446D);

  // Coins, stars, rewards.
  static const Color butter = Color(0xFFFFD15C);
  static const Color butterLip = Color(0xFFC9952A);

  // Info, frozen hints.
  static const Color sky = Color(0xFF6EC6FF);
}

/// Spacing scale, 4 dp base.
abstract final class TBSpacing {
  static const double s4 = 4;
  static const double s8 = 8;
  static const double s12 = 12;
  static const double s16 = 16;
  static const double s24 = 24;
  static const double s32 = 32;
  static const double s48 = 48;
  static const double s64 = 64;

  /// Screen side margin on phones.
  static const double screenMarginPhone = s16;

  /// Screen side margin on tablets.
  static const double screenMarginTablet = s32;
}

/// Corner radii. Nothing else is allowed (B8).
abstract final class TBRadius {
  static const double r12 = 12;
  static const double r20 = 20;
  static const double r32 = 32;
  static const double pill = 999;

  static const BorderRadius br12 = BorderRadius.all(Radius.circular(r12));
  static const BorderRadius br20 = BorderRadius.all(Radius.circular(r20));
  static const BorderRadius br32 = BorderRadius.all(Radius.circular(r32));
  static const BorderRadius brPill = BorderRadius.all(Radius.circular(pill));
}

/// The only three elevations (B7). Each is a drop shadow + a tight contact
/// shadow. X offsets lean right to follow the top-left key light.
abstract final class TBElevation {
  /// Pills, small chips.
  static const List<BoxShadow> e1 = [
    BoxShadow(
      color: Color(0x2E121A2B), // ink900 @ 18%
      offset: Offset(0, 3),
      blurRadius: 6,
    ),
    BoxShadow(
      color: Color(0x40121A2B), // ink900 @ 25%
      offset: Offset(0, 1),
      blurRadius: 1,
    ),
  ];

  /// Buttons, cards.
  static const List<BoxShadow> e2 = [
    BoxShadow(
      color: Color(0x38121A2B), // ink900 @ 22%
      offset: Offset(2, 8),
      blurRadius: 16,
    ),
    BoxShadow(
      color: Color(0x4D121A2B), // ink900 @ 30%
      offset: Offset(0, 2),
      blurRadius: 2,
    ),
  ];

  /// Sheets, dialogs, win plaque.
  static const List<BoxShadow> e3 = [
    BoxShadow(
      color: Color(0x47121A2B), // ink900 @ 28%
      offset: Offset(4, 18),
      blurRadius: 32,
    ),
    BoxShadow(
      color: Color(0x4D121A2B), // ink900 @ 30%
      offset: Offset(0, 3),
      blurRadius: 3,
    ),
  ];
}

/// Light and material constants from `docs/10` §2.
abstract final class TBLight {
  /// Key light comes from the top-left.
  static const Alignment direction = Alignment.topLeft;

  /// Key light elevation in degrees.
  static const double elevationDegrees = 35;

  /// Bevel-light is +18% lightness; bevel-dark/lip is -22%.
  static const double bevelLightDelta = 0.18;
  static const double bevelDarkDelta = -0.22;

  /// Specular streak opacity range (white 55–70%).
  static const double specularMin = 0.55;
  static const double specularMax = 0.70;

  /// Contact shadow: 2–4 dp at 30% ink.
  static const double contactShadowOpacity = 0.30;

  /// Scrim behind sheets: ink900 @ 55%.
  static const Color scrim = Color(0x8C121A2B);
}

/// Motion durations and curves from `docs/10` §3.5.
abstract final class TBMotion {
  /// Press down.
  static const Duration tap = Duration(milliseconds: 90);
  static const Curve tapCurve = Curves.easeOut;

  /// Release / pop (ease-out-back with overshoot 1.4).
  static const Duration release = Duration(milliseconds: 160);
  static const Curve releaseCurve = _EaseOutBack(1.4);

  /// Sheets and panels slide in.
  static const Duration enter = Duration(milliseconds: 240);
  static const Curve enterCurve = Curves.easeOutCubic;

  /// Stars, plaques, chests: 360–600 ms spring.
  static const Duration celebrateMin = Duration(milliseconds: 360);
  static const Duration celebrateMax = Duration(milliseconds: 600);
  static const SpringDescription celebrateSpring = SpringDescription(
    mass: 1,
    stiffness: 380,
    damping: 22,
  );

  /// Sheets enter with a slight overshoot (docs/10 §5 `TBSheet`).
  static const Curve sheetCurve = _EaseOutBack(0.8);

  /// Stagger between list items.
  static const Duration stagger = Duration(milliseconds: 40);

  /// Stars stamp in one by one, this far apart (GDD §4 "Star award").
  static const Duration starStagger = Duration(milliseconds: 180);

  /// Toasts auto-hide after this long.
  static const Duration toast = Duration(seconds: 2);

  /// Idle loop of the progress highlight band.
  static const Duration shimmer = Duration(milliseconds: 1600);

  /// With Reduce Motion everything becomes a 160 ms fade.
  static const Duration reducedMotionFade = Duration(milliseconds: 160);
}

class _EaseOutBack extends Curve {
  const new(this.overshoot);

  final double overshoot;

  @override
  double transformInternal(double t) {
    final c3 = overshoot + 1;
    final u = t - 1;
    return 1 + c3 * u * u * u + overshoot * u * u;
  }
}

/// Component sizes and accessibility minimums.
abstract final class TBSizes {
  static const double minTapTarget = 44;
  static const double buttonPrimaryHeight = 64;
  static const double buttonSecondaryHeight = 52;
  static const double buttonTertiaryHeight = 44;
  static const double iconButton = 56;
  static const double buttonLip = 6;
  static const double buttonPressDepth = 4;
  static const double buttonLipPressed = 2;
  static const double buttonIcon = 32;

  /// Shortest side at/above which a device is treated as a tablet.
  static const double tabletShortestSide = 600;

  // Component dimensions (docs/10 §5). Only values the spec does not fix are
  // chosen here; each is documented in docs/10 §3.6.
  static const double pillHeight = 40;
  static const double pillIconOverlap = 0.30;
  static const double pillPlusButton = 34;
  static const double badgeHeight = 22;
  static const double toggleWidth = 64;
  static const double toggleHeight = 36;
  static const double toggleKnob = 30;
  static const double sliderTrack = 14;
  static const double sliderKnob = 32;
  static const double progressHeight = 20;
  static const double flowMeterHeight = 28;
  static const double starRowStar = 52;
  static const double ribbonHeight = 56;
  static const double ribbonFold = 14;
  static const double tabHeight = 56;
  static const double toastHeight = 48;
  static const double sheetHandle = 4;
  static const double chapterCardWidth = 280;
  static const double chapterCardHeight = 340;
  static const double chapterFrame = 14;
  static const double focusRing = 3;
  static const double tiltDegrees = 4;

  // Responsive limits: wide screens centre the content instead of stretching.
  static const double sheetMaxWidth = 560;
  static const double contentMaxWidth = 720;
  static const double grainDot = 1.2;
}

/// Derived material colours (docs/10 §2 "Materials"). The palette in §3.1 has
/// no wood or brass, so they are mixed from palette colours; no new hues.
abstract final class TBMaterials {
  /// Lacquered wood: `tangerineLip` toned down into the night blue.
  static final Color woodFace = Color.lerp(
    TBColors.tangerineLip,
    TBColors.ink700,
    0.55,
  )!;
  static final Color woodLip = Color.lerp(woodFace, TBColors.ink900, 0.45)!;
  static final Color woodHighlight = Color.lerp(
    woodFace,
    TBColors.cream100,
    0.25,
  )!;

  /// Brushed brass: butter lip as the base, butter as the highlight.
  static const Color brassFace = TBColors.butterLip;
  static final Color brassLight = Color.lerp(
    TBColors.butter,
    TBColors.cream100,
    0.35,
  )!;
  static final Color brassDark = Color.lerp(
    TBColors.butterLip,
    TBColors.ink900,
    0.45,
  )!;

  /// Crystal / ice face (translucent).
  static const Color crystalFace = TBColors.sky;
}

/// Geometry of the Toybox 3D material recipes (docs/10 §2, §5).
abstract final class TBBevel {
  /// Inner top-left highlight stroke on ceramic.
  static const double innerHighlight = 1.5;

  /// Opacity of that highlight (white 45%).
  static const double innerHighlightOpacity = 0.45;

  /// Specular streak: thickness and opacity (white 55–70%).
  static const double specularThickness = 3;
  static const double specularOpacity = TBLight.specularMax;

  /// Paper / panel bottom bevel and top rim light.
  static const double panelBevel = 4;
  static const double rimLight = 2;

  /// Grain: 2% opacity noise on paper and wood.
  static const double grainOpacity = 0.02;

  /// How much lighter the top of a ceramic face is (+8%).
  static const double faceTopLightness = 0.08;

  /// Disabled ceramic loses this much saturation (80%).
  static const double disabledDesaturation = 0.8;

  /// Recessed surfaces: inner shadow offset and blur.
  static const double innerShadowOffset = 3;
  static const double innerShadowBlur = 4;

  /// Brass and wood frame thicknesses.
  static const double plaqueRim = 3;
  static const double woodRim = 6;
}

/// Board animation timings and limits for Flame, in seconds (`docs/03` §4).
abstract final class TBGameMotion {
  /// An arrow flying off the board: 250–450 ms depending on distance.
  static const double exitMin = 0.25;
  static const double exitMax = 0.45;
  static const double exitPerCell = 0.03;

  /// Blocked tap: the arrow lurches 0.35 cell, then recoils elastically.
  static const double lurchCells = 0.35;
  static const double lurch = 0.09;
  static const double recoil = 0.22;

  /// The blocker flashes red twice.
  static const double flash = 0.4;

  /// Frozen arrow shake.
  static const double shake = 0.3;

  /// Hint glow period.
  static const double hintPulse = 1.1;

  /// Long-press path preview fade.
  static const double peekFade = 0.12;

  /// Pause between the last arrow leaving and the win sheet.
  static const double winDelay = 0.7;

  /// Reduce Motion: a plain fade replaces flying and shaking.
  static const double reducedFade = 0.16;

  /// Hard cap of live particles (`CLAUDE.md` performance rule).
  static const int maxParticles = 120;
}

/// Touch timings of the board (`docs/03` §3).
abstract final class TBGesture {
  /// Hold this long to peek an arrow's exit path.
  static const Duration peekHold = Duration(milliseconds: 250);

  /// Two taps on empty felt within this time fit the board.
  static const Duration doubleTap = Duration(milliseconds: 300);

  /// A Flow streak survives this long between correct taps.
  static const Duration flowWindow = Duration(milliseconds: 1500);

  /// How often the Flow meter checks whether the streak lapsed.
  static const Duration flowTick = Duration(milliseconds: 150);

  /// A finger that moved further than this (dp) is a drag, not a tap.
  static const double slop = 8;
}
