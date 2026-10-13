import 'package:arrowchime/app/theme/chapter_theme.dart';
import 'package:arrowchime/app/theme/tokens.dart';
import 'package:arrowchime/core/ui/components/tb_button.dart';
import 'package:arrowchime/core/ui/components/tb_flow_meter.dart';
import 'package:arrowchime/core/ui/components/tb_icon_button.dart';
import 'package:arrowchime/core/ui/components/tb_pill.dart';
import 'package:arrowchime/core/ui/components/tb_ribbon.dart';
import 'package:arrowchime/core/ui/components/tb_sheet.dart';
import 'package:arrowchime/core/ui/components/tb_star_row.dart';
import 'package:arrowchime/core/ui/components/tb_tab_bar.dart';
import 'package:arrowchime/core/ui/components/tb_text.dart';
import 'package:arrowchime/core/ui/components/tb_toast.dart';
import 'package:arrowchime/core/ui/icons/tb_icon_id.dart';
import 'package:arrowchime/core/ui/support/tb_layout.dart';
import 'package:arrowchime/features/design_gallery/design_gallery_screen.dart';
import 'package:arrowchime/features/design_gallery/gallery_pages.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/ui_harness.dart';

/// Components adapt to narrow boxes, large text and wide screens
/// (`docs/09` §7, `docs/03` §9): nothing overflows, targets stay >= 44 dp.
void main() {
  group('narrow containers and big text', () {
    testWidgets('a long button label ellipsises instead of overflowing', (
      tester,
    ) async {
      await pumpSurface(
        tester,
        SizedBox(
          width: 140,
          child: TBButton.primary(
            label: 'Continue to the next chapter',
            onPressed: () {},
            expand: true,
          ),
        ),
        size: const Size(220, 140),
      );
      expect(tester.takeException(), isNull);
      expect(tester.getSize(find.byType(TBButton)).width, 140);
    });

    testWidgets('buttons grow with the text scale and keep a 44 dp target', (
      tester,
    ) async {
      for (final kind in TBButtonKind.values) {
        await pumpSurface(
          tester,
          TBButton(label: 'Play', onPressed: () {}, kind: kind),
          textScale: 2,
        );
        final h = tester.getSize(find.byType(TBButton)).height;
        expect(
          h,
          greaterThanOrEqualTo(TBSizes.minTapTarget),
          reason: kind.name,
        );
        if (kind == TBButtonKind.tertiary) {
          expect(h, greaterThan(TBSizes.buttonTertiaryHeight));
        }
        expect(tester.takeException(), isNull);
      }
    });

    testWidgets('nominal heights are unchanged at 1x text', (tester) async {
      await pumpSurface(
        tester,
        TBButton.primary(label: 'Play', onPressed: () {}),
      );
      expect(tester.getSize(find.byType(TBButton)).height, 64);
    });

    testWidgets('a long ribbon title scales down inside a narrow box', (
      tester,
    ) async {
      await pumpSurface(
        tester,
        const SizedBox(
          width: 240,
          child: TBRibbon('A very long chapter title indeed'),
        ),
        size: const Size(300, 140),
        textScale: 1.5,
      );
      expect(tester.takeException(), isNull);
    });

    testWidgets('the ribbon grows with the text scale', (tester) async {
      await pumpSurface(
        tester,
        const TBRibbon('Level 37'),
        size: const Size(320, 160),
      );
      final base = tester.getSize(find.byType(TBRibbon)).height;
      await pumpSurface(
        tester,
        const TBRibbon('Level 37'),
        size: const Size(320, 160),
        textScale: 1.8,
      );
      expect(tester.getSize(find.byType(TBRibbon)).height, greaterThan(base));
    });

    testWidgets('a long pill value ellipsises; the pill grows with text', (
      tester,
    ) async {
      await pumpSurface(
        tester,
        const SizedBox(
          width: 150,
          child: TBPill(icon: TBIconId.coin, value: '123,456,789,012'),
        ),
        size: const Size(220, 120),
        textScale: 1.5,
      );
      expect(tester.takeException(), isNull);
      expect(
        tester.getSize(find.byType(TBPill)).height,
        greaterThan(TBSizes.pillHeight),
      );
    });

    testWidgets('the tab bar grows taller instead of clipping its labels', (
      tester,
    ) async {
      const tabs = [
        TBTabItem(icon: TBIconId.shop, label: 'Shop'),
        TBTabItem(icon: TBIconId.collection, label: 'Collection'),
        TBTabItem(icon: TBIconId.quests, label: 'Quests'),
      ];
      await pumpSurface(
        tester,
        TBTabBar(tabs: tabs, selectedIndex: 1, onSelected: (_) {}),
        size: const Size(280, 200),
      );
      final base = tester.getSize(find.byType(TBTabBar)).height;
      await pumpSurface(
        tester,
        TBTabBar(tabs: tabs, selectedIndex: 1, onSelected: (_) {}),
        size: const Size(280, 220),
        textScale: 2,
      );
      expect(tester.takeException(), isNull);
      expect(tester.getSize(find.byType(TBTabBar)).height, greaterThan(base));
    });

    testWidgets('three stars scale down into a narrow box', (tester) async {
      await pumpSurface(
        tester,
        const SizedBox(width: 150, child: TBStarRow(filled: 3, animate: false)),
        size: const Size(220, 120),
      );
      expect(tester.takeException(), isNull);
      expect(
        tester.getSize(find.byType(TBStarRow)).width,
        lessThanOrEqualTo(150),
      );
    });

    testWidgets('the flow meter works in a narrow box', (tester) async {
      await pumpSurface(
        tester,
        SizedBox(
          width: 180,
          child: TBFlowMeter(
            fill: 0.7,
            color: ChapterTheme.mistyGarden.arrowColors[0],
            multiplier: 5,
          ),
        ),
        size: const Size(240, 100),
      );
      expect(tester.takeException(), isNull);
    });

    testWidgets('a toast wraps long copy', (tester) async {
      await pumpSurface(
        tester,
        const SizedBox(
          width: 220,
          child: TBToast(
            'Hold to peek the path, then let go to hide it again.',
            icon: TBIconId.hint,
          ),
        ),
        size: const Size(300, 200),
        textScale: 1.3,
      );
      expect(tester.takeException(), isNull);
    });

    testWidgets('icon buttons keep their 56 dp size at any text scale', (
      tester,
    ) async {
      await pumpSurface(
        tester,
        TBIconButton(
          icon: TBIconId.hint,
          onPressed: () {},
          semanticLabel: 'Hint',
          badge: '12',
        ),
        textScale: 2,
      );
      expect(tester.getSize(find.byType(TBIconButton)).shortestSide, 56);
    });

    testWidgets('caption and body text honour the text scale', (tester) async {
      await pumpSurface(tester, const TBText.body('Scale me'));
      final base = tester.getSize(find.text('Scale me')).height;
      await pumpSurface(tester, const TBText.body('Scale me'), textScale: 1.5);
      expect(tester.getSize(find.text('Scale me')).height, greaterThan(base));
    });
  });

  group('tablets and wide screens', () {
    testWidgets('a sheet is capped at 560 dp and centred on a tablet', (
      tester,
    ) async {
      await pumpSurface(
        tester,
        const Align(
          alignment: Alignment.bottomCenter,
          child: TBSheet(
            title: 'Level 37',
            child: SizedBox(height: 60, child: Text('x')),
          ),
        ),
        size: const Size(1280, 800),
        surface: TestSurface.ink,
        padding: EdgeInsets.zero,
      );
      final rect = tester.getRect(find.byType(TBSheet));
      expect(rect.width, lessThanOrEqualTo(TBSizes.sheetMaxWidth + 2 * 32));
      expect(rect.center.dx, closeTo(640, 1));
    });

    testWidgets('a sheet fills a phone minus the 16 dp margins', (
      tester,
    ) async {
      await pumpSurface(
        tester,
        const Align(
          alignment: Alignment.bottomCenter,
          child: TBSheet(
            title: 'Level 37',
            child: SizedBox(height: 60, child: Text('x')),
          ),
        ),
        size: const Size(375, 667),
        surface: TestSurface.ink,
        padding: EdgeInsets.zero,
      );
      expect(tester.getSize(find.byType(TBSheet)).width, 375);
    });

    testWidgets('the gallery centres its content and widens the margin', (
      tester,
    ) async {
      await pumpSurface(
        tester,
        const DesignGalleryScreen(initial: GalleryGroup.buttons),
        size: const Size(1280, 800),
        surface: TestSurface.ink,
        padding: EdgeInsets.zero,
      );
      final column = find.descendant(
        of: find.byType(TBCentered),
        matching: find.byType(Column),
      );
      final rect = tester.getRect(column.first);
      expect(rect.width, lessThanOrEqualTo(TBSizes.contentMaxWidth));
      expect(rect.center.dx, closeTo(640, 2));
    });
  });

  group('TBLayout', () {
    Future<BuildContext> contextOf(
      WidgetTester tester,
      Size size,
      double scale,
    ) async {
      late BuildContext captured;
      await pumpSurface(
        tester,
        Builder(
          builder: (context) {
            captured = context;
            return const SizedBox();
          },
        ),
        size: size,
        textScale: scale,
      );
      return captured;
    }

    testWidgets('tablet starts at a 600 dp shortest side', (tester) async {
      expect(
        TBLayout.isTablet(await contextOf(tester, const Size(599, 900), 1)),
        isFalse,
      );
      expect(
        TBLayout.isTablet(await contextOf(tester, const Size(600, 900), 1)),
        isTrue,
      );
      expect(
        TBLayout.isTablet(await contextOf(tester, const Size(1280, 800), 1)),
        isTrue,
      );
      // A landscape phone is still a phone.
      expect(
        TBLayout.isTablet(await contextOf(tester, const Size(844, 390), 1)),
        isFalse,
      );
    });

    testWidgets('screen margin is 16 on phones, 32 on tablets', (tester) async {
      expect(
        TBLayout.screenMargin(await contextOf(tester, const Size(390, 844), 1)),
        TBSpacing.screenMarginPhone,
      );
      expect(
        TBLayout.screenMargin(
          await contextOf(tester, const Size(768, 1024), 1),
        ),
        TBSpacing.screenMarginTablet,
      );
    });

    testWidgets('scaledLine follows the user text scale', (tester) async {
      final one = TBLayout.scaledLine(
        await contextOf(tester, const Size(375, 667), 1),
        20,
      );
      final big = TBLayout.scaledLine(
        await contextOf(tester, const Size(375, 667), 1.5),
        20,
      );
      expect(one, closeTo(25, 0.01));
      expect(
        TBLayout.extraLine(
          await contextOf(tester, const Size(375, 667), 1),
          20,
        ),
        0,
      );
      expect(
        TBLayout.extraLine(
          await contextOf(tester, const Size(375, 667), 1.5),
          20,
        ),
        closeTo(12.5, 0.01),
      );
      expect(big, closeTo(37.5, 0.01));
    });

    testWidgets('TBCentered caps the width and centres', (tester) async {
      await pumpSurface(
        tester,
        const TBCentered(
          maxWidth: 300,
          child: SizedBox(
            key: ValueKey('inner'),
            width: double.infinity,
            height: 40,
          ),
        ),
        size: const Size(800, 200),
        padding: EdgeInsets.zero,
      );
      final rect = tester.getRect(find.byKey(const ValueKey('inner')));
      expect(rect.width, 300);
      expect(rect.center.dx, closeTo(400, 1));
    });
  });
}
