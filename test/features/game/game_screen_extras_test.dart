import 'package:arrowchime/features/game/hud/game_shelf.dart';
import 'package:arrowchime/features/game/state/game_session.dart';
import 'package:arrowchime/features/game/state/game_settings.dart';
import 'package:arrowchime/features/game/state/level_ref.dart';
import 'package:arrowchime/features/game/state/level_repository.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../core/level/support/fixtures.dart';
import 'support/game_harness.dart';

class _FailingBundle extends CachingAssetBundle {
  @override
  Future<ByteData> load(String key) => Future.error(Exception('no such asset'));
}

void main() {
  const id = LevelRef(1, 5);

  test('settings toggle independently', () {
    final c = ProviderContainer();
    addTearDown(c.dispose);
    final s = c.read(gameSettingsControllerProvider.notifier);
    expect(c.read(gameSettingsControllerProvider).gridOn, isFalse);
    s
      ..toggleGrid()
      ..setLeftHanded(value: true)
      ..setRelaxed(value: true);
    final state = c.read(gameSettingsControllerProvider);
    expect(state.gridOn, isTrue);
    expect(state.leftHanded, isTrue);
    expect(state.relaxed, isTrue);
    s.toggleGrid();
    expect(c.read(gameSettingsControllerProvider).gridOn, isFalse);
  });

  test('the repository loads a level from the bundled packs', () async {
    final c = ProviderContainer();
    addTearDown(c.dispose);
    final level = await c.read(levelProvider(const LevelRef(2, 3)).future);
    expect(level.chapter, 2);
    expect(level.index, 3);
    expect(c.read(levelBundleProvider), isNotNull);
  });

  testWidgets('a level that cannot load shows a message and a way back', (
    tester,
  ) async {
    final c = ProviderContainer(
      overrides: [levelBundleProvider.overrideWithValue(_FailingBundle())],
    );
    addTearDown(c.dispose);
    await pumpGameWith(tester, c, id: id);
    expect(find.text('This level could not be opened.'), findsWidgets);
    expect(find.text('Back'), findsWidgets);
  });

  group('shelf', () {
    Future<List<double>> order(
      WidgetTester tester, {
      required bool left,
    }) async {
      final c = ProviderContainer(
        overrides: [levelProvider(id).overrideWith((ref) => freeTrio())],
      );
      addTearDown(c.dispose);
      c
          .read(gameSettingsControllerProvider.notifier)
          .setLeftHanded(value: left);
      await pumpGameWith(tester, c, id: id, level: freeTrio());
      return [
        for (final label in ['Undo', 'Hint', 'Grid lines', 'Fit board'])
          tester.getCenter(find.bySemanticsLabel(label)).dx,
      ];
    }

    testWidgets('right-handed: Undo is on the left', (tester) async {
      final xs = await order(tester, left: false);
      expect(xs, orderedEquals([...xs]..sort()));
    });

    testWidgets('left-handed mirrors the order', (tester) async {
      final xs = await order(tester, left: true);
      final descending = xs.toList()..sort((a, b) => b.compareTo(a));
      expect(xs, orderedEquals(descending));
    });

    testWidgets('undo is disabled until something was played', (tester) async {
      final h = await pumpGame(tester, id: id, level: freeTrio());
      expect(find.byType(GameShelf), findsOneWidget);
      h.session.undo();
      expect(h.container.read(gameSessionProvider(id)).canUndo, isFalse);
    });
  });

  testWidgets('tablet landscape puts the shelf on the right', (tester) async {
    await pumpGame(
      tester,
      id: id,
      level: freeTrio(),
      size: const Size(1280, 800),
    );
    final undo = tester.getCenter(find.bySemanticsLabel('Undo'));
    final hint = tester.getCenter(find.bySemanticsLabel('Hint'));
    expect(undo.dx, greaterThan(1280 * 0.7));
    expect(hint.dy, greaterThan(undo.dy));
    expect(undo.dx, closeTo(hint.dx, 1));
  });

  testWidgets('tap targets and labels pass the accessibility guidelines', (
    tester,
  ) async {
    final handle = tester.ensureSemantics();
    await pumpGame(tester, id: id, level: freeTrio());
    await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
    await expectLater(tester, meetsGuideline(iOSTapTargetGuideline));
    await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
    handle.dispose();
  });

  testWidgets('Reduce Motion: the board still plays and wins', (tester) async {
    final h = await pumpGame(
      tester,
      id: id,
      level: freeTrio(),
      disableAnimations: true,
    );
    [0, 1, 2].forEach(h.session.tap);
    await settle(tester, frames: 30);
    expect(find.text('Next level'), findsWidgets);
  });

  testWidgets('large text does not overflow the HUD', (tester) async {
    tester.platformDispatcher.textScaleFactorTestValue = 2;
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
    await pumpGame(
      tester,
      id: id,
      level: freeTrio(),
      size: const Size(375, 667),
    );
    expect(tester.takeException(), isNull);
  });
}
