import 'package:arrowchime/core/economy/rewards.dart';
import 'package:arrowchime/core/level/generator/chapter_plan.dart';
import 'package:arrowchime/core/meta/achievements.dart';
import 'package:arrowchime/core/meta/date_key.dart';
import 'package:arrowchime/core/meta/player_level.dart';
import 'package:arrowchime/core/meta/quests.dart';
import 'package:arrowchime/core/meta/streak.dart';
import 'package:arrowchime/core/save/save_data.dart';

/// What happened in a cleared level.
class WinReport {
  const new({
    required this.chapter,
    required this.index,
    required this.stars,
    required this.bestFlow,
    required this.arrowsFreed,
    required this.blockedTaps,
    required this.seconds,
  });

  final int chapter;
  final int index;
  final int stars;

  /// Highest Flow multiplier reached (1 = none).
  final int bestFlow;
  final int arrowsFreed;
  final int blockedTaps;
  final int seconds;
}

/// What a win changed, for the win sheet and the toasts.
class WinOutcome {
  const new({
    required this.data,
    required this.coins,
    required this.xp,
    required this.firstClear,
    required this.improved,
    required this.levelUps,
    required this.achievements,
  });

  /// The save after the win.
  final SaveData data;

  /// Coins from the level itself (first clear, or the extra stars).
  final int coins;
  final int xp;
  final bool firstClear;
  final bool improved;

  /// Player levels gained (each also paid [PlayerLevel.levelUpCoins]).
  final int levelUps;

  /// Achievements unlocked by this win (each also paid its coins).
  final List<String> achievements;
}

/// The rules of progress (`docs/03` §6–7, `docs/08` §1) as pure functions of
/// [SaveData], so they are tested without any UI or storage.
///
/// Replays do not farm coins: a level pays in full the first time, and later
/// only for the extra stars of a better result.
abstract final class Progression {
  static const int chapters = 5;
  static const int levelsPerChapter = ChapterPlan.levelsPerChapter;

  /// Daily Knot coins: 50, +25 per streak tier (`docs/08`).
  static const int dailyBase = 50;
  static const int dailyPerTier = 25;

  // --- reading progress -------------------------------------------------------

  static String levelId(int chapter, int index) =>
      ChapterPlan.idFor(chapter, index);

  /// The next level to play in [chapter] (1-60; 61 when finished).
  static int nextIndex(SaveData d, int chapter) =>
      d.currentLevel['$chapter'] ?? 1;

  /// Chapter 1 is open; chapter N opens when chapter N-1 is finished.
  static bool isChapterUnlocked(SaveData d, int chapter) =>
      chapter <= 1 || nextIndex(d, chapter - 1) > levelsPerChapter;

  /// A level can be played if its chapter is open and every level before it
  /// in the chapter is cleared (replays of cleared levels are always allowed).
  static bool isLevelUnlocked(SaveData d, int chapter, int index) =>
      isChapterUnlocked(d, chapter) && index <= nextIndex(d, chapter);

  /// Levels of [chapter] cleared at least once.
  static int cleared(SaveData d, int chapter) => d.stars.keys
      .where((k) => k.startsWith('ch${chapter}_l') && d.stars[k]! > 0)
      .length;

  /// Restoration of the chapter scene, 0-1 (60 fragments).
  static double restoration(SaveData d, int chapter) =>
      cleared(d, chapter) / levelsPerChapter;

  /// Stars collected in [chapter] (max 180).
  static int chapterStars(SaveData d, int chapter) => d.stars.entries
      .where((e) => e.key.startsWith('ch${chapter}_l'))
      .fold(0, (a, e) => a + e.value);

  static int totalStars(SaveData d) => d.stars.values.fold(0, (a, b) => a + b);

  /// Where Home's PLAY button goes: the first chapter with levels left.
  static (int chapter, int index) playTarget(SaveData d) {
    // The track never ends: the frontier is the first stage not yet finished.
    var c = 1;
    while (nextIndex(d, c) > levelsPerChapter) {
      c++;
    }
    return (c, nextIndex(d, c));
  }

  // --- recording a win ----------------------------------------------------------

  /// Applies a cleared level on local day [today] (`yyyy-MM-dd`).
  static WinOutcome recordWin(
    SaveData before,
    WinReport r, {
    required String today,
  }) {
    final id = levelId(r.chapter, r.index);
    final prev = before.starsOf(id);
    final first = prev == 0;
    final improved = !first && r.stars > prev;

    // Coins and XP: everything on a first clear, the extra stars afterwards.
    var coins = 0;
    var xp = 0;
    if (first) {
      final reward = Rewards.forWin(
        stars: r.stars,
        index: r.index,
        flowMultiplier: r.bestFlow,
      );
      coins = reward.coins;
      xp = reward.xp;
    } else if (improved) {
      final now = Rewards.forWin(stars: r.stars, index: r.index);
      final then = Rewards.forWin(stars: prev, index: r.index);
      coins = now.coins - then.coins;
      xp = now.xp - then.xp;
    }

    final stats = before.stats;
    final perfect = r.stars == 3;
    final newStats = stats.copyWith(
      arrowsFreed: stats.arrowsFreed + r.arrowsFreed,
      levelsCleared: stats.levelsCleared + (first ? 1 : 0),
      perfectClears: stats.perfectClears + (perfect ? 1 : 0),
      perfectRun: perfect ? stats.perfectRun + 1 : 0,
      bestFlow: r.bestFlow > stats.bestFlow ? r.bestFlow : stats.bestFlow,
      blockedTaps: stats.blockedTaps + r.blockedTaps,
      playSeconds: stats.playSeconds + r.seconds,
    );

    var quests = Quests.ensureToday(before.quests, today);
    quests = Quests.advance(quests, QuestMetric.levelsCleared, 1);
    quests = Quests.advance(quests, QuestMetric.arrowsFreed, r.arrowsFreed);
    if (r.bestFlow >= 3) {
      quests = Quests.advance(quests, QuestMetric.flowThree, 1);
    }
    if (perfect) quests = Quests.advance(quests, QuestMetric.perfectClears, 1);

    final data = before.copyWith(
      stars: {...before.stars, id: r.stars > prev ? r.stars : prev},
      currentLevel: {
        ...before.currentLevel,
        '${r.chapter}': nextIndex(before, r.chapter) > r.index
            ? nextIndex(before, r.chapter)
            : r.index + 1,
      },
      coins: before.coins + coins,
      xp: before.xp + xp,
      stats: newStats,
      streak: Streak.play(before.streak, today),
      quests: quests,
    );

    final (data2, levelUps, unlocked) = settle(data, before.xp, today);
    return WinOutcome(
      data: data2,
      coins: coins,
      xp: xp,
      firstClear: first,
      improved: improved,
      levelUps: levelUps,
      achievements: unlocked,
    );
  }

  /// Pays level-up coins and unlocks achievements for [data] (call after any
  /// change to stats, stars, streak or XP). [xpBefore] is the XP before it.
  static (SaveData, int, List<String>) settle(
    SaveData data,
    int xpBefore,
    String today,
  ) {
    final levelUps = PlayerLevel.of(data.xp) - PlayerLevel.of(xpBefore);
    var out = data.copyWith(
      coins: data.coins + levelUps * PlayerLevel.levelUpCoins,
    );
    final unlocked = <String>[];
    // Unlocking can pay coins, never more stats, so one pass is enough.
    for (final id in Achievements.newlyUnlocked(out)) {
      unlocked.add(id);
      out = out.copyWith(
        achievements: {...out.achievements, id: today},
        coins: out.coins + Achievements.def(id).coins,
      );
    }
    return (out, levelUps, unlocked);
  }

  // --- the Daily Knot ---------------------------------------------------------

  /// Records a finished Daily of UTC [dateKey]; [today] is the local date and
  /// [localHour] the local hour of day (for "Night Owl").
  static WinOutcome recordDaily(
    SaveData before,
    String dateKey,
    DailyResult result, {
    required String today,
    required int localHour,
    int dailyBase = Progression.dailyBase,
    int dailyPerTier = Progression.dailyPerTier,
  }) {
    final firstTime = !before.daily.containsKey(dateKey);
    final tier = Streak.tierOf(Streak.play(before.streak, today).count);
    final coins = firstTime && !result.replayed
        ? dailyBase + dailyPerTier * tier
        : 0;
    final xp = firstTime ? 10 * result.stars : 0;

    var quests = Quests.ensureToday(before.quests, today);
    quests = Quests.advance(quests, QuestMetric.daily, 1);
    if (result.bestFlow >= 3) {
      quests = Quests.advance(quests, QuestMetric.flowThree, 1);
    }

    var data = before.copyWith(
      daily: {
        ...before.daily,
        dateKey: firstTime ? result : _better(before.daily[dateKey]!, result),
      },
      coins: before.coins + coins,
      xp: before.xp + xp,
      stats: before.stats.copyWith(
        dailiesPlayed: before.stats.dailiesPlayed + (firstTime ? 1 : 0),
        bestFlow: result.bestFlow > before.stats.bestFlow
            ? result.bestFlow
            : before.stats.bestFlow,
        playSeconds: before.stats.playSeconds + result.seconds,
      ),
      streak: Streak.play(before.streak, today),
      quests: quests,
      flags: localHour < 5 && !result.replayed
          ? {...before.flags, 'nightOwl': true}
          : before.flags,
    );
    final (settled, levelUps, unlocked) = settle(data, before.xp, today);
    data = settled;
    return WinOutcome(
      data: data,
      coins: coins,
      xp: xp,
      firstClear: firstTime,
      improved: false,
      levelUps: levelUps,
      achievements: unlocked,
    );
  }

  static DailyResult _better(DailyResult a, DailyResult b) =>
      b.stars > a.stars ? b : a;

  /// Past 30 UTC days ending at [todayUtc] (oldest first), with each day's
  /// state for the calendar.
  static List<CalendarDay> calendar(
    SaveData d,
    String todayUtc, {
    int days = 30,
  }) => [
    for (var i = days - 1; i >= 0; i--)
      () {
        final key = DateKey.addDays(todayUtc, -i);
        return CalendarDay(
          key: key,
          played: d.daily.containsKey(key),
          isToday: i == 0,
        );
      }(),
  ];
}

/// One day of the Daily Knot calendar.
class CalendarDay {
  const new({required this.key, required this.played, required this.isToday});

  final String key;
  final bool played;
  final bool isToday;

  /// A missed day can be replayed for coins.
  bool get missed => !played && !isToday;
}
