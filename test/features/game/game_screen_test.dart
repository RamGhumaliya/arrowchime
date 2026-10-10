import 'package:arrowchime/core/level/engine/game_engine.dart';
import 'package:arrowchime/features/game/flame/arrow_game.dart';
import 'package:arrowchime/features/game/hud/hearts_row.dart';
import 'package:arrowchime/features/game/state/game_session.dart';
import 'package:arrowchime/features/game/state/level_ref.dart';
import 'package:flame/game.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../core/level/support/fixtures.dart';
import 'support/game_harness.dart';

void main() {
  const id = LevelRef(1, 1);

  testWidgets('shows the HUD and the board', (tester) async {
    await pumpGame(tester, id: id);
    expect(find.text('Level 1'), findsWidgets);
    expect(find.byType(HeartsRow), findsOneWidget);
    expect(find.byType(GameWidget<ArrowGame>), findsOneWidget);
    expect(find.bySemanticsLabel('Undo'), findsOneWidget);
    expect(find.bySemanticsLabel('Hint'), findsOneWidget);
    expect(find.bySemanticsLabel('Grid lines'), findsOneWidget);
    expect(find.bySemanticsLabel('Fit board'), findsOneWidget);
  });

  testWidgets('playing every arrow wins and opens the win sheet', (
    tester,
  ) async {
    final h = await pumpGame(tester, id: id, level: freeTrio());
    for (final arrow in [0, 1, 2]) {
      h.session.tap(arrow);
      await settle(tester, frames: 4);
    }
    await settle(tester, frames: 30);
    expect(h.container.read(gameSessionProvider(id)).status, GameStatus.won);
    expect(find.text('Next level'), findsWidgets);
    expect(find.text('Replay'), findsWidgets);
    expect(find.text('+25 coins'), findsWidgets);
  });

  testWidgets('losing opens the fail sheet; Retry is free', (tester) async {
    final h = await pumpGame(tester, id: id, level: blockedPair(hearts: 1));
    h.session.tap(0);
    await settle(tester, frames: 30);
    expect(find.text('Out of hearts'), findsWidgets);
    expect(find.text('Retry'), findsWidgets);
    expect(find.text('+1 heart'), findsWidgets);
    await tester.tap(find.text('Retry').last);
    await settle(tester);
    expect(find.text('Out of hearts'), findsNothing);
    final state = h.container.read(gameSessionProvider(id));
    expect(state.status, GameStatus.playing);
    expect(state.hearts, 1);
  });

  testWidgets('the ad button continues with one more heart', (tester) async {
    final h = await pumpGame(tester, id: id, level: blockedPair(hearts: 1));
    h.session.tap(0);
    await settle(tester, frames: 30);
    await tester.tap(find.text('+1 heart').last);
    await settle(tester);
    final state = h.container.read(gameSessionProvider(id));
    expect(state.status, GameStatus.playing);
    expect(state.hearts, 1);
  });
}
