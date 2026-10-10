import 'dart:async';

import 'package:arrowchime/core/audio/feedback_settings.dart';
import 'package:flutter/services.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'haptics_service.g.dart';

/// Haptic feedback of the juice table (`docs/03` §4), behind an interface so
/// tests can record it. Silently does nothing where unsupported.
abstract interface class HapticsService {
  /// Touch-down on an arrow, button press.
  void selection();

  /// A freed arrow, a star.
  void light();

  /// A blocked tap (called twice).
  void medium();

  /// Losing the level.
  void heavy();

  /// Winning: a short rising double tap.
  void success();
}

/// [HapticFeedback] on the real device; off when the player turns haptics off.
class PlatformHaptics implements HapticsService {
  new({required this._enabled});

  final bool Function() _enabled;

  void _run(Future<void> Function() call) {
    if (_enabled()) unawaited(call().onError((_, _) {}));
  }

  @override
  void selection() => _run(HapticFeedback.selectionClick);

  @override
  void light() => _run(HapticFeedback.lightImpact);

  @override
  void medium() => _run(HapticFeedback.mediumImpact);

  @override
  void heavy() => _run(HapticFeedback.heavyImpact);

  @override
  void success() {
    _run(HapticFeedback.lightImpact);
    Timer(
      const Duration(milliseconds: 90),
      () => _run(HapticFeedback.mediumImpact),
    );
  }
}

@Riverpod(keepAlive: true)
HapticsService haptics(Ref ref) => PlatformHaptics(
  enabled: () => ref.read(feedbackSettingsControllerProvider).hapticsOn,
);
