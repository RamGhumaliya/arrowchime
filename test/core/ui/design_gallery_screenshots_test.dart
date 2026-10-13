import 'package:arrowchime/app/theme/tokens.dart';
import 'package:arrowchime/features/design_gallery/design_gallery_screen.dart';
import 'package:arrowchime/features/design_gallery/gallery_pages.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/ui_harness.dart';

/// Design review gate (`docs/10` §11): every gallery page at iPhone SE
/// (375×667) and iPhone 15 Pro Max (430×932) widths, saved under
/// `docs/screenshots/phase3/`. Regenerate with
/// `flutter test --update-goldens test/core/ui/design_gallery_screenshots_test.dart`.
void main() {
  const devices = <String, Size>{
    'iphone_se': Size(375, 667),
    'iphone_pro_max': Size(430, 932),
  };

  // Tablet landscape (Android, 1280x800) for the pages that matter on it.
  const tablet = MapEntry('android_tablet', Size(1280, 800));
  const tabletGroups = {GalleryGroup.buttons, GalleryGroup.hud};

  for (final group in GalleryGroup.values) {
    for (final device in [
      ...devices.entries,
      if (tabletGroups.contains(group)) tablet,
    ]) {
      testWidgets('${group.name} on ${device.key}', (tester) async {
        // First pump tall to measure the page, then crop to its height.
        await pumpSurface(
          tester,
          DesignGalleryScreen(initial: group),
          size: Size(device.value.width, 6000),
          surface: TestSurface.ink,
          dpr: 2,
          padding: EdgeInsets.zero,
        );
        final scroll = find.byType(SingleChildScrollView).first;
        // Offsets are relative to the screen: the surface centres its child.
        final top =
            tester.getTopLeft(scroll).dy -
            tester.getTopLeft(find.byType(DesignGalleryScreen)).dy;
        final content = tester.getSize(
          find.descendant(of: scroll, matching: find.byType(Column)).first,
        );
        final height = (top + content.height + TBSpacing.s48 + TBSpacing.s12)
            .clamp(device.value.height, 6000.0);
        await pumpSurface(
          tester,
          DesignGalleryScreen(initial: group),
          size: Size(device.value.width, height),
          surface: TestSurface.ink,
          dpr: 2,
          padding: EdgeInsets.zero,
        );
        await expectLater(
          find.byKey(surfaceKey),
          matchesGoldenFile(
            '../../../docs/screenshots/phase3/${group.name}_${device.key}.png',
          ),
        );
      });
    }
  }
}
