import 'package:arrowchime/core/save/save_data.dart';

/// What a planned notification says. The words live in the ARB files; the
/// planner only decides *which* and *when*.
enum NoteKind {
  /// "You cleared N levels yesterday — your best day yet."
  appreciation,

  /// "Your N-day streak is safe until midnight."
  streak,

  /// "Today's Daily Chime is ready."
  daily,

  /// 3 days away: gentle, no pressure.
  comeback3,

  /// 7 days away: the last one for a while.
  comeback7,
}

/// One notification to schedule.
class PlannedNote {
  const new({
    required this.id,
    required this.kind,
    required this.at,
    this.number = 0,
  });

  /// Stable per kind, so re-planning replaces instead of stacking.
  final int id;
  final NoteKind kind;

  /// Local time it should arrive.
  final DateTime at;

  /// The number the words mention (streak days, levels yesterday).
  final int number;

  @override
  String toString() => 'PlannedNote($kind at $at, $number)';
}

/// The Chime Companion's rules (`docs/11` §5), as a pure function of the save
/// and the clock so every rule is unit-tested without a phone:
///
/// * only after the player opted in, never in "off", never after 3 ignored
///   notifications in a row;
/// * at most one a day, never between 22:00 and 09:00, at the hour the player
///   usually plays;
/// * appreciation, never guilt: comeback notes stop after day 7;
/// * "fewer" keeps only the streak guardian and the day-7 note.
abstract final class CompanionPlanner {
  /// Notifications ignored in a row before the Companion goes quiet.
  static const int maxIgnored = 3;

  /// Earliest and latest hour a note may arrive (quiet hours 22:00–09:00).
  static const int earliestHour = 9;
  static const int latestHour = 21;

  /// A streak this long is worth guarding.
  static const int minGuardedStreak = 3;

  /// How many days ahead the first comeback notes fall.
  static const int comebackShortDays = 3;
  static const int comebackLongDays = 7;

  /// Plans the notifications to schedule when the app goes to the background.
  ///
  /// [streak] is the live streak count, [playedToday] whether a level or the
  /// Daily was finished today.
  static List<PlannedNote> plan({
    required CompanionState state,
    required DateTime now,
    required int streak,
    required bool playedToday,
    required bool dailyDone,
    required bool firstSession,
  }) {
    if (firstSession) return const [];
    if (state.optedInAt == 0 || state.mode == 'off') return const [];
    if (state.ignoredInRow >= maxIgnored) return const [];

    final fewer = state.mode == 'fewer';
    final notes = <PlannedNote>[];

    DateTime at(int daysAhead) {
      final hour = state.usualHour.clamp(earliestHour, latestHour);
      // A small deterministic spread so it is not always on the dot.
      final minute = (now.day * 7 + daysAhead * 11) % 30;
      final day = DateTime(now.year, now.month, now.day + daysAhead);
      return DateTime(day.year, day.month, day.day, hour, minute);
    }

    // Tomorrow: the one note for the next day, by priority.
    final tomorrow = at(1);
    if (streak >= minGuardedStreak && playedToday) {
      // Tomorrow the streak needs a play: the guardian reminds them.
      notes.add(
        PlannedNote(id: 2, kind: NoteKind.streak, at: tomorrow, number: streak),
      );
    } else if (!fewer && state.yesterdayRecord > 0) {
      notes.add(
        PlannedNote(
          id: 1,
          kind: NoteKind.appreciation,
          at: tomorrow,
          number: state.yesterdayRecord,
        ),
      );
    } else if (!fewer) {
      notes.add(PlannedNote(id: 3, kind: NoteKind.daily, at: tomorrow));
    }

    // Away for days: two soft notes, then nothing until they return.
    if (!fewer) {
      notes.add(
        PlannedNote(id: 4, kind: NoteKind.comeback3, at: at(comebackShortDays)),
      );
    }
    notes.add(
      PlannedNote(id: 5, kind: NoteKind.comeback7, at: at(comebackLongDays)),
    );

    // Nothing already in the past or inside quiet hours; one per day.
    final seenDays = <String>{};
    return [
      for (final n in notes)
        if (n.at.isAfter(now) &&
            n.at.hour >= earliestHour &&
            n.at.hour <= latestHour &&
            seenDays.add('${n.at.year}-${n.at.month}-${n.at.day}'))
          n,
    ];
  }

  /// The player's usual hour after a session that ended at [hour]: a slow
  /// moving average, so one late night does not move it far.
  static int learnHour(int usual, int hour) =>
      ((usual * 4 + hour) / 5).round().clamp(0, 23);
}
