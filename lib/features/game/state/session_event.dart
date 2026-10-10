import 'package:arrowchime/core/level/engine/events.dart';

/// What the presentation layer has to animate (Flame only replays these).
sealed class SessionEvent {
  const new();
}

/// The engine answered a tap or an undo.
final class EnginePlayed extends SessionEvent {
  const new(this.events);

  final List<GameEvent> events;
}

/// The level started over (Retry / Replay).
final class BoardReset extends SessionEvent {
  const new();
}

/// A lost level continues with an extra heart.
final class HeartGranted extends SessionEvent {
  const new();
}

/// A hint highlights this arrow.
final class HintGiven extends SessionEvent {
  const new(this.arrowId);

  final int arrowId;
}
