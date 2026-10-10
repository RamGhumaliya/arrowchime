import 'package:arrowchime/app/router.dart';
import 'package:arrowchime/l10n/gen/app_localizations.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const labels = <String, String>{
    AppRoutes.splash: 'Arrowchime',
    AppRoutes.home: 'Home',
    AppRoutes.chapterMap: 'Chapters',
    AppRoutes.daily: 'Daily Knot',
    AppRoutes.shop: 'Shop',
    AppRoutes.collection: 'Collection',
    AppRoutes.achievements: 'Achievements',
    AppRoutes.settings: 'Settings',
    AppRoutes.designGallery: 'Design Gallery',
    AppRoutes.levelLab: 'Level Lab',
  };

  for (final entry in labels.entries) {
    testWidgets('route ${entry.key} shows ${entry.value}', (tester) async {
      final router = createRouter();
      addTearDown(router.dispose);
      await tester.pumpWidget(
        WidgetsApp.router(
          routerConfig: router,
          color: const Color(0xFF000000),
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
          ],
          supportedLocales: AppLocalizations.supportedLocales,
        ),
      );
      router.go(entry.key);
      await tester.pumpAndSettle();
      expect(find.text(entry.value), findsOneWidget);
    });
  }

  testWidgets('level route reads chapter and index', (tester) async {
    final router = createRouter();
    addTearDown(router.dispose);
    await tester.pumpWidget(
      WidgetsApp.router(
        routerConfig: router,
        color: const Color(0xFF000000),
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
        ],
        supportedLocales: AppLocalizations.supportedLocales,
      ),
    );
    router.go(AppRoutes.levelPath('ch1', 7));
    await tester.pumpAndSettle();
    expect(find.text('Level ch1 · 7'), findsOneWidget);
  });
}
