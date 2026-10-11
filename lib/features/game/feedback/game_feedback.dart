import 'dart:async';

import 'package:arrowchime/app/theme/tokens.dart';
import 'package:arrowchime/core/audio/audio_service.dart';
import 'package:arrowchime/core/audio/melody_player.dart';
import 'package:arrowchime/core/audio/sfx.dart';
import 'package:arrowchime/core/haptics/haptics_service.dart';
import 'package:arrowchime/core/level/engine/events.dart';

/// Turns what the engine did into sound and touch: the audio and haptic
/// columns of the juice table (`docs/03` §4) and the Arrow Symphony
/// (`docs/07` §1). The look of the same events is `ArrowGame`'s job.
class GameFeedback {
  new({
    required this.audio,
    required this.haptics,
    required this.chapter,
    required this.levelIndex,
    required this.arrowLength,
    this.isBoss = false,
    this.instrument,
    this.onLastThree,
  }) : melody = MelodyPlayer.forLevel(chapter, levelIndex);

  final AudioService audio;
  final HapticsService haptics;
  final int chapter;
  final int levelIndex;

  /// Number of cells of an arrow (long arrows ring heavier).
  final int Function(int arrowId) arrowLength;
  final bool isBoss;

  /// The equipped cosmetic instrument (`null` / `auto`: the chapter's own).
  final String? instrument;

  /// The last three arrows: the screen nudges the zoom in by 3%.
  final void Function()? onLastThree;

  final MelodyPlayer melody;

  /// Whoosh pitch variation, cycled (±5%) so repeated taps do not machine-gun.
  static const List<double> _whooshPitch = [0.95, 1, 1.05, 0.97, 1.03];

  int _flow = 1;
  int _whooshAt = 0;
  bool _lastThreeDone = false;
  Timer? _brightTimer;
  final List<Timer> _timers = [];

  /// Preloads the chapter's sounds and starts its music.
  Future<void> start() async {
    await audio.enterChapter(chapter, instrument: instrument);
    if (isBoss) await audio.preloadSting(chapter);
  }

  /// A finger lands on an arrow.
  void touchDown() {
    haptics.selection();
    audio.sfx(Sfx.arrowTouch, volume: 0.6);
  }

  /// Plays what [events] sound like. [flow] is the Flow multiplier after the
  /// tap and [remaining] the arrows left.
  void played(
    List<GameEvent> events, {
    required int flow,
    required int remaining,
  }) {
    var notePlayed = false;
    for (final e in events) {
      switch (e) {
        case ArrowFreed():
          if (!notePlayed && !e.viaLink) {
            notePlayed = true;
            _note(e.arrowId, flow);
          }
          if (e.paths.length > 1) audio.sfx(Sfx.portalPass, volume: 0.8);
        case BlockedTap():
          audio.sfx(Sfx.arrowBlocked);
          haptics.medium();
          _later(TBFeedback.doublePulse, haptics.medium);
        case HeartLost():
          audio.sfx(Sfx.heartLost, delay: TBFeedback.layerDelay);
        case FrozenTapped():
          audio.sfx(Sfx.iceTick, volume: 0.8);
        case FrozenTicked():
          final thawed = e.counters.values.any((c) => c <= 0);
          audio.sfx(
            thawed ? Sfx.iceBreak : Sfx.iceTick,
            volume: thawed ? 1 : 0.5,
          );
        case RotatorsTurned():
        case ArrowsFlipped():
          audio.sfx(Sfx.rotatorTurn, volume: 0.8);
        case GateOpened():
          audio
            ..sfx(Sfx.gateOpen)
            ..sfx(Sfx.keyCollect, delay: TBFeedback.keyDelay);
        case UndoApplied():
          for (var i = 0; i < e.restoredArrowIds.length; i++) {
            melody.rewind();
          }
          audio.sfx(Sfx.uiBack);
        case LevelWon():
          _win();
        case LevelLost():
          _lose();
      }
    }
    _flowChanged(flow);
    if (!_lastThreeDone && remaining <= 3 && remaining > 0) {
      _lastThreeDone = true;
      audio
        ..duck(on: true)
        ..sfx(Sfx.fragmentRestore, volume: 0.6);
      onLastThree?.call();
    }
  }

  void _note(int arrowId, int flow) {
    final cue = melody.next(flow: flow, arrowLength: arrowLength(arrowId));
    final sound = melody.sound;
    audio
      ..note(
        sound,
        cue.index,
        volume: cue.heavy ? 1 : 0.85,
        instrument: instrument,
      )
      ..sfx(
        Sfx.arrowWhoosh,
        volume: 0.5,
        speed: _whooshPitch[_whooshAt++ % _whooshPitch.length],
      );
    for (final h in cue.harmony) {
      audio.note(sound, h, volume: 0.4, instrument: instrument);
    }
    if (flow >= 3) {
      // The shaker tick layer of Flow ×3.
      audio.sfx(Sfx.arrowTouch, volume: 0.35, delay: TBFeedback.layerDelay);
    }
    if (cue.sparkle) audio.sfx(Sfx.fragmentRestore, volume: 0.25);
    haptics.light();
  }

  void _flowChanged(int flow) {
    if (flow > _flow && flow >= 2) {
      audio.sfx(Sfx.flowUp, speed: 1 + 0.12 * (flow - 2));
      if (flow >= 5) {
        audio.brighten(open: true);
        _brightTimer?.cancel();
        _brightTimer = Timer(
          TBFeedback.brightFor,
          () => audio.brighten(open: false),
        );
      }
    }
    _flow = flow;
  }

  void _win() {
    haptics.success();
    var delay = Duration.zero;
    for (final i in melody.cascade()) {
      audio.note(melody.sound, i, delay: delay, instrument: instrument);
      delay += TBFeedback.cascadeStep;
    }
    delay += TBFeedback.flourishGap;
    audio.duck(on: true);
    for (final i in melody.flourish()) {
      audio.note(melody.sound, i, delay: delay, instrument: instrument);
      delay += TBFeedback.flourishStep;
    }
    audio.sfx(Sfx.boardClear, delay: delay);
    _later(delay + TBFeedback.duckRestore, () => audio.duck(on: false));
    if (isBoss) _later(delay, () => audio.bossSting(chapter));
  }

  void _lose() {
    audio.sfx(Sfx.levelFail);
    haptics.heavy();
  }

  /// The win sheet is up: ding each star 180 ms apart.
  void starsAwarded(int stars) {
    for (var n = 1; n <= stars; n++) {
      final delay = TBFeedback.starStep * (n - 1);
      audio.sfx(Sfx.star(n), delay: delay);
      _later(delay, haptics.light);
    }
  }

  /// The [i]th coin of the reward count-up: a clink, higher each time.
  void coinTick(int i) => audio.sfx(Sfx.coin, speed: 1 + 0.06 * i, volume: 0.7);

  /// Retry / Replay: the tune starts from the top again.
  void reset() {
    melody.reset();
    _flow = 1;
    _lastThreeDone = false;
    _brightTimer?.cancel();
    audio
      ..duck(on: false)
      ..brighten(open: false);
  }

  void _later(Duration after, void Function() call) {
    if (after <= Duration.zero) {
      call();
      return;
    }
    late final Timer timer;
    timer = Timer(after, () {
      _timers.remove(timer);
      call();
    });
    _timers.add(timer);
  }

  /// Leaving the level: stop the music and free the chapter's notes.
  Future<void> dispose() async {
    _brightTimer?.cancel();
    for (final t in _timers) {
      t.cancel();
    }
    _timers.clear();
    audio.duck(on: false);
    await audio.leaveChapter();
  }
}
