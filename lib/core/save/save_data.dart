// Freezed redirecting factories keep the type name; the `new` shorthand the
// lint suggests is not supported by freezed 4.
// ignore_for_file: unnecessary_type_name_in_constructor
import 'package:freezed_annotation/freezed_annotation.dart';

part 'save_data.freezed.dart';
part 'save_data.g.dart';

/// Version written by this build (`docs/05` §6). Older saves are upgraded by
/// `SaveMigrations` before parsing.
const int currentSaveSchema = 2;

/// Streak state (`docs/03` §7). Dates are local `yyyy-MM-dd` strings.
@freezed
abstract class StreakState with _$StreakState {
  const factory StreakState({
    /// Days in a row with at least one level played.
    @Default(0) int count,
    @Default(0) int best,

    /// Local date of the last day played, or `''`.
    @Default('') String lastPlayed,

    /// Streak freezes in stock (one free per week, more for coins).
    @Default(0) int freezes,

    /// ISO week (`2026-W41`) the free freeze was last granted.
    @Default('') String freezeWeek,
  }) = _StreakState;

  factory StreakState.fromJson(Map<String, dynamic> json) =>
      _$StreakStateFromJson(json);
}

/// Result of a played Daily Knot.
@freezed
abstract class DailyResult with _$DailyResult {
  const factory DailyResult({
    @Default(0) int stars,
    @Default(0) int heartsLeft,
    @Default(1) int bestFlow,
    @Default(0) int seconds,

    /// Played as a replay of a missed day (paid for).
    @Default(false) bool replayed,
  }) = _DailyResult;

  factory DailyResult.fromJson(Map<String, dynamic> json) =>
      _$DailyResultFromJson(json);
}

/// One of today's quests.
@freezed
abstract class QuestProgress with _$QuestProgress {
  const factory QuestProgress({
    required String id,
    @Default(0) int progress,
    @Default(false) bool claimed,
  }) = _QuestProgress;

  factory QuestProgress.fromJson(Map<String, dynamic> json) =>
      _$QuestProgressFromJson(json);
}

/// The three quests of one day and their chest.
@freezed
abstract class QuestState with _$QuestState {
  const factory QuestState({
    /// Local date these quests belong to.
    @Default('') String date,
    @Default(<QuestProgress>[]) List<QuestProgress> items,
    @Default(false) bool chestOpened,
  }) = _QuestState;

  factory QuestState.fromJson(Map<String, dynamic> json) =>
      _$QuestStateFromJson(json);
}

/// Lifetime counters (Achievements & Stats screen).
@freezed
abstract class PlayStats with _$PlayStats {
  const factory PlayStats({
    @Default(0) int arrowsFreed,
    @Default(0) int levelsCleared,
    @Default(0) int perfectClears,

    /// Consecutive ★★★ clears (resets on a worse one).
    @Default(0) int perfectRun,
    @Default(1) int bestFlow,
    @Default(0) int blockedTaps,
    @Default(0) int playSeconds,
    @Default(0) int dailiesPlayed,
    @Default(0) int hintsUsed,
  }) = _PlayStats;

  factory PlayStats.fromJson(Map<String, dynamic> json) =>
      _$PlayStatsFromJson(json);
}

/// Preferences (`docs/03` §8).
@freezed
abstract class SaveSettings with _$SaveSettings {
  const factory SaveSettings({
    @Default(true) bool musicOn,
    @Default(true) bool soundOn,
    @Default(true) bool hapticsOn,
    @Default(1.0) double musicVolume,
    @Default(1.0) double soundVolume,
    @Default(false) bool leftHanded,
    @Default(false) bool relaxed,
    @Default(false) bool gridOn,

    /// `system` follows the OS, `on` always reduces motion.
    @Default('system') String reduceMotion,

    /// `off`, `deutan` (also protan) or `tritan`.
    @Default('off') String colorBlind,
  }) = _SaveSettings;

  factory SaveSettings.fromJson(Map<String, dynamic> json) =>
      _$SaveSettingsFromJson(json);
}

/// Everything that survives closing the app (`docs/05` §6).
@freezed
abstract class SaveData with _$SaveData {
  const factory SaveData({
    @Default(currentSaveSchema) int schemaVersion,

    /// Monotonic write counter: of two storage slots, the higher valid one
    /// wins after a crash mid-write.
    @Default(0) int seq,

    /// Best stars per level id (`ch1_l007`).
    @Default(<String, int>{}) Map<String, int> stars,

    /// Next level to play per chapter (1-60; 61 = chapter finished).
    @Default(<String, int>{'1': 1}) Map<String, int> currentLevel,
    @Default(0) int coins,
    @Default(0) int xp,
    @Default(<String>[]) List<String> inventory,
    @Default(<String, String>{}) Map<String, String> equipped,
    @Default(StreakState()) StreakState streak,

    /// Daily Knot results by UTC date (`2026-10-10`).
    @Default(<String, DailyResult>{}) Map<String, DailyResult> daily,

    /// Achievement id → local date unlocked.
    @Default(<String, String>{}) Map<String, String> achievements,
    @Default(QuestState()) QuestState quests,
    @Default(SaveSettings()) SaveSettings settings,
    @Default(PlayStats()) PlayStats stats,

    /// Free-form flags (`adsRemoved`, `onboardingDone`, ...).
    @Default(<String, bool>{}) Map<String, bool> flags,
    @Default('') String updatedAt,
  }) = _SaveData;

  const SaveData._();

  factory SaveData.fromJson(Map<String, dynamic> json) =>
      _$SaveDataFromJson(json);

  /// A brand-new player.
  factory SaveData.initial() => const SaveData();

  /// Best stars on [levelId] (0 = never cleared).
  int starsOf(String levelId) => stars[levelId] ?? 0;
}
