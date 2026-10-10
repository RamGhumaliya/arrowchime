import 'package:arrowchime/app/theme/tokens.dart';

/// The Flow streak (`docs/03` §4): consecutive correct taps, each within 1.5 s
/// of the previous one with no error in between. Streaks of 3 / 5 / 7 / 9 give
/// the ×2 / ×3 / ×4 / ×5 multipliers. A blocked tap or a pause of more than
/// 1.5 s resets it.
///
/// Pure and clock-injected so tests need no real time.
class FlowTracker {
  new({required this.now});

  /// Monotonic time source.
  final Duration Function() now;

  /// How long the streak survives without a tap.
  static const Duration window = TBGesture.flowWindow;

  /// Taps needed for ×2; every 2 more taps add one more multiplier.
  static const int firstTier = 3;
  static const int tierStep = 2;
  static const int maxMultiplier = 5;

  int _streak = 0;
  Duration? _lastTap;
  int _bestMultiplier = 1;

  /// Correct taps in the current streak (0 once it expired).
  int get streak {
    _expireIfStale();
    return _streak;
  }

  /// Current multiplier, 1 (none) to 5.
  int get multiplier => _multiplierFor(streak);

  /// Highest multiplier reached since the last [reset].
  int get bestMultiplier => _bestMultiplier;

  /// 0–1, how far through the current tier the streak is (1 at ×5).
  double get fill {
    final s = streak;
    if (s >= firstTier + tierStep * (maxMultiplier - 2)) return 1;
    if (s < firstTier) return s / firstTier;
    return ((s - firstTier) % tierStep + 1) / tierStep;
  }

  /// A correct tap.
  void onFreed() {
    _expireIfStale();
    _streak++;
    _lastTap = now();
    final m = _multiplierFor(_streak);
    if (m > _bestMultiplier) _bestMultiplier = m;
  }

  /// A blocked tap: the streak is lost.
  void onBlocked() {
    _streak = 0;
    _lastTap = null;
  }

  /// Forget everything (new attempt at the level).
  void reset() {
    onBlocked();
    _bestMultiplier = 1;
  }

  /// Whether the streak is alive right now (used to schedule UI updates).
  bool get isActive => streak > 0;

  void _expireIfStale() {
    final last = _lastTap;
    if (last != null && now() - last > window) {
      _streak = 0;
      _lastTap = null;
    }
  }

  static int _multiplierFor(int streak) {
    if (streak < firstTier) return 1;
    final m = 2 + (streak - firstTier) ~/ tierStep;
    return m > maxMultiplier ? maxMultiplier : m;
  }
}
