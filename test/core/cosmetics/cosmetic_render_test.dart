import 'dart:io';
import 'dart:ui';

import 'package:arrowchime/app/theme/chapter_theme.dart';
import 'package:arrowchime/app/theme/tokens.dart';
import 'package:arrowchime/core/audio/chapter_sound.dart';
import 'package:arrowchime/core/ui/painters/arrow_skin.dart';
import 'package:arrowchime/core/ui/painters/enamel_tube_painter.dart';
import 'package:arrowchime/core/ui/painters/glow_shader.dart';
import 'package:arrowchime/features/game/flame/board_themes.dart';
import 'package:arrowchime/features/game/flame/particle_pool.dart';
import 'package:arrowchime/features/game/flame/trail_style.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('arrow skins', () {
    test('nine skins; unknown ids fall back to candy', () {
      expect(ArrowSkin.values, hasLength(9));
      expect(ArrowSkin.fromId('neon'), ArrowSkin.neon);
      expect(ArrowSkin.fromId('nope'), ArrowSkin.candy);
    });

    test('each skin recolours the body; candy leaves it alone', () {
      const base = TBColors.berry;
      expect(ArrowSkin.candy.body(base), base);
      expect(ArrowSkin.brass.body(base), TBMaterials.brassFace);
      expect(ArrowSkin.neon.body(base), TBColors.ink900);
      for (final skin in ArrowSkin.values) {
        expect(skin.body(base), isA<Color>());
      }
      expect(ArrowSkin.neon.glows, isTrue);
      expect(ArrowSkin.galaxy.glows, isTrue);
      expect(ArrowSkin.paper.glows, isFalse);
    });

    test('every skin paints a bent arrow without errors', () {
      for (final skin in ArrowSkin.values) {
        final recorder = PictureRecorder();
        EnamelTube.paint(
          Canvas(recorder),
          const [
            Offset(20, 60),
            Offset(60, 60),
            Offset(100, 60),
            Offset(100, 20),
          ],
          40,
          TBColors.teal,
          skin: skin,
        );
        final picture = recorder.endRecording();
        expect(picture.approximateBytesUsed, greaterThan(0), reason: skin.name);
        picture.dispose();
      }
    });

    test('the painter widget repaints when the skin changes', () {
      const a = EnamelTubePainter(cells: [(0, 0), (1, 0)], color: TBColors.sky);
      const b = EnamelTubePainter(
        cells: [(0, 0), (1, 0)],
        color: TBColors.sky,
        skin: ArrowSkin.pixel,
      );
      expect(b.shouldRepaint(a), isTrue);
      expect(a.shouldRepaint(a), isFalse);
    });

    test('the glow shader is optional: without it, nothing breaks', () async {
      await GlowShader.load();
      final shader = GlowShader.shader(const Size(10, 10), TBColors.sky);
      expect(shader == null, !GlowShader.isAvailable);
      shader?.dispose();
    });
  });

  group('trails', () {
    test('five styles with shapes, counts and fall', () {
      expect(TrailStyle.fromId('snow'), TrailStyle.snow);
      expect(TrailStyle.fromId('x'), TrailStyle.none);
      expect(TrailStyle.none.perEmit, 0);
      expect(TrailStyle.sparkle.perEmit, 1);
      expect(TrailStyle.petals.shape, ParticleShape.petal);
      expect(TrailStyle.ribbons.shape, ParticleShape.ribbon);
      expect(TrailStyle.snow.fall, lessThan(1));
      for (final t in TrailStyle.values) {
        expect(t.burst, greaterThan(0));
        expect(t.color(TBColors.sky, 0), isA<Color>());
        expect(t.color(TBColors.sky, 1), isA<Color>());
      }
    });

    test('every particle shape renders and the pool stays capped', () {
      final pool = ParticlePool(seed: 3);
      for (final shape in ParticleShape.values) {
        pool.burst(5, 5, TBColors.butter, shape: shape, fall: 0.2);
      }
      pool.update(0.1);
      final recorder = PictureRecorder();
      pool.render(Canvas(recorder));
      recorder.endRecording().dispose();
      expect(pool.alive, lessThanOrEqualTo(ParticlePool.capacity));
    });
  });

  group('board themes', () {
    test('a theme swaps the felt; auto and unknown keep the chapter tray', () {
      const base = ChapterTheme.mistyGarden;
      expect(BoardThemes.apply(base, 'auto'), same(base));
      expect(BoardThemes.apply(base, 'whatever'), same(base));
      for (final id in ['night', 'sunset', 'constellation', 'aurora']) {
        final t = BoardThemes.apply(base, id);
        expect(t.trayFelt, isNot(base.trayFelt), reason: id);
        expect(t.arrowColors, base.arrowColors);
        expect(t.id, base.id);
      }
      expect(BoardThemes.apply(base, 'night').darkTray, isTrue);
      expect(BoardThemes.apply(base, 'sunset').darkTray, isFalse);
    });
  });

  group('cosmetic instruments (pitch-mapped samples)', () {
    final ch2 = ChapterSound.of(
      2,
    ); // G major: Fs5 is not in the C pentatonic set

    test('auto and unknown use the chapter instrument at speed 1', () {
      final v = ch2.voiceOf(0);
      expect(v.asset, ch2.assetOf(0));
      expect(v.speed, 1);
      expect(ch2.voiceOf(0, instrument: 'auto').asset, ch2.assetOf(0));
      expect(ch2.voiceOf(0, instrument: 'nope').asset, ch2.assetOf(0));
    });

    test('a note outside the C pentatonic set is transposed from the nearest sample', () {
      // G4 exists as a piano sample: unchanged.
      final g4 = ch2.voiceOf(0, instrument: 'piano');
      expect(g4.asset, endsWith('piano/G4.wav'));
      expect(g4.speed, closeTo(1, 1e-9));
      // B4 -> nearest piano sample is A4 or C5, a transposed one.
      final b4 = ch2.voiceOf(2, instrument: 'piano');
      expect(b4.speed, isNot(1));
      expect(b4.speed, inInclusiveRange(0.85, 1.15));
    });

    test('8-bit is the pixel folder; every needed sample file exists', () {
      expect(ch2.voiceOf(0, instrument: 'eightbit').asset, contains('/pixel/'));
      for (final chapter in [1, 2, 3, 4, 5]) {
        final s = ChapterSound.of(chapter);
        for (final inst in ['piano', 'marimba', 'eightbit', 'choir']) {
          for (final asset in s.voiceAssets(instrument: inst)) {
            expect(File(asset).existsSync(), isTrue, reason: asset);
          }
        }
      }
    });

    test('the same note always maps to the same sample', () {
      final a = ch2.voiceOf(5, instrument: 'choir');
      final b = ch2.voiceOf(5, instrument: 'choir');
      expect(a.asset, b.asset);
      expect(a.speed, b.speed);
    });
  });
}
