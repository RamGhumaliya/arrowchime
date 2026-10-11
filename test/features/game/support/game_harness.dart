import 'dart:io';

import 'package:arrowchime/core/ads/ads_controller.dart';
import 'package:arrowchime/core/ads/ads_service.dart';
import 'package:arrowchime/core/audio/audio_service.dart';
import 'package:arrowchime/core/haptics/haptics_service.dart';
import 'package:arrowchime/core/level/models/level.dart';
import 'package:arrowchime/core/level/pack_loader.dart';
import 'package:arrowchime/core/save/save_controller.dart';
import 'package:arrowchime/features/game/game_screen.dart';
import 'package:arrowchime/features/game/state/game_session.dart';
import 'package:arrowchime/features/game/state/level_ref.dart';
import 'package:arrowchime/features/game/state/level_repository.dart';
import 'package:arrowchime/l10n/gen/app_localizations.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:flutter_test/flutter_test.dart';

import '../../../core/ui/support/ui_harness.dart';
import '../../../support/fakes.dart';

/// A level of a shipped chapter pack, read from disk.
Level shippedLevel(LevelRef id) {
  final text = File('assets/levels/ch${id.chapter}.json').readAsStringSync();
  return PackLoader.parsePack(text, validate: false).levels[id.index - 1];
}

/// Overrides that keep tests silent and let them see what was played.
List<Override> feedbackOverrides(
  FakeAudioBackend audio,
  FakeHaptics haptics, [
  FakeAdsService? ads,
]) => [
  adsServiceProvider.overrideWithValue(ads ?? FakeAdsService()),
  saveDebounceProvider.overrideWithValue(null),
  audioBackendProvider.overrideWithValue(audio),
  hapticsProvider.overrideWithValue(haptics),
];

class GameHarness {
  new(this.container, this.id, {this.audio, this.haptics});

  final ProviderContainer container;
  final LevelRef id;
  final FakeAudioBackend? audio;
  final FakeHaptics? haptics;

  GameSession get session => container.read(gameSessionProvider(id).notifier);
}

/// Pumps the game screen for [id] on a [size] logical screen.
Future<GameHarness> pumpGame(
  WidgetTester tester, {
  required LevelRef id,
  Level? level,
  Size size = const Size(390, 844),
  double dpr = 2,
  bool disableAnimations = false,
}) {
  final audio = FakeAudioBackend();
  final haptics = FakeHaptics();
  final container = ProviderContainer(
    overrides: [
      levelProvider(id).overrideWith((ref) => level ?? shippedLevel(id)),
      ...feedbackOverrides(audio, haptics),
    ],
  );
  addTearDown(container.dispose);
  return pumpGameWith(
    tester,
    container,
    id: id,
    size: size,
    dpr: dpr,
    disableAnimations: disableAnimations,
    audio: audio,
    haptics: haptics,
  );
}

/// Like [pumpGame] with a caller-made [container] (custom overrides).
Future<GameHarness> pumpGameWith(
  WidgetTester tester,
  ProviderContainer container, {
  required LevelRef id,
  Level? level,
  Size size = const Size(390, 844),
  double dpr = 2,
  bool disableAnimations = false,
  FakeAudioBackend? audio,
  FakeHaptics? haptics,
}) async {
  tester.view
    ..devicePixelRatio = dpr
    ..physicalSize = size * dpr;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(
    UncontrolledProviderScope(
      container: container,
      child: WidgetsApp(
        color: const Color(0xFF000000),
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
        ],
        supportedLocales: AppLocalizations.supportedLocales,
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(context)
              .copyWith(disableAnimations: disableAnimations),
          child: RepaintBoundary(key: surfaceKey, child: child),
        ),
        pageRouteBuilder: <T>(settings, builder) => PageRouteBuilder<T>(
          settings: settings,
          pageBuilder: (context, _, _) => builder(context),
        ),
        home: GameScreen(levelRef: id),
      ),
    ),
  );
  await settle(tester);
  return GameHarness(container, id, audio: audio, haptics: haptics);
}

/// Lets the level load, the Flame game boot and a few frames run. The Flame
/// loop never "settles", so `pumpAndSettle` is not an option.
Future<void> settle(WidgetTester tester, {int frames = 8}) async {
  for (var i = 0; i < frames; i++) {
    await tester.pump(const Duration(milliseconds: 50));
  }
}
