import 'dart:math' as math;

import 'package:arrowchime/app/theme/tokens.dart';
import 'package:arrowchime/core/economy/rewards.dart';
import 'package:arrowchime/core/level/models/level.dart';
import 'package:arrowchime/core/ui/components/tb_button.dart';
import 'package:arrowchime/core/ui/components/tb_star_row.dart';
import 'package:arrowchime/core/ui/components/tb_text.dart';
import 'package:arrowchime/core/ui/icons/tb_icon.dart';
import 'package:arrowchime/core/ui/icons/tb_icon_id.dart';
import 'package:arrowchime/core/ui/painters/shade.dart';
import 'package:arrowchime/core/ui/support/tb_motion_scope.dart';
import 'package:arrowchime/l10n/gen/app_localizations.dart';
import 'package:flutter/widgets.dart';

/// Level cleared (`docs/10` §7, V2 "Clean Line"): a full-screen celebration —
/// teal gradient, a slowly turning sunburst, confetti, the stars stamping in,
/// the finished picture of the level on a white card, the coins and XP, then
/// Next (primary) and Replay. Shown with `showTBFullscreen`.
class WinSheet extends StatefulWidget {
  const new({
    required this.levelNumber,
    required this.stars,
    required this.reward,
    required this.onNext,
    required this.onReplay,
    this.level,
    this.animate = true,
    this.onCoinTick,
    this.nextLabel,
    this.onDoubleCoins,
    this.bonusLines = const [],
    super.key,
  });

  final int levelNumber;
  final int stars;
  final LevelReward reward;
  final VoidCallback onNext;
  final VoidCallback onReplay;

  /// The cleared level: its shape is revealed as a coloured picture.
  final Level? level;
  final bool animate;

  /// Called for each clink of the coin count-up (0-based).
  final void Function(int index)? onCoinTick;

  /// Label of the primary button (default "Next level"; Daily: "Done").
  final String? nextLabel;

  /// "x2 coins" rewarded ad; `null` hides the button (no coins, cap used or
  /// no ad ready).
  final VoidCallback? onDoubleCoins;

  /// Extra lines under the rewards: a level-up, achievements unlocked.
  final List<String> bonusLines;

  @override
  State<WinSheet> createState() => _WinSheetState();
}

class _WinSheetState extends State<WinSheet> with TickerProviderStateMixin {
  /// The sunburst's slow turn and the confetti's one-shot fall share a clock.
  late final AnimationController _show = AnimationController(
    vsync: this,
    duration: TBMotion.celebrateMax * 5,
  );
  late final AnimationController _turn = AnimationController(
    vsync: this,
    duration: TBMotion.shimmer * 30,
  );

  @override
  void initState() {
    super.initState();
    if (widget.animate) {
      _show.forward();
      _turn.repeat();
    } else {
      _show.value = 1;
    }
  }

  @override
  void dispose() {
    _show.dispose();
    _turn.dispose();
    super.dispose();
  }

  /// A 0–1 interval of the entrance, so pieces arrive one after the other.
  Animation<double> _enter(double from, double to) => CurvedAnimation(
    parent: _show,
    curve: Interval(from, to, curve: TBMotion.releaseCurve),
  );

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final reduced = TBMotionScope.reduced(context);
    final level = widget.level;
    return Semantics(
      scopesRoute: true,
      explicitChildNodes: true,
      child: Stack(
        fit: StackFit.expand,
        children: [
          DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  TBShade.lighten(TBColors.tangerine, 0.1),
                  TBColors.tangerineLip,
                ],
              ),
            ),
          ),
          ExcludeSemantics(
            child: AnimatedBuilder(
              animation: _turn,
              builder: (context, _) =>
                  CustomPaint(painter: _SunburstPainter(turn: _turn.value)),
            ),
          ),
          if (!reduced)
            ExcludeSemantics(
              child: AnimatedBuilder(
                animation: _show,
                builder: (context, _) =>
                    CustomPaint(painter: _ConfettiPainter(t: _show.value)),
              ),
            ),
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: TBSpacing.s24,
                  vertical: TBSpacing.s16,
                ),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(
                    maxWidth: TBSizes.sheetMaxWidth,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _Pop(
                        animation: _enter(0, 0.3),
                        child: Column(
                          children: [
                            TBText.counter(
                              l10n.winTitle(widget.levelNumber),
                              color: TBColors.cream100.withValues(alpha: 0.85),
                            ),
                            const SizedBox(height: TBSpacing.s4),
                            TBText.display(
                              l10n.winHeadline,
                              color: TBColors.cream100,
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: TBSpacing.s16),
                      Semantics(
                        label: l10n.winStars(widget.stars),
                        excludeSemantics: true,
                        child: TBStarRow(
                          filled: widget.stars,
                          animate: widget.animate,
                        ),
                      ),
                      const SizedBox(height: TBSpacing.s16),
                      if (level != null)
                        _Pop(
                          animation: _enter(0.2, 0.55),
                          child: _PictureCard(level: level),
                        ),
                      const SizedBox(height: TBSpacing.s16),
                      _CoinCountUp(
                        coins: widget.reward.coins,
                        animate: widget.animate,
                        onTick: widget.onCoinTick,
                      ),
                      if (widget.onDoubleCoins != null) ...[
                        const SizedBox(height: TBSpacing.s8),
                        TBButton.secondary(
                          label: l10n.winDoubleCoins,
                          onPressed: widget.onDoubleCoins,
                        ),
                      ],
                      const SizedBox(height: TBSpacing.s8),
                      _RewardRow(
                        icon: TBIconId.trophy,
                        text: l10n.winXp(widget.reward.xp),
                      ),
                      for (final line in widget.bonusLines) ...[
                        const SizedBox(height: TBSpacing.s8),
                        TBText.body(
                          line,
                          color: TBColors.cream100,
                          textAlign: TextAlign.center,
                        ),
                      ],
                      const SizedBox(height: TBSpacing.s24),
                      TBButton.tertiary(
                        label: widget.nextLabel ?? l10n.winNext,
                        onPressed: widget.onNext,
                        expand: true,
                      ),
                      const SizedBox(height: TBSpacing.s8),
                      _TextLink(
                        label: l10n.winReplay,
                        onPressed: widget.onReplay,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Scales and fades [child] in along [animation] (settles with a small
/// overshoot). Reduce Motion: the animation is already finished.
class _Pop extends StatelessWidget {
  const new({required this.animation, required this.child});

  final Animation<double> animation;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        final t = animation.value.clamp(0.0, 1.0);
        return Opacity(
          opacity: t,
          child: Transform.scale(scale: 0.6 + 0.4 * t, child: child),
        );
      },
      child: child,
    );
  }
}

/// A quiet text button on the coloured page.
class _TextLink extends StatelessWidget {
  const new({required this.label, required this.onPressed});

  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: label,
      excludeSemantics: true,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onPressed,
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            minHeight: TBSizes.minTapTarget,
            minWidth: TBSizes.minTapTarget,
          ),
          child: Center(child: TBText.button(label, color: TBColors.cream100)),
        ),
      ),
    );
  }
}

class _RewardRow extends StatelessWidget {
  const new({required this.icon, required this.text});

  final TBIconId icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        TBIcon(icon),
        const SizedBox(width: TBSpacing.s8),
        TBText.counter(text, color: TBColors.cream100),
      ],
    );
  }
}

/// "+N coins" counting up from 0 with a clink every fifth of the way, each a
/// little higher (`docs/03` §4). Reduce Motion / no animation: the final text.
class _CoinCountUp extends StatefulWidget {
  const new({required this.coins, required this.animate, required this.onTick});

  final int coins;
  final bool animate;
  final void Function(int index)? onTick;

  @override
  State<_CoinCountUp> createState() => _CoinCountUpState();
}

class _CoinCountUpState extends State<_CoinCountUp>
    with SingleTickerProviderStateMixin {
  static const int _clinks = 5;

  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: TBMotion.celebrateMax,
  );
  int _ticked = 0;

  @override
  void initState() {
    super.initState();
    if (widget.animate && widget.coins > 0) {
      _c
        ..addListener(_maybeTick)
        ..forward();
    } else {
      _c.value = 1;
    }
  }

  void _maybeTick() {
    final due = (_c.value * _clinks).floor();
    while (_ticked < due) {
      widget.onTick?.call(_ticked++);
    }
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _c,
      builder: (context, _) => _RewardRow(
        icon: TBIconId.coin,
        text: AppLocalizations.of(
          context,
        ).winCoins((widget.coins * Curves.easeOut.transform(_c.value)).round()),
      ),
    );
  }
}

/// The finished picture: every cell of the level as a rounded tile, coloured
/// by the arrow that stood on it. Masked-out cells stay empty, so a heart
/// level reveals a heart.
class _PictureCard extends StatelessWidget {
  const new({required this.level});

  final Level level;

  @override
  Widget build(BuildContext context) {
    return ExcludeSemantics(
      child: DecoratedBox(
        decoration: const BoxDecoration(
          color: TBColors.cream100,
          borderRadius: TBRadius.br32,
          boxShadow: TBElevation.e3,
        ),
        child: Padding(
          padding: const EdgeInsets.all(TBSpacing.s16),
          child: SizedBox(
            height: 200,
            width: double.infinity,
            child: CustomPaint(painter: _PicturePainter(level)),
          ),
        ),
      ),
    );
  }
}

class _PicturePainter extends CustomPainter {
  const new(this.level);

  final Level level;

  static const List<Color> _palette = [
    TBColors.tangerine,
    TBColors.butter,
    TBColors.berry,
    TBColors.sky,
    TBColors.teal,
  ];

  @override
  void paint(Canvas canvas, Size size) {
    final cols = level.width;
    final rows = level.height;
    final cell = math.min(size.width / cols, size.height / rows);
    final origin = Offset(
      (size.width - cols * cell) / 2,
      (size.height - rows * cell) / 2,
    );
    final owner = <int, int>{};
    for (final a in level.arrows) {
      for (final c in a.body) {
        owner[c.y * cols + c.x] = a.id;
      }
    }
    final mask = level.mask;
    for (var y = 0; y < rows; y++) {
      for (var x = 0; x < cols; x++) {
        if (mask != null && mask[y][x] != '1') continue;
        final id = owner[y * cols + x];
        final color = id == null
            ? TBColors.cream300
            : _palette[id % _palette.length];
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromLTWH(
              origin.dx + x * cell,
              origin.dy + y * cell,
              cell,
              cell,
            ).deflate(cell * 0.06),
            Radius.circular(cell * 0.22),
          ),
          Paint()..color = color,
        );
      }
    }
  }

  @override
  bool shouldRepaint(_PicturePainter old) => old.level != level;
}

/// Alternating translucent wedges turning slowly behind the content.
class _SunburstPainter extends CustomPainter {
  const new({required this.turn});

  final double turn;

  static const int _rays = 24;

  @override
  void paint(Canvas canvas, Size size) {
    final centre = Offset(size.width / 2, size.height * 0.46);
    final reach = size.longestSide * 1.2;
    final paint = Paint()..color = TBColors.cream100.withValues(alpha: 0.09);
    const step = 2 * math.pi / _rays;
    for (var i = 0; i < _rays; i += 2) {
      final a0 = turn * 2 * math.pi + i * step;
      final a1 = a0 + step;
      canvas.drawPath(
        Path()
          ..moveTo(centre.dx, centre.dy)
          ..lineTo(
            centre.dx + math.cos(a0) * reach,
            centre.dy + math.sin(a0) * reach,
          )
          ..lineTo(
            centre.dx + math.cos(a1) * reach,
            centre.dy + math.sin(a1) * reach,
          )
          ..close(),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(_SunburstPainter old) => old.turn != turn;
}

/// A one-shot shower of confetti, laid out from a fixed noise sequence so the
/// picture is identical every run.
class _ConfettiPainter extends CustomPainter {
  new({required this.t}) {
    final noise = TBNoise(7);
    for (var i = 0; i < _count; i++) {
      _x.add(noise.next());
      _speed.add(0.55 + noise.next() * 0.6);
      _phase.add(noise.next());
      _spin.add(noise.next() * 6);
      _color.add(_palette[(noise.next() * _palette.length).floor()]);
    }
  }

  final double t;

  static const int _count = 70;
  static const List<Color> _palette = [
    TBColors.butter,
    TBColors.cream100,
    TBColors.berry,
    TBColors.sky,
    TBColors.tangerineLip,
  ];

  final List<double> _x = [];
  final List<double> _speed = [];
  final List<double> _phase = [];
  final List<double> _spin = [];
  final List<Color> _color = [];

  @override
  void paint(Canvas canvas, Size size) {
    for (var i = 0; i < _count; i++) {
      final progress = t * _speed[i] * 1.5 - _phase[i] * 0.5;
      if (progress <= 0 || progress >= 1.1) continue;
      final x =
          size.width * _x[i] +
          math.sin(progress * 6 + _phase[i] * 6) * size.width * 0.03;
      final y = -20 + progress * (size.height + 40);
      canvas
        ..save()
        ..translate(x, y)
        ..rotate(_spin[i] + progress * 8)
        ..drawRect(
          const Rect.fromLTWH(-4, -7, 8, 14),
          Paint()..color = _color[i],
        )
        ..restore();
    }
  }

  @override
  bool shouldRepaint(_ConfettiPainter old) => old.t != t;
}
