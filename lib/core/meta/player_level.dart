/// XP → player level (`docs/03` §7: a level-up every ~8 levels early, slower
/// later). Level 1 needs 240 XP to reach level 2 (about 8 levels at ~30 XP),
/// and each next step asks 30 XP more.
abstract final class PlayerLevel {
  static const int baseXp = 240;
  static const int stepXp = 30;

  /// Coins for each level-up (`docs/08`).
  static const int levelUpCoins = 100;

  /// A cosmetic is unlocked every this many levels (Phase 8 hands it out).
  static const int cosmeticEvery = 5;

  /// XP needed to go from [level] to the next one.
  static int needed(int level) => baseXp + stepXp * (level - 1);

  /// Level reached with [xp] total XP (1-based).
  static int of(int xp) {
    var level = 1;
    var left = xp;
    while (left >= needed(level)) {
      left -= needed(level);
      level++;
    }
    return level;
  }

  /// XP gathered inside the current level, and what that level needs.
  static (int into, int needed) progress(int xp) {
    var level = 1;
    var left = xp;
    while (left >= needed(level)) {
      left -= needed(level);
      level++;
    }
    return (left, needed(level));
  }
}
