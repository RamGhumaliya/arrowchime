import 'package:arrowchime/app/router.dart';
import 'package:arrowchime/core/save/save_data.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../core/ui/support/ui_harness.dart';
import '../game/support/game_harness.dart';
import 'meta_harness.dart';

/// Design review gate (`docs/10` §11) for the Phase 6 screens, at iPhone SE and
/// Pro Max (portrait) and an Android tablet (landscape), saved under
/// `docs/screenshots/phase6/`. Regenerate with
/// `flutter test --update-goldens test/features/meta/phase6_screenshots_test.dart`.
void main() {
  const devices = <String, Size>{
    'iphone_se': Size(375, 667),
    'iphone_pro_max': Size(430, 932),
    'android_tablet': Size(1280, 800),
  };

  /// A player part-way through Chapter 1 with a week's streak and some history.
  final midGame = SaveData(
    stars: {
      for (var i = 1; i <= 37; i++)
        'ch1_l${i.toString().padLeft(3, '0')}': i % 5 == 0 ? 2 : 3,
    },
    currentLevel: {'1': 38},
    coins: 1240,
    xp: 800,
    streak: const StreakState(
      count: 8,
      best: 12,
      lastPlayed: '2026-10-10',
      freezes: 1,
      freezeWeek: '2026-W41',
    ),
    daily: {
      '2026-10-09': const DailyResult(
        stars: 3,
        heartsLeft: 3,
        bestFlow: 5,
        seconds: 95,
      ),
      '2026-10-07': const DailyResult(
        stars: 2,
        heartsLeft: 2,
        bestFlow: 3,
        seconds: 140,
      ),
      '2026-10-06': const DailyResult(
        stars: 3,
        heartsLeft: 3,
        bestFlow: 4,
        seconds: 118,
      ),
    },
    achievements: {
      'first_note': '2026-09-20',
      'levels_10': '2026-09-24',
      'flow_3': '2026-09-25',
      'maestro': '2026-10-02',
      'streak_3': '2026-10-04',
      'streak_7': '2026-10-08',
      'daily_1': '2026-10-06',
    },
    stats: const PlayStats(
      arrowsFreed: 640,
      levelsCleared: 37,
      perfectClears: 28,
      perfectRun: 6,
      bestFlow: 5,
      playSeconds: 11400,
      dailiesPlayed: 3,
    ),
    quests: const QuestState(
      date: '2026-10-10',
      items: [
        QuestProgress(id: 'clear5', progress: 3),
        QuestProgress(id: 'flow3', progress: 1),
        QuestProgress(id: 'free100', progress: 100, claimed: true),
      ],
    ),
  );

  Future<void> shot(WidgetTester tester, String name) => expectLater(
    find.byKey(surfaceKey),
    matchesGoldenFile('../../../docs/screenshots/phase6/$name.png'),
  );

  for (final device in devices.entries) {
    group(device.key, () {
      testWidgets('home', (tester) async {
        await pumpApp(tester, size: device.value, save: midGame);
        await shot(tester, 'home_${device.key}');
      });

      testWidgets('home, new player', (tester) async {
        await pumpApp(tester, size: device.value);
        await shot(tester, 'home_new_${device.key}');
      });

      testWidgets('chapter map', (tester) async {
        await pumpApp(
          tester,
          size: device.value,
          save: midGame,
          location: AppRoutes.chapterMap,
        );
        await shot(tester, 'chapters_${device.key}');
      });

      testWidgets('daily knot', (tester) async {
        await pumpApp(
          tester,
          size: device.value,
          save: midGame,
          location: AppRoutes.daily,
        );
        await settle(tester, frames: 30);
        await shot(tester, 'daily_${device.key}');
      });

      testWidgets('daily knot, done today', (tester) async {
        await pumpApp(
          tester,
          size: device.value,
          save: midGame.copyWith(
            daily: {
              ...midGame.daily,
              '2026-10-10': const DailyResult(
                stars: 2,
                heartsLeft: 2,
                bestFlow: 4,
                seconds: 112,
              ),
            },
          ),
          location: AppRoutes.daily,
        );
        await settle(tester, frames: 30);
        await shot(tester, 'daily_done_${device.key}');
      });

      testWidgets('quests sheet', (tester) async {
        await pumpApp(tester, size: device.value, save: midGame);
        await tester.tap(find.bySemanticsLabel('Quests'));
        await settle(tester, frames: 14);
        await shot(tester, 'quests_${device.key}');
      });

      testWidgets('achievements', (tester) async {
        await pumpApp(
          tester,
          size: device.value,
          save: midGame,
          location: AppRoutes.achievements,
        );
        await shot(tester, 'achievements_${device.key}');
      });

      testWidgets('stats', (tester) async {
        await pumpApp(
          tester,
          size: device.value,
          save: midGame,
          location: AppRoutes.achievements,
        );
        await tester.tap(find.text('Stats').last);
        await settle(tester, frames: 6);
        await shot(tester, 'stats_${device.key}');
      });

      testWidgets('settings', (tester) async {
        await pumpApp(
          tester,
          size: device.value,
          save: midGame,
          location: AppRoutes.settings,
        );
        await shot(tester, 'settings_${device.key}');
      });

      testWidgets('onboarding level 1', (tester) async {
        await pumpApp(
          tester,
          size: device.value,
          location: AppRoutes.levelPath('ch1', 1),
        );
        await settle(tester, frames: 12);
        await shot(tester, 'onboarding_${device.key}');
      });
    });
  }

  testWidgets('splash', (tester) async {
    await pumpApp(tester, size: devices['iphone_pro_max']!, location: '/');
    await settle(tester);
    await shot(tester, 'splash_iphone_pro_max');
  });
}
