import 'package:arrowchime/app/theme/tokens.dart';
import 'package:flutter/painting.dart';

/// Three-tone shading (`docs/10` §2): every solid object has a `face`, a
/// `bevel-light` (+18% lightness, top/left rim) and a `bevel-dark` / lip
/// (−22% lightness, bottom/right rim). All colours are derived from palette
/// tokens; nothing is hand-tuned per widget.
abstract final class TBShade {
  /// +18% lightness (top/left rim).
  static Color bevelLight(Color c) =>
      _shiftLightness(c, TBLight.bevelLightDelta);

  /// −22% lightness (bottom/right rim and lips without a dedicated token).
  static Color bevelDark(Color c) => _shiftLightness(c, TBLight.bevelDarkDelta);

  /// Lightens by an arbitrary amount (e.g. the +8% top of a ceramic face).
  static Color lighten(Color c, double delta) => _shiftLightness(c, delta);

  /// Removes [amount] (0–1) of the saturation (disabled state: 0.8).
  static Color desaturate(Color c, double amount) {
    final hsl = HSLColor.fromColor(c);
    return hsl.withSaturation(hsl.saturation * (1 - amount)).toColor();
  }

  /// White at [opacity] (highlights / speculars).
  static Color white(double opacity) =>
      TBColors.cream100.withValues(alpha: opacity);

  /// `ink900` at [opacity] (shadows, grooves).
  static Color ink(double opacity) =>
      TBColors.ink900.withValues(alpha: opacity);

  static Color _shiftLightness(Color c, double delta) {
    final hsl = HSLColor.fromColor(c);
    return hsl.withLightness((hsl.lightness + delta).clamp(0.0, 1.0)).toColor();
  }
}

/// A deterministic, platform-independent pseudo-random sequence for grain
/// and noise (never `dart:math` `Random`: goldens must not change per run).
class TBNoise {
  new(int seed) : _state = seed & 0xFFFFFFFF;

  int _state;

  /// Next value in `[0, 1)` (xorshift32).
  double next() {
    var x = _state == 0 ? 0x9E3779B9 : _state;
    x ^= (x << 13) & 0xFFFFFFFF;
    x ^= x >> 17;
    x ^= (x << 5) & 0xFFFFFFFF;
    _state = x & 0xFFFFFFFF;
    return _state / 4294967296;
  }
}
