import 'dart:async';

import 'package:arrowchime/app/router.dart';
import 'package:arrowchime/app/theme/chapter_theme.dart';
import 'package:arrowchime/app/theme/tokens.dart';
import 'package:arrowchime/core/ads/rewarded_ads.dart';
import 'package:arrowchime/core/economy/pricing.dart';
import 'package:arrowchime/core/economy/wallet.dart';
import 'package:arrowchime/core/ui/components/tb_button.dart';
import 'package:arrowchime/core/ui/components/tb_chapter_card.dart';
import 'package:arrowchime/core/ui/components/tb_flow_meter.dart';
import 'package:arrowchime/core/ui/components/tb_sheet.dart';
import 'package:arrowchime/core/ui/components/tb_text.dart';
import 'package:arrowchime/core/ui/components/tb_toast.dart';
import 'package:arrowchime/core/ui/icons/tb_icon_id.dart';
import 'package:arrowchime/core/ui/support/tb_layout.dart';
import 'package:arrowchime/core/ui/support/tb_motion_scope.dart';
import 'package:arrowchime/features/game/dialogs/fail_sheet.dart';
import 'package:arrowchime/features/game/dialogs/win_sheet.dart';
import 'package:arrowchime/features/game/flame/arrow_game.dart';
import 'package:arrowchime/features/game/hud/game_shelf.dart';
import 'package:arrowchime/features/game/hud/game_top_bar.dart';
import 'package:arrowchime/features/game/input/board_gestures.dart';
import 'package:arrowchime/features/game/state/game_session.dart';
import 'package:arrowchime/features/game/state/game_settings.dart';
import 'package:arrowchime/features/game/state/level_ref.dart';
import 'package:arrowchime/features/game/state/level_repository.dart';
import 'package:arrowchime/features/game/state/session_event.dart';
import 'package:arrowchime/features/game/state/session_state.dart';
import 'package:arrowchime/l10n/gen/app_localizations.dart';
import 'package:flame/game.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// The playable level (`docs/10` §7 LEVEL): back + ribbon + hearts + coins on
/// top, the Flow meter, the board on its tray, and the wooden shelf of
/// helpers. Tablets in landscape put the shelf on the right.
class GameScreen extends ConsumerWidget {
  const new({required this.levelRef, super.key});

  final LevelRef levelRef;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final level = ref.watch(levelProvider(levelRef));
    final theme = ChapterTheme.byId(levelRef.chapter);
    return _Backdrop(
      theme: theme,
      child: level.when(
        data: (_) => _GameView(levelRef: levelRef, theme: theme),
        loading: () => _Message(text: AppLocalizations.of(context).gameLoading),
        error: (_, _) => _Message(
          text: AppLocalizations.of(context).gameLoadError,
          showBack: true,
        ),
      ),
    );
  }
}

class _Backdrop extends StatelessWidget {
  const new({required this.theme, required this.child});

  final ChapterTheme theme;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        CustomPaint(
          painter: ChapterScenePainter(
            chapter: theme,
            restoration: 1,
            locked: false,
          ),
        ),
        SafeArea(child: child),
      ],
    );
  }
}

class _Message extends StatelessWidget {
  const new({required this.text, this.showBack = false});

  final String text;
  final bool showBack;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TBText.title(text, textAlign: TextAlign.center),
          if (showBack) ...[
            const SizedBox(height: TBSpacing.s24),
            TBButton.primary(
              label: AppLocalizations.of(context).gameBack,
              onPressed: () => _leave(context),
            ),
          ],
        ],
      ),
    );
  }
}

void _leave(BuildContext context) {
  if (context.canPop()) {
    context.pop();
  } else {
    context.go(AppRoutes.home);
  }
}

class _GameView extends ConsumerStatefulWidget {
  const new({required this.levelRef, required this.theme});

  final LevelRef levelRef;
  final ChapterTheme theme;

  @override
  ConsumerState<_GameView> createState() => _GameViewState();
}

class _GameViewState extends ConsumerState<_GameView> {
  static const bool _showFps = bool.fromEnvironment('SHOW_FPS');

  ArrowGame? _game;
  StreamSubscription<SessionEvent>? _events;
  Timer? _flowTimer;

  GameSession get _session =>
      ref.read(gameSessionProvider(widget.levelRef).notifier);

  @override
  void initState() {
    super.initState();
    _events = _session.events.listen(_onEvent);
    _flowTimer = Timer.periodic(TBGesture.flowTick, (_) {
      if (mounted) _session.tickFlow();
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _game ??= ArrowGame(
      engine: _session.engine,
      theme: widget.theme,
      reduceMotion: TBMotionScope.reduced(context),
      pixelRatio: MediaQuery.devicePixelRatioOf(context),
      // ignore: avoid_redundant_argument_values, set by --dart-define
      showFps: _showFps,
      onWon: _showWin,
      onLost: _showFail,
    );
  }

  @override
  void dispose() {
    unawaited(_events?.cancel());
    _flowTimer?.cancel();
    super.dispose();
  }

  void _onEvent(SessionEvent e) {
    final game = _game;
    if (game == null) return;
    switch (e) {
      case EnginePlayed():
        game.playEvents(e.events);
      case BoardReset():
        game.resetBoard();
      case HeartGranted():
        game.resumeAfterLoss();
      case HintGiven():
        game.showHint(e.arrowId);
    }
  }

  // --- input ----------------------------------------------------------------

  bool _tap(Offset position) {
    final id = _game?.arrowAt(position);
    if (id == null) return false;
    _session.tap(id);
    return true;
  }

  void _toast(String message, {TBIconId? icon}) =>
      showTBToast(context, message, icon: icon);

  void _undo() {
    final result = _session.undo();
    if (result == PurchaseResult.noCoins) {
      _toast(AppLocalizations.of(context).gameNoCoins, icon: TBIconId.coin);
    }
  }

  void _hint() {
    final l10n = AppLocalizations.of(context);
    switch (_session.hint()) {
      case PurchaseResult.noCoins:
        _toast(l10n.gameNoCoins, icon: TBIconId.coin);
      case PurchaseResult.unavailable:
        _toast(l10n.gameNoHint, icon: TBIconId.hint);
      case PurchaseResult.done:
      case PurchaseResult.free:
        break;
    }
  }

  // --- results --------------------------------------------------------------

  void _showWin() {
    if (!mounted) return;
    final state = ref.read(gameSessionProvider(widget.levelRef));
    final reward = state.reward;
    if (reward == null) return;
    final id = widget.levelRef;
    unawaited(
      showTBSheet<void>(
        context,
        barrierDismissible: false,
        sheet: WinSheet(
          levelNumber: id.index,
          stars: state.stars,
          reward: reward,
          animate: !TBMotionScope.reduced(context),
          onNext: () {
            Navigator.of(context).pop();
            context.go(
              id.index < 60
                  ? AppRoutes.levelPath(id.chapterSlug, id.index + 1)
                  : AppRoutes.chapterMap,
            );
          },
          onReplay: () {
            Navigator.of(context).pop();
            _session.retry();
          },
        ),
      ),
    );
  }

  void _showFail() {
    if (!mounted) return;
    final session = _session;
    unawaited(
      showTBSheet<void>(
        context,
        barrierDismissible: false,
        sheet: Consumer(
          builder: (context, ref, _) => FailSheet(
            level: session.engine.level,
            theme: widget.theme,
            remaining: session.engine.remainingIds.toSet(),
            heartPrice: Pricing.heart,
            canAffordHeart: ref.watch(walletProvider) >= Pricing.heart,
            onRetry: () {
              Navigator.of(context).pop();
              session.retry();
            },
            onHeartAd: () async {
              final earned = await ref.read(rewardedAdsProvider).show();
              if (!earned || !context.mounted) return;
              Navigator.of(context).pop();
              session.grantHeart();
            },
            onHeartCoins: () {
              if (session.buyHeart() == PurchaseResult.done) {
                Navigator.of(context).pop();
              }
            },
          ),
        ),
      ),
    );
  }

  // --- build ----------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    final id = widget.levelRef;
    final state = ref.watch(gameSessionProvider(id));
    final settings = ref.watch(gameSettingsControllerProvider);
    final coins = ref.watch(walletProvider);
    final l10n = AppLocalizations.of(context);
    final game = _game!..setGridVisible(visible: settings.gridOn);

    ref.listen(gameSessionProvider(id).select((s) => s.flowMultiplier), (
      before,
      after,
    ) {
      if (after > (before ?? 1) && after >= 2) _toast(l10n.gameFlowNice);
    });

    final size = MediaQuery.sizeOf(context);
    final landscapeTablet =
        TBLayout.isTablet(context) && size.width > size.height;
    final margin = TBLayout.screenMargin(context);

    final topBar = GameTopBar(
      levelNumber: id.index,
      hearts: state.hearts,
      totalHearts: state.initialHearts,
      coins: coins,
      onBack: () => _leave(context),
    );
    final flow = TBFlowMeter(
      fill: state.flowFill,
      color: widget.theme.arrowColors.first,
      multiplier: state.flowMultiplier,
    );
    final board = _Board(game: game, remaining: state.remaining, onTap: _tap);

    Widget shelf(Axis axis) => ValueListenableBuilder<bool>(
      valueListenable: game.atFit,
      builder: (context, atFit, _) => GameShelf(
        axis: axis,
        leftHanded: settings.leftHanded,
        canUndo: state.canUndo && state.isPlaying,
        undoBadge: state.freeUndosLeft > 0
            ? '${state.freeUndosLeft}'
            : '${Pricing.undo}',
        hintBadge: _hintBadge(state),
        gridOn: settings.gridOn,
        canFit: !atFit,
        onUndo: _undo,
        onHint: _hint,
        onGrid: ref.read(gameSettingsControllerProvider.notifier).toggleGrid,
        onFit: game.fitBoard,
      ),
    );

    if (landscapeTablet) {
      return Padding(
        padding: EdgeInsets.all(margin),
        child: Row(
          children: [
            Expanded(
              flex: 7,
              child: Column(
                children: [
                  topBar,
                  const SizedBox(height: TBSpacing.s12),
                  flow,
                  const SizedBox(height: TBSpacing.s12),
                  Expanded(child: board),
                ],
              ),
            ),
            const SizedBox(width: TBSpacing.s24),
            Expanded(flex: 3, child: Center(child: shelf(Axis.vertical))),
          ],
        ),
      );
    }
    return Padding(
      padding: EdgeInsets.fromLTRB(margin, TBSpacing.s8, margin, TBSpacing.s12),
      child: Column(
        children: [
          topBar,
          const SizedBox(height: TBSpacing.s12),
          flow,
          const SizedBox(height: TBSpacing.s12),
          Expanded(child: board),
          const SizedBox(height: TBSpacing.s12),
          shelf(Axis.horizontal),
        ],
      ),
    );
  }

  String? _hintBadge(SessionState state) {
    if (widget.levelRef.globalIndex < Pricing.hintsFreeBelowLevel) return null;
    return state.freeHintsLeft > 0
        ? '${state.freeHintsLeft}'
        : '${Pricing.hint}';
  }
}

class _Board extends StatelessWidget {
  const new({required this.game, required this.remaining, required this.onTap});

  final ArrowGame game;
  final int remaining;
  final bool Function(Offset position) onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: AppLocalizations.of(context).gameBoardLabel(remaining),
      child: ClipRRect(
        borderRadius: TBRadius.br20,
        child: BoardGestures(
          onTap: onTap,
          onPan: game.panBy,
          onZoom: game.zoomBy,
          onPeekStart: game.peekAt,
          onPeekEnd: game.endPeek,
          onDoubleTapEmpty: game.toggleZoom,
          child: GameWidget(game: game),
        ),
      ),
    );
  }
}
