import 'package:arrowchime/core/level/generator/mechanic_tutorials.dart';

/// What the hand cursor shows.
enum HandGesture { tap, hold, pinch }

/// Which caption to show (resolved to ARB text by the overlay).
enum OnboardingCaption {
  tap,
  blocked,
  hearts,
  bend,
  peek,
  zoom,
  knot,
  rotator,
  gate,
  frozen,
  link,
  portal,
}

/// One onboarding hint of Chapter 1 (`docs/03` §6): at most one new idea per
/// level, a caption of at most six words and a hand showing the gesture.
class OnboardingStep {
  const new(this.caption, this.gesture, {this.mechanic});

  final OnboardingCaption caption;
  final HandGesture gesture;

  /// For mechanic tutorials: which mechanic the hand should point at.
  final Mechanic? mechanic;
}

/// The hint of each tutorial level; levels 6, 7 and 9 are plain practice.
abstract final class OnboardingPlan {
  static const int lastLevel = 10;

  static const Map<int, OnboardingStep> steps = {
    1: OnboardingStep(OnboardingCaption.tap, HandGesture.tap),
    2: OnboardingStep(OnboardingCaption.blocked, HandGesture.tap),
    3: OnboardingStep(OnboardingCaption.hearts, HandGesture.tap),
    4: OnboardingStep(OnboardingCaption.bend, HandGesture.tap),
    5: OnboardingStep(OnboardingCaption.peek, HandGesture.hold),
    8: OnboardingStep(OnboardingCaption.zoom, HandGesture.pinch),
    10: OnboardingStep(OnboardingCaption.knot, HandGesture.tap),
  };

  /// One caption per mechanic tutorial (`docs/03` §5): the level where a
  /// mechanic first appears.
  static const Map<Mechanic, OnboardingStep> mechanicSteps = {
    Mechanic.rotator: OnboardingStep(
      OnboardingCaption.rotator,
      HandGesture.tap,
      mechanic: Mechanic.rotator,
    ),
    Mechanic.gateKey: OnboardingStep(
      OnboardingCaption.gate,
      HandGesture.tap,
      mechanic: Mechanic.gateKey,
    ),
    Mechanic.frozen: OnboardingStep(
      OnboardingCaption.frozen,
      HandGesture.tap,
      mechanic: Mechanic.frozen,
    ),
    Mechanic.link: OnboardingStep(
      OnboardingCaption.link,
      HandGesture.tap,
      mechanic: Mechanic.link,
    ),
    Mechanic.portal: OnboardingStep(
      OnboardingCaption.portal,
      HandGesture.tap,
      mechanic: Mechanic.portal,
    ),
  };

  /// Whether a level is part of a tutorial (no interstitials there,
  /// `docs/08` §2): Chapter 1's first ten and the mechanic tutorials.
  static bool isTutorial(int chapter, int index) =>
      (chapter == 1 && index <= lastLevel) ||
      MechanicTutorials.at(chapter, index) != null;

  /// The step for a chapter level, or `null` outside the tutorials. Only levels
  /// that have never been cleared get a hint: Chapter 1's first ten, and the
  /// level where each mechanic is introduced.
  static OnboardingStep? stepFor({
    required int chapter,
    required int index,
    required bool cleared,
    bool daily = false,
  }) {
    if (daily || cleared) return null;
    final mechanic = MechanicTutorials.at(chapter, index);
    if (mechanic != null) return mechanicSteps[mechanic];
    if (chapter != 1 || index > lastLevel) return null;
    return steps[index];
  }
}
