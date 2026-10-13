import 'dart:async';
import 'dart:ui' show PlatformDispatcher;

import 'package:arrowchime/core/companion/companion_planner.dart';
import 'package:arrowchime/core/companion/notification_service.dart';
import 'package:arrowchime/core/meta/date_key.dart';
import 'package:arrowchime/core/meta/streak.dart';
import 'package:arrowchime/core/save/save_controller.dart';
import 'package:arrowchime/core/save/save_data.dart';
import 'package:arrowchime/l10n/gen/app_localizations.dart';
import 'package:flutter/widgets.dart' show Locale;
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'companion_controller.g.dart';

/// Joins the pure [CompanionPlanner], the saved [CompanionState] and the
/// [NotificationService]: the one place that asks for permission, learns the
/// player's habits and schedules the next notes.
class CompanionController {
  new(this._ref);

  final Ref _ref;

  /// The pre-prompt is shown from this many cleared levels, and again after
  /// [askRetryDays] if the player said "maybe later".
  static const int askAfterLevels = 5;
  static const int askRetryDays = 7;

  NotificationService get _service => _ref.read(notificationServiceProvider);
  SaveController get _save => _ref.read(saveControllerProvider.notifier);
  SaveData get _data => _ref.read(saveControllerProvider);
  DateTime get _now => _ref.read(clockProvider)();

  void _set(CompanionState Function(CompanionState s) f) =>
      _save.update((d) => d.copyWith(companion: f(d.companion)));

  /// Whether the friendly pre-prompt should be shown now (at most once per
  /// visit; never for someone who already answered yes or no).
  bool shouldAsk() {
    final c = _data.companion;
    if (c.optedInAt > 0) return false;
    if (c.askState == 'declined') return false;
    if (_data.stats.levelsCleared < askAfterLevels) return false;
    if (c.askState == 'asked') {
      return _now.millisecondsSinceEpoch >= c.askRetryAt;
    }
    return true;
  }

  /// "Yes, please": the system permission dialog follows. Returns whether
  /// notifications are now allowed.
  Future<bool> accept() async {
    final granted = await _service.requestPermission();
    final nowMs = _now.millisecondsSinceEpoch;
    _set(
      (s) => granted
          ? s.copyWith(optedInAt: nowMs, askState: 'asked', ignoredInRow: 0)
          : s.copyWith(askState: 'declined'),
    );
    if (granted) await onBackground();
    return granted;
  }

  /// "Maybe later": ask again in a week, once.
  void later() {
    final retry = _now.add(const Duration(days: askRetryDays));
    _set((s) {
      if (s.askState == 'asked') return s.copyWith(askState: 'declined');
      return s.copyWith(
        askState: 'asked',
        askRetryAt: retry.millisecondsSinceEpoch,
      );
    });
  }

  /// Settings: `normal`, `fewer` or `off`.
  Future<void> setMode(String mode) async {
    _set((s) => s.copyWith(mode: mode));
    if (mode == 'off') {
      await _service.cancelAll();
    } else {
      await onBackground();
    }
  }

  /// The app was opened. [fromNote] is whether a notification opened it: that
  /// is the proof the last batch was welcome, so the ignored count resets.
  /// Otherwise a batch that had come due and was not tapped counts as ignored.
  void onSessionStart({required bool fromNote}) {
    final nowMs = _now.millisecondsSinceEpoch;
    _set((s) {
      if (fromNote) return s.copyWith(ignoredInRow: 0);
      final due = s.lastPlannedCount > 0 && s.lastPlannedAt > 0;
      final waited =
          nowMs - s.lastPlannedAt > const Duration(hours: 20).inMilliseconds;
      return due && waited
          ? s.copyWith(ignoredInRow: s.ignoredInRow + 1, lastPlannedCount: 0)
          : s;
    });
  }

  /// A level was cleared: counts the day, notes a record, and learns the hour.
  void onLevelCleared() {
    final now = _now;
    final today = DateKey.of(now);
    _set((s) {
      var count = s.todayLevels;
      var date = s.todayDate;
      var yesterday = s.yesterdayRecord;
      var best = s.bestDayLevels;
      if (date != today) {
        // A new day: was the day that just ended the best so far?
        yesterday = date.isNotEmpty && count > best && count >= 3 ? count : 0;
        if (count > best) best = count;
        date = today;
        count = 0;
      }
      return s.copyWith(
        todayDate: date,
        todayLevels: count + 1,
        bestDayLevels: best,
        yesterdayRecord: yesterday,
        usualHour: CompanionPlanner.learnHour(s.usualHour, now.hour),
      );
    });
  }

  /// The app goes to the background: plan and schedule the next notes.
  Future<void> onBackground() async {
    final data = _data;
    final c = data.companion;
    final now = _now;
    final today = DateKey.of(now);
    final notes = CompanionPlanner.plan(
      state: c,
      now: now,
      streak: Streak.liveCount(data.streak, today),
      playedToday: data.streak.lastPlayed == today,
      dailyDone: data.daily.containsKey(DateKey.utc(now)),
      firstSession: !(data.flags['secondSession'] ?? false),
    );
    if (notes.isEmpty) {
      await _service.cancelAll();
    } else {
      final l10n = _l10n();
      await _service.scheduleAll([
        for (final n in notes)
          ScheduledText(
            id: n.id,
            at: n.at,
            title: _title(l10n, n),
            body: _body(l10n, n),
          ),
      ]);
    }
    _set(
      (s) => s.copyWith(
        lastPlannedAt: now.millisecondsSinceEpoch,
        lastPlannedCount: notes.length,
      ),
    );
  }

  AppLocalizations _l10n() {
    try {
      return lookupAppLocalizations(PlatformDispatcher.instance.locale);
    } on Object {
      return lookupAppLocalizations(const Locale('en'));
    }
  }

  static String _title(AppLocalizations l, PlannedNote n) => switch (n.kind) {
    NoteKind.appreciation => l.noteAppreciationTitle,
    NoteKind.streak => l.noteStreakTitle(n.number),
    NoteKind.daily => l.noteDailyTitle,
    NoteKind.comeback3 => l.noteComeback3Title,
    NoteKind.comeback7 => l.noteComeback7Title,
  };

  static String _body(AppLocalizations l, PlannedNote n) => switch (n.kind) {
    NoteKind.appreciation => l.noteAppreciationBody(n.number),
    NoteKind.streak => l.noteStreakBody,
    NoteKind.daily => l.noteDailyBody,
    NoteKind.comeback3 => l.noteComeback3Body,
    NoteKind.comeback7 => l.noteComeback7Body,
  };
}

@Riverpod(keepAlive: true)
CompanionController companionController(Ref ref) => CompanionController(ref);
