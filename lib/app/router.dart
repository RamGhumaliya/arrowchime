import 'package:arrowchime/app/stub_screen.dart';
import 'package:arrowchime/features/design_gallery/design_gallery_screen.dart';
import 'package:arrowchime/features/game/game_screen.dart';
import 'package:arrowchime/features/game/state/level_ref.dart';
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
  static const shop = '/shop';
  static const collection = '/collection';
  static const achievements = '/achievements';
  static const settings = '/settings';
  static const designGallery = '/design-gallery';
  static const levelLab = '/level-lab';

  static String levelPath(String chapter, int index) =>
      '/level/$chapter/$index';
}

GoRouter createRouter() {
  return GoRouter(
    routes: [
      GoRoute(
        path: AppRoutes.splash,
        builder: (context, state) => StubScreen(
          label: AppLocalizations.of(context).routeSplash,
          // Until Home exists (Phase 6/7): a way into the game in dev builds.
          actionLabel: kReleaseMode
              ? null
              : AppLocalizations.of(context).devPlay,
          onAction: () => context.go(AppRoutes.levelPath('ch1', 1)),
        ),
      ),
      GoRoute(
        path: AppRoutes.home,
        builder: (context, state) =>
            StubScreen(label: AppLocalizations.of(context).routeHome),
      ),
      GoRoute(
        path: AppRoutes.chapterMap,
        builder: (context, state) =>
            StubScreen(label: AppLocalizations.of(context).routeChapterMap),
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
        builder: (context, state) =>
            StubScreen(label: AppLocalizations.of(context).routeDaily),
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
        builder: (context, state) =>
            StubScreen(label: AppLocalizations.of(context).routeAchievements),
      ),
      GoRoute(
        path: AppRoutes.settings,
        builder: (context, state) =>
            StubScreen(label: AppLocalizations.of(context).routeSettings),
      ),
      // Debug-only tooling (B1 exception: Level Lab / Design Gallery).
      if (kDebugMode) ...[
        GoRoute(
          path: AppRoutes.designGallery,
          builder: (context, state) => const DesignGalleryScreen(),
        ),
        GoRoute(
          path: AppRoutes.levelLab,
          builder: (context, state) =>
              StubScreen(label: AppLocalizations.of(context).routeLevelLab),
        ),
      ],
    ],
  );
}
