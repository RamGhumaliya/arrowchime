/// What the hand cursor shows.
enum HandGesture { tap, hold, pinch }

/// Which caption to show (resolved to ARB text by the overlay).
enum OnboardingCaption { tap, blocked, hearts, bend, peek, zoom, knot }

/// One onboarding hint of Chapter 1 (`docs/03` §6): at most one new idea per
/// level, a caption of at most six words and a hand showing the gesture.
class OnboardingStep {
  const new(this.caption, this.gesture);

  final OnboardingCaption caption;
  final HandGesture gesture;
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

  /// The step for a chapter level, or `null` outside the tutorial. Only levels
  /// of chapter 1 that have never been cleared get a hint.
  static OnboardingStep? stepFor({
    required int chapter,
    required int index,
    required bool cleared,
    bool daily = false,
  }) {
    if (daily || chapter != 1 || cleared || index > lastLevel) return null;
    return steps[index];
  }
}
