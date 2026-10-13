import 'package:arrowchime/app/router.dart';
import 'package:arrowchime/core/companion/notification_service.dart';
import 'package:arrowchime/core/save/save_data.dart';
import 'package:flutter_test/flutter_test.dart';

import '../game/support/game_harness.dart';
import '../meta/meta_harness.dart';

void main() {
  SaveData veteran({
    int cleared = 6,
    CompanionState companion = const CompanionState(),
    int bestFlow = 1,
  }) => SaveData(
    stars: {
      for (var i = 1; i <= cleared; i++)
        'ch1_l${i.toString().padLeft(3, '0')}': 3,
    },
    currentLevel: {'1': cleared + 1},
    stats: PlayStats(levelsCleared: cleared, bestFlow: bestFlow),
    companion: companion,
    // The Starter Bundle and the iOS pre-prompt have had their turn.
    ads: const AdState(starterShownDate: '2026-10-10'),
    flags: const {'secondSession': true},
  );

  group('the pre-prompt', () {
    testWidgets('appears after 5 levels; yes asks the system and plans', (
      tester,
    ) async {
      final notes = FakeNotificationService();
      final h = await pumpApp(tester, save: veteran(), notifications: notes);
      await settle(tester, frames: 16);
      expect(find.text('Chime Companion'), findsWidgets);
      await tester.tap(find.text('Yes, please').last);
      await settle(tester, frames: 12);
      expect(notes.permissionRequests, 1);
      expect(h.save.companion.optedInAt, greaterThan(0));
      expect(notes.scheduled, isNotEmpty);
    });

    testWidgets('maybe later waits a week', (tester) async {
      final notes = FakeNotificationService();
      final h = await pumpApp(tester, save: veteran(), notifications: notes);
      await settle(tester, frames: 16);
      await tester.tap(find.text('Maybe later').last);
      await settle(tester, frames: 12);
      expect(notes.permissionRequests, 0);
      expect(h.save.companion.askState, 'asked');
      expect(h.save.companion.askRetryAt, greaterThan(0));
    });

    testWidgets('does not appear before 5 levels', (tester) async {
      await pumpApp(tester, save: veteran(cleared: 3));
      await settle(tester, frames: 16);
      expect(find.text('Chime Companion'), findsNothing);
    });
  });

  group('settings and the diary', () {
    testWidgets('Off in Settings cancels everything', (tester) async {
      final notes = FakeNotificationService();
      final h = await pumpApp(
        tester,
        location: AppRoutes.settings,
        save: veteran(companion: const CompanionState(optedInAt: 1)),
        notifications: notes,
      );
      await tester.ensureVisible(find.text('Off').last);
      await tester.tap(find.text('Off').last);
      await settle(tester, frames: 8);
      expect(h.save.companion.mode, 'off');
      expect(notes.cancels, greaterThan(0));
    });

    testWidgets('the diary lists the best moments', (tester) async {
      await pumpApp(
        tester,
        location: AppRoutes.diary,
        save: veteran(cleared: 12, bestFlow: 5),
      );
      expect(find.text('Chime Diary'), findsWidgets);
      expect(find.text('Levels cleared'), findsOneWidget);
      expect(find.text('12'), findsWidgets);
      expect(find.text('×5'), findsWidgets);
    });
  });
}
