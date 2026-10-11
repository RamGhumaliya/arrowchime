import 'dart:async';

import 'package:arrowchime/app/router.dart';
import 'package:arrowchime/app/theme/tokens.dart';
import 'package:arrowchime/core/ads/ads_controller.dart';
import 'package:arrowchime/core/audio/audio_service.dart';
import 'package:arrowchime/core/audio/sfx.dart';
import 'package:arrowchime/core/meta/progression.dart';
import 'package:arrowchime/core/save/save_controller.dart';
import 'package:arrowchime/core/ui/components/tb_panel.dart';
import 'package:arrowchime/core/ui/components/tb_text.dart';
import 'package:arrowchime/core/ui/support/tb_motion_scope.dart';
import 'package:arrowchime/l10n/gen/app_localizations.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// Splash (`docs/03` §8): the logo plate drops onto the screen with a chime
/// while the current chapter's sounds load, then Home opens. Reduce Motion:
/// the plate just fades in.
class SplashScreen extends ConsumerStatefulWidget {
  const new({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _drop = AnimationController(
    vsync: this,
    duration: TBMotion.celebrateMax * 2,
  );

  @override
  void initState() {
    super.initState();
    final (chapter, _) = Progression.playTarget(
      ref.read(saveControllerProvider),
    );
    final audio = ref.read(audioServiceProvider);
    unawaited(audio.enterChapter(chapter));
    // Consent (UMP) and the ad SDK start here; a failure never blocks the game.
    // Provider changes wait until the tree has finished building.
    unawaited(
      Future.microtask(() {
        final ads = ref.read(adsControllerProvider)..markSessionStart();
        unawaited(ads.init());
      }),
    );
    _drop.addStatusListener((status) {
      if (status != AnimationStatus.completed || !mounted) return;
      audio.sfx(Sfx.star3);
      context.go(AppRoutes.home);
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_drop.isAnimating && !_drop.isCompleted) {
      if (TBMotionScope.reduced(context)) {
        _drop.duration = TBMotion.reducedMotionFade * 4;
      }
      _drop.forward();
    }
  }

  @override
  void dispose() {
    _drop.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final reduced = TBMotionScope.reduced(context);
    final height = MediaQuery.sizeOf(context).height;
    return ColoredBox(
      color: TBColors.ink900,
      child: Center(
        child: AnimatedBuilder(
          animation: _drop,
          builder: (context, child) {
            final t = _drop.value;
            if (reduced) return Opacity(opacity: t, child: child);
            final y = (1 - TBMotion.sheetCurve.transform(t)) * -height * 0.4;
            return Opacity(
              opacity: (t * 4).clamp(0.0, 1.0),
              child: Transform.translate(offset: Offset(0, y), child: child),
            );
          },
          child: Semantics(
            header: true,
            label: l10n.appTitle,
            excludeSemantics: true,
            child: TBPanel(
              padding: const EdgeInsets.symmetric(
                horizontal: TBSpacing.s48,
                vertical: TBSpacing.s32,
              ),
              child: TBText.display(l10n.appTitle, color: TBColors.tangerine),
            ),
          ),
        ),
      ),
    );
  }
}
