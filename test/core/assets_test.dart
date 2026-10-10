import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:arrowchime/core/assets.dart';
import 'package:flutter_test/flutter_test.dart';

/// "Placeholders exist at every manifest path" (Phase 2 acceptance).
void main() {
  final entries = AssetCatalog.all();

  group('catalog vs. assets/ASSET_MANIFEST.md', () {
    test('has the expected number of files per category', () {
      int count(AssetKind k) => entries.where((e) => e.kind == k).length;
      expect(count(AssetKind.brandingImage), 5);
      expect(count(AssetKind.chapterLayer), 50, reason: '5 layers x 2 x 5');
      expect(count(AssetKind.chapterThumb), 5);
      expect(count(AssetKind.chapterFragments), 5);
      expect(count(AssetKind.uiIcon), 75, reason: '25 icons x @1x/2x/3x');
      expect(count(AssetKind.mechanicSvg), 7);
      expect(count(AssetKind.mechanicImage), 1);
      expect(count(AssetKind.cosmeticPreview), 9);
      expect(count(AssetKind.shader), 2);
      expect(count(AssetKind.rive), 2);
      expect(count(AssetKind.lottie), 1);
      expect(count(AssetKind.music), 5);
      expect(count(AssetKind.sting), 5);
      expect(count(AssetKind.sfx), 23);
      expect(count(AssetKind.licence), 2);
      expect(entries.length, 308);
    });

    test('instrument note sets match the chapter scales', () {
      const n = AudioCatalog.instrumentNotes;
      expect(n.keys.toSet(), {
        'kalimba',
        'musicbox',
        'santoor',
        'celesta',
        'harp',
        'piano',
        'marimba',
        'pixel',
        'choir',
      });
      expect(n['kalimba']!.first, 'C4');
      expect(n['kalimba']!.last, 'C6');
      expect(n['musicbox']!.first, 'G4');
      expect(n['musicbox']!.last, 'G6');
      expect(n['santoor']!.first, 'D4');
      expect(n['celesta']!.first, 'A4');
      expect(n['harp']!.first, 'E4');
      for (final notes in n.values) {
        expect(notes.length, inInclusiveRange(10, 15));
        expect(notes.any((x) => x.contains('#')), isFalse);
      }
      expect(AudioCatalog.chapterInstrument.length, 5);
    });

    test('every fixed path in the manifest is in the catalog', () {
      final manifest = File('assets/ASSET_MANIFEST.md').readAsStringSync();
      final inCatalog = {
        for (final e in entries)
          // Compare ignoring the placeholder/final extension.
          e.path.replaceAll(RegExp(r'\.(png|wav|webp|ogg)$'), ''),
      };
      final fixed = RegExp('`(assets/[^`]+)`')
          .allMatches(manifest)
          .map((m) => m.group(1)!)
          .where(
            (p) =>
                !p.contains(RegExp('[<>{}*…]')) &&
                !p.contains('chN') &&
                !p.endsWith('/') &&
                !p.contains('..') &&
                !p.startsWith('assets/levels/') &&
                !p.startsWith('assets/branding/') &&
                !p.startsWith('assets/fonts/') &&
                !p.startsWith('assets/ASSET_MANIFEST') &&
                !p.contains(' '),
          )
          .toSet();
      expect(fixed, isNotEmpty);
      for (final p in fixed) {
        final key = p.replaceAll(RegExp(r'\.(png|wav|webp|ogg)$'), '');
        expect(inCatalog, contains(key), reason: '$p is in the manifest');
      }
    });

    test('paths are unique and use forward slashes', () {
      final paths = entries.map((e) => e.path).toList();
      expect(paths.toSet().length, paths.length);
      expect(paths.any((p) => p.contains(r'\')), isFalse);
      expect(paths.every((p) => p.startsWith('assets/')), isTrue);
    });

    test('extensions follow AssetFormats', () {
      expect(AssetCatalog.uiIconPath('coin'), 'assets/images/ui/coin.png');
      expect(
        AssetCatalog.uiIconPath('coin', scale: 2),
        'assets/images/ui/2.0x/coin.png',
      );
      expect(
        AssetCatalog.chapterLayerPath(3, 'bg_far', land: true),
        'assets/images/chapters/ch3/bg_far_land.png',
      );
      expect(
        AssetCatalog.notePath('harp', 'Fs5'),
        'assets/audio/notes/harp/Fs5.wav',
      );
      expect(AssetCatalog.musicPath(2), 'assets/audio/music/ch2_loop.wav');
      expect(
        AssetCatalog.stingPath(4),
        'assets/audio/music/boss_sting_ch4.wav',
      );
      expect(AssetCatalog.sfxPath('coin'), 'assets/audio/sfx/coin.wav');
      expect(
        AssetCatalog.cosmeticPreviewPath('neon'),
        'assets/images/cosmetics/neon_preview.png',
      );
      expect(
        AssetCatalog.iceBlockPath,
        'assets/images/mechanics/ice_block_9slice.png',
      );
      expect(AssetCatalog.shaderPath('glow'), 'assets/shaders/glow.frag');
      expect(
        AssetCatalog.chapterThumbPath(1),
        'assets/images/chapters/ch1/thumb.png',
      );
      expect(
        AssetCatalog.chapterFragmentsPath(5),
        'assets/images/chapters/ch5/fragments.json',
      );
      expect(
        AssetCatalog.mechanicSvgPath('portal_ring'),
        'assets/images/mechanics/portal_ring.svg',
      );
      expect(AssetCatalog.chapterDir(2), 'assets/images/chapters/ch2');
    });
  });

  group(
    'placeholders exist on disk (run tool/gen_placeholder_assets.dart)',
    () {
      test('every catalog path has a file', () {
        final missing = [
          for (final e in entries)
            if (!File(e.path).existsSync()) e.path,
        ];
        expect(missing, isEmpty);
      });

      test('images are real PNGs of the manifest size', () {
        for (final e in entries.where(
          (e) =>
              e.width > 0 &&
              e.kind != AssetKind.chapterLayer, // big files: sampled below
        )) {
          final b = File(e.path).readAsBytesSync();
          expect(b.sublist(0, 8), [
            137,
            80,
            78,
            71,
            13,
            10,
            26,
            10,
          ], reason: e.path);
          final h = ByteData.sublistView(b, 16, 24);
          expect(
            (h.getUint32(0), h.getUint32(4)),
            (e.width, e.height),
            reason: e.path,
          );
        }
        for (final e
            in entries
                .where((e) => e.kind == AssetKind.chapterLayer)
                .where((e) => e.chapter == 1 || e.name == 'fg')) {
          final b = File(e.path).readAsBytesSync();
          final h = ByteData.sublistView(b, 16, 24);
          expect(
            (h.getUint32(0), h.getUint32(4)),
            (e.width, e.height),
            reason: e.path,
          );
        }
      });

      test('WAVs are 16-bit mono PCM with sound in them', () {
        for (final e in entries.where(
          (e) =>
              e.kind == AssetKind.note ||
              e.kind == AssetKind.sfx ||
              e.kind == AssetKind.music ||
              e.kind == AssetKind.sting,
        )) {
          final b = File(e.path).readAsBytesSync();
          final d = ByteData.sublistView(b);
          expect(utf8.decode(b.sublist(0, 4)), 'RIFF', reason: e.path);
          expect(utf8.decode(b.sublist(8, 12)), 'WAVE', reason: e.path);
          expect(d.getUint16(22, Endian.little), 1, reason: '${e.path} mono');
          expect(d.getUint16(34, Endian.little), 16, reason: e.path);
          final dataLen = d.getUint32(40, Endian.little);
          expect(dataLen, b.length - 44, reason: e.path);
          var peak = 0;
          for (var i = 44; i + 1 < b.length; i += 2) {
            final v = d.getInt16(i, Endian.little).abs();
            if (v > peak) peak = v;
          }
          expect(peak, greaterThan(500), reason: '${e.path} is silent');
        }
      });

      test('text placeholders are well formed and labelled', () {
        for (final e in entries.where((e) => e.kind == AssetKind.mechanicSvg)) {
          final s = File(e.path).readAsStringSync();
          expect(s, contains('<svg'), reason: e.path);
          expect(s.trimRight().endsWith('</svg>'), isTrue, reason: e.path);
          expect(s, contains('PLACEHOLDER'), reason: e.path);
        }
        for (final e in entries.where((e) => e.kind == AssetKind.shader)) {
          final s = File(e.path).readAsStringSync();
          expect(s, contains('PLACEHOLDER'), reason: e.path);
          expect(s, contains('FlutterFragCoord'), reason: e.path);
        }
        final lottie = jsonDecode(
          File('assets/lottie/confetti.json').readAsStringSync(),
        ) as Map<String, Object?>;
        expect(lottie['nm'], contains('PLACEHOLDER'));
        for (var c = 1; c <= 5; c++) {
          final f = jsonDecode(
            File(AssetCatalog.chapterFragmentsPath(c)).readAsStringSync(),
          ) as Map<String, Object?>;
          final fragments = f['fragments']! as List;
          expect(fragments, hasLength(60));
          expect(f['chapter'], c);
          final first = (fragments.first as Map)['rect'] as List;
          expect(first, hasLength(4));
        }
      });

      test('the gate sprites carry a distinct colour-blind symbol', () {
        final shapes = {
          'gate_amber': '<circle cx="64" cy="76" r="12"',
          'gate_jade': 'M64 62 L78 88 L50 88 Z',
          'gate_rose': '<rect x="52" y="64"',
          'gate_azure': 'M64 62 L78 76 L64 90 L50 76 Z',
        };
        for (final MapEntry(key: name, value: snippet) in shapes.entries) {
          final s = File(AssetCatalog.mechanicSvgPath(name)).readAsStringSync();
          expect(s, contains(snippet), reason: name);
        }
      });

      test('licence ledgers exist and say placeholder', () {
        expect(
          File('assets/audio/LICENSES.md').readAsStringSync(),
          contains('placeholder'),
        );
        expect(
          File('assets/ART_LICENSES.md').readAsStringSync(),
          contains('placeholder'),
        );
      });
    },
  );

  group('pubspec registers every asset directory', () {
    test('each directory is listed (Flutter does not recurse)', () {
      final pubspec = File('pubspec.yaml').readAsStringSync();
      for (final dir in AssetCatalog.assetDirectories()) {
        expect(pubspec, contains('- $dir'), reason: dir);
      }
      expect(pubspec, contains('- assets/levels/'));
      expect(pubspec, contains('- assets/branding/'));
    });

    test('density folders are not listed separately', () {
      final dirs = AssetCatalog.assetDirectories();
      expect(dirs.any((d) => d.contains('2.0x')), isFalse);
      expect(dirs, contains('assets/images/ui/'));
    });
  });
}
