import 'package:arrowchime/app/theme/tokens.dart';
import 'package:arrowchime/app/theme/typography.dart';
import 'package:arrowchime/core/ui/components/tb_text.dart';
import 'package:arrowchime/core/ui/icons/tb_icon.dart';
import 'package:arrowchime/core/ui/icons/tb_icon_id.dart';
import 'package:arrowchime/core/ui/painters/paper_painter.dart';
import 'package:arrowchime/core/ui/painters/shade.dart';
import 'package:arrowchime/core/ui/painters/wood_painter.dart';
import 'package:arrowchime/core/ui/support/tb_haptics.dart';
import 'package:arrowchime/core/ui/support/tb_layout.dart';
import 'package:flutter/widgets.dart';

/// One tab of a [TBTabBar].
class TBTabItem {
  const new({required this.icon, required this.label});

  final TBIconId icon;
  final String label;
}

/// A wooden shelf with 3D tab plaques. The selected plaque is raised paper
/// with a tangerine underline glow; the others sit flat in the wood.
class TBTabBar extends StatelessWidget {
  const new({
    required this.tabs,
    required this.selectedIndex,
    required this.onSelected,
    super.key,
  });

  final List<TBTabItem> tabs;
  final int selectedIndex;
  final ValueChanged<int> onSelected;

  static const double _lift = TBSpacing.s4;
  static const double _glowHeight = TBSpacing.s4;

  @override
  Widget build(BuildContext context) {
    // Taller shelf when the user scales text up, so labels never clip.
    final extra = TBLayout.extraLine(
      context,
      TBTypography.caption.style.fontSize!,
    );
    return CustomPaint(
      painter: const _ShelfPainter(),
      child: Padding(
        padding: const EdgeInsets.all(TBSpacing.s8),
        child: SizedBox(
          height: TBSizes.tabHeight + _lift + _glowHeight + extra,
          child: Row(
            children: [
              for (var i = 0; i < tabs.length; i++)
                Expanded(
                  child: _Tab(
                    item: tabs[i],
                    selected: i == selectedIndex,
                    onTap: () {
                      if (i == selectedIndex) return;
                      TBHaptics.selection();
                      onSelected(i);
                    },
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Tab extends StatelessWidget {
  const new({required this.item, required this.selected, required this.onTap});

  final TBTabItem item;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: selected,
      label: item.label,
      excludeSemantics: true,
      onTap: onTap,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: TBSpacing.s4),
          child: CustomPaint(
            painter: _PlaquePainter(selected: selected),
            child: Padding(
              padding: EdgeInsets.only(
                top: selected ? 0 : TBTabBar._lift,
                bottom: selected ? TBTabBar._lift : 0,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TBIcon(item.icon, size: TBSizes.buttonIcon - TBSpacing.s4),
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    child: TBText.caption(
                      item.label,
                      color: selected ? TBColors.ink900 : TBColors.cream100,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ShelfPainter extends CustomPainter {
  const new();

  @override
  void paint(Canvas canvas, Size size) => Wood.paint(canvas, size);

  @override
  bool shouldRepaint(_ShelfPainter old) => false;
}

class _PlaquePainter extends CustomPainter {
  const new({required this.selected});

  final bool selected;

  @override
  void paint(Canvas canvas, Size size) {
    const lift = TBTabBar._lift;
    const glow = TBTabBar._glowHeight;
    if (selected) {
      // Raised paper plaque, tangerine underline glow below it.
      final h = size.height - glow - lift / 2;
      canvas
        ..save()
        ..translate(0, 0);
      Paper.paintRaised(
        canvas,
        Size(size.width, h),
        radius: TBRadius.r12,
        elevation: TBElevation.e1,
        grainSeed: 5,
      );
      canvas.restore();
      final bar = RRect.fromRectAndRadius(
        Rect.fromLTWH(
          size.width * 0.25,
          size.height - glow,
          size.width * 0.5,
          glow,
        ),
        const Radius.circular(TBRadius.pill),
      );
      canvas
        ..drawRRect(
          bar,
          Paint()
            ..color = TBColors.tangerine.withValues(alpha: 0.6)
            ..maskFilter = const MaskFilter.blur(BlurStyle.normal, glow),
        )
        ..drawRRect(bar, Paint()..color = TBColors.tangerine);
    } else {
      // Flat plaque pressed into the shelf.
      final rect = Rect.fromLTWH(
        0,
        lift,
        size.width,
        size.height - glow - lift,
      );
      final r = RRect.fromRectAndRadius(
        rect,
        const Radius.circular(TBRadius.r12),
      );
      canvas
        ..drawRRect(r, Paint()..color = TBShade.ink(0.18))
        ..drawRRect(
          r.deflate(TBBevel.rimLight),
          Paint()..color = TBMaterials.woodFace,
        );
    }
  }

  @override
  bool shouldRepaint(_PlaquePainter old) => old.selected != selected;
}
