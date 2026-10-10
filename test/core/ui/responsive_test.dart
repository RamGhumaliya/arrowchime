import 'package:arrowchime/features/design_gallery/design_gallery_screen.dart';
import 'package:arrowchime/features/design_gallery/gallery_pages.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/ui_harness.dart';

/// Responsiveness (docs/09 §1/§7): every gallery page lays out without
/// overflow on small phones, large phones, tablets (portrait + landscape)
/// and at 1.3x / 1.5x text scale.
void main() {
  const viewports = <String, Size>{
    'small phone 320x568': Size(320, 568),
    'iPhone SE 375x667': Size(375, 667),
    'Pro Max 430x932': Size(430, 932),
    'tablet portrait 768x1024': Size(768, 1024),
    'tablet landscape 1280x800': Size(1280, 800),
  };

  for (final group in GalleryGroup.values) {
    for (final vp in viewports.entries) {
      for (final scale in const [1.0, 1.3, 1.5]) {
        testWidgets('${group.label} @ ${vp.key} x$scale', (tester) async {
          await pumpSurface(
            tester,
            DesignGalleryScreen(initial: group),
            size: vp.value,
            surface: TestSurface.ink,
            padding: EdgeInsets.zero,
            textScale: scale,
          );
          await tester.pump(const Duration(milliseconds: 400));
          expect(tester.takeException(), isNull);
        });
      }
    }
  }
}
