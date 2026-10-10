import 'dart:async';

import 'package:arrowchime/app/feedback_bridge.dart';
import 'package:arrowchime/app/router.dart';
import 'package:arrowchime/app/save_lifecycle.dart';
import 'package:arrowchime/app/theme/tokens.dart';
import 'package:arrowchime/features/game/state/game_settings.dart';
import 'package:arrowchime/l10n/gen/app_localizations.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// Root widget. Uses [WidgetsApp.router] so no stock Material look can leak
/// into player UI (`docs/10` B1).
class ArrowchimeApp extends StatefulWidget {
  const new({this.router, super.key});

  /// A router to use instead of the default one (tests start anywhere).
  final GoRouter? router;

  @override
  State<ArrowchimeApp> createState() => _ArrowchimeAppState();
}

class _ArrowchimeAppState extends State<ArrowchimeApp> {
  late final GoRouter _router = widget.router ?? createRouter();

  @override
  void dispose() {
    if (widget.router == null) _router.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WidgetsApp.router(
      debugShowCheckedModeBanner: false,
      routerConfig: _router,
      color: TBColors.ink900,
      title: 'Arrowchime',
      onGenerateTitle: (context) => AppLocalizations.of(context).appTitle,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      builder: (context, child) => SaveLifecycle(
        child: FeedbackBridge(
          child: _MotionPolicy(
            child: _OrientationPolicy(child: child ?? const SizedBox.shrink()),
          ),
        ),
      ),
    );
  }
}

/// Portrait on phones, all orientations on tablets.
class _OrientationPolicy extends StatefulWidget {
  const new({required this.child});

  final Widget child;

  @override
  State<_OrientationPolicy> createState() => _OrientationPolicyState();
}

class _OrientationPolicyState extends State<_OrientationPolicy> {
  bool? _isTablet;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final tablet =
        MediaQuery.sizeOf(context).shortestSide >= TBSizes.tabletShortestSide;
    if (tablet != _isTablet) {
      _isTablet = tablet;
      unawaited(
        SystemChrome.setPreferredOrientations(
          tablet
              ? DeviceOrientation.values
              : const [DeviceOrientation.portraitUp],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) => widget.child;
}

/// "Reduce motion: on" in Settings forces it even when the system does not
/// ask (`docs/03` §8); "system" leaves the platform's choice alone.
class _MotionPolicy extends ConsumerWidget {
  const new({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final forced = ref.watch(
      gameSettingsControllerProvider.select((s) => s.reduceMotion == 'on'),
    );
    if (!forced) return child;
    return MediaQuery(
      data: MediaQuery.of(context).copyWith(disableAnimations: true),
      child: child,
    );
  }
}
