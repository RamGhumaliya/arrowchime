import 'dart:async';

import 'package:flutter/services.dart';

/// Haptic hooks of the component library. The real `HapticsService`
/// (`docs/05` §3) replaces these in Phase 5; until then components call the
/// platform directly, and tests swap [selection] / [tick] for recorders.
abstract final class TBHaptics {
  /// Button press, toggle flip.
  static void Function() selection = _selection;

  /// Slider tick (every 10%).
  static void Function() tick = _tick;

  static void _selection() =>
      unawaited(HapticFeedback.selectionClick().onError((_, _) {}));

  static void _tick() =>
      unawaited(HapticFeedback.lightImpact().onError((_, _) {}));
}
