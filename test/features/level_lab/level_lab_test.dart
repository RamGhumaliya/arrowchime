import 'package:arrowchime/app/router.dart';
import 'package:arrowchime/features/game/flame/arrow_game.dart';
import 'package:arrowchime/features/level_lab/level_lab_state.dart';
import 'package:flame/game.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import '../game/support/game_harness.dart';
import '../meta/meta_harness.dart';

void main() {
  const wide = Size(1280, 800);

  testWidgets('lists the pack with scores, mechanics and the selected level', (
    tester,
  ) async {
    await pumpApp(tester, location: AppRoutes.levelLab, size: wide, dpr: 1);
    await settle(tester, frames: 20);
    expect(find.text('Level Lab'), findsOneWidget);
    expect(find.textContaining('ch1_l001'), findsWidgets);
    expect(find.textContaining('arrows'), findsWidgets);
    expect(find.byType(GameWidget<ArrowGame>), findsOneWidget);
    expect(find.text('Play'), findsOneWidget);
  });

  testWidgets('selecting a level and a chapter changes the detail', (
    tester,
  ) async {
    final h = await pumpApp(
      tester,
      location: AppRoutes.levelLab,
      size: wide,
      dpr: 1,
    );
    await settle(tester, frames: 20);
    await tester.tap(find.textContaining('3  6×6').first);
    await settle(tester, frames: 10);
    expect(h.container.read(levelLabProvider).index, 3);
    h.container.read(levelLabProvider.notifier).select(chapter: 3, index: 1);
    await settle(tester, frames: 20);
    expect(find.textContaining('ch3_l001'), findsWidgets);
    expect(find.textContaining('tutorial-1.0'), findsWidgets);
    expect(find.textContaining('gateKey'), findsWidgets);
  });

  testWidgets('approve toggles meta.approved and shows a check mark', (
    tester,
  ) async {
    final h = await pumpApp(
      tester,
      location: AppRoutes.levelLab,
      size: wide,
      dpr: 1,
    );
    await settle(tester, frames: 20);
    await tester.tap(find.text('Approve'));
    await settle(tester, frames: 10);
    final pack = await h.container.read(levelLabProvider.notifier).pack(1);
    expect(pack.first.meta.approved, isTrue);
    expect(find.text('Unapprove'), findsOneWidget);
    await tester.tap(find.text('Unapprove'));
    await settle(tester, frames: 10);
    expect(
      (await h.container.read(levelLabProvider.notifier).pack(1))
          .first
          .meta
          .approved,
      isFalse,
    );
  });

  testWidgets('check runs the real checker', (tester) async {
    final h = await pumpApp(
      tester,
      location: AppRoutes.levelLab,
      size: wide,
      dpr: 1,
    );
    await settle(tester, frames: 20);
    await tester.tap(find.text('Check'));
    await settle(tester, frames: 10);
    expect(
      h.container.read(levelLabProvider).message,
      startsWith('Checker: ok'),
    );
  });

  testWidgets('regenerate swaps in a new level; export includes the edit', (
    tester,
  ) async {
    final h = await pumpApp(
      tester,
      location: AppRoutes.levelLab,
      size: wide,
      dpr: 1,
    );
    await settle(tester, frames: 20);
    h.container.read(levelLabProvider.notifier).select(index: 20);
    await settle(tester, frames: 10);
    final lab = h.container.read(levelLabProvider.notifier);
    final before = (await lab.pack(1))[19].meta.seed;
    await tester.runAsync(lab.regenerate);
    await settle(tester, frames: 10);
    final after = (await lab.pack(1))[19];
    expect(after.meta.seed, isNot(before));
    expect(h.container.read(levelLabProvider).edited, contains('ch1_l020'));
    expect(
      h.container.read(levelLabProvider).message,
      startsWith('Regenerated'),
    );

    String? copied;
    tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
      SystemChannels.platform,
      (call) async {
        if (call.method == 'Clipboard.setData') {
          copied = (call.arguments as Map)['text'] as String;
        }
        return null;
      },
    );
    addTearDown(
      () => tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
        SystemChannels.platform,
        null,
      ),
    );
    await tester.ensureVisible(find.text('Export pack'));
    await tester.tap(find.text('Export pack'));
    await settle(tester, frames: 10);
    expect(copied, contains('"id":"ch1_l020"'));
    expect(copied, contains('"chapter":1'));
  });

  testWidgets('Play opens the level in the game screen', (tester) async {
    await pumpApp(tester, location: AppRoutes.levelLab, size: wide, dpr: 1);
    await settle(tester, frames: 20);
    await tester.tap(find.text('Play'));
    await settle(tester, frames: 30);
    expect(find.byType(GameWidget<ArrowGame>), findsWidgets);
    expect(find.text('Level 1'), findsWidgets);
  });

  testWidgets('FPS and solution switches rebuild the preview', (tester) async {
    await pumpApp(tester, location: AppRoutes.levelLab, size: wide, dpr: 1);
    await settle(tester, frames: 20);
    await tester.ensureVisible(find.text('FPS overlay'));
    await tester.tap(find.text('FPS overlay'));
    await tester.tap(find.text('Solution order'));
    await settle(tester, frames: 10);
    expect(tester.takeException(), isNull);
  });
}
