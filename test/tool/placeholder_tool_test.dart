import 'dart:io';
import 'dart:typed_data';

import 'package:arrowchime/app/theme/chapter_theme.dart';
import 'package:arrowchime/app/theme/tokens.dart';
import 'package:flutter/painting.dart' show Color;
import 'package:flutter_test/flutter_test.dart';

import '../../tool/placeholder/font5x7.dart';
import '../../tool/placeholder/palette.dart';
import '../../tool/placeholder/pixmap.dart';
import '../../tool/placeholder/shapes.dart';
import '../../tool/placeholder/sounds.dart';
import '../../tool/placeholder/svgs.dart';
import '../../tool/placeholder/wav.dart';

int rgb(Color c) => c.toARGB32() & 0xFFFFFF;

void main() {
  group('palette mirrors the theme tokens', () {
    test('brand colours', () {
      expect(PlaceholderPalette.ink900, rgb(TBColors.ink900));
      expect(PlaceholderPalette.ink700, rgb(TBColors.ink700));
      expect(PlaceholderPalette.ink500, rgb(TBColors.ink500));
      expect(PlaceholderPalette.cream100, rgb(TBColors.cream100));
      expect(PlaceholderPalette.cream300, rgb(TBColors.cream300));
      expect(PlaceholderPalette.teal, rgb(TBColors.teal));
      expect(PlaceholderPalette.berry, rgb(TBColors.berry));
      expect(PlaceholderPalette.butter, rgb(TBColors.butter));
      expect(PlaceholderPalette.butterLip, rgb(TBColors.butterLip));
      expect(PlaceholderPalette.sky, rgb(TBColors.sky));
    });

    test('chapter sky and tray colours', () {
      for (final c in ChapterTheme.all) {
        final p = PlaceholderPalette.chapters[c.id]!;
        expect(p.$1, rgb(c.skyTop), reason: 'ch${c.id} skyTop');
        expect(p.$2, rgb(c.skyBottom), reason: 'ch${c.id} skyBottom');
        expect(p.$3, rgb(c.trayFelt), reason: 'ch${c.id} trayFelt');
      }
    });
  });

  group('Pixmap / PNG', () {
    test('writes a valid PNG: signature, CRCs and inflatable pixel data', () {
      final pm = Pixmap(7, 5)
        ..fillRows((y) => argb(10 * y, 20, 30))
        ..fillRect(1, 1, 3, 3, argb(255, 0, 0, 128));
      final png = pm.toPng();
      expect(png.sublist(0, 8), [137, 80, 78, 71, 13, 10, 26, 10]);

      final d = ByteData.sublistView(png);
      var o = 8;
      final idat = BytesBuilder();
      var sawEnd = false;
      while (o < png.length) {
        final len = d.getUint32(o);
        final type = String.fromCharCodes(png.sublist(o + 4, o + 8));
        final data = png.sublist(o + 8, o + 8 + len);
        final crc = d.getUint32(o + 8 + len);
        // CRC-32 over type + data.
        var c = 0xFFFFFFFF;
        for (final b in [...png.sublist(o + 4, o + 8), ...data]) {
          c ^= b;
          for (var k = 0; k < 8; k++) {
            c = (c & 1) != 0 ? 0xEDB88320 ^ (c >> 1) : c >> 1;
          }
        }
        expect(c ^ 0xFFFFFFFF, crc, reason: 'CRC of $type');
        if (type == 'IHDR') {
          expect((d.getUint32(o + 8), d.getUint32(o + 12)), (7, 5));
          expect(data[8], 8, reason: 'bit depth');
          expect(data[9], 6, reason: 'RGBA');
        }
        if (type == 'IDAT') idat.add(data);
        if (type == 'IEND') sawEnd = true;
        o += 12 + len;
      }
      expect(sawEnd, isTrue);

      // Undo filter 2 (Up) and compare with the canvas.
      final raw = zlib.decode(idat.toBytes());
      expect(raw.length, 5 * (7 * 4 + 1));
      final prev = Uint8List(7 * 4);
      for (var y = 0; y < 5; y++) {
        final row = raw.sublist(y * 29, (y + 1) * 29);
        expect(row[0], 2, reason: 'filter type Up');
        for (var i = 0; i < 28; i++) {
          final v = (row[1 + i] + prev[i]) & 0xFF;
          expect(v, pm.rgba[y * 28 + i], reason: 'pixel byte $i row $y');
          prev[i] = v;
        }
      }
    });

    test('blend composites alpha and ignores out-of-range pixels', () {
      final pm = Pixmap(2, 2)
        ..setPixel(0, 0, 0, 0, 255)
        ..blend(0, 0, 255, 0, 0, 128)
        ..blend(1, 1, 10, 20, 30, 255)
        ..blend(5, 5, 1, 2, 3, 255)
        ..blend(1, 0, 9, 9, 9, 0)
        ..blend(0, 1, 40, 50, 60, 100);
      expect(pm.rgba[0], inInclusiveRange(120, 135), reason: 'half red');
      expect(pm.rgba[2], inInclusiveRange(120, 135), reason: 'half blue');
      expect(pm.rgba[3], 255);
      expect(pm.rgba[(1 * 2 + 1) * 4 + 3], 255);
      expect(pm.rgba[(0 * 2 + 1) * 4 + 3], 0, reason: 'alpha 0 draws nothing');
      expect(pm.rgba[(1 * 2 + 0) * 4 + 3], 100, reason: 'over empty');
    });

    test('colour helpers', () {
      expect(argb(1, 2, 3, 4), 0x04010203);
      expect(withAlpha(0xFF112233, 0x80), 0x80112233);
      expect(mixColor(0x000000, 0xFFFFFF, 0.5), 0x808080);
      expect(mixColor(0x102030, 0x102030, 0.7), 0x102030);
    });
  });

  group('shapes and the 3-tone look', () {
    test('SDFs are negative inside and positive outside', () {
      final inside = <String, Sdf>{
        'disc': Shapes.disc(),
        'ring': Shapes.ring(),
        'roundRect': Shapes.roundRect(0.8, 0.6),
        'frame': Shapes.frame(0.8, 0.8),
        'diamond': Shapes.diamond(),
        'star': Shapes.star(),
        'heart': Shapes.heart(),
        'hexagon': Shapes.hexagon(),
      };
      for (final MapEntry(key: name, value: sdf) in inside.entries) {
        expect(sdf(2, 2), greaterThan(0), reason: '$name far outside');
      }
      expect(Shapes.disc()(0, 0), lessThan(0));
      expect(Shapes.roundRect(0.8, 0.6)(0, 0), lessThan(0));
      expect(Shapes.diamond()(0, 0), lessThan(0));
      expect(Shapes.star()(0, 0), lessThan(0));
      expect(Shapes.hexagon()(0, 0), lessThan(0));
      expect(Shapes.heart()(0, 0.1), lessThan(0));
      expect(Shapes.ring()(0.6, 0), lessThan(0));
      expect(Shapes.ring()(0, 0), greaterThan(0), reason: 'hole');
      expect(Shapes.frame(0.8, 0.8)(0, 0), greaterThan(0), reason: 'hole');
    });

    test(
      'lit from the top-left: highlight rim top-left, shade bottom-right',
      () {
        final pm = paintIcon(Shapes.disc(), PlaceholderPalette.teal, 128);
        int lum(int x, int y) {
          final i = (y * 128 + x) * 4;
          return pm.rgba[i] + pm.rgba[i + 1] + pm.rgba[i + 2];
        }

        // Points just inside the rim at the same radius.
        final tl = lum(30, 30);
        final br = lum(97, 97);
        expect(tl, greaterThan(br), reason: 'top-left rim brighter');
        expect(pm.rgba[3], 0, reason: 'corner transparent');
        expect(pm.rgba[(64 * 128 + 64) * 4 + 3], 255, reason: 'centre opaque');
      },
    );

    test('has a specular streak near the top-left', () {
      final pm = paintIcon(Shapes.disc(), PlaceholderPalette.berry, 256);
      var brightest = 0;
      var bx = 0;
      var by = 0;
      for (var y = 0; y < 256; y++) {
        for (var x = 0; x < 256; x++) {
          final i = (y * 256 + x) * 4;
          if (pm.rgba[i + 3] < 255) continue;
          final l = pm.rgba[i] + pm.rgba[i + 1] + pm.rgba[i + 2];
          if (l > brightest) {
            brightest = l;
            bx = x;
            by = y;
          }
        }
      }
      expect(bx, lessThan(128));
      expect(by, lessThan(128));
    });
  });

  group('bitmap font', () {
    test('width and drawing', () {
      expect(Font5x7.widthOf('AB', 2), 2 * 6 * 2 - 2);
      final pm = Pixmap(40, 12);
      Font5x7.draw(pm, 'I', 0, 0, 1, argb(255, 255, 255));
      // Top row of "I" is 01110.
      expect(pm.rgba[0 * 4 + 3], 0);
      expect(pm.rgba[1 * 4 + 3], 255);
      expect(pm.rgba[3 * 4 + 3], 255);
      expect(pm.rgba[4 * 4 + 3], 0);
      Font5x7.drawCentered(pm, 'a?', 2, 1, argb(255, 255, 255));
      expect(pm.rgba.any((v) => v != 0), isTrue);
    });
  });

  group('audio synthesis', () {
    test('note frequencies', () {
      expect(Wav.noteFrequency('A4'), closeTo(440, 1e-9));
      expect(Wav.noteFrequency('C4'), closeTo(261.6256, 1e-3));
      expect(Wav.noteFrequency('Fs5'), closeTo(739.9888, 1e-3));
      expect(
        Wav.noteFrequency('C5') / Wav.noteFrequency('C4'),
        closeTo(2, 1e-9),
      );
    });

    test('WAV encoding header', () {
      final bytes = Wav.encode([0, 0.5, -0.5, 2, -2]);
      final d = ByteData.sublistView(bytes);
      expect(String.fromCharCodes(bytes.sublist(0, 4)), 'RIFF');
      expect(d.getUint32(24, Endian.little), Wav.sampleRate);
      expect(d.getUint32(40, Endian.little), 10);
      expect(d.getInt16(44 + 6, Endian.little), 32000, reason: 'clipped');
      expect(d.getInt16(44 + 8, Endian.little), -32000);
    });

    test('rendering is deterministic and bounded', () {
      for (final inst in [
        'kalimba',
        'musicbox',
        'santoor',
        'celesta',
        'harp',
        'piano',
        'marimba',
        'pixel',
        'choir',
        'unknown',
      ]) {
        final a = Sounds.note(inst, 'C5');
        expect(a, Sounds.note(inst, 'C5'));
        expect(a.any((v) => v.abs() > 0.05), isTrue, reason: inst);
        expect(a.every((v) => v.abs() <= 1.0), isTrue, reason: inst);
      }
      for (final c in [1, 2, 3, 4, 5]) {
        expect(Sounds.musicLoop(c).length, 6 * Wav.sampleRate);
        expect(Sounds.bossSting(c).length, 8 * Wav.sampleRate);
      }
    });

    test('every SFX id renders; unknown ids are rejected', () {
      for (final id in [
        'ui_tap',
        'ui_back',
        'arrow_touch',
        'arrow_whoosh',
        'arrow_blocked',
        'heart_lost',
        'rotator_turn',
        'gate_open',
        'key_collect',
        'ice_tick',
        'ice_break',
        'portal_pass',
        'flow_up',
        'board_clear',
        'star_1',
        'star_2',
        'star_3',
        'coin',
        'level_fail',
        'fragment_restore',
        'chest_open',
        'daily_complete',
        'purchase',
      ]) {
        final s = Sounds.sfx(id);
        expect(s.any((v) => v.abs() > 0.02), isTrue, reason: id);
      }
      expect(() => Sounds.sfx('nope'), throwsArgumentError);
    });
  });

  group('svgs', () {
    test('every sprite is a labelled svg; unknown names are rejected', () {
      for (final n in [
        'rotator_ring',
        'portal_ring',
        'chain_link',
        'gate_amber',
        'gate_jade',
        'gate_rose',
        'gate_azure',
      ]) {
        final s = Svgs.forName(n);
        expect(s, startsWith('<svg'));
        expect(s, contains('PLACEHOLDER'));
      }
      expect(() => Svgs.forName('nope'), throwsArgumentError);
    });
  });
}
