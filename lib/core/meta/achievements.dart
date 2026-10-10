import 'package:arrowchime/core/save/save_data.dart';

/// One achievement (`docs/03` §7: about 30; `docs/08`: 50–500 coins).
///
/// [progress] reads the player's save; the achievement is unlocked when it
/// reaches [target]. Titles and descriptions live in the ARB files under
/// `ach_<id>` / `achDesc_<id>`.
class AchievementDef {
  const new(this.id, this.icon, this.target, this.coins, this.progress);

  final String id;

  /// Name of a `TBIconId` (core code does not import UI).
  final String icon;
  final int target;
  final int coins;
  final int Function(SaveData data) progress;
}

int _chapterCleared(SaveData d, int chapter) => d.stars.keys
    .where((k) => k.startsWith('ch${chapter}_l') && d.stars[k]! > 0)
    .length;

int _starTotal(SaveData d) => d.stars.values.fold(0, (a, b) => a + b);

abstract final class Achievements {
  static final List<AchievementDef> all = [
    AchievementDef('first_note', 'star', 1, 50, (d) => d.stats.levelsCleared),
    AchievementDef('levels_10', 'star', 10, 50, (d) => d.stats.levelsCleared),
    AchievementDef('levels_50', 'star', 50, 100, (d) => d.stats.levelsCleared),
    AchievementDef(
      'levels_100',
      'star',
      100,
      150,
      (d) => d.stats.levelsCleared,
    ),
    AchievementDef(
      'levels_200',
      'star',
      200,
      250,
      (d) => d.stats.levelsCleared,
    ),
    AchievementDef(
      'levels_300',
      'trophy',
      300,
      500,
      (d) => d.stats.levelsCleared,
    ),
    AchievementDef('untangler', 'key', 1000, 150, (d) => d.stats.arrowsFreed),
    AchievementDef('arrows_5000', 'key', 5000, 300, (d) => d.stats.arrowsFreed),
    AchievementDef('perfect_pitch', 'star', 10, 200, (d) => d.stats.perfectRun),
    AchievementDef('perfect_25', 'star', 25, 100, (d) => d.stats.perfectClears),
    AchievementDef(
      'perfect_100',
      'star',
      100,
      300,
      (d) => d.stats.perfectClears,
    ),
    AchievementDef('flow_3', 'flame', 3, 50, (d) => d.stats.bestFlow),
    AchievementDef('maestro', 'flame', 5, 150, (d) => d.stats.bestFlow),
    AchievementDef(
      'chapter_1',
      'trophy',
      60,
      200,
      (d) => _chapterCleared(d, 1),
    ),
    AchievementDef(
      'chapter_2',
      'trophy',
      60,
      200,
      (d) => _chapterCleared(d, 2),
    ),
    AchievementDef(
      'chapter_3',
      'trophy',
      60,
      200,
      (d) => _chapterCleared(d, 3),
    ),
    AchievementDef(
      'chapter_4',
      'trophy',
      60,
      200,
      (d) => _chapterCleared(d, 4),
    ),
    AchievementDef(
      'chapter_5',
      'trophy',
      60,
      300,
      (d) => _chapterCleared(d, 5),
    ),
    AchievementDef('streak_3', 'flame', 3, 50, (d) => d.streak.best),
    AchievementDef('streak_7', 'flame', 7, 100, (d) => d.streak.best),
    AchievementDef('streak_30', 'flame', 30, 300, (d) => d.streak.best),
    AchievementDef('streak_100', 'flame', 100, 500, (d) => d.streak.best),
    AchievementDef('daily_1', 'calendar', 1, 50, (d) => d.stats.dailiesPlayed),
    AchievementDef('daily_7', 'calendar', 7, 150, (d) => d.stats.dailiesPlayed),
    AchievementDef(
      'daily_30',
      'calendar',
      30,
      400,
      (d) => d.stats.dailiesPlayed,
    ),
    AchievementDef(
      'night_owl',
      'bell',
      1,
      100,
      (d) => (d.flags['nightOwl'] ?? false) ? 1 : 0,
    ),
    const AchievementDef('stars_100', 'star', 100, 100, _starTotal),
    const AchievementDef('stars_300', 'star', 300, 250, _starTotal),
    const AchievementDef('stars_600', 'star', 600, 500, _starTotal),
    AchievementDef(
      'quest_chest',
      'chest',
      1,
      50,
      (d) => (d.flags['questChestOpened'] ?? false) ? 1 : 0,
    ),
  ];

  static AchievementDef def(String id) => all.firstWhere((a) => a.id == id);

  /// Ids that are newly satisfied by [data] (not yet in its achievements).
  static List<String> newlyUnlocked(SaveData data) => [
    for (final a in all)
      if (!data.achievements.containsKey(a.id) && a.progress(data) >= a.target)
        a.id,
  ];
}
