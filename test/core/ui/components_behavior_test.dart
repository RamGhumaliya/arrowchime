import 'dart:ui' as ui;

import 'package:arrowchime/app/theme/chapter_theme.dart';
import 'package:arrowchime/app/theme/tokens.dart';
import 'package:arrowchime/core/ui/components/tb_button.dart';
import 'package:arrowchime/core/ui/components/tb_chapter_card.dart';
import 'package:arrowchime/core/ui/components/tb_flow_meter.dart';
import 'package:arrowchime/core/ui/components/tb_icon_button.dart';
import 'package:arrowchime/core/ui/components/tb_panel.dart';
import 'package:arrowchime/core/ui/components/tb_pill.dart';
import 'package:arrowchime/core/ui/components/tb_progress_bar.dart';
import 'package:arrowchime/core/ui/components/tb_ribbon.dart';
import 'package:arrowchime/core/ui/components/tb_sheet.dart';
import 'package:arrowchime/core/ui/components/tb_slider.dart';
import 'package:arrowchime/core/ui/components/tb_star_row.dart';
import 'package:arrowchime/core/ui/components/tb_tab_bar.dart';
import 'package:arrowchime/core/ui/components/tb_text.dart';
import 'package:arrowchime/core/ui/components/tb_toast.dart';
import 'package:arrowchime/core/ui/components/tb_toggle.dart';
import 'package:arrowchime/core/ui/icons/tb_icon_id.dart';
import 'package:arrowchime/core/ui/painters/ceramic_painter.dart';
import 'package:arrowchime/core/ui/support/tb_haptics.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/ui_harness.dart';

void main() {
  late int selections;
  late int ticks;
  final originalSelection = TBHaptics.selection;
  final originalTick = TBHaptics.tick;

  setUp(() {
    selections = 0;
    ticks = 0;
    TBHaptics.selection = () => selections++;
    TBHaptics.tick = () => ticks++;
  });
  tearDown(() {
    TBHaptics.selection = originalSelection;
    TBHaptics.tick = originalTick;
  });

  CeramicPainter ceramicOf(WidgetTester tester, Finder within) {
    final paints = find.descendant(
      of: within,
      matching: find.byWidgetPredicate(
        (w) => w is CustomPaint && w.painter is CeramicPainter,
      ),
    );
    return (tester.widget<CustomPaint>(paints.first).painter!)
        as CeramicPainter;
  }

  group('TBButton', () {
    testWidgets('tap calls onPressed once and fires a selection haptic', (
      tester,
    ) async {
      var taps = 0;
      await pumpSurface(
        tester,
        TBButton.primary(label: 'Play', onPressed: () => taps++),
      );
      await tester.tap(find.byType(TBButton));
      await tester.pumpAndSettle();
      expect(taps, 1);
      expect(selections, 1);
    });

    testWidgets('disabled: no callback, no haptic, still labelled', (
      tester,
    ) async {
      final handle = tester.ensureSemantics();
      await pumpSurface(
        tester,
        const TBButton.primary(label: 'Play', onPressed: null),
      );
      await tester.tap(find.byType(TBButton));
      await tester.pumpAndSettle();
      expect(selections, 0);
      final node = tester.getSemantics(find.byType(TBButton));
      expect(node.label, contains('Play'));
      expect(node.flagsCollection.isEnabled, ui.Tristate.isFalse);
      handle.dispose();
    });

    testWidgets('semantics: button with the label, tappable', (tester) async {
      final handle = tester.ensureSemantics();
      await pumpSurface(
        tester,
        TBButton.secondary(
          label: 'Retry',
          onPressed: () {},
          semanticLabel: 'Retry level',
        ),
      );
      final node = tester.getSemantics(find.byType(TBButton));
      expect(node.label, 'Retry level');
      expect(node.flagsCollection.isButton, isTrue);
      expect(node.getSemanticsData().hasAction(SemanticsAction.tap), isTrue);
      handle.dispose();
    });

    testWidgets('heights are 64 / 52 / 44 and never below the tap minimum', (
      tester,
    ) async {
      for (final (kind, h) in const [
        (TBButtonKind.primary, 64.0),
        (TBButtonKind.secondary, 52.0),
        (TBButtonKind.tertiary, 44.0),
      ]) {
        await pumpSurface(
          tester,
          TBButton(label: 'Go', onPressed: () {}, kind: kind),
        );
        final size = tester.getSize(find.byType(TBButton));
        expect(size.height, h, reason: kind.name);
        expect(size.width, greaterThanOrEqualTo(TBSizes.minTapTarget));
      }
    });

    testWidgets('expand fills the width', (tester) async {
      await pumpSurface(
        tester,
        SizedBox(
          width: 300,
          child: TBButton.primary(
            label: 'Next',
            onPressed: () {},
            expand: true,
          ),
        ),
        size: const Size(400, 120),
      );
      expect(tester.getSize(find.byType(TBButton)).width, 300);
    });

    testWidgets('press physics: face down 4 dp, lip 6 -> 2 dp, then release', (
      tester,
    ) async {
      await pumpSurface(
        tester,
        TBButton.primary(label: 'Play', onPressed: () {}),
      );
      expect(ceramicOf(tester, find.byType(TBButton)).press, 0);

      final gesture = await tester.startGesture(
        tester.getCenter(find.byType(TBButton)),
      );
      await tester.pump(); // the ticker starts on the first frame
      await tester.pump(TBMotion.tap + const Duration(milliseconds: 5));
      expect(ceramicOf(tester, find.byType(TBButton)).press, closeTo(1, 0.01));

      await gesture.up();
      await tester.pump();
      await tester.pump(TBMotion.release * 0.4);
      // Mid-release the face is moving back up (and may overshoot a hair).
      expect(ceramicOf(tester, find.byType(TBButton)).press, lessThan(1));
      await tester.pumpAndSettle();
      expect(ceramicOf(tester, find.byType(TBButton)).press, closeTo(0, 0.001));
    });

    testWidgets('release overshoots past rest (mRelease easeOutBack)', (
      tester,
    ) async {
      await pumpSurface(
        tester,
        TBButton.primary(label: 'Play', onPressed: () {}),
      );
      final gesture = await tester.startGesture(
        tester.getCenter(find.byType(TBButton)),
      );
      await tester.pump(); // the ticker starts on the first frame
      await tester.pump(TBMotion.tap + const Duration(milliseconds: 5));
      await gesture.up();
      var lowest = 1.0;
      for (var i = 0; i < 16; i++) {
        await tester.pump(const Duration(milliseconds: 10));
        final p = ceramicOf(tester, find.byType(TBButton)).press;
        if (p < lowest) lowest = p;
      }
      expect(lowest, lessThan(0), reason: 'the face pops above its rest pose');
    });

    testWidgets('Reduce Motion: no overshoot, 160 ms', (tester) async {
      await pumpSurface(
        tester,
        TBButton.primary(label: 'Play', onPressed: () {}),
        disableAnimations: true,
      );
      final gesture = await tester.startGesture(
        tester.getCenter(find.byType(TBButton)),
      );
      await tester.pump();
      await tester.pump(
        TBMotion.reducedMotionFade + const Duration(milliseconds: 5),
      );
      await gesture.up();
      var lowest = 1.0;
      for (var i = 0; i < 20; i++) {
        await tester.pump(const Duration(milliseconds: 10));
        final p = ceramicOf(tester, find.byType(TBButton)).press;
        if (p < lowest) lowest = p;
      }
      expect(lowest, greaterThanOrEqualTo(0));
    });

    testWidgets('forced pressed / focused looks (gallery states)', (
      tester,
    ) async {
      await pumpSurface(
        tester,
        TBButton.primary(
          label: 'Play',
          onPressed: () {},
          forcePressed: true,
          forceFocused: true,
        ),
      );
      final p = ceramicOf(tester, find.byType(TBButton));
      expect(p.press, 1);
      expect(p.focused, isTrue);
    });

    testWidgets('all three constructors set the kind', (tester) async {
      await pumpSurface(
        tester,
        Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TBButton.primary(label: 'A', onPressed: () {}),
            TBButton.secondary(label: 'B', onPressed: () {}),
            TBButton.tertiary(label: 'C', onPressed: () {}),
          ],
        ),
        size: const Size(300, 300),
      );
      final kinds = tester
          .widgetList<TBButton>(find.byType(TBButton))
          .map((b) => b.kind)
          .toList();
      expect(kinds, [
        TBButtonKind.primary,
        TBButtonKind.secondary,
        TBButtonKind.tertiary,
      ]);
    });
  });

  group('TBIconButton', () {
    testWidgets('56 dp, labelled, shows its badge', (tester) async {
      final handle = tester.ensureSemantics();
      await pumpSurface(
        tester,
        TBIconButton(
          icon: TBIconId.hint,
          onPressed: () {},
          semanticLabel: 'Hint',
          badge: '2',
        ),
      );
      expect(tester.getSize(find.byType(TBIconButton)).shortestSide, 56);
      expect(find.text('2'), findsWidgets);
      expect(
        tester.getSemantics(find.byType(TBIconButton)).label,
        contains('Hint'),
      );
      handle.dispose();
    });

    testWidgets('tap works, selected uses the teal glaze', (tester) async {
      var taps = 0;
      await pumpSurface(
        tester,
        TBIconButton(
          icon: TBIconId.grid,
          onPressed: () => taps++,
          semanticLabel: 'Grid',
          selected: true,
        ),
      );
      await tester.tap(find.byType(TBIconButton));
      await tester.pumpAndSettle();
      expect(taps, 1);
      expect(ceramicOf(tester, find.byType(TBIconButton)).face, TBColors.teal);
    });

    testWidgets('disabled is desaturated and inert', (tester) async {
      await pumpSurface(
        tester,
        const TBIconButton(
          icon: TBIconId.fit,
          onPressed: null,
          semanticLabel: 'Fit',
        ),
      );
      expect(ceramicOf(tester, find.byType(TBIconButton)).disabled, isTrue);
      await tester.tap(find.byType(TBIconButton));
      expect(selections, 0);
    });
  });

  group('TBPill', () {
    testWidgets('semantics reads the icon and the value', (tester) async {
      final handle = tester.ensureSemantics();
      await pumpSurface(
        tester,
        const TBPill(icon: TBIconId.heart, value: '5/5'),
      );
      expect(tester.getSemantics(find.byType(TBPill)).label, 'Heart 5/5');
      handle.dispose();
    });

    testWidgets('the + button calls onAdd', (tester) async {
      var adds = 0;
      await pumpSurface(
        tester,
        TBPill(icon: TBIconId.coin, value: '85', onAdd: () => adds++),
        size: const Size(300, 120),
      );
      final plus = find.byWidgetPredicate(
        (w) => w.runtimeType.toString() == '_PlusButton',
      );
      await tester.tap(plus);
      await tester.pumpAndSettle();
      expect(adds, 1);
      expect(selections, 1);
    });

    testWidgets('custom semantic label wins', (tester) async {
      final handle = tester.ensureSemantics();
      await pumpSurface(
        tester,
        const TBPill(
          icon: TBIconId.coin,
          value: '5',
          semanticLabel: 'Coins: 5',
        ),
      );
      expect(tester.getSemantics(find.byType(TBPill)).label, 'Coins: 5');
      handle.dispose();
    });
  });

  group('TBText', () {
    testWidgets('sticker variants stack shadow, stroke and fill', (
      tester,
    ) async {
      await pumpSurface(tester, const TBText.display('Hi'));
      // shadow + stroke + fill
      expect(find.byType(Text), findsNWidgets(3));
      await pumpSurface(tester, const TBText.title('Hi'));
      expect(find.byType(Text), findsNWidgets(3));
    });

    testWidgets('counter and button have a stroke but no hard shadow', (
      tester,
    ) async {
      await pumpSurface(tester, const TBText.counter('5'));
      expect(find.byType(Text), findsNWidgets(2));
      await pumpSurface(tester, const TBText.button('Go'));
      expect(find.byType(Text), findsNWidgets(2));
    });

    testWidgets('body and caption are plain', (tester) async {
      await pumpSurface(tester, const TBText.body('Hello'));
      expect(find.byType(Text), findsOneWidget);
      await pumpSurface(tester, const TBText.caption('Small'));
      expect(find.byType(Text), findsOneWidget);
    });

    testWidgets('exposes one semantic label, not three', (tester) async {
      final handle = tester.ensureSemantics();
      await pumpSurface(tester, const TBText.display('Level 37'));
      expect(find.bySemanticsLabel('Level 37'), findsOneWidget);
      handle.dispose();
    });

    testWidgets('uses the bundled fonts, never Roboto or Inter', (
      tester,
    ) async {
      await pumpSurface(
        tester,
        const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TBText.display('a'),
            TBText.body('b'),
            TBText.caption('c'),
          ],
        ),
        size: const Size(200, 300),
      );
      final families = tester
          .widgetList<Text>(find.byType(Text))
          .map((t) => t.style?.fontFamily)
          .toSet();
      expect(families, {'Fredoka', 'Nunito'});
    });

    testWidgets('all text constructors build', (tester) async {
      await pumpSurface(
        tester,
        const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TBText.display(
              'a',
              color: TBColors.berry,
              textAlign: TextAlign.center,
              maxLines: 1,
            ),
            TBText.title(
              'b',
              color: TBColors.teal,
              textAlign: TextAlign.center,
              maxLines: 1,
            ),
            TBText.counter('c', color: TBColors.butter),
            TBText.button(
              'd',
              color: TBColors.cream100,
              strokeColor: TBColors.tealLip,
            ),
            TBText.body(
              'e',
              color: TBColors.ink500,
              textAlign: TextAlign.center,
              maxLines: 2,
            ),
            TBText.caption(
              'f',
              color: TBColors.ink500,
              textAlign: TextAlign.center,
              maxLines: 1,
            ),
            TBText('g', overflow: TextOverflow.ellipsis),
          ],
        ),
        size: const Size(240, 500),
      );
      expect(find.text('g'), findsOneWidget);
    });
  });

  group('TBToggle', () {
    testWidgets('tap flips through onChanged and fires a haptic', (
      tester,
    ) async {
      var value = false;
      await pumpSurface(
        tester,
        StatefulBuilder(
          builder: (context, setState) => TBToggle(
            value: value,
            onChanged: (v) => setState(() => value = v),
            semanticLabel: 'Haptics',
          ),
        ),
      );
      await tester.tap(find.byType(TBToggle));
      await tester.pumpAndSettle();
      expect(value, isTrue);
      expect(selections, 1);
      await tester.tap(find.byType(TBToggle));
      await tester.pumpAndSettle();
      expect(value, isFalse);
    });

    testWidgets('semantics: toggled state and tap action', (tester) async {
      final handle = tester.ensureSemantics();
      await pumpSurface(
        tester,
        TBToggle(value: true, onChanged: (_) {}, semanticLabel: 'Music'),
      );
      final node = tester.getSemantics(find.byType(TBToggle));
      expect(node.label, 'Music');
      expect(node.flagsCollection.isToggled, ui.Tristate.isTrue);
      expect(node.getSemanticsData().hasAction(SemanticsAction.tap), isTrue);
      handle.dispose();
    });

    testWidgets('disabled does nothing', (tester) async {
      await pumpSurface(
        tester,
        const TBToggle(value: true, onChanged: null, semanticLabel: 'Locked'),
      );
      await tester.tap(find.byType(TBToggle));
      expect(selections, 0);
    });

    testWidgets('meets the 44 dp tap target', (tester) async {
      await pumpSurface(
        tester,
        TBToggle(value: true, onChanged: (_) {}, semanticLabel: 'x'),
      );
      expect(
        tester.getSize(find.byType(TBToggle)).height,
        greaterThanOrEqualTo(TBSizes.minTapTarget),
      );
    });

    testWidgets('reduced motion jumps straight to the new position', (
      tester,
    ) async {
      var value = false;
      late StateSetter set;
      await pumpSurface(
        tester,
        StatefulBuilder(
          builder: (context, setState) {
            set = setState;
            return TBToggle(
              value: value,
              onChanged: (v) {},
              semanticLabel: 'x',
            );
          },
        ),
        disableAnimations: true,
      );
      set(() => value = true);
      await tester.pump();
      // No animation left running.
      expect(tester.hasRunningAnimations, isFalse);
    });
  });

  group('TBSlider', () {
    testWidgets('dragging reports values and ticks every 10%', (tester) async {
      var value = 0.0;
      await pumpSurface(
        tester,
        StatefulBuilder(
          builder: (context, setState) => SizedBox(
            width: 300,
            child: TBSlider(
              value: value,
              onChanged: (v) => setState(() => value = v),
              semanticLabel: 'Volume',
            ),
          ),
        ),
        size: const Size(360, 120),
      );
      final box = tester.getRect(find.byType(TBSlider));
      final start = Offset(box.left + TBSizes.sliderKnob / 2, box.center.dy);
      final gesture = await tester.startGesture(start);
      await tester.pump();
      final target = box.left + box.width / 2;
      for (var x = start.dx + 10; x <= target; x += 10) {
        await gesture.moveTo(Offset(x, box.center.dy));
        await tester.pump();
      }
      await gesture.moveTo(Offset(target, box.center.dy));
      await tester.pump();
      await gesture.up();
      expect(value, closeTo(0.5, 0.05));
      expect(ticks, greaterThanOrEqualTo(4));
      expect(ticks, lessThanOrEqualTo(6));
    });

    testWidgets('tapping jumps to the position', (tester) async {
      var value = 0.0;
      await pumpSurface(
        tester,
        StatefulBuilder(
          builder: (context, setState) => SizedBox(
            width: 300,
            child: TBSlider(
              value: value,
              onChanged: (v) => setState(() => value = v),
              semanticLabel: 'Volume',
            ),
          ),
        ),
        size: const Size(360, 120),
      );
      final box = tester.getRect(find.byType(TBSlider));
      await tester.tapAt(
        Offset(box.right - TBSizes.sliderKnob / 2, box.center.dy),
      );
      expect(value, closeTo(1, 0.01));
    });

    testWidgets('semantics: value and increase / decrease actions', (
      tester,
    ) async {
      final handle = tester.ensureSemantics();
      var value = 0.5;
      await pumpSurface(
        tester,
        SizedBox(
          width: 300,
          child: TBSlider(
            value: value,
            onChanged: (v) => value = v,
            semanticLabel: 'Music volume',
          ),
        ),
        size: const Size(360, 120),
      );
      final node = tester.getSemantics(find.byType(TBSlider));
      expect(node.label, 'Music volume');
      expect(node.value, '50%');
      expect(node.increasedValue, '60%');
      expect(node.decreasedValue, '40%');
      tester.semantics.increase(find.semantics.byLabel('Music volume'));
      expect(value, closeTo(0.6, 1e-9));
      tester.semantics.decrease(find.semantics.byLabel('Music volume'));
      expect(value, closeTo(0.4, 1e-9));
      handle.dispose();
    });

    testWidgets('disabled ignores drags and exposes no actions', (
      tester,
    ) async {
      final handle = tester.ensureSemantics();
      await pumpSurface(
        tester,
        const SizedBox(
          width: 300,
          child: TBSlider(value: 0.3, onChanged: null, semanticLabel: 'Locked'),
        ),
        size: const Size(360, 120),
      );
      await tester.drag(find.byType(TBSlider), const Offset(100, 0));
      expect(ticks, 0);
      expect(
        tester
            .getSemantics(find.byType(TBSlider))
            .getSemanticsData()
            .hasAction(SemanticsAction.increase),
        isFalse,
      );
      handle.dispose();
    });
  });

  group('TBTabBar', () {
    const tabs = [
      TBTabItem(icon: TBIconId.shop, label: 'Shop'),
      TBTabItem(icon: TBIconId.collection, label: 'Collection'),
      TBTabItem(icon: TBIconId.quests, label: 'Quests'),
    ];

    testWidgets('selecting another tab reports it with a haptic', (
      tester,
    ) async {
      var selected = 0;
      await pumpSurface(
        tester,
        StatefulBuilder(
          builder: (context, setState) => TBTabBar(
            tabs: tabs,
            selectedIndex: selected,
            onSelected: (i) => setState(() => selected = i),
          ),
        ),
        size: const Size(375, 160),
      );
      await tester.tap(find.text('Quests'));
      await tester.pumpAndSettle();
      expect(selected, 2);
      expect(selections, 1);
      // Tapping the selected tab again does nothing.
      await tester.tap(find.text('Quests'));
      await tester.pumpAndSettle();
      expect(selections, 1);
    });

    testWidgets('semantics: one selected tab, all labelled', (tester) async {
      final handle = tester.ensureSemantics();
      await pumpSurface(
        tester,
        TBTabBar(tabs: tabs, selectedIndex: 1, onSelected: (_) {}),
        size: const Size(375, 160),
      );
      final shop = find.semantics.byLabel('Shop').evaluate().single;
      final collection = find.semantics.byLabel('Collection').evaluate().single;
      expect(shop.flagsCollection.isSelected, ui.Tristate.isFalse);
      expect(collection.flagsCollection.isSelected, ui.Tristate.isTrue);
      handle.dispose();
    });
  });

  group('TBStarRow', () {
    testWidgets('stars stamp in one by one, 180 ms apart', (tester) async {
      await pumpSurface(
        tester,
        const TBStarRow(filled: 3),
        size: const Size(320, 140),
      );
      await tester.pump(const Duration(milliseconds: 1));
      expect(tester.hasRunningAnimations, isTrue, reason: 'first star stamps');
      await tester.pump(TBMotion.starStagger * 3 + TBMotion.celebrateMin);
      await tester.pumpAndSettle();
      expect(tester.hasRunningAnimations, isFalse);
    });

    testWidgets('semantics label counts the stars', (tester) async {
      final handle = tester.ensureSemantics();
      await pumpSurface(
        tester,
        const TBStarRow(filled: 2, animate: false),
        size: const Size(320, 140),
      );
      expect(find.bySemanticsLabel('2 of 3 stars'), findsOneWidget);
      handle.dispose();
    });

    testWidgets('earning another star animates only the new one', (
      tester,
    ) async {
      late StateSetter set;
      var filled = 1;
      await pumpSurface(
        tester,
        StatefulBuilder(
          builder: (context, setState) {
            set = setState;
            return TBStarRow(filled: filled);
          },
        ),
        size: const Size(320, 140),
      );
      await tester.pumpAndSettle();
      set(() => filled = 2);
      await tester.pump();
      await tester.pump(TBMotion.starStagger);
      await tester.pumpAndSettle();
      set(() => filled = 0);
      await tester.pump();
      expect(tester.takeException(), isNull);
    });

    testWidgets('Reduce Motion fades instead of stamping', (tester) async {
      await pumpSurface(
        tester,
        const TBStarRow(filled: 3),
        size: const Size(320, 140),
        disableAnimations: true,
      );
      await tester.pump(TBMotion.starStagger * 3 + TBMotion.celebrateMin);
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    });

    test('more than three stars is a programming error', () {
      expect(() => TBStarRow(filled: 4), throwsAssertionError);
      expect(() => TBStarRow(filled: -1), throwsAssertionError);
    });
  });

  group('TBProgressBar / TBFlowMeter', () {
    testWidgets('progress exposes its percentage', (tester) async {
      final handle = tester.ensureSemantics();
      await pumpSurface(
        tester,
        const SizedBox(
          width: 240,
          child: TBProgressBar(
            value: 0.55,
            semanticLabel: 'Restoration',
            shimmer: false,
          ),
        ),
        size: const Size(300, 80),
      );
      await tester.pumpAndSettle();
      final node = tester.getSemantics(find.byType(TBProgressBar));
      expect(node.label, 'Restoration');
      expect(node.value, '55%');
      handle.dispose();
    });

    testWidgets('the idle shimmer stops under Reduce Motion', (tester) async {
      await pumpSurface(
        tester,
        const SizedBox(width: 240, child: TBProgressBar(value: 0.5)),
        size: const Size(300, 80),
        disableAnimations: true,
      );
      await tester.pumpAndSettle();
      expect(tester.hasRunningAnimations, isFalse);
    });

    testWidgets('the shimmer runs otherwise', (tester) async {
      await pumpSurface(
        tester,
        const SizedBox(width: 240, child: TBProgressBar(value: 0.5)),
        size: const Size(300, 80),
      );
      await tester.pump(const Duration(milliseconds: 100));
      expect(tester.hasRunningAnimations, isTrue);
    });

    testWidgets('the fill animates to a new value', (tester) async {
      late StateSetter set;
      var v = 0.1;
      await pumpSurface(
        tester,
        StatefulBuilder(
          builder: (context, setState) {
            set = setState;
            return SizedBox(
              width: 240,
              child: TBProgressBar(value: v, shimmer: false),
            );
          },
        ),
        size: const Size(300, 80),
      );
      set(() => v = 0.9);
      await tester.pump();
      await tester.pump(TBMotion.enter * 0.5);
      expect(tester.hasRunningAnimations, isTrue);
      await tester.pumpAndSettle();
      expect(tester.hasRunningAnimations, isFalse);
    });

    testWidgets(
      'flow meter: badge only from x2; label carries the multiplier',
      (tester) async {
        final handle = tester.ensureSemantics();
        await pumpSurface(
          tester,
          SizedBox(
            width: 300,
            child: TBFlowMeter(
              fill: 0.4,
              color: ChapterTheme.mistyGarden.arrowColors[0],
            ),
          ),
          size: const Size(360, 80),
        );
        expect(find.text('×1'), findsNothing);
        expect(find.bySemanticsLabel('Flow ×1'), findsOneWidget);

        await pumpSurface(
          tester,
          SizedBox(
            width: 300,
            child: TBFlowMeter(
              fill: 0.8,
              color: ChapterTheme.mistyGarden.arrowColors[0],
              multiplier: 4,
            ),
          ),
          size: const Size(360, 80),
        );
        await tester.pumpAndSettle();
        expect(find.text('×4'), findsWidgets);
        expect(find.bySemanticsLabel('Flow ×4'), findsOneWidget);
        handle.dispose();
      },
    );

    testWidgets('the badge pops again when the multiplier rises', (
      tester,
    ) async {
      late StateSetter set;
      var m = 2;
      await pumpSurface(
        tester,
        StatefulBuilder(
          builder: (context, setState) {
            set = setState;
            return SizedBox(
              width: 300,
              child: TBFlowMeter(
                fill: 0.6,
                color: ChapterTheme.mistyGarden.arrowColors[0],
                multiplier: m,
              ),
            );
          },
        ),
        size: const Size(360, 80),
      );
      await tester.pumpAndSettle();
      set(() => m = 3);
      await tester.pump();
      await tester.pump(TBMotion.celebrateMin * 0.2);
      expect(tester.hasRunningAnimations, isTrue, reason: 'pop in progress');
      await tester.pumpAndSettle();
    });
  });

  group('overlays', () {
    Widget app(Widget Function(BuildContext) home) => WidgetsApp(
      color: TBColors.ink900,
      textStyle: const TextStyle(fontFamily: 'Nunito'),
      pageRouteBuilder: <T>(settings, builder) => PageRouteBuilder<T>(
        settings: settings,
        pageBuilder: (context, _, _) => builder(context),
      ),
      home: Builder(builder: home),
    );

    testWidgets('showTBSheet slides in, the scrim dismisses it', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(375, 667);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      await tester.pumpWidget(
        app(
          (context) => Center(
            child: TBButton.secondary(
              label: 'Open',
              onPressed: () => showTBSheet<void>(
                context,
                sheet: const TBSheet(
                  title: 'Level 37',
                  child: Text('Nice flow!', textDirection: TextDirection.ltr),
                ),
              ),
            ),
          ),
        ),
      );
      await tester.tap(find.byType(TBButton));
      await tester.pump();
      await tester.pump(TBMotion.enter ~/ 2);
      expect(find.text('Level 37'), findsWidgets);
      await tester.pumpAndSettle();
      expect(find.text('Nice flow!'), findsOneWidget);

      // Tap the scrim (top of the screen).
      await tester.tapAt(const Offset(187, 40));
      await tester.pumpAndSettle();
      expect(find.text('Nice flow!'), findsNothing);
    });

    testWidgets('a sheet can refuse scrim dismissal', (tester) async {
      tester.view.physicalSize = const Size(375, 667);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      await tester.pumpWidget(
        app(
          (context) => Center(
            child: TBButton.secondary(
              label: 'Open',
              onPressed: () => showTBSheet<void>(
                context,
                barrierDismissible: false,
                sheet: const TBSheet(
                  title: 'Pay',
                  child: Text('Sticky', textDirection: TextDirection.ltr),
                ),
              ),
            ),
          ),
        ),
      );
      await tester.tap(find.byType(TBButton));
      await tester.pumpAndSettle();
      await tester.tapAt(const Offset(187, 40));
      await tester.pumpAndSettle();
      expect(find.text('Sticky'), findsOneWidget);
    });

    testWidgets('showTBToast appears and hides itself after 2 s', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(375, 667);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      await tester.pumpWidget(
        app(
          (context) => Center(
            child: TBButton.secondary(
              label: 'Toast',
              onPressed: () => showTBToast(context, 'Nice flow!'),
            ),
          ),
        ),
      );
      await tester.tap(find.byType(TBButton));
      await tester.pump();
      await tester.pump(TBMotion.enter);
      expect(find.text('Nice flow!'), findsOneWidget);
      await tester.pump(TBMotion.toast);
      await tester.pump(TBMotion.enter);
      await tester.pumpAndSettle();
      expect(find.text('Nice flow!'), findsNothing);
    });

    testWidgets('toasts fade under Reduce Motion', (tester) async {
      tester.view.physicalSize = const Size(375, 667);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      await tester.pumpWidget(
        MediaQuery(
          data: const MediaQueryData(disableAnimations: true),
          child: app(
            (context) => Center(
              child: TBButton.secondary(
                label: 'Toast',
                onPressed: () =>
                    showTBToast(context, 'Hi', icon: TBIconId.hint),
              ),
            ),
          ),
        ),
      );
      await tester.tap(find.byType(TBButton));
      await tester.pump();
      await tester.pump(TBMotion.reducedMotionFade);
      expect(find.text('Hi'), findsOneWidget);
      await tester.pump(TBMotion.toast);
      await tester.pumpAndSettle();
      expect(find.text('Hi'), findsNothing);
    });
  });

  group('TBChapterCard', () {
    testWidgets('announces name and restoration; tap works', (tester) async {
      final handle = tester.ensureSemantics();
      var taps = 0;
      await pumpSurface(
        tester,
        TBChapterCard(
          chapter: ChapterTheme.mistyGarden,
          restoration: 0.42,
          onTap: () => taps++,
        ),
        size: const Size(340, 420),
        surface: TestSurface.ink,
      );
      expect(
        tester.getSemantics(find.byType(TBChapterCard)).label,
        'Misty Garden, 42 percent restored',
      );
      await tester.tap(find.byType(TBChapterCard));
      expect(taps, 1);
      handle.dispose();
    });

    testWidgets('locked cards say so and ignore taps', (tester) async {
      final handle = tester.ensureSemantics();
      var taps = 0;
      await pumpSurface(
        tester,
        TBChapterCard(
          chapter: ChapterTheme.lanternBazaar,
          restoration: 0,
          locked: true,
          onTap: () => taps++,
        ),
        size: const Size(340, 420),
        surface: TestSurface.ink,
      );
      expect(
        tester.getSemantics(find.byType(TBChapterCard)).label,
        'Lantern Bazaar, locked',
      );
      await tester.tap(find.byType(TBChapterCard));
      expect(taps, 0);
      handle.dispose();
    });

    testWidgets('tilts 4 degrees, relaxes to 0 when focused', (tester) async {
      Matrix4 tilt() => tester
          .widgetList<Transform>(find.byType(Transform))
          .firstWhere((t) => t.transform.entry(3, 2) != 0)
          .transform;

      late StateSetter set;
      var focused = false;
      await pumpSurface(
        tester,
        StatefulBuilder(
          builder: (context, setState) {
            set = setState;
            return TBChapterCard(
              chapter: ChapterTheme.mistyGarden,
              restoration: 0.1,
              focused: focused,
            );
          },
        ),
        size: const Size(340, 420),
        surface: TestSurface.ink,
      );
      await tester.pumpAndSettle();
      // cos(4 deg) = 0.99756.
      expect(tilt().entry(1, 1), closeTo(0.99756, 1e-4));

      set(() => focused = true);
      await tester.pumpAndSettle();
      expect(tilt().entry(1, 1), closeTo(1, 1e-9));
    });

    test('restoration outside 0-1 is a programming error', () {
      expect(
        () =>
            TBChapterCard(chapter: ChapterTheme.mistyGarden, restoration: 1.5),
        throwsAssertionError,
      );
    });
  });

  group('panels and ribbons', () {
    testWidgets('panel keeps its content above the bevel strip', (
      tester,
    ) async {
      await pumpSurface(
        tester,
        const TBPanel(child: SizedBox(width: 100, height: 40)),
        size: const Size(240, 160),
      );
      final size = tester.getSize(find.byType(TBPanel));
      expect(size.height, 40 + TBSpacing.s16 * 2 + TBBevel.panelBevel);
    });

    testWidgets('recessed constructor sets the flag', (tester) async {
      await pumpSurface(
        tester,
        const TBPanel.recessed(child: SizedBox(width: 50, height: 20)),
      );
      expect(tester.widget<TBPanel>(find.byType(TBPanel)).recessed, isTrue);
    });

    testWidgets('ribbons are headers with the title as label', (tester) async {
      final handle = tester.ensureSemantics();
      await pumpSurface(
        tester,
        const TBRibbon('Out of hearts', kind: TBRibbonKind.berry),
        size: const Size(320, 120),
      );
      final node = tester.getSemantics(find.byType(TBRibbon));
      expect(node.label, 'Out of hearts');
      expect(node.flagsCollection.isHeader, isTrue);
      handle.dispose();
    });

    testWidgets('compact ribbon is smaller', (tester) async {
      await pumpSurface(
        tester,
        const TBRibbon('A', compact: true),
        size: const Size(320, 120),
      );
      final compact = tester.getSize(find.byType(TBRibbon)).height;
      await pumpSurface(
        tester,
        const TBRibbon('A'),
        size: const Size(320, 120),
      );
      expect(compact, lessThan(tester.getSize(find.byType(TBRibbon)).height));
    });

    testWidgets('toast is a live region', (tester) async {
      final handle = tester.ensureSemantics();
      await pumpSurface(
        tester,
        const TBToast('Nice flow!'),
        size: const Size(320, 120),
      );
      final node = tester.getSemantics(find.byType(TBToast));
      expect(node.label, 'Nice flow!');
      expect(node.flagsCollection.isLiveRegion, isTrue);
      handle.dispose();
    });
  });
}
