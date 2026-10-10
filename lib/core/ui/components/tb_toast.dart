import 'dart:async';

import 'package:arrowchime/app/theme/tokens.dart';
import 'package:arrowchime/core/ui/components/tb_text.dart';
import 'package:arrowchime/core/ui/icons/tb_icon.dart';
import 'package:arrowchime/core/ui/icons/tb_icon_id.dart';
import 'package:arrowchime/core/ui/painters/wood_painter.dart';
import 'package:arrowchime/core/ui/support/tb_motion_scope.dart';
import 'package:flutter/widgets.dart';

/// A small floating wooden plaque (`docs/10` §5): slides in from the top and
/// hides itself after 2 s. Show with [showTBToast].
class TBToast extends StatelessWidget {
  const new(this.message, {this.icon, super.key});

  final String message;
  final TBIconId? icon;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      liveRegion: true,
      label: message,
      excludeSemantics: true,
      child: CustomPaint(
        painter: const _PlaquePainter(),
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: TBSizes.toastHeight),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: TBSpacing.s16,
              vertical: TBSpacing.s8,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (icon != null) ...[
                  TBIcon(icon!, size: TBSizes.buttonIcon - TBSpacing.s8),
                  const SizedBox(width: TBSpacing.s8),
                ],
                Flexible(child: TBText.body(message, color: TBColors.cream100)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _PlaquePainter extends CustomPainter {
  const new();

  @override
  void paint(Canvas canvas, Size size) =>
      Wood.paint(canvas, size, grainSeed: 7);

  @override
  bool shouldRepaint(_PlaquePainter old) => false;
}

/// Shows a toast under the status bar for [TBMotion.toast] (2 s). Returns the
/// entry so callers can remove it early.
OverlayEntry showTBToast(
  BuildContext context,
  String message, {
  TBIconId? icon,
}) {
  final overlay = Overlay.of(context);
  late final OverlayEntry entry;
  entry = OverlayEntry(
    builder: (context) => _ToastHost(
      onDone: () {
        if (entry.mounted) entry.remove();
      },
      child: TBToast(message, icon: icon),
    ),
  );
  overlay.insert(entry);
  return entry;
}

class _ToastHost extends StatefulWidget {
  const new({required this.child, required this.onDone});

  final Widget child;
  final VoidCallback onDone;

  @override
  State<_ToastHost> createState() => _ToastHostState();
}

class _ToastHostState extends State<_ToastHost>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: TBMotion.enter,
  );
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _controller.forward();
    _timer = Timer(TBMotion.toast, () async {
      if (!mounted) return;
      await _controller.reverse();
      widget.onDone();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final reduced = TBMotionScope.reduced(context);
    final curved = CurvedAnimation(
      parent: _controller,
      curve: TBMotion.enterCurve,
    );
    final top = MediaQuery.paddingOf(context).top + TBSpacing.s12;
    return Positioned(
      top: top,
      left: TBSpacing.s16,
      right: TBSpacing.s16,
      child: Align(
        alignment: Alignment.topCenter,
        child: reduced
            ? FadeTransition(opacity: curved, child: widget.child)
            : SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0, -1.5),
                  end: Offset.zero,
                ).animate(curved),
                child: FadeTransition(opacity: curved, child: widget.child),
              ),
      ),
    );
  }
}
