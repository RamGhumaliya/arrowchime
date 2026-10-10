import 'package:arrowchime/app/theme/tokens.dart';
import 'package:arrowchime/core/ui/components/tb_button.dart';
import 'package:arrowchime/core/ui/components/tb_ribbon.dart';
import 'package:arrowchime/core/ui/components/tb_text.dart';
import 'package:arrowchime/core/ui/support/tb_layout.dart';
import 'package:arrowchime/features/design_gallery/gallery_pages.dart';
import 'package:flutter/widgets.dart';

/// Debug-only route `/design-gallery` (`docs/10` §11): every `TB*` component
/// with all its states, grouped into pages, on cream, ink and one chapter
/// background. Developer labels here are not player copy.
///
/// Responsive: the whole page scrolls (so a large text scale never squeezes
/// the content), phones use a 16 dp margin, tablets a 32 dp margin with the
/// content centred at a readable width.
class DesignGalleryScreen extends StatefulWidget {
  const new({this.initial = GalleryGroup.foundations, super.key});

  final GalleryGroup initial;

  @override
  State<DesignGalleryScreen> createState() => _DesignGalleryScreenState();
}

class _DesignGalleryScreenState extends State<DesignGalleryScreen> {
  late GalleryGroup _group = widget.initial;

  @override
  Widget build(BuildContext context) {
    final padding = MediaQuery.paddingOf(context);
    final margin = TBLayout.screenMargin(context);
    return ColoredBox(
      // ink700 so the ink900 surface blocks stay visible against the page.
      color: TBColors.ink700,
      child: SingleChildScrollView(
        key: ValueKey(_group),
        padding: EdgeInsets.only(
          left: margin,
          top: padding.top + TBSpacing.s12,
          right: margin,
          bottom: padding.bottom + TBSpacing.s48,
        ),
        child: TBCentered(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Center(child: TBRibbon('Design Gallery')),
              const SizedBox(height: TBSpacing.s12),
              Wrap(
                spacing: TBSpacing.s8,
                runSpacing: TBSpacing.s12,
                children: [
                  for (final g in GalleryGroup.values)
                    if (g == _group)
                      TBButton.secondary(label: g.label, onPressed: () {})
                    else
                      TBButton.tertiary(
                        label: g.label,
                        onPressed: () => setState(() => _group = g),
                      ),
                ],
              ),
              const SizedBox(height: TBSpacing.s16),
              _group.page,
              const TBText.caption(
                'Debug only · placeholders are marked',
                color: TBColors.cream300,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
