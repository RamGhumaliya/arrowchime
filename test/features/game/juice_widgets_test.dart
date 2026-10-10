import 'package:arrowchime/app/feedback_bridge.dart';
import 'package:arrowchime/core/economy/rewards.dart';
import 'package:arrowchime/core/haptics/haptics_service.dart';
import 'package:arrowchime/core/ui/support/tb_haptics.dart';
import 'package:arrowchime/features/game/dialogs/win_sheet.dart';
import 'package:arrowchime/features/game/hud/hearts_row.dart';
import 'package:arrowchime/l10n/gen/app_localizations.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../support/fakes.dart';

Widget host(Widget child, {bool disableAnimations = false}) => Directionality(
  textDirection: TextDirection.ltr,
  child: MediaQuery(
    data: MediaQueryData(disableAnimations: disableAnimations),
    child: Localizations(
      locale: const Locale('en'),
      delegates: const [
        AppLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ],
      child: Center(child: child),
    ),
  ),
);

void main() {
  testWidgets('a lost heart cracks: it shakes and pops, then rests', (
    tester,
  ) async {
    Widget row(int hearts) => host(HeartsRow(hearts: hearts, total: 3));
    await tester.pumpWidget(row(3));
    await tester.pumpWidget(row(2));
    await tester.pump(const Duration(milliseconds: 100));
    expect(find.byType(Transform), findsWidgets);
    await tester.pump(const Duration(seconds: 1));
    expect(tester.takeException(), isNull);
    // A heart coming back (+1 heart) does not animate.
    await tester.pumpWidget(row(3));
    await tester.pump(const Duration(milliseconds: 50));
    expect(tester.takeException(), isNull);
  });

  testWidgets('Reduce Motion: hearts swap without the crack', (tester) async {
    await tester.pumpWidget(
      host(const HeartsRow(hearts: 3, total: 3), disableAnimations: true),
    );
    await tester.pumpWidget(
      host(const HeartsRow(hearts: 2, total: 3), disableAnimations: true),
    );
    await tester.pump(const Duration(milliseconds: 100));
    expect(tester.takeException(), isNull);
  });

  group('win sheet coin count-up', () {
    Widget sheet(List<int> ticks, {bool animate = true}) => host(
      WinSheet(
        levelNumber: 3,
        stars: 3,
        reward: const LevelReward(coins: 25, xp: 30),
        onNext: () {},
        onReplay: () {},
        animate: animate,
        onCoinTick: ticks.add,
      ),
    );

    testWidgets('counts up with five clinks', (tester) async {
      final ticks = <int>[];
      await tester.pumpWidget(sheet(ticks));
      await tester.pump(const Duration(milliseconds: 100));
      expect(find.text('+25 coins'), findsNothing);
      await tester.pump(const Duration(seconds: 2));
      expect(find.text('+25 coins'), findsWidgets);
      expect(ticks, [0, 1, 2, 3, 4]);
    });

    testWidgets('without animation it shows the total at once', (tester) async {
      final ticks = <int>[];
      await tester.pumpWidget(sheet(ticks, animate: false));
      expect(find.text('+25 coins'), findsWidgets);
      expect(ticks, isEmpty);
    });
  });

  testWidgets('the bridge routes component haptics through the service', (
    tester,
  ) async {
    final fake = FakeHaptics();
    final before = (TBHaptics.selection, TBHaptics.tick);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [hapticsProvider.overrideWithValue(fake)],
        child: const FeedbackBridge(child: SizedBox()),
      ),
    );
    TBHaptics.selection();
    TBHaptics.tick();
    expect(fake.log, ['selection', 'light']);
    await tester.pumpWidget(const SizedBox());
    expect((TBHaptics.selection, TBHaptics.tick), before);
  });
}
