import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:arrowchime/app/theme/tokens.dart';
import 'package:arrowchime/core/assets.dart';
import 'package:arrowchime/core/ui/icons/tb_icon.dart';
import 'package:arrowchime/core/ui/icons/tb_icon_id.dart';
import 'package:arrowchime/core/ui/icons/tb_icon_shapes.dart';
import 'package:arrowchime/core/ui/painters/brass_painter.dart';
import 'package:arrowchime/core/ui/painters/ceramic_painter.dart';
import 'package:arrowchime/core/ui/painters/crystal_painter.dart';
import 'package:arrowchime/core/ui/painters/enamel_tube_painter.dart';
import 'package:arrowchime/core/ui/painters/inset_painter.dart';
import 'package:arrowchime/core/ui/painters/knob_painter.dart';
import 'package:arrowchime/core/ui/painters/paper_painter.dart';
import 'package:arrowchime/core/ui/painters/shade.dart';
import 'package:arrowchime/core/ui/painters/wood_painter.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

/// Rasterised RGBA pixels of a drawing.
class Raster {
  new(this.width, this.height, this.bytes);

  final int width;
  final int height;
  final Uint8List bytes;

  (int, int, int, int) at(int x, int y) {
    final i = (y * width + x) * 4;
    return (bytes[i], bytes[i + 1], bytes[i + 2], bytes[i + 3]);
  }

  int alpha(int x, int y) => at(x, y).$4;

  double luma(int x, int y) {
    final (r, g, b, _) = at(x, y);
    return 0.299 * r + 0.587 * g + 0.114 * b;
  }

  int get opaquePixels {
    var n = 0;
    for (var i = 3; i < bytes.length; i += 4) {
      if (bytes[i] > 16) n++;
    }
    return n;
  }
}

Future<Raster> rasterize(
  Size size,
  void Function(Canvas canvas) draw, {
  double scale = 1,
}) async {
  final recorder = ui.PictureRecorder();
  final canvas = Canvas(recorder)..scale(scale);
  draw(canvas);
  final image = await recorder.endRecording().toImage(
    (size.width * scale).round(),
    (size.height * scale).round(),
  );
  final data = (await image.toByteData())!;
  return Raster(image.width, image.height, data.buffer.asUint8List());
}

bool near((int, int, int, int) c, Color target, [int tol = 14]) {
  int ch(double v) => (v * 255).round();
  return (c.$1 - ch(target.r)).abs() <= tol &&
      (c.$2 - ch(target.g)).abs() <= tol &&
      (c.$3 - ch(target.b)).abs() <= tol;
}

void main() {
  group('TBShade', () {
    test('bevel light +18%, bevel dark -22% lightness (HSL)', () {
      final base = HSLColor.fromColor(TBColors.teal);
      expect(
        HSLColor.fromColor(TBShade.bevelLight(TBColors.teal)).lightness,
        closeTo(base.lightness + 0.18, 0.01),
      );
      expect(
        HSLColor.fromColor(TBShade.bevelDark(TBColors.teal)).lightness,
        closeTo(base.lightness - 0.22, 0.01),
      );
    });

    test('lightness is clamped to 0..1', () {
      expect(
        HSLColor.fromColor(TBShade.lighten(TBColors.cream100, 0.9)).lightness,
        1,
      );
      expect(
        HSLColor.fromColor(TBShade.lighten(TBColors.ink900, -0.9)).lightness,
        0,
      );
    });

    test('desaturate 80% leaves 20% of the saturation', () {
      final s = HSLColor.fromColor(TBColors.tangerine).saturation;
      final d = HSLColor.fromColor(
        TBShade.desaturate(TBColors.tangerine, TBBevel.disabledDesaturation),
      ).saturation;
      expect(d, closeTo(s * 0.2, 0.01));
    });

    test('white / ink helpers use palette colours with the given opacity', () {
      expect(TBShade.white(0.5).a, closeTo(0.5, 0.01));
      expect(TBShade.ink(0.25).a, closeTo(0.25, 0.01));
      expect(
        TBShade.ink(1).toARGB32() & 0xFFFFFF,
        TBColors.ink900.toARGB32() & 0xFFFFFF,
      );
    });

    test('TBNoise is a deterministic xorshift in [0, 1)', () {
      final a = TBNoise(1);
      final values = [for (var i = 0; i < 4; i++) a.next()];
      expect(values, [
        6.295018829405308e-05,
        0.015747428173199296,
        0.6164041024167091,
        0.07161863497458398,
      ]);
      final b = TBNoise(1);
      expect([for (var i = 0; i < 4; i++) b.next()], values);
      final c = TBNoise(0); // 0 is remapped, never stuck
      for (var i = 0; i < 1000; i++) {
        final v = c.next();
        expect(v, inInclusiveRange(0, 0.9999999999));
      }
    });
  });

  group('Ceramic (docs/10 §5 press physics, measured in pixels)', () {
    const size = Size(120, 64);

    Future<Raster> button(double press, {bool disabled = false}) => rasterize(
      size,
      (c) => Ceramic.paint(
        c,
        size,
        face: TBColors.tangerine,
        lip: TBColors.tangerineLip,
        radius: TBRadius.r20,
        press: press,
        disabled: disabled,
      ),
    );

    int lipRows(Raster r) {
      var n = 0;
      for (var y = r.height - 1; y >= 0; y--) {
        if (near(r.at(60, y), TBColors.tangerineLip, 22)) {
          n++;
        } else {
          break;
        }
      }
      return n;
    }

    int firstOpaqueRow(Raster r) {
      for (var y = 0; y < r.height; y++) {
        if (r.alpha(60, y) > 200) return y;
      }
      return -1;
    }

    test('at rest the lip is 6 dp and the face starts at the top', () async {
      final r = await button(0);
      expect(lipRows(r), inInclusiveRange(5, 6));
      expect(firstOpaqueRow(r), inInclusiveRange(0, 1));
    });

    test('pressed: face moves down 4 dp and the lip shrinks to 2 dp', () async {
      final r = await button(1);
      expect(lipRows(r), inInclusiveRange(2, 3));
      expect(firstOpaqueRow(r), inInclusiveRange(4, 5));
    });

    test('disabled has no lip and is desaturated', () async {
      final r = await button(0, disabled: true);
      expect(lipRows(r), 0);
      final face = r.at(60, 28);
      final hsl = HSLColor.fromColor(
        Color.fromARGB(255, face.$1, face.$2, face.$3),
      );
      expect(hsl.saturation, lessThan(0.45));
    });

    test('light comes from the top-left: highlight left, none right', () async {
      final r = await button(0);
      // 1.5 dp inner highlight runs along the top and left edges.
      final left = r.luma(1, 30);
      final right = r.luma(size.width.round() - 2, 30);
      expect(left, greaterThan(right + 4));
    });

    test('focus draws a sky ring outside the slab', () async {
      final r = await rasterize(
        const Size(140, 80),
        (c) => c
          ..translate(10, 6)
          ..save(),
      );
      expect(r.opaquePixels, 0);
      final f = await rasterize(const Size(140, 80), (c) {
        c.translate(10, 6);
        Ceramic.paint(
          c,
          const Size(120, 64),
          face: TBColors.teal,
          lip: TBColors.tealLip,
          radius: TBRadius.r20,
          focused: true,
        );
      });
      // Sample the ring just left of the slab, mid height.
      expect(near(f.at(7, 30), TBColors.sky, 50), isTrue);
    });

    test('a pill radius is capped to half the face height', () async {
      final r = await rasterize(
        const Size(56, 56),
        (c) => Ceramic.paint(
          c,
          const Size(56, 56),
          face: TBColors.cream100,
          lip: TBColors.cream300,
          radius: TBRadius.pill,
        ),
      );
      expect(r.opaquePixels, greaterThan(1200));
    });
  });

  group('Knob', () {
    test('lit top-left, shaded bottom-right, painted without error', () async {
      const d = 64.0;
      final r = await rasterize(
        const Size(d + 8, d + 8),
        (c) => Knob.paint(c, const Offset(4, 4), d),
      );
      expect(r.opaquePixels, greaterThan(2000));
      // Specular streak up-left is brighter than the lower-right face.
      expect(r.luma(24, 22), greaterThan(r.luma(50, 50)));
    });

    test('focus ring is drawn when focused', () async {
      final r = await rasterize(
        const Size(80, 80),
        (c) => Knob.paint(c, const Offset(8, 8), 64, focused: true),
      );
      expect(near(r.at(6, 38), TBColors.sky, 60), isTrue);
    });
  });

  group('Paper / Inset / Wood / Brass / Crystal', () {
    test(
      'recessed paper is darker top-left (inner shadow) than bottom-right',
      () async {
        const size = Size(160, 100);
        final r = await rasterize(
          size,
          (c) => Paper.paintRecessed(c, size, radius: TBRadius.r20),
        );
        expect(r.luma(24, 6), lessThan(r.luma(130, 85)));
      },
    );

    test('raised paper has a bevel strip darker than its face', () async {
      const size = Size(160, 100);
      final r = await rasterize(
        size,
        (c) => Paper.paintRaised(c, size, elevation: const []),
      );
      expect(r.luma(80, 97), lessThan(r.luma(80, 60)));
      expect(near(r.at(80, 97), TBColors.cream300, 20), isTrue);
    });

    test('grain is deterministic', () async {
      const size = Size(120, 80);
      Future<Raster> draw() => rasterize(
        size,
        (c) => Paper.paintRaised(c, size, elevation: const [], grainSeed: 4),
      );
      expect((await draw()).bytes, (await draw()).bytes);
    });

    test('paper adapter paints both variants and repaints on change', () {
      const raised = PaperPainter();
      const recessed = PaperPainter(recessed: true);
      expect(raised.shouldRepaint(recessed), isTrue);
      expect(raised.shouldRepaint(const PaperPainter()), isFalse);
      expect(
        const PaperPainter(face: TBColors.sky).shouldRepaint(raised),
        isTrue,
      );
      expect(
        const PaperPainter(radius: TBRadius.r12).shouldRepaint(raised),
        isTrue,
      );
    });

    test('inset: shadow top-left, light rim bottom-right', () async {
      const size = Size(160, 60);
      final r = await rasterize(
        size,
        (c) => Inset.paint(
          c,
          RRect.fromRectAndRadius(
            Offset.zero & size,
            const Radius.circular(20),
          ),
          fill: TBColors.cream300,
        ),
      );
      expect(r.luma(30, 3), lessThan(r.luma(130, 56)));
    });

    test(
      'wood grain is deterministic and the plank has a darker lip',
      () async {
        const size = Size(160, 60);
        Future<Raster> draw() =>
            rasterize(size, (c) => Wood.paint(c, size, elevation: const []));
        final a = await draw();
        expect(a.bytes, (await draw()).bytes);
        expect(a.luma(80, 57), lessThan(a.luma(80, 30)));
      },
    );

    test('felt tray shows felt inside a wooden rim', () async {
      const size = Size(160, 100);
      final r = await rasterize(
        size,
        (c) => Felt.paintTray(c, size, felt: const Color(0xFFE9E2D0)),
      );
      // Centre ~ felt colour; the rim ring is much darker (wood).
      expect(r.luma(80, 50), greaterThan(180));
      expect(r.luma(80, 2), lessThan(140));
    });

    test('brass reads as metal: a light-dark-light gradient', () async {
      const size = Size(160, 60);
      final r = await rasterize(
        size,
        (c) => Brass.paint(
          c,
          RRect.fromRectAndRadius(
            Offset.zero & size,
            const Radius.circular(12),
          ),
          elevation: const [],
        ),
      );
      final lumas = [for (var x = 12; x < 148; x += 8) r.luma(x, 30)];
      final spread =
          lumas.reduce((a, b) => a > b ? a : b) -
          lumas.reduce((a, b) => a < b ? a : b);
      expect(spread, greaterThan(30));
      expect(const BrassPainter().shouldRepaint(const BrassPainter()), isFalse);
      expect(
        const BrassPainter(radius: TBRadius.r20)
            .shouldRepaint(const BrassPainter()),
        isTrue,
      );
    });

    test('crystal is translucent with a bright top-left rim', () async {
      const size = Size(120, 80);
      final r = await rasterize(
        size,
        (c) => Crystal.paint(
          c,
          RRect.fromRectAndRadius(
            Offset.zero & size,
            const Radius.circular(12),
          ),
        ),
      );
      expect(r.alpha(60, 40), lessThan(255), reason: 'translucent face');
      expect(r.luma(4, 30), greaterThan(r.luma(116, 60)));
      expect(
        const CrystalPainter().shouldRepaint(const CrystalPainter()),
        isFalse,
      );
      expect(
        const CrystalPainter(radius: TBRadius.r20)
            .shouldRepaint(const CrystalPainter()),
        isTrue,
      );
    });
  });

  group('EnamelTube (docs/10 §8)', () {
    Future<Raster> tube(List<Offset> pts, {double c = 40}) => rasterize(
      const Size(260, 120),
      (canvas) => EnamelTube.paint(canvas, pts, c, TBColors.berry),
    );

    int whitish(Raster r) {
      var n = 0;
      for (var y = 0; y < r.height; y++) {
        for (var x = 0; x < r.width; x++) {
          final (rr, g, b, a) = r.at(x, y);
          if (a > 200 && rr > 235 && g > 200 && b > 200) n++;
        }
      }
      return n;
    }

    test('paints a body, head and nock for every shape', () async {
      for (final pts in [
        const [Offset(130, 60)],
        const [Offset(40, 60), Offset(220, 60)],
        const [
          Offset(40, 90),
          Offset(120, 90),
          Offset(120, 30),
          Offset(220, 30),
        ],
        const [
          Offset(30, 30),
          Offset(230, 30),
          Offset(230, 90),
          Offset(30, 90),
        ],
      ]) {
        final r = await tube(pts);
        expect(r.opaquePixels, greaterThan(600), reason: '$pts');
      }
    });

    test(
      'five passes: dark rim, body colour, lighter band, specular',
      () async {
        final r = await tube(const [Offset(40, 60), Offset(180, 60)]);
        // Down the middle of the tube: rim (dark) -> body -> band (light).
        final rim = r.luma(110, 60 + 8);
        final body = r.luma(110, 60);
        expect(body, isNot(closeTo(rim, 4)));
        final column = [for (var y = 40; y < 80; y++) r.luma(110, y)];
        expect(
          column.reduce((a, b) => a > b ? a : b),
          greaterThan(column.reduce((a, b) => a < b ? a : b) + 25),
        );
      },
    );

    test('specular only on segments running up or left', () async {
      final right = await tube(const [Offset(40, 60), Offset(200, 60)]);
      final left = await tube(const [Offset(200, 60), Offset(40, 60)]);
      expect(whitish(left), greaterThan(whitish(right)));
    });

    test('the shadow falls down and to the right', () async {
      final r = await tube(const [Offset(40, 60), Offset(180, 60)]);
      // Below the tube there is shadow (alpha), above it is empty.
      expect(r.alpha(100, 60 + 18), greaterThan(r.alpha(100, 60 - 24)));
    });

    test('the widget painter fits cells into its box', () async {
      final r = await rasterize(
        const Size(200, 80),
        (c) => const EnamelTubePainter(
          cells: [(0, 2), (1, 2), (2, 2), (2, 1), (3, 1), (4, 1), (4, 0)],
          color: TBColors.teal,
        ).paint(c, const Size(200, 80)),
      );
      expect(r.opaquePixels, greaterThan(800));
      const p = EnamelTubePainter(cells: [(0, 0)], color: TBColors.teal);
      expect(p.shouldRepaint(p), isFalse);
      expect(
        p.shouldRepaint(
          const EnamelTubePainter(cells: [(0, 0)], color: TBColors.berry),
        ),
        isTrue,
      );
    });
  });

  group('TBIcon set (docs/10 §6)', () {
    test('25 icons that match the manifest names exactly', () {
      expect(TBIconId.values, hasLength(25));
      expect({
        for (final i in TBIconId.values) i.assetName,
      }, AssetCatalog.uiIcons.toSet());
    });

    test('every icon has distinct, non-empty semantics', () {
      final labels = {for (final i in TBIconId.values) i.semanticLabel};
      expect(labels.length, TBIconId.values.length);
      expect(labels.every((l) => l.isNotEmpty), isTrue);
    });

    test('every icon has shapes, and a flat detail never covers the bevel', () {
      for (final id in TBIconId.values) {
        final parts = TBIconShapes.partsFor(id);
        expect(parts, isNotEmpty, reason: id.name);
        expect(parts.any((p) => p.bevel), isTrue, reason: id.name);
        for (final p in parts) {
          final b = p.path.getBounds();
          expect(b.left, greaterThanOrEqualTo(-0.01), reason: id.name);
          expect(b.top, greaterThanOrEqualTo(-0.01), reason: id.name);
          expect(b.right, lessThanOrEqualTo(1.01), reason: id.name);
          expect(b.bottom, lessThanOrEqualTo(1.01), reason: id.name);
        }
      }
    });

    test(
      'every icon paints at every size (16 to 256) with visible pixels',
      () async {
        for (final id in TBIconId.values) {
          for (final s in const [16.0, 24.0, 32.0, 64.0, 256.0]) {
            final r = await rasterize(
              Size.square(s),
              (c) => TBIconPainter(id).paint(c, Size.square(s)),
            );
            expect(
              r.opaquePixels,
              greaterThan(s * s * 0.06),
              reason: '${id.name} @${s.round()}',
            );
          }
        }
      },
    );

    test('3-tone: the coin is lit top-left and shaded bottom-right', () async {
      final r = await rasterize(
        const Size.square(128),
        (c) =>
            const TBIconPainter(TBIconId.coin).paint(c, const Size.square(128)),
      );
      // Inside the rim at 225 deg (top-left) vs 45 deg (bottom-right).
      expect(r.luma(28, 28), greaterThan(r.luma(100, 100)));
    });

    test('the painter repaints only when the icon changes', () {
      const p = TBIconPainter(TBIconId.coin);
      expect(p.shouldRepaint(const TBIconPainter(TBIconId.coin)), isFalse);
      expect(p.shouldRepaint(const TBIconPainter(TBIconId.gem)), isTrue);
    });

    test('asset names for the multiword icons', () {
      expect(TBIconId.heartBroken.assetName, 'heart_broken');
      expect(TBIconId.starEmpty.assetName, 'star_empty');
      expect(TBIconId.coin.assetName, 'coin');
    });

    testWidgets('TBIcon is a labelled image of the requested size', (
      tester,
    ) async {
      final handle = tester.ensureSemantics();
      await tester.pumpWidget(
        const Directionality(
          textDirection: TextDirection.ltr,
          child: Center(child: TBIcon(TBIconId.heart, size: 48)),
        ),
      );
      expect(tester.getSize(find.byType(TBIcon)), const Size.square(48));
      expect(find.bySemanticsLabel('Heart'), findsOneWidget);
      handle.dispose();
    });
  });
}
