import 'package:arrowchime/core/meta/date_key.dart';
import 'package:arrowchime/core/save/save_data.dart';

/// The daily streak (`docs/03` §7): play at least one level per local day.
/// A missed day is covered by a **Streak Freeze** if one is in stock, else the
/// streak restarts. One free freeze arrives each ISO week (at most
/// [maxFreezes] in stock); more can be bought (`docs/08`, 200 coins).
abstract final class Streak {
  static const int maxFreezes = 2;

  /// Visual tiers of the flame (3 / 7 / 30 / 100 days): 0-4.
  static int tierOf(int count) => count >= 100
      ? 4
      : count >= 30
      ? 3
      : count >= 7
      ? 2
      : count >= 3
      ? 1
      : 0;

  /// Grants this week's free freeze if it has not been granted yet.
  static StreakState refreshFreezes(StreakState s, String today) {
    final week = DateKey.isoWeek(today);
    if (s.freezeWeek == week) return s;
    return s.copyWith(
      freezeWeek: week,
      freezes: s.freezes >= maxFreezes ? s.freezes : s.freezes + 1,
    );
  }

  /// A level was played on local day [today].
  static StreakState play(StreakState before, String today) {
    final s = refreshFreezes(before, today);
    if (s.lastPlayed == today) return s;
    int count;
    var freezes = s.freezes;
    if (s.lastPlayed.isEmpty) {
      count = 1;
    } else {
      final gap = DateKey.daysBetween(s.lastPlayed, today);
      if (gap <= 0) {
        // Clock moved back: do not punish, do not reward.
        return s.copyWith(lastPlayed: today);
      }
      final missed = gap - 1;
      if (missed == 0) {
        count = s.count + 1;
      } else if (freezes >= missed) {
        freezes -= missed;
        count = s.count + 1;
      } else {
        count = 1;
      }
    }
    return s.copyWith(
      count: count,
      best: count > s.best ? count : s.best,
      lastPlayed: today,
      freezes: freezes,
    );
  }

  /// Whether the streak is still alive on [today] (shown on Home: a streak
  /// that already broke displays 0 until the next play).
  static int liveCount(StreakState s, String today) {
    if (s.lastPlayed.isEmpty) return 0;
    final missed = DateKey.daysBetween(s.lastPlayed, today) - 1;
    if (missed <= 0) return s.count;
    return s.freezes >= missed ? s.count : 0;
  }

  /// Adds one freeze (the price is Remote Config's): returns the new
  /// state, or `null` when the stock is full.
  static StreakState? addFreeze(StreakState s) {
    if (s.freezes >= maxFreezes) return null;
    return s.copyWith(freezes: s.freezes + 1);
  }
}
