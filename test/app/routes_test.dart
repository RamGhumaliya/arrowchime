import 'package:arrowchime/app/router.dart';
import 'package:arrowchime/features/design_gallery/design_gallery_screen.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import '../features/meta/meta_harness.dart';

void main() {
  const labels = <String, String>{
    AppRoutes.splash: 'Arrowchime',
    AppRoutes.home: 'PLAY · Level 1',
    AppRoutes.chapterMap: 'Chapters',
    AppRoutes.daily: 'Daily Knot #283',
    AppRoutes.shop: 'Shop',
    AppRoutes.collection: 'Collection',
    AppRoutes.achievements: 'Achievements',
    AppRoutes.settings: 'Settings',
    AppRoutes.levelLab: 'Level Lab',
  };

  for (final entry in labels.entries) {
    testWidgets('route ${entry.key} shows ${entry.value}', (tester) async {
      await pumpApp(tester, location: entry.key);
      expect(find.text(entry.value), findsWidgets);
    });
  }

  testWidgets('the design gallery route shows the gallery (debug only)', (
    tester,
  ) async {
    await pumpApp(
      tester,
      location: AppRoutes.designGallery,
      size: const Size(375, 800),
      dpr: 1,
    );
    expect(find.byType(DesignGalleryScreen), findsOneWidget);
  });

  testWidgets('a malformed level route falls back to the stub', (tester) async {
    await pumpApp(tester, location: AppRoutes.levelPath('ch9', 7));
    expect(find.text('Level ch9 · 7'), findsOneWidget);
  });

  testWidgets('daily play only opens for today and the last 30 days', (
    tester,
  ) async {
    await pumpApp(tester, location: AppRoutes.dailyPlayPath('2026-12-31'));
    expect(find.text('Daily Knot'), findsWidgets);
    expect(find.text('Level 283'), findsNothing);
  });
}
