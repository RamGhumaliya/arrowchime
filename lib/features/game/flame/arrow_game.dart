import 'dart:ui';

import 'package:arrowchime/app/theme/chapter_theme.dart';
import 'package:arrowchime/app/theme/tokens.dart';
import 'package:arrowchime/app/theme/typography.dart';
import 'package:arrowchime/core/level/engine/events.dart';
import 'package:arrowchime/core/level/engine/game_engine.dart';
import 'package:arrowchime/core/level/models/arrow.dart';
import 'package:arrowchime/core/level/models/direction.dart';
import 'package:arrowchime/core/ui/painters/arrow_skin.dart';
import 'package:arrowchime/core/ui/painters/shade.dart';
import 'package:arrowchime/features/game/flame/arrow_component.dart';
import 'package:arrowchime/features/game/flame/arrow_visuals.dart';
import 'package:arrowchime/features/game/flame/baked_picture.dart';
import 'package:arrowchime/features/game/flame/board_component.dart';
import 'package:arrowchime/features/game/flame/particle_pool.dart';
import 'package:arrowchime/features/game/flame/trail_style.dart';
import 'package:arrowchime/features/game/input/tap_resolver.dart';
import 'package:arrowchime/features/game/model/board_geometry.dart';
import 'package:arrowchime/features/game/model/view_transform.dart';
import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flutter/animation.dart' show Curves;
import 'package:flutter/foundation.dart' show ValueNotifier;

/// The board: renders the level and **replays** engine events as animations.
/// It reads the engine for queries (directions, exit paths) but never changes
/// it; all rules live in `lib/core/level`.
class ArrowGame extends FlameGame {
  new({
    required this.engine,
    required this.theme,
    required this.reduceMotion,
    this.showFps = false,
    this.pixelRatio = 1,
    this.colorBlind = 'off',
    this.skin = ArrowSkin.candy,
    this.trail = TrailStyle.none,
    this.onWon,
    this.onLost,
  }) : geometry = BoardGeometry(engine.level) {
    view = ViewTransform(
      worldSize: geometry.worldSize,
      viewport: const Size(1, 1),
    );
    resolver = TapResolver(geometry);
  }

  /// Read-only use: queries for the animation (`dirOf`, `exitPaths`, ...).
  final GameEngine engine;
  final ChapterTheme theme;
  final bool reduceMotion;

  /// Debug / profile builds: draw the frame rate (`--dart-define=SHOW_FPS=true`).
  final bool showFps;

  /// Device pixels per logical pixel (sizes the baked images).
  final double pixelRatio;

  /// Palette mode: `off`, `deutan` or `tritan`.
  final String colorBlind;

  /// Equipped cosmetics: arrow skin and the particle trail.
  final ArrowSkin skin;
  final TrailStyle trail;

  /// The last arrow has left and the pause is over: show the win sheet.
  final void Function()? onWon;

  /// The blocked-tap animation is over: show the fail sheet.
  final void Function()? onLost;

  final BoardGeometry geometry;
  late final ViewTransform view;
  late final TapResolver resolver;
  late final BoardComponent board;
  late final ParticlePool particles;
  final Map<int, ArrowComponent> arrows = {};

  /// Shared with every board component.
  final BoardRenderContext boardContext = BoardRenderContext();

  /// Whether the camera shows the whole board (the Fit button disables).
  final ValueNotifier<bool> atFit = ValueNotifier<bool>(true);

  bool _gridVisible = false;
  bool _ready = false;

  /// Images that may be baked in one frame.
  static const int _bakesPerFrame = 8;

  /// Seconds without camera movement before images are re-baked.
  static const double _settleTime = 0.2;

  double _quiet = 1;
  double _desaturate = 0;
  double _resultTimer = -1;
  bool _won = false;
  _ViewTween? _tween;

  /// The chapter scene shows through; Flame's default would be opaque black.
  @override
  Color backgroundColor() => TBShade.white(0);

  @override
  Future<void> onLoad() async {
    board = BoardComponent(
      level: engine.level,
      geometry: geometry,
      theme: theme,
      reduceMotion: reduceMotion,
      isAlive: arrows.containsKey,
      context: boardContext,
    );
    particles = ParticlePool()..priority = 100;
    await world.addAll([board, particles]);
    if (showFps) {
      await add(
        FpsTextComponent(
          position: Vector2.all(8),
          textRenderer: TextPaint(style: TBTypography.caption.style),
        ),
      );
    }
    _spawnArrows();
    board.gridVisible = _gridVisible;
    _ready = true;
    _syncCamera();
  }

  // --- building -----------------------------------------------------------

  void _spawnArrows() {
    final arrows = engine.level.arrows;
    // Arrows pop in one after the other, the whole entrance within ~0.5 s.
    final step = arrows.length > 1 ? 0.5 / arrows.length : 0.0;
    for (var i = 0; i < arrows.length; i++) {
      _spawn(arrows[i], introDelay: reduceMotion ? -1 : i * step);
    }
  }

  void _spawn(Arrow arrow, {double introDelay = -1}) {
    final comp = ArrowComponent(
      arrow: arrow,
      geometry: geometry,
      color: ArrowVisuals.arrowColor(arrow, theme, colorBlind: colorBlind),
      skin: skin,
      accent: theme.accent,
      introDelay: introDelay,
      reduceMotion: reduceMotion,
      context: boardContext,
      onExited: (c) => _leaving.remove(c.arrow.id),
    );
    arrows[arrow.id] = comp;
    for (var i = 0; i < arrow.body.length; i++) {
      resolver.occupied[arrow.body[i]] = CellArrow(
        arrow.id,
        isHead: i == arrow.body.length - 1,
      );
    }
    world.add(comp); // ignore: discarded_futures, mounts synchronously
  }

  /// Starts over: every arrow back, gates closed, no leftovers.
  void resetBoard() {
    for (final c in arrows.values) {
      c.removeFromParent();
    }
    arrows.clear();
    resolver.occupied.clear();
    board.resetGates();
    particles.clear();
    _desaturate = 0;
    _resultTimer = -1;
    _won = false;
    _spawnArrows();
  }

  // --- replaying events ---------------------------------------------------

  /// Animates what the engine just did.
  void playEvents(List<GameEvent> events) {
    _idle = 0;
    for (final c in arrows.values) {
      c.clearHint();
    }
    for (final e in events) {
      switch (e) {
        case ArrowFreed():
          _free(e);
        case BlockedTap():
          _blocked(e);
        case FrozenTapped():
          arrows[e.arrowId]
            ?..shake()
            ..setFrozen(e.counter);
        case FrozenTicked():
          _frozenTicked(e.counters);
        case RotatorsTurned():
          _turn(e.dirs);
        case ArrowsFlipped():
          _turn(e.dirs);
        case GateOpened():
          _gateOpened(e);
        case UndoApplied():
          _undone(e.restoredArrowIds);
        case LevelWon():
          _won = true;
          _resultTimer = 0;
        case LevelLost():
          _won = false;
          _resultTimer = 0;
        case HeartLost():
          break;
      }
    }
  }

  void _free(ArrowFreed e) {
    final comp = arrows.remove(e.arrowId);
    if (comp == null) return;
    resolver.occupied.removeWhere((_, v) => v.arrowId == e.arrowId);
    comp.exit(e.paths);
    final head = comp.headPoint;
    final tint = ArrowVisuals.arrowColor(
      comp.arrow,
      theme,
      colorBlind: colorBlind,
    );
    particles.burst(
      head.dx,
      head.dy,
      trail.color(tint, 0),
      count: reduceMotion ? 0 : trail.burst,
      speed: geometry.cell * 2,
      size: geometry.cell * 0.07,
      shape: trail.shape,
      fall: trail.fall,
    );
    // It stays in the tree until its flight is over, but is no longer
    // addressable; `_leaving` lets the win sheet wait for it.
    _leaving[e.arrowId] = comp;
  }

  final Map<int, ArrowComponent> _leaving = {};
  double _trailClock = 0;
  int _trailCount = 0;

  /// A trail cosmetic drops a particle behind every arrow in flight.
  void _emitTrails(double dt) {
    if (trail.perEmit == 0 || reduceMotion) return;
    _trailClock += dt;
    if (_trailClock < _trailEvery) return;
    _trailClock = 0;
    for (final comp in _leaving.values) {
      final at = comp.flightHead;
      if (at == null) continue;
      final tint = ArrowVisuals.arrowColor(
        comp.arrow,
        theme,
        colorBlind: colorBlind,
      );
      particles.burst(
        at.dx,
        at.dy,
        trail.color(tint, _trailCount++),
        count: trail.perEmit,
        speed: geometry.cell * 0.6,
        size: geometry.cell * 0.07,
        life: 0.7,
        shape: trail.shape,
        fall: trail.fall,
      );
    }
  }

  /// Seconds between trail particles.
  static const double _trailEvery = 0.03;

  void _blocked(BlockedTap e) {
    arrows[e.arrowId]?.bump();
    if (e.blockedArrowId != e.arrowId) arrows[e.blockedArrowId]?.bump();
    final blocker = e.blockerArrowId;
    if (blocker != null) arrows[blocker]?.flashBlocker();
    final cell = e.blockerCell;
    if (cell != null && !reduceMotion) {
      final p = geometry.center(cell);
      particles.burst(
        p.dx,
        p.dy,
        TBColors.berry,
        count: 6,
        speed: geometry.cell * 1.5,
        size: geometry.cell * 0.06,
        life: 0.35,
      );
    }
  }

  void _frozenTicked(Map<int, int> counters) {
    counters.forEach((id, counter) {
      final comp = arrows[id];
      if (comp == null) return;
      final thawed = counter <= 0;
      comp.setFrozen(counter);
      if (thawed && !reduceMotion) {
        final p = comp.headPoint;
        particles.burst(
          p.dx,
          p.dy,
          TBColors.sky,
          speed: geometry.cell * 2,
          size: geometry.cell * 0.06,
        );
      }
    });
  }

  void _turn(Map<int, Direction> dirs) {
    dirs.forEach((id, dir) => arrows[id]?.turnTo(dir));
  }

  void _gateOpened(GateOpened e) {
    board.openGates(e.color);
    if (reduceMotion) return;
    for (final cell in e.cells) {
      final p = geometry.center(cell);
      particles.burst(
        p.dx,
        p.dy,
        ArrowVisuals.gateColor(e.color),
        speed: geometry.cell * 2,
        size: geometry.cell * 0.07,
      );
    }
  }

  void _undone(List<int> restored) {
    for (final id in restored) {
      final arrow = engine.level.arrows.firstWhere((a) => a.id == id);
      _leaving.remove(id)?.removeFromParent();
      _spawn(arrow);
    }
    // Undo also winds back rotations, thaws and gates.
    for (final entry in arrows.entries) {
      final dir = engine.dirOf(entry.key);
      if (dir != null) entry.value.turnTo(dir);
      entry.value.setFrozen(engine.frozenCounter(entry.key));
    }
    board.resetGates();
    for (final color in GateColor.values) {
      final keyLeft = engine.level.arrows.any(
        (a) =>
            a.kind == ArrowKind.key &&
            a.color == color &&
            arrows.containsKey(a.id),
      );
      if (!keyLeft && engine.level.gates.any((g) => g.color == color)) {
        board.openGates(color);
      }
    }
  }

  /// A lost level goes on after an extra heart: colour comes back.
  void resumeAfterLoss() {
    _desaturate = 0;
    _resultTimer = -1;
  }

  /// A finger is down on [arrowId] (null: lifted).
  void pressArrow(int? arrowId) {
    for (final entry in arrows.entries) {
      entry.value.press(down: entry.key == arrowId);
    }
  }

  /// Flow multiplier: the felt edge glows warmer from ×2.
  // ignore: use_setters_to_change_properties, called as a method from events
  void setFlow(int multiplier) => board.flowTier = multiplier;

  /// Last three arrows: ease in by 3%.
  void nudgeZoom() {
    if (view.multiplier > 1.01) return;
    _animateTo(TBFeedback.lastThreeZoom, view.center);
  }

  /// Hint: pulse arrow [arrowId] until the next tap.
  void showHint(int arrowId) => arrows[arrowId]?.showHint();

  /// Fail: the board loses its colour. Win: confetti.
  void celebrate() {
    if (reduceMotion) return;
    particles.confetti(geometry.worldSize.width, -geometry.cell, [
      ...theme.arrowColors,
      TBColors.butter,
    ]);
  }

  // --- input helpers (screen space) ----------------------------------------

  /// The arrow under a screen point, with tap assist.
  int? arrowAt(Offset screen) {
    final world = view.toWorld(screen);
    return resolver.resolve(world, screenCell: view.zoom * geometry.cell);
  }

  /// Shows the exit path of the arrow under [screen] (long press).
  void peekAt(Offset screen) {
    final id = arrowAt(screen);
    if (id == null) return;
    final paths = engine.exitPaths(id);
    board.showPeek([for (final p in paths) ...p], free: engine.isFree(id));
  }

  void endPeek() => board.hidePeek();

  void zoomBy(Offset focal, double factor) {
    _touched();
    _tween = null;
    view.zoomAbout(focal, view.multiplier * factor);
    _syncCamera();
  }

  void panBy(Offset delta) {
    _touched();
    _tween = null;
    view.panByScreen(delta);
    _syncCamera();
  }

  /// Back to the whole board (double tap, Fit button).
  void fitBoard() => _animateTo(1, view.boardCenter);

  /// Double tap: fit if zoomed, else zoom in on [focal].
  void toggleZoom(Offset focal) {
    if (view.multiplier > 1.05) {
      fitBoard();
    } else {
      final world = view.toWorld(focal);
      _animateTo(2.5, world);
    }
  }

  /// The camera is moving: hold off re-baking images until it settles.
  void _touched() {
    _quiet = 0;
    boardContext.interacting = true;
  }

  void _animateTo(double multiplier, Offset center) {
    _touched();
    if (reduceMotion) {
      view
        ..multiplier = multiplier
        ..center = center
        ..clamp();
      _syncCamera();
      return;
    }
    _tween = _ViewTween(
      fromMultiplier: view.multiplier,
      toMultiplier: multiplier,
      fromCenter: view.center,
      toCenter: center,
    );
  }

  void setGridVisible({required bool visible}) {
    _gridVisible = visible;
    if (_ready) board.gridVisible = visible;
  }

  void _syncCamera() {
    final zoom = view.zoom;
    boardContext
      ..pxPerUnit = zoom * pixelRatio
      ..visible = Rect.fromCenter(
        center: view.center,
        width: view.viewport.width / zoom,
        height: view.viewport.height / zoom,
      ).inflate(geometry.cell);
    camera.viewfinder
      ..zoom = view.zoom
      ..position = Vector2(view.center.dx, view.center.dy);
    atFit.value = view.multiplier <= 1.001;
  }

  // --- loop ----------------------------------------------------------------

  @override
  void onGameResize(Vector2 size) {
    super.onGameResize(size);
    view.resize(Size(size.x, size.y));
    _syncCamera();
  }

  @override
  void update(double dt) {
    boardContext.bakesLeft = _bakesPerFrame;
    _emitTrails(dt);
    if (boardContext.interacting) {
      _quiet += dt;
      if (_quiet >= _settleTime && _tween == null) {
        boardContext.interacting = false;
      }
    }
    super.update(dt);
    final tween = _tween;
    if (tween != null) {
      tween.t += dt / 0.25;
      final k = Curves.easeOutCubic.transform(tween.t.clamp(0.0, 1.0));
      view
        ..multiplier =
            tween.fromMultiplier +
            (tween.toMultiplier - tween.fromMultiplier) * k
        ..center = Offset.lerp(tween.fromCenter, tween.toCenter, k)!
        ..clamp();
      _syncCamera();
      if (tween.t >= 1) _tween = null;
    }
    _idleNudge(dt);
    if (_resultTimer >= 0) {
      _resultTimer += dt;
      if (_won) {
        if (_leaving.isEmpty && _resultTimer >= TBGameMotion.winDelay) {
          _resultTimer = -1;
          celebrate();
          onWon?.call();
        }
      } else {
        _desaturate = (_resultTimer / 0.4).clamp(0.0, 1.0);
        if (_resultTimer >= 0.6) {
          _resultTimer = -1;
          onLost?.call();
        }
      }
    }
  }

  /// Seconds without a tap before a free arrow bounces ("tap me"), then again
  /// every [_idleRepeat].
  static const double _idleFirst = 6;
  static const double _idleRepeat = 3;
  double _idle = 0;

  void _idleNudge(double dt) {
    if (reduceMotion || _resultTimer >= 0 || _won) return;
    _idle += dt;
    if (_idle < _idleFirst) return;
    _idle = _idleFirst - _idleRepeat;
    for (final id in engine.freeArrowIds) {
      final comp = arrows[id];
      if (comp != null && !comp.isLeaving) {
        comp.nudge();
        return;
      }
    }
  }

  @override
  void render(Canvas canvas) {
    if (_desaturate <= 0) {
      super.render(canvas);
      return;
    }
    final s = 1 - _desaturate * 0.85;
    canvas.saveLayer(
      null,
      Paint()..colorFilter = ColorFilter.matrix(_saturation(s)),
    );
    super.render(canvas);
    canvas.restore();
  }

  static List<double> _saturation(double s) {
    const r = 0.2126;
    const g = 0.7152;
    const b = 0.0722;
    final i = 1 - s;
    return [
      r * i + s, g * i, b * i, 0, 0, //
      r * i, g * i + s, b * i, 0, 0, //
      r * i, g * i, b * i + s, 0, 0, //
      0, 0, 0, 1, 0,
    ];
  }

  @override
  void onRemove() {
    atFit.dispose();
    super.onRemove();
  }
}

class _ViewTween {
  new({
    required this.fromMultiplier,
    required this.toMultiplier,
    required this.fromCenter,
    required this.toCenter,
  });

  final double fromMultiplier;
  final double toMultiplier;
  final Offset fromCenter;
  final Offset toCenter;
  double t = 0;
}
