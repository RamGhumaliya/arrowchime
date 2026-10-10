import 'package:arrowchime/core/audio/audio_service.dart';
import 'package:arrowchime/core/audio/chapter_sound.dart';
import 'package:arrowchime/core/audio/feedback_settings.dart';
import 'package:arrowchime/core/audio/sfx.dart';
import 'package:arrowchime/core/audio/soloud_backend.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

/// The real engine on a device: starts, loads a chapter, plays a burst of
/// 10 taps a second (note + whoosh + harmony each), ducks, brightens, stops.
/// It checks nothing throws and the engine reports ready; whether it SOUNDS
/// right needs a person with ears (docs/09).
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('SoLoud backend plays a chapter without errors', (tester) async {
    final service = AudioService(
      backend: SoLoudBackend(),
      settings: () => const FeedbackSettings(),
    );
    await service.enterChapter(1);
    expect(service.isReady, isTrue, reason: 'audio engine did not start');

    final sound = ChapterSound.of(1);
    for (var i = 0; i < 30; i++) {
      service
        ..note(sound, i % sound.length)
        ..note(sound, (i + 3) % sound.length, volume: 0.4)
        ..sfx(Sfx.arrowWhoosh, speed: 0.95 + (i % 3) * 0.05);
      await tester.pump(const Duration(milliseconds: 100));
    }
    service
      ..sfx(Sfx.boardClear, delay: const Duration(milliseconds: 300))
      ..note(sound, 0, delay: const Duration(milliseconds: 90))
      ..duck(on: true)
      ..brighten(open: true);
    await tester.pump(const Duration(seconds: 1));
    service
      ..duck(on: false)
      ..brighten(open: false);
    await service.preloadSting(1);
    service.bossSting(1);
    await tester.pump(const Duration(milliseconds: 500));
    await service.leaveChapter();
    await service.dispose();
  });
}
