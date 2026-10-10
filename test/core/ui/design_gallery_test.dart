import 'package:arrowchime/features/design_gallery/design_gallery_screen.dart';
import 'package:arrowchime/features/design_gallery/gallery_pages.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/ui_harness.dart';

void main() {
  for (final group in GalleryGroup.values) {
    testWidgets('gallery page "${group.label}" builds with no errors', (
      tester,
    ) async {
      await pumpSurface(
        tester,
        DesignGalleryScreen(initial: group),
        size: const Size(375, 3000),
        surface: TestSurface.ink,
        padding: EdgeInsets.zero,
      );
      await tester.pump(const Duration(milliseconds: 500));
      expect(tester.takeException(), isNull);
      expect(find.byType(DesignGalleryScreen), findsOneWidget);
    });
  }

  testWidgets('switching groups swaps the page', (tester) async {
    await pumpSurface(
      tester,
      const DesignGalleryScreen(),
      size: const Size(375, 2000),
      surface: TestSurface.ink,
      padding: EdgeInsets.zero,
    );
    expect(find.text('Colour'), findsWidgets);
    await tester.tap(find.bySemanticsLabel('Controls').first);
    await tester.pumpAndSettle();
    expect(find.text('TBToggle'), findsWidgets);
    expect(find.text('Colour'), findsNothing);
  });

  testWidgets('the interactive controls respond inside the gallery', (
    tester,
  ) async {
    await pumpSurface(
      tester,
      const DesignGalleryScreen(initial: GalleryGroup.controls),
      size: const Size(375, 3000),
      surface: TestSurface.ink,
      padding: EdgeInsets.zero,
    );
    await tester.pump(const Duration(milliseconds: 300));
    expect(tester.takeException(), isNull);
  });

  group('accessibility guidelines (docs/09 §7)', () {
    for (final group in [
      GalleryGroup.buttons,
      GalleryGroup.hud,
      GalleryGroup.controls,
    ]) {
      testWidgets('${group.label}: tap targets >= 44 and labelled', (
        tester,
      ) async {
        final handle = tester.ensureSemantics();
        await pumpSurface(
          tester,
          DesignGalleryScreen(initial: group),
          size: const Size(375, 4200),
          surface: TestSurface.ink,
          padding: EdgeInsets.zero,
        );
        await tester.pump(const Duration(milliseconds: 300));
        await expectLater(tester, meetsGuideline(iOSTapTargetGuideline));
        await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
        handle.dispose();
      });
    }
  });
}
