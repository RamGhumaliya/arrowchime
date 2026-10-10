import 'dart:io';

import 'package:arrowchime/app/app.dart';
import 'package:arrowchime/app/router.dart';
import 'package:arrowchime/core/save/save_controller.dart';
import 'package:arrowchime/core/save/save_data.dart';
import 'package:arrowchime/core/save/save_repository.dart';
import 'package:arrowchime/core/share/share_service.dart';
import 'package:arrowchime/features/game/state/level_repository.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../core/ui/support/ui_harness.dart';
import '../../support/fakes.dart';
import '../game/support/game_harness.dart';

/// Reads assets straight from the project folder, so level packs load within
/// the test's fake clock (the real bundle needs real async I/O).
class DiskAssetBundle extends CachingAssetBundle {
  // `loadString` of big files decodes in an isolate, which a fake clock never
  // finishes: read the text directly.
  @override
  Future<String> loadString(String key, {bool cache = true}) {
    final file = File(key);
    if (!file.existsSync()) return Future.error(FlutterError('no asset $key'));
    return Future.value(file.readAsStringSync());
  }

  @override
  Future<ByteData> load(String key) {
    final file = File(key);
    if (!file.existsSync()) return Future.error(FlutterError('no asset $key'));
    final bytes = file.readAsBytesSync();
    return Future.value(ByteData.sublistView(Uint8List.fromList(bytes)));
  }
}

/// Records what would be shared.
class FakeShare implements ShareService {
  final List<({String text, bool hasImage})> shared = [];

  @override
  Future<void> share({required String text, Uint8List? image}) async {
    shared.add((text: text, hasImage: image != null));
  }
}

/// The app at a given location with a fixed clock, an in-memory save (optionally
/// pre-filled) and silent audio.
class AppHarness {
  new(this.container, this.audio, this.haptics, this.share);

  final ProviderContainer container;
  final FakeAudioBackend audio;
  final FakeHaptics haptics;
  final FakeShare share;

  SaveData get save => container.read(saveControllerProvider);
}

/// 2026-10-10 14:30 local (a Saturday).
final DateTime testNow = DateTime(2026, 10, 10, 14, 30);

Future<AppHarness> pumpApp(
  WidgetTester tester, {
  String location = AppRoutes.home,
  SaveData? save,
  Size size = const Size(390, 844),
  double dpr = 2,
  DateTime? now,
}) async {
  tester.view
    ..devicePixelRatio = dpr
    ..physicalSize = size * dpr;
  addTearDown(tester.view.reset);
  final audio = FakeAudioBackend();
  final haptics = FakeHaptics();
  final share = FakeShare();
  final store = MemorySaveStore();
  if (save != null) await SaveRepository(store).save(save);
  final container = ProviderContainer(
    overrides: [
      saveRepositoryProvider.overrideWithValue(SaveRepository(store)),
      clockProvider.overrideWithValue(() => now ?? testNow),
      shareServiceProvider.overrideWithValue(share),
      levelBundleProvider.overrideWithValue(DiskAssetBundle()),
      ...feedbackOverrides(audio, haptics),
    ],
  );
  addTearDown(container.dispose);
  final router = createRouter(initialLocation: location);
  addTearDown(router.dispose);
  await tester.pumpWidget(
    UncontrolledProviderScope(
      container: container,
      child: RepaintBoundary(
        key: surfaceKey,
        child: ArrowchimeApp(router: router),
      ),
    ),
  );
  await settle(tester);
  return AppHarness(container, audio, haptics, share);
}
