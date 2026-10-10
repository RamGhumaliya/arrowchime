import 'dart:math' as math;

import 'package:arrowchime/app/theme/tokens.dart';
import 'package:arrowchime/core/ui/components/tb_panel.dart';
import 'package:arrowchime/core/ui/icons/tb_icon.dart';
import 'package:arrowchime/core/ui/icons/tb_icon_id.dart';
import 'package:arrowchime/core/ui/support/tb_motion_scope.dart';
import 'package:arrowchime/l10n/gen/app_localizations.dart';
import 'package:flutter/widgets.dart';

/// Hearts left on this attempt: full hearts, then broken ones, on a small
/// recessed capsule. Colour is never the only signal: broken hearts have a
/// different shape. A heart that has just been lost cracks: it shakes and
/// pops (Reduce Motion: it just swaps).
class HeartsRow extends StatefulWidget {
  const new({required this.hearts, required this.total, super.key});

  final int hearts;
  final int total;

  @override
  State<HeartsRow> createState() => _HeartsRowState();
}

class _HeartsRowState extends State<HeartsRow>
    with SingleTickerProviderStateMixin {
  static const double _icon = 24;

  late final AnimationController _crack = AnimationController(
    vsync: this,
    duration: TBMotion.celebrateMin,
  );
  int _cracking = -1;

  @override
  void didUpdateWidget(HeartsRow old) {
    super.didUpdateWidget(old);
    if (widget.hearts < old.hearts && !TBMotionScope.reduced(context)) {
      _cracking = widget.hearts;
      _crack.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _crack.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final hearts = widget.hearts;
    final shown = widget.total < hearts ? hearts : widget.total;
    return Semantics(
      label: AppLocalizations.of(context).gameHeartsLabel(hearts),
      excludeSemantics: true,
      child: TBPanel.recessed(
        padding: const EdgeInsets.symmetric(
          horizontal: TBSpacing.s8,
          vertical: TBSpacing.s4,
        ),
        child: AnimatedBuilder(
          animation: _crack,
          builder: (context, _) => Row(
            mainAxisSize: MainAxisSize.min,
            children: [for (var i = 0; i < shown; i++) _heart(i, i < hearts)],
          ),
        ),
      ),
    );
  }

  Widget _heart(int i, bool full) {
    final icon = TBIcon(
      full ? TBIconId.heart : TBIconId.heartBroken,
      size: _icon,
    );
    if (i != _cracking || !_crack.isAnimating) return icon;
    final t = _crack.value;
    final shake = math.sin(t * math.pi * 6) * (1 - t) * 4;
    final pop = 1 + 0.3 * math.sin(t * math.pi);
    return Transform.translate(
      offset: Offset(shake, 0),
      child: Transform.scale(scale: pop, child: icon),
    );
  }
}
