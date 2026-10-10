import 'dart:async';

import 'package:arrowchime/core/economy/pricing.dart';
import 'package:arrowchime/core/economy/rewards.dart';
import 'package:arrowchime/core/economy/wallet.dart';
import 'package:arrowchime/core/level/engine/events.dart';
import 'package:arrowchime/core/level/engine/game_engine.dart';
import 'package:arrowchime/core/level/solver/hint.dart';
import 'package:arrowchime/features/game/model/flow_tracker.dart';
import 'package:arrowchime/features/game/state/game_settings.dart';
import 'package:arrowchime/features/game/state/level_ref.dart';
import 'package:arrowchime/features/game/state/level_repository.dart';
import 'package:arrowchime/features/game/state/session_event.dart';
import 'package:arrowchime/features/game/state/session_state.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'game_session.g.dart';

/// Monotonic clock of the Flow streak (replaced in tests).
final flowClockProvider = Provider<Duration Function()>((ref) {
  final watch = Stopwatch()..start();
  return () => watch.elapsed;
});

/// Result of paying for an undo or a hint.
enum PurchaseResult { done, free, noCoins, unavailable }

/// One attempt at one level: owns the engine, the Flow streak and the hint
/// cache, pays and charges the wallet, and publishes [events] for Flame.
@riverpod
class GameSession extends _$GameSession {
  late GameEngine _engine;
  late FlowTracker _flow;
  late HintService _hints;
  late LevelRef _id;
  final _events = StreamController<SessionEvent>.broadcast();
  int _freeUndosLeft = Pricing.freeUndos;
  int _freeHintsLeft = Pricing.freeHintsPerLevel;
  int? _hintArrowId;
  LevelReward? _reward;

  /// Animations to play, in order.
  Stream<SessionEvent> get events => _events.stream;

  GameEngine get engine => _engine;

  @override
  SessionState build(LevelRef levelRef) {
    _id = levelRef;
    final level = ref.watch(levelProvider(levelRef)).requireValue;
    final settings = ref.read(gameSettingsControllerProvider);
    _engine = GameEngine(
      level,
      options: EngineOptions(relaxed: settings.relaxed),
    );
    _flow = FlowTracker(now: ref.read(flowClockProvider));
    _hints = HintService(_engine);
    ref.onDispose(_events.close);
    return _snapshot();
  }

  SessionState _snapshot() => SessionState(
    level: _engine.level,
    status: _engine.status,
    hearts: _engine.hearts,
    initialHearts: _engine.initialHearts,
    remaining: _engine.remaining,
    total: _engine.level.arrows.length,
    stars: _engine.stars,
    freeUndosLeft: _freeUndosLeft,
    canUndo: _engine.canUndo,
    freeHintsLeft: _freeHintsLeft,
    flowMultiplier: _flow.multiplier,
    flowFill: _flow.fill,
    bestFlow: _flow.bestMultiplier,
    taps: _engine.stats.freedTaps + _engine.stats.blockedTaps,
    blockedTaps: _engine.stats.blockedTaps,
    hintArrowId: _hintArrowId,
    reward: _reward,
  );

  /// The player tapped arrow [arrowId].
  void tap(int arrowId) {
    if (_engine.status != GameStatus.playing) return;
    final events = _engine.tap(arrowId);
    if (events.isEmpty) return;
    _hintArrowId = null;
    for (final e in events) {
      if (e is ArrowFreed && !e.viaLink) _flow.onFreed();
      if (e is BlockedTap) _flow.onBlocked();
    }
    if (events.any((e) => e is LevelWon)) _pay();
    _events.add(EnginePlayed(events));
    state = _snapshot();
  }

  /// Pays the win reward exactly once (G4).
  void _pay() {
    if (_reward != null) return;
    final reward = Rewards.forWin(
      stars: _engine.stars,
      index: _id.index,
      flowMultiplier: _flow.bestMultiplier,
    );
    _reward = reward;
    ref.read(walletProvider.notifier).add(reward.coins);
  }

  /// Undoes the last removal: free twice, then [Pricing.undo] coins.
  PurchaseResult undo() {
    if (!_engine.canUndo) return PurchaseResult.unavailable;
    var result = PurchaseResult.free;
    if (_freeUndosLeft > 0) {
      _freeUndosLeft--;
    } else if (ref.read(walletProvider.notifier).trySpend(Pricing.undo)) {
      result = PurchaseResult.done;
    } else {
      return PurchaseResult.noCoins;
    }
    final events = _engine.undo();
    _flow.onBlocked();
    _hintArrowId = null;
    _events.add(EnginePlayed(events));
    state = _snapshot();
    return result;
  }

  /// Highlights an arrow that keeps the level solvable. Free on the first
  /// levels and once per level afterwards, then [Pricing.hint] coins.
  PurchaseResult hint() {
    if (_engine.status != GameStatus.playing) return PurchaseResult.unavailable;
    final id = _hints.next();
    if (id == null) return PurchaseResult.unavailable;
    var result = PurchaseResult.free;
    if (_id.globalIndex >= Pricing.hintsFreeBelowLevel) {
      if (_freeHintsLeft > 0) {
        _freeHintsLeft--;
      } else if (ref.read(walletProvider.notifier).trySpend(Pricing.hint)) {
        result = PurchaseResult.done;
      } else {
        return PurchaseResult.noCoins;
      }
    }
    _hintArrowId = id;
    _events.add(HintGiven(id));
    state = _snapshot();
    return result;
  }

  /// Starts the level over. Always free and never shows an ad (G3).
  void retry() {
    _engine.reset();
    _flow.reset();
    _freeUndosLeft = Pricing.freeUndos;
    _freeHintsLeft = Pricing.freeHintsPerLevel;
    _hintArrowId = null;
    _reward = null;
    _events.add(const BoardReset());
    state = _snapshot();
  }

  /// A lost level continues with one more heart (fail sheet, after an ad).
  void grantHeart() {
    if (_engine.status == GameStatus.won) return;
    _engine.addHeart();
    _events.add(const HeartGranted());
    state = _snapshot();
  }

  /// "+1 heart" for [Pricing.heart] coins.
  PurchaseResult buyHeart() {
    if (_engine.status != GameStatus.lost) return PurchaseResult.unavailable;
    if (!ref.read(walletProvider.notifier).trySpend(Pricing.heart)) {
      return PurchaseResult.noCoins;
    }
    grantHeart();
    return PurchaseResult.done;
  }

  /// Called a few times a second while a streak is alive so the meter
  /// empties when the 1.5 s window lapses.
  void tickFlow() {
    if (state.flowMultiplier != _flow.multiplier ||
        state.flowFill != _flow.fill) {
      state = _snapshot();
    }
  }
}
