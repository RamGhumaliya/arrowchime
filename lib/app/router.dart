import 'package:arrowchime/app/stub_screen.dart';
import 'package:arrowchime/core/meta/date_key.dart';
import 'package:arrowchime/features/achievements/achievements_screen.dart';
import 'package:arrowchime/features/chapter_map/chapter_map_screen.dart';
import 'package:arrowchime/features/daily/daily_screen.dart';
import 'package:arrowchime/features/design_gallery/design_gallery_screen.dart';
import 'package:arrowchime/features/game/game_screen.dart';
import 'package:arrowchime/features/game/state/level_ref.dart';
import 'package:arrowchime/features/home/home_screen.dart';
import 'package:arrowchime/features/level_lab/level_lab_screen.dart';
import 'package:arrowchime/features/settings/settings_screen.dart';
import 'package:arrowchime/features/splash/splash_screen.dart';
import 'package:arrowchime/l10n/gen/app_localizations.dart';
import 'package:flutter/foundation.dart';
import 'package:go_router/go_router.dart';

/// Route paths. Deep links from notifications use `/daily` and
/// `/level/ch1/7` (`docs/05` §1).
abstract final class AppRoutes {
  static const splash = '/';
  static const home = '/home';
  static const chapterMap = '/chapters';
  static const level = '/level/:chapter/:index';
  static const daily = '/daily';
  static const dailyPlay = '/daily/play/:date';
  static const shop = '/shop';
  static const collection = '/collection';
  static const achievements = '/achievements';
  static const settings = '/settings';
  static const designGallery = '/design-gallery';
  static const levelLab = '/level-lab';

  static String levelPath(String chapter, int index) =>
      '/level/$chapter/$index';

  static String dailyPlayPath(String date) => '/daily/play/$date';
}

/// A Daily Knot may be played for today or a missed day of the last 30 days.
bool _validDailyDate(String? date, DateTime now) {
  if (date == null || !RegExp(r'^\d{4}-\d{2}-\d{2}$').hasMatch(date)) {
    return false;
  }
  final ago = DateKey.daysBetween(date, DateKey.utc(now));
  return ago >= 0 && ago < 30;
}

GoRouter createRouter({String initialLocation = AppRoutes.splash}) {
  return GoRouter(
    initialLocation: initialLocation,
    routes: [
      GoRoute(
        path: AppRoutes.splash,
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: AppRoutes.home,
        builder: (context, state) => const HomeScreen(),
      ),
      GoRoute(
        path: AppRoutes.chapterMap,
        builder: (context, state) => const ChapterMapScreen(),
      ),
      GoRoute(
        path: AppRoutes.level,
        builder: (context, state) {
          final id = LevelRef.parse(
            state.pathParameters['chapter'],
            state.pathParameters['index'],
          );
          if (id == null) {
            return StubScreen(
              label: AppLocalizations.of(context).routeLevel(
                '${state.pathParameters['chapter']} · '
                '${state.pathParameters['index']}',
              ),
            );
          }
          return GameScreen(levelRef: id);
        },
      ),
      GoRoute(
        path: AppRoutes.daily,
        builder: (context, state) => const DailyScreen(),
      ),
      GoRoute(
        path: AppRoutes.dailyPlay,
        builder: (context, state) {
          final date = state.pathParameters['date'];
          if (!_validDailyDate(date, DateTime.now())) {
            return StubScreen(label: AppLocalizations.of(context).routeDaily);
          }
          return GameScreen(levelRef: LevelRef.dailyOf(date!));
        },
      ),
      GoRoute(
        path: AppRoutes.shop,
        builder: (context, state) =>
            StubScreen(label: AppLocalizations.of(context).routeShop),
      ),
      GoRoute(
        path: AppRoutes.collection,
        builder: (context, state) =>
            StubScreen(label: AppLocalizations.of(context).routeCollection),
      ),
      GoRoute(
        path: AppRoutes.achievements,
        builder: (context, state) => const AchievementsScreen(),
      ),
      GoRoute(
        path: AppRoutes.settings,
        builder: (context, state) => const SettingsScreen(),
      ),
      // Debug-only tooling (B1 exception: Level Lab / Design Gallery).
      if (kDebugMode) ...[
        GoRoute(
          path: AppRoutes.designGallery,
          builder: (context, state) => const DesignGalleryScreen(),
        ),
        GoRoute(
          path: AppRoutes.levelLab,
          builder: (context, state) => const LevelLabScreen(),
        ),
      ],
    ],
  );
}
