import 'package:arrowchime/core/companion/companion_controller.dart';
import 'package:arrowchime/core/companion/notification_service.dart';
import 'package:arrowchime/core/save/save_controller.dart';
import 'package:arrowchime/core/save/save_data.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  // Saturday 2026-10-10, 20:30.
  var clock = DateTime(2026, 10, 10, 20, 30);
  late FakeNotificationService service;
  late ProviderContainer c;

  CompanionController ctl() => c.read(companionControllerProvider);
  CompanionState state() => c.read(saveControllerProvider).companion;

  void seed(SaveData Function(SaveData d) f) =>
      c.read(saveControllerProvider.notifier).update(f);

  setUp(() {
    clock = DateTime(2026, 10, 10, 20, 30);
    service = FakeNotificationService();
    c = ProviderContainer(
      overrides: [
        saveDebounceProvider.overrideWithValue(null),
        notificationServiceProvider.overrideWithValue(service),
        clockProvider.overrideWithValue(() => clock),
      ],
    );
    addTearDown(c.dispose);
    // A veteran: second session done, 12 levels cleared.
    seed(
      (d) => d.copyWith(
        flags: {'secondSession': true},
        stats: d.stats.copyWith(levelsCleared: 12),
      ),
    );
  });

  group('asking', () {
    test('not before 5 levels, then once; "later" waits a week', () {
      seed((d) => d.copyWith(stats: d.stats.copyWith(levelsCleared: 4)));
      expect(ctl().shouldAsk(), isFalse);
      seed((d) => d.copyWith(stats: d.stats.copyWith(levelsCleared: 5)));
      expect(ctl().shouldAsk(), isTrue);
      ctl().later();
      expect(ctl().shouldAsk(), isFalse);
      clock = clock.add(const Duration(days: 8));
      expect(ctl().shouldAsk(), isTrue);
      ctl().later(); // the second "later" is a no
      clock = clock.add(const Duration(days: 30));
      expect(ctl().shouldAsk(), isFalse);
    });

    test('yes: asks the system, remembers, and plans notes', () async {
      final granted = await ctl().accept();
      expect(granted, isTrue);
      expect(service.permissionRequests, 1);
      expect(state().optedInAt, greaterThan(0));
      expect(service.scheduled, isNotEmpty);
      expect(ctl().shouldAsk(), isFalse);
    });

    test('the system says no: never asked again, nothing scheduled', () async {
      service.permission = false;
      expect(await ctl().accept(), isFalse);
      expect(state().askState, 'declined');
      expect(state().optedInAt, 0);
      expect(ctl().shouldAsk(), isFalse);
      expect(service.scheduled, isEmpty);
    });
  });

  group('after opting in', () {
    setUp(() async {
      await ctl().accept();
    });

    test('words come from the ARB and arrive in daytime', () async {
      seed(
        (d) => d.copyWith(companion: d.companion.copyWith(yesterdayRecord: 9)),
      );
      await ctl().onBackground();
      final first = service.scheduled.first;
      expect(first.body, contains('9 levels'));
      expect(first.at.hour, inInclusiveRange(9, 21));
      expect(first.at.isAfter(clock), isTrue);
    });

    test('off cancels everything and stays off', () async {
      await ctl().setMode('off');
      expect(service.scheduled, isEmpty);
      await ctl().onBackground();
      expect(service.scheduled, isEmpty);
      await ctl().setMode('normal');
      expect(service.scheduled, isNotEmpty);
    });

    test('three ignored batches in a row silence it; a tap resets', () async {
      for (var i = 0; i < 3; i++) {
        await ctl().onBackground();
        clock = clock.add(const Duration(days: 2));
        ctl().onSessionStart(fromNote: false);
      }
      expect(state().ignoredInRow, 3);
      await ctl().onBackground();
      expect(service.scheduled, isEmpty);
      ctl().onSessionStart(fromNote: true);
      expect(state().ignoredInRow, 0);
      await ctl().onBackground();
      expect(service.scheduled, isNotEmpty);
    });

    test('learns the hour and the best day', () {
      clock = DateTime(2026, 10, 10, 23, 0);
      for (var i = 0; i < 4; i++) {
        ctl().onLevelCleared();
      }
      expect(state().todayLevels, 4);
      expect(state().usualHour, greaterThan(19));
      // The next day starts: yesterday was a record of 4.
      clock = DateTime(2026, 10, 11, 9, 0);
      ctl().onLevelCleared();
      expect(state().todayLevels, 1);
      expect(state().yesterdayRecord, 4);
      expect(state().bestDayLevels, 4);
    });
  });
}
