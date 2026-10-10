import 'dart:math' as math;

import 'package:arrowchime/app/theme/tokens.dart';
import 'package:arrowchime/core/ui/components/tb_text.dart';
import 'package:arrowchime/core/ui/painters/shade.dart';
import 'package:arrowchime/core/ui/support/tb_motion_scope.dart';
import 'package:arrowchime/features/game/flame/arrow_game.dart';
import 'package:arrowchime/features/onboarding/onboarding_plan.dart';
import 'package:arrowchime/l10n/gen/app_localizations.dart';
import 'package:flutter/widgets.dart';

/// The Chapter 1 hint on the board (`docs/10` §7 ONBOARDING OVERLAY): a short
/// caption on top and a hand cursor that loops the gesture on the first
/// arrow of the solution. It ignores touches, so the player just plays; the
/// screen removes it after the first correct tap.
class OnboardingOverlay extends StatefulWidget {
  const new({
    required this.step,
    required this.game,
    required this.targetArrowId,
    super.key,
  });

  final OnboardingStep step;
  final ArrowGame game;

  /// The arrow the hand points at (the solution's first move).
  final int targetArrowId;

  @override
  State<OnboardingOverlay> createState() => _OnboardingOverlayState();
}

class _OnboardingOverlayState extends State<OnboardingOverlay>
    with SingleTickerProviderStateMixin {
  static const double _handSize = 56;

  late final AnimationController _loop = AnimationController(
    vsync: this,
    duration: TBMotion.celebrateMax * 3,
  );

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (TBMotionScope.reduced(context)) {
      _loop.value = 0.5;
    } else if (!_loop.isAnimating) {
      _loop.repeat();
    }
  }

  @override
  void dispose() {
    _loop.dispose();
    super.dispose();
  }

  String _caption(AppLocalizations l10n) => switch (widget.step.caption) {
    OnboardingCaption.tap => l10n.obTap,
    OnboardingCaption.blocked => l10n.obBlocked,
    OnboardingCaption.hearts => l10n.obHearts,
    OnboardingCaption.bend => l10n.obBend,
    OnboardingCaption.peek => l10n.obPeek,
    OnboardingCaption.zoom => l10n.obZoom,
    OnboardingCaption.knot => l10n.obKnot,
  };

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return IgnorePointer(
      child: Stack(
        children: [
          Align(
            alignment: Alignment.topCenter,
            child: Padding(
              padding: const EdgeInsets.only(top: TBSpacing.s12),
              child: _Caption(text: _caption(l10n)),
            ),
          ),
          AnimatedBuilder(
            animation: _loop,
            builder: (context, _) {
              final comp = widget.game.arrows[widget.targetArrowId];
              final size = widget.game.view.viewport;
              final Offset at;
              if (widget.step.gesture == HandGesture.pinch || comp == null) {
                at = Offset(size.width / 2, size.height / 2);
              } else {
                at = widget.game.view.toScreen(comp.headPoint);
              }
              // The finger touches down (scale 1) and lifts (scale 1.25).
              final press = widget.step.gesture == HandGesture.hold
                  ? (_loop.value < 0.7 ? 1.0 : 0.0)
                  : (math.sin(_loop.value * math.pi * 2) + 1) / 2;
              return Positioned(
                left: at.dx - _handSize * 0.3,
                top: at.dy - _handSize * 0.15,
                child: Transform.scale(
                  scale: 1.25 - 0.25 * press,
                  alignment: Alignment.topLeft,
                  child: const CustomPaint(
                    size: Size.square(_handSize),
                    painter: _HandPainter(),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _Caption extends StatelessWidget {
  const new({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      liveRegion: true,
      label: text,
      excludeSemantics: true,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: TBShade.ink(0.72),
          borderRadius: TBRadius.brPill,
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: TBSpacing.s16,
            vertical: TBSpacing.s8,
          ),
          child: TBText.body(text),
        ),
      ),
    );
  }
}

/// A cream mitten-style hand with a pointing finger: code-painted placeholder
/// for the 3D ceramic hand (`docs/10` §10).
class _HandPainter extends CustomPainter {
  const new();

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final finger = RRect.fromRectAndRadius(
      Rect.fromLTWH(w * 0.22, 0, w * 0.2, w * 0.55),
      Radius.circular(w * 0.1),
    );
    final palm = RRect.fromRectAndRadius(
      Rect.fromLTWH(w * 0.12, w * 0.4, w * 0.5, w * 0.5),
      Radius.circular(w * 0.2),
    );
    final shadow = Paint()..color = TBShade.ink(0.35);
    final face = Paint()..color = TBColors.cream100;
    final rim = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = w * 0.045
      ..color = TBColors.ink900;
    canvas
      ..drawRRect(finger.shift(Offset(w * 0.04, w * 0.05)), shadow)
      ..drawRRect(palm.shift(Offset(w * 0.04, w * 0.05)), shadow)
      ..drawRRect(palm, face)
      ..drawRRect(finger, face)
      ..drawRRect(palm, rim)
      ..drawRRect(finger, rim)
      // A soft highlight along the lit (top-left) side.
      ..drawRRect(
        finger.deflate(w * 0.05),
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = w * 0.03
          ..color = TBShade.white(0.7),
      );
  }

  @override
  bool shouldRepaint(_HandPainter old) => false;
}
