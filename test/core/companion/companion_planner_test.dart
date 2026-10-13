import 'package:arrowchime/core/companion/companion_planner.dart';
import 'package:arrowchime/core/save/save_data.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  // Saturday 2026-10-10, 20:30 local.
  final now = DateTime(2026, 10, 10, 20, 30);
  const opted = CompanionState(optedInAt: 1);

  List<PlannedNote> plan(
    CompanionState s, {
    int streak = 0,
    bool played = true,
    bool first = false,
  }) => CompanionPlanner.plan(
    state: s,
    now: now,
    streak: streak,
    playedToday: played,
    dailyDone: false,
    firstSession: first,
  );

  group('who may be notified', () {
    test('nobody who has not opted in', () {
      expect(plan(const CompanionState()), isEmpty);
    });

    test('nothing in the first session', () {
      expect(plan(opted, first: true), isEmpty);
    });

    test('nothing when switched off', () {
      expect(plan(opted.copyWith(mode: 'off')), isEmpty);
    });

    test('quiet after three ignored notifications in a row', () {
      expect(plan(opted.copyWith(ignoredInRow: 2)), isNotEmpty);
      expect(plan(opted.copyWith(ignoredInRow: 3)), isEmpty);
    });
  });

  group('what is planned', () {
    test("a guarded streak gets tomorrow's streak note", () {
      final notes = plan(opted, streak: 6);
      final first = notes.first;
      expect(first.kind, NoteKind.streak);
      expect(first.number, 6);
      expect(first.at.day, 11);
    });

    test('a streak under 3 is not nagged about', () {
      final notes = plan(opted, streak: 2);
      expect(notes.any((n) => n.kind == NoteKind.streak), isFalse);
    });

    test('a record day is appreciated the next morning', () {
      final notes = plan(opted.copyWith(yesterdayRecord: 12));
      expect(notes.first.kind, NoteKind.appreciation);
      expect(notes.first.number, 12);
    });

    test('otherwise the Daily is the nudge', () {
      expect(plan(opted).first.kind, NoteKind.daily);
    });

    test('comeback notes come on day 3 and day 7, then nothing', () {
      final notes = plan(opted);
      final c3 = notes.firstWhere((n) => n.kind == NoteKind.comeback3);
      final c7 = notes.firstWhere((n) => n.kind == NoteKind.comeback7);
      expect(c3.at.day, 13);
      expect(c7.at.day, 17);
      expect(notes.length, lessThanOrEqualTo(3));
    });

    test('"fewer" keeps only the streak guardian and day 7', () {
      final notes = plan(opted.copyWith(mode: 'fewer'), streak: 5);
      expect(notes.map((n) => n.kind).toSet(), {
        NoteKind.streak,
        NoteKind.comeback7,
      });
      final noStreak = plan(opted.copyWith(mode: 'fewer'));
      expect(noStreak.map((n) => n.kind).toList(), [NoteKind.comeback7]);
    });
  });

  group('when', () {
    test('never in quiet hours, whatever the usual hour', () {
      for (final hour in [0, 3, 8, 9, 15, 21, 22, 23]) {
        final notes = plan(opted.copyWith(usualHour: hour), streak: 4);
        for (final n in notes) {
          expect(n.at.hour, inInclusiveRange(9, 21), reason: 'usual $hour');
        }
      }
    });

    test('at the hour the player usually plays', () {
      final notes = plan(opted.copyWith(usualHour: 18), streak: 4);
      expect(notes.first.at.hour, 18);
    });

    test('at most one a day', () {
      final notes = plan(opted, streak: 4);
      final days = notes.map((n) => n.at.day).toList();
      expect(days.toSet().length, days.length);
    });

    test('ids are stable per kind, so planning again replaces', () {
      final a = plan(opted, streak: 4);
      final b = plan(opted, streak: 4);
      expect([for (final n in a) n.id], [for (final n in b) n.id]);
      expect(a.map((n) => n.id).toSet().length, a.length);
    });

    test('the usual hour moves slowly', () {
      expect(CompanionPlanner.learnHour(19, 19), 19);
      expect(CompanionPlanner.learnHour(19, 23), 20);
      expect(CompanionPlanner.learnHour(19, 1), 15);
    });
  });
}
