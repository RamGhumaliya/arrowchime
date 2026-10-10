import 'package:arrowchime/app/theme/tokens.dart';
import 'package:arrowchime/core/ui/components/tb_icon_button.dart';
import 'package:arrowchime/core/ui/icons/tb_icon_id.dart';
import 'package:arrowchime/core/ui/painters/wood_painter.dart';
import 'package:arrowchime/l10n/gen/app_localizations.dart';
import 'package:flutter/widgets.dart';

/// The wooden shelf with Undo / Hint / Grid / Fit (`docs/10` §7). Horizontal
/// at the bottom of a portrait screen (mirrored for left-handed players),
/// vertical on the right of a tablet in landscape.
class GameShelf extends StatelessWidget {
  const new({
    required this.axis,
    required this.leftHanded,
    required this.canUndo,
    required this.undoBadge,
    required this.hintBadge,
    required this.gridOn,
    required this.canFit,
    required this.onUndo,
    required this.onHint,
    required this.onGrid,
    required this.onFit,
    super.key,
  });

  final Axis axis;
  final bool leftHanded;
  final bool canUndo;

  /// Free count (`2`) or price (`30`), or `null`.
  final String? undoBadge;
  final String? hintBadge;
  final bool gridOn;
  final bool canFit;
  final VoidCallback onUndo;
  final VoidCallback onHint;
  final VoidCallback onGrid;
  final VoidCallback onFit;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final buttons = <Widget>[
      TBIconButton(
        icon: TBIconId.undo,
        semanticLabel: l10n.gameUndo,
        badge: undoBadge,
        onPressed: canUndo ? onUndo : null,
      ),
      TBIconButton(
        icon: TBIconId.hint,
        semanticLabel: l10n.gameHint,
        badge: hintBadge,
        onPressed: onHint,
      ),
      TBIconButton(
        icon: TBIconId.grid,
        semanticLabel: l10n.gameGrid,
        selected: gridOn,
        onPressed: onGrid,
      ),
      TBIconButton(
        icon: TBIconId.fit,
        semanticLabel: l10n.gameFit,
        onPressed: canFit ? onFit : null,
      ),
    ];
    final ordered = leftHanded ? buttons.reversed.toList() : buttons;
    final horizontal = axis == Axis.horizontal;
    return CustomPaint(
      painter: const _ShelfPainter(),
      child: Padding(
        padding: const EdgeInsets.all(TBSpacing.s12),
        child: Flex(
          direction: axis,
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            for (final b in ordered)
              Padding(
                padding: horizontal
                    ? const EdgeInsets.symmetric(horizontal: TBSpacing.s4)
                    : const EdgeInsets.symmetric(vertical: TBSpacing.s8),
                child: b,
              ),
          ],
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
