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

  /// Stagger between list items.
  static const Duration stagger = Duration(milliseconds: 40);

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
}
