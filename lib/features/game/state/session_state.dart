// Freezed redirecting factories keep the type name; the `new` shorthand the
// lint suggests is not supported by freezed 4.
// ignore_for_file: unnecessary_type_name_in_constructor
import 'package:arrowchime/core/economy/rewards.dart';
import 'package:arrowchime/core/level/engine/game_engine.dart';
import 'package:arrowchime/core/level/models/level.dart';
import 'package:arrowchime/core/meta/progression.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'session_state.freezed.dart';

/// Everything the HUD and the sheets show about the running level.
@Freezed(makeCollectionsUnmodifiable: false)
abstract class SessionState with _$SessionState {
  const factory SessionState({
    required Level level,
    required GameStatus status,
    required int hearts,
    required int initialHearts,
    required int remaining,
    required int total,
    required int stars,
    required int freeUndosLeft,
    required bool canUndo,
    required int freeHintsLeft,
    required int flowMultiplier,
    required double flowFill,
    required int bestFlow,
    required int taps,
    required int blockedTaps,
    int? hintArrowId,

    /// Set once the level is won (already paid into the wallet).
    LevelReward? reward,

    /// What the win changed in the save (level-ups, achievements, first
    /// clear); `null` until won.
    WinOutcome? outcome,
  }) = _SessionState;

  const SessionState._();

  bool get isPlaying => status == GameStatus.playing;
}
