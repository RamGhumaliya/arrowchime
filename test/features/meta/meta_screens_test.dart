import 'package:arrowchime/app/router.dart';
import 'package:arrowchime/core/level/engine/game_engine.dart';
import 'package:arrowchime/core/meta/quests.dart';
import 'package:arrowchime/core/save/save_data.dart';
import 'package:arrowchime/core/ui/components/tb_toggle.dart';
import 'package:arrowchime/features/game/flame/arrow_game.dart';
import 'package:arrowchime/features/game/state/game_session.dart';
import 'package:arrowchime/features/game/state/level_ref.dart';
import 'package:arrowchime/features/onboarding/onboarding_overlay.dart';
import 'package:flame/game.dart';
import 'package:flutter_test/flutter_test.dart';

import '../game/support/game_harness.dart';
import 'meta_harness.dart';

SaveData played({
  int cleared = 0,
  int coins = 0,
  Map<String, DailyResult> daily = const {},
  StreakState streak = const StreakState(),
  QuestState? quests,
}) => SaveData(
  stars: {
    for (var i = 1; i <= cleared; i++)
      'ch1_l${i.toString().padLeft(3, '0')}': 3,
  },
  currentLevel: {'1': cleared + 1},
  coins: coins,
  daily: daily,
  streak: streak,
  quests: quests ?? const QuestState(),
);

void main() {
  group('Home', () {
    testWidgets('a new player: Play Level 1, no streak, 0 coins', (
      tester,
    ) async {
      await pumpApp(tester);
      expect(find.text('PLAY · Level 1'), findsWidgets);
      expect(find.bySemanticsLabel('No streak yet'), findsOneWidget);
      expect(find.bySemanticsLabel('Shop'), findsOneWidget);
      expect(find.bySemanticsLabel('Collection'), findsOneWidget);
      expect(find.bySemanticsLabel('Quests'), findsOneWidget);
    });

    testWidgets('progress moves the Play button', (tester) async {
      await pumpApp(tester, save: played(cleared: 30, coins: 120));
      expect(find.text('PLAY · Level 31'), findsWidgets);
      expect(find.text('120'), findsWidgets);
    });

    testWidgets('Play opens that level', (tester) async {
      await pumpApp(tester, save: played(cleared: 4));
      await tester.tap(find.text('PLAY · Level 5').last);
      await settle(tester, frames: 12);
      expect(find.byType(GameWidget<ArrowGame>), findsOneWidget);
    });

    testWidgets('plaques and pills open their screens', (tester) async {
      await pumpApp(tester);
      await tester.tap(find.bySemanticsLabel('Settings'));
      await settle(tester, frames: 12);
      expect(find.text('Sound'), findsWidgets);
    });

    testWidgets('the streak shows and a broken one shows 0', (tester) async {
      final yesterday = DateTime(2026, 10, 9);
      expect(yesterday.day, 9);
      await pumpApp(
        tester,
        save: played(
          streak: const StreakState(
            count: 5,
            best: 5,
            lastPlayed: '2026-10-09',
            freezeWeek: '2026-W41',
          ),
        ),
      );
      expect(find.bySemanticsLabel('5-day streak'), findsOneWidget);
    });

    testWidgets("opening Home draws today's quests and the weekly freeze", (
      tester,
    ) async {
      final h = await pumpApp(tester);
      expect(h.save.quests.date, '2026-10-10');
      expect(h.save.quests.items, hasLength(3));
      expect(h.save.streak.freezes, 1);
    });

    testWidgets('Home starts the chapter music', (tester) async {
      final h = await pumpApp(tester);
      expect(h.audio.plays.any((p) => p.loop), isTrue);
    });
  });

  group('Quests sheet', () {
    testWidgets('shows three quests; claim pays once; the chest opens', (
      tester,
    ) async {
      final h = await pumpApp(
        tester,
        save: played(
          quests: const QuestState(
            date: '2026-10-10',
            items: [
              QuestProgress(id: 'clear5', progress: 5),
              QuestProgress(id: 'flow3', progress: 1),
              QuestProgress(id: 'free100', progress: 100),
            ],
          ),
        ),
      );
      await tester.tap(find.bySemanticsLabel('Quests'));
      await settle(tester, frames: 12);
      expect(find.text('Daily quests'), findsWidgets);
      expect(find.text('Clear 5 levels'), findsWidgets);
      expect(find.text('Claim'), findsNWidgets(3));
      for (var i = 0; i < 3; i++) {
        await tester.tap(find.text('Claim').last);
        await settle(tester, frames: 4);
      }
      expect(h.save.coins, 40 + 30 + 50);
      expect(Quests.chestReady(h.save.quests), isTrue);
      await tester.tap(find.text('Open chest').last);
      await settle(tester, frames: 4);
      expect(h.save.quests.chestOpened, isTrue);
      expect(
        h.save.coins,
        120 +
            100 +
            (h.save.achievements.containsKey('quest_chest') ? 0 : 0) +
            50,
      );
      expect(find.text('Chest opened'), findsWidgets);
    });

    testWidgets('an unfinished quest cannot be claimed; the chest waits', (
      tester,
    ) async {
      await pumpApp(tester);
      await tester.tap(find.bySemanticsLabel('Quests'));
      await settle(tester, frames: 12);
      expect(find.text('Claim'), findsNothing);
    });
  });

  group('Daily Knot', () {
    testWidgets("today's card, PLAY TODAY, calendar of 30 days", (
      tester,
    ) async {
      await pumpApp(tester, location: AppRoutes.daily);
      await settle(tester, frames: 30);
      expect(find.text('Daily Knot #283'), findsWidgets);
      expect(find.text('PLAY TODAY'), findsWidgets);
      expect(find.text('Last 30 days'), findsWidgets);
      expect(find.bySemanticsLabel('2026-10-10, today'), findsOneWidget);
      expect(find.bySemanticsLabel('2026-10-09, missed'), findsOneWidget);
    });

    testWidgets("PLAY TODAY opens today's knot", (tester) async {
      await pumpApp(tester, location: AppRoutes.daily);
      await settle(tester, frames: 30);
      await tester.tap(find.text('PLAY TODAY').last);
      await settle(tester, frames: 30);
      expect(find.byType(GameWidget<ArrowGame>), findsOneWidget);
    });

    testWidgets('once done the primary button shares the result', (
      tester,
    ) async {
      final h = await pumpApp(
        tester,
        location: AppRoutes.daily,
        save: played(
          daily: const {
            '2026-10-10': DailyResult(
              stars: 2,
              heartsLeft: 2,
              bestFlow: 4,
              seconds: 112,
            ),
          },
        ),
      );
      await settle(tester, frames: 30);
      expect(find.text('PLAY TODAY'), findsNothing);
      await tester.tap(find.text('Share result').last);
      await tester.pump(); // the card paints off-screen, then is captured
      await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 300)),
      );
      await settle(tester, frames: 6);
      expect(h.share.shared, hasLength(1));
      expect(
        h.share.shared.single.text,
        startsWith('Arrowchime Daily #283 ❤️❤️🖤 ⚡x4 ⏱1:52'),
      );
      expect(h.share.shared.single.hasImage, isTrue);
    });

    testWidgets('a missed day can be replayed for 100 coins', (tester) async {
      // On the 12th, the 10th (inside the baked pack) is a missed day.
      final h = await pumpApp(
        tester,
        location: AppRoutes.daily,
        save: played(coins: 150),
        now: DateTime(2026, 10, 12, 9),
      );
      await settle(tester, frames: 30);
      await tester.tap(find.bySemanticsLabel('2026-10-10, missed'));
      await settle(tester, frames: 12);
      expect(find.text('Costs 100 coins.'), findsWidgets);
      await tester.tap(find.text('Replay · 100').last);
      await settle(tester, frames: 30);
      expect(h.save.coins, 50);
      expect(find.byType(GameWidget<ArrowGame>), findsOneWidget);
    });

    testWidgets('without the coins the replay is disabled', (tester) async {
      final h = await pumpApp(
        tester,
        location: AppRoutes.daily,
        save: played(coins: 20),
      );
      await settle(tester, frames: 30);
      await tester.tap(find.bySemanticsLabel('2026-10-09, missed'));
      await settle(tester, frames: 12);
      await tester.tap(find.text('Replay · 100').last);
      await settle(tester, frames: 6);
      expect(h.save.coins, 20);
    });

    testWidgets('streak freeze: buy for 200 coins', (tester) async {
      final h = await pumpApp(
        tester,
        location: AppRoutes.daily,
        save: played(coins: 300),
      );
      await settle(tester, frames: 30);
      expect(find.text('Freezes: 0'), findsWidgets);
      await tester.tap(find.text('Buy a freeze · 200').last);
      await settle(tester, frames: 4);
      expect(h.save.coins, 100);
      expect(h.save.streak.freezes, 1);
    });
  });

  group('Achievements and stats', () {
    testWidgets('badge tiles, locked with progress, unlocked with a date', (
      tester,
    ) async {
      await pumpApp(
        tester,
        location: AppRoutes.achievements,
        save: const SaveData(
          achievements: {'first_note': '2026-10-01'},
          stats: PlayStats(levelsCleared: 4, arrowsFreed: 250),
        ),
      );
      expect(find.text('First Note'), findsWidgets);
      expect(
        find.bySemanticsLabel('First Note, Unlocked 2026-10-01'),
        findsOneWidget,
      );
      expect(find.bySemanticsLabel('Untangler, 250 / 1000'), findsOneWidget);
    });

    testWidgets('a tile opens its description; the Stats tab lists numbers', (
      tester,
    ) async {
      await pumpApp(
        tester,
        location: AppRoutes.achievements,
        save: const SaveData(
          xp: 300,
          stats: PlayStats(arrowsFreed: 412, bestFlow: 4, playSeconds: 3900),
          streak: StreakState(best: 6),
        ),
      );
      await tester.tap(find.bySemanticsLabel('Untangler, 412 / 1000'));
      await settle(tester, frames: 12);
      expect(find.text('Free 1,000 arrows.'), findsWidgets);
      await tester.tapAt(const Offset(10, 10));
      await settle(tester, frames: 12);
      await tester.tap(find.text('Stats').last);
      await settle(tester, frames: 6);
      expect(find.bySemanticsLabel('Arrows freed, 412'), findsOneWidget);
      expect(find.bySemanticsLabel('Best Flow, ×4'), findsOneWidget);
      expect(find.bySemanticsLabel('Play time, 1h 5m'), findsOneWidget);
      expect(find.bySemanticsLabel('Longest streak, 6 days'), findsOneWidget);
      expect(find.bySemanticsLabel('Player level, 2'), findsOneWidget);
    });
  });

  group('Settings', () {
    testWidgets('every switch writes the save', (tester) async {
      final h = await pumpApp(tester, location: AppRoutes.settings);
      // Toggles, top to bottom: music, effects, haptics, left-handed,
      // relaxed, reduce motion.
      final toggles = find.byType(TBToggle);
      for (final i in [2, 3, 4, 5]) {
        await tester.ensureVisible(toggles.at(i));
        await tester.tap(toggles.at(i));
      }
      await settle(tester, frames: 4);
      final s = h.save.settings;
      expect(s.leftHanded, isTrue);
      expect(s.relaxed, isTrue);
      expect(s.hapticsOn, isFalse);
      expect(s.reduceMotion, 'on');
    });

    testWidgets('music and sound toggles; sliders only while on', (
      tester,
    ) async {
      final h = await pumpApp(tester, location: AppRoutes.settings);
      await tester.tap(find.byType(TBToggle).at(0));
      await settle(tester, frames: 4);
      expect(h.save.settings.musicOn, isFalse);
      await tester.tap(find.byType(TBToggle).at(1));
      await settle(tester, frames: 4);
      expect(h.save.settings.soundOn, isFalse);
    });

    testWidgets('the colour-blind palette is a three-way choice', (
      tester,
    ) async {
      final h = await pumpApp(tester, location: AppRoutes.settings);
      await tester.tap(find.text('Red-green').last);
      await settle(tester, frames: 6);
      expect(h.save.settings.colorBlind, 'deutan');
      await tester.tap(find.text('Blue-yellow').last);
      await settle(tester, frames: 6);
      expect(h.save.settings.colorBlind, 'tritan');
    });

    testWidgets('account rows say coming soon; credits open a sheet', (
      tester,
    ) async {
      await pumpApp(tester, location: AppRoutes.settings);
      await tester.ensureVisible(find.text('Privacy').last);
      await tester.tap(find.text('Privacy').last);
      await settle(tester, frames: 6);
      expect(find.text('Coming soon.'), findsWidgets);
      await tester.ensureVisible(find.text('Credits').last);
      await tester.tap(find.text('Credits').last);
      await settle(tester, frames: 12);
      expect(find.textContaining('Webazonic'), findsWidgets);
    });
  });

  group('Playing saves progress (docs/09 §4: survives app kill)', () {
    testWidgets('a win is written to the save and flushes to storage', (
      tester,
    ) async {
      final h = await pumpApp(tester, location: AppRoutes.levelPath('ch1', 1));
      await settle(tester, frames: 12);
      final session = h.container.read(
        gameSessionProvider(const LevelRef(1, 1)).notifier,
      );
      session.engine.level.meta.solution.forEach(session.tap);
      await settle(tester, frames: 40);
      expect(h.save.starsOf('ch1_l001'), 3);
      expect(h.save.currentLevel['1'], 2);
      expect(h.save.coins, greaterThanOrEqualTo(25));
      expect(h.save.stats.levelsCleared, 1);
      expect(h.save.streak.count, 1);
      expect(session.engine.status, GameStatus.won);
    });

    testWidgets('a replay of a cleared level pays nothing more', (
      tester,
    ) async {
      final h = await pumpApp(
        tester,
        location: AppRoutes.levelPath('ch1', 1),
        save: played(cleared: 1, coins: 10),
      );
      await settle(tester, frames: 12);
      final session = h.container.read(
        gameSessionProvider(const LevelRef(1, 1)).notifier,
      );
      session.engine.level.meta.solution.forEach(session.tap);
      await settle(tester, frames: 40);
      expect(h.save.coins, 10);
    });

    testWidgets('a Daily win is recorded for its UTC date', (tester) async {
      final h = await pumpApp(
        tester,
        location: AppRoutes.dailyPlayPath('2026-10-10'),
      );
      await settle(tester, frames: 60);
      final ref = LevelRef.dailyOf('2026-10-10');
      final session = h.container.read(gameSessionProvider(ref).notifier);
      session.engine.level.meta.solution.forEach(session.tap);
      await settle(tester, frames: 40);
      expect(h.save.daily.keys, ['2026-10-10']);
      expect(h.save.stats.dailiesPlayed, 1);
      expect(find.text('Done'), findsWidgets);
    });
  });

  group('Onboarding hints (Chapter 1)', () {
    testWidgets('level 1 shows the caption and hand; the first tap hides it', (
      tester,
    ) async {
      final h = await pumpApp(tester, location: AppRoutes.levelPath('ch1', 1));
      await settle(tester, frames: 12);
      expect(find.byType(OnboardingOverlay), findsOneWidget);
      expect(find.text('Tap an arrow to free it.'), findsWidgets);
      final session = h.container.read(
        gameSessionProvider(const LevelRef(1, 1)).notifier,
      );
      session.tap(session.engine.level.meta.solution.first);
      await settle(tester, frames: 6);
      expect(find.byType(OnboardingOverlay), findsNothing);
    });

    testWidgets('a cleared level and levels outside the tutorial have none', (
      tester,
    ) async {
      await pumpApp(
        tester,
        location: AppRoutes.levelPath('ch1', 1),
        save: played(cleared: 1),
      );
      await settle(tester, frames: 12);
      expect(find.byType(OnboardingOverlay), findsNothing);
    });

    for (final (level, caption) in [
      (5, 'Hold to peek the path.'),
      (8, 'Pinch to zoom, drag to pan.'),
      (10, 'A knot! Take your time.'),
    ]) {
      testWidgets('level $level shows its hint', (tester) async {
        await pumpApp(
          tester,
          location: AppRoutes.levelPath('ch1', level),
          save: played(cleared: level - 1),
        );
        await settle(tester, frames: 12);
        expect(find.text(caption), findsWidgets);
      });
    }

    for (final (chapter, level, caption) in [
      (2, 1, 'Arrows turn after each tap.'),
      (3, 1, 'Free the key arrow first.'),
      (4, 1, 'Ice thaws as arrows leave.'),
      (5, 1, 'Chained arrows leave together.'),
      (5, 20, 'Portals carry arrows across.'),
    ]) {
      testWidgets('mechanic tutorial ch$chapter L$level shows its hint', (
        tester,
      ) async {
        await pumpApp(
          tester,
          location: AppRoutes.levelPath('ch$chapter', level),
          save: SaveData(
            currentLevel: {
              for (var c = 1; c <= 5; c++) '$c': c < chapter ? 61 : level,
            },
          ),
        );
        await settle(tester, frames: 12);
        expect(find.text(caption), findsWidgets);
        expect(find.byType(OnboardingOverlay), findsOneWidget);
      });
    }

    testWidgets('level 6 is practice: no hint', (tester) async {
      await pumpApp(
        tester,
        location: AppRoutes.levelPath('ch1', 6),
        save: played(cleared: 5),
      );
      await settle(tester, frames: 12);
      expect(find.byType(OnboardingOverlay), findsNothing);
    });
  });
}
