import 'dart:math' as math;
import 'dart:ui';

import 'package:arrowchime/app/theme/tokens.dart';
import 'package:arrowchime/app/theme/typography.dart';
import 'package:arrowchime/core/level/models/arrow.dart';
import 'package:arrowchime/core/level/models/cell.dart';
import 'package:arrowchime/core/level/models/direction.dart';
import 'package:arrowchime/core/ui/icons/tb_icon.dart';
import 'package:arrowchime/core/ui/icons/tb_icon_id.dart';
import 'package:arrowchime/core/ui/painters/brass_painter.dart';
import 'package:arrowchime/core/ui/painters/crystal_painter.dart';
import 'package:arrowchime/core/ui/painters/enamel_tube_painter.dart';
import 'package:arrowchime/core/ui/painters/shade.dart';
import 'package:arrowchime/features/game/flame/arrow_visuals.dart';
import 'package:arrowchime/features/game/flame/baked_picture.dart';
import 'package:arrowchime/features/game/model/board_geometry.dart';
import 'package:flame/components.dart';
import 'package:flutter/animation.dart' show Curves;
import 'package:flutter/painting.dart'
    show TextDirection, TextPainter, TextSpan;

/// One arrow on the board. Idle arrows paint a cached [Picture] (recorded in
/// world units, so it stays crisp at every zoom); only the few arrows that are
/// moving, shaking or glowing at a given moment paint more.
///
/// It never decides anything: it replays what the engine already did.
class ArrowComponent extends Component {
  new({
    required this.arrow,
    required this.geometry,
    required this.color,
    required this.reduceMotion,
    required this.context,
    this.onExited,
  }) : _dir = arrow.dir,
       _frozen = arrow.frozen ?? 0 {
    _points = [for (final c in arrow.body) geometry.center(c)];
    _bodyPath = EnamelTube.smoothPath(_points, geometry.cell);
    _baked = BakedPicture(
      bounds: _bodyPath.getBounds().inflate(geometry.cell * 0.9),
      paintInto: paintStatic,
    );
  }

  final Arrow arrow;
  final BoardGeometry geometry;
  final Color color;
  final bool reduceMotion;

  /// Shared per-frame facts: what is on screen, the zoom bucket, bake budget.
  final BoardRenderContext context;

  /// Called once when the exit animation has finished.
  final void Function(ArrowComponent)? onExited;

  late final List<Offset> _points;
  late final Path _bodyPath;
  late final BakedPicture _baked;
  Direction _dir;
  int _frozen;

  // Dynamic state.
  _Exit? _exit;
  double _lurchT = -1;
  double _shakeT = -1;
  double _flashT = -1;
  double _hintT = -1;
  bool _hinted = false;

  double get _c => geometry.cell;

  /// Whether the arrow is still on the board (not flying off).
  bool get isLeaving => _exit != null;

  Direction get dir => _dir;

  /// Rotators turn: the head swings round.
  void turnTo(Direction d) {
    if (d == _dir) return;
    _dir = d;
    _baked.invalidate();
  }

  /// A frozen counter changed.
  void setFrozen(int counter) {
    if (counter == _frozen) return;
    _frozen = counter;
    _baked.invalidate();
  }

  /// Highlights this arrow as the hint (until [clearHint] or the next tap).
  void showHint() {
    _hinted = true;
    _hintT = 0;
  }

  void clearHint() => _hinted = false;

  /// Blocked tap: lurch forward then recoil.
  void bump() {
    if (reduceMotion) {
      _flashT = 0;
      return;
    }
    _lurchT = 0;
  }

  /// The arrow was the thing in the way: flash red twice.
  void flashBlocker() => _flashT = 0;

  /// Frozen arrow tapped: a short shake.
  void shake() {
    if (reduceMotion) {
      _flashT = 0;
    } else {
      _shakeT = 0;
    }
  }

  /// Flies off along [paths] (the cells its head passes), then reports
  /// [onExited].
  void exit(List<List<Cell>> paths) {
    _hinted = false;
    if (reduceMotion) {
      _exit = _Exit.fade();
      return;
    }
    _exit = _Exit.fly(this, paths);
  }

  /// World position of the head, for particles.
  Offset get headPoint => _points.last;

  @override
  void update(double dt) {
    final exit = _exit;
    if (exit != null) {
      exit.t += dt;
      if (exit.t >= exit.duration) {
        removeFromParent();
        onExited?.call(this);
      }
      return;
    }
    if (_lurchT >= 0) {
      _lurchT += dt;
      if (_lurchT > TBGameMotion.lurch + TBGameMotion.recoil) _lurchT = -1;
    }
    if (_shakeT >= 0) {
      _shakeT += dt;
      if (_shakeT > TBGameMotion.shake) _shakeT = -1;
    }
    if (_flashT >= 0) {
      _flashT += dt;
      if (_flashT > TBGameMotion.flash) _flashT = -1;
    }
    if (_hinted) _hintT += dt;
  }

  @override
  void render(Canvas canvas) {
    final exit = _exit;
    if (exit != null) {
      exit.paint(canvas, this);
      return;
    }
    final offset = _dynamicOffset();
    if (offset != Offset.zero) {
      canvas
        ..save()
        ..translate(offset.dx, offset.dy);
    }
    if (_baked.bounds.overlaps(context.visible)) {
      _baked.paint(canvas, context);
      _paintGlow(canvas);
    }
    if (offset != Offset.zero) canvas.restore();
  }

  Offset _dynamicOffset() {
    var o = Offset.zero;
    if (_lurchT >= 0) {
      final double travel;
      if (_lurchT < TBGameMotion.lurch) {
        travel =
            Curves.easeOut.transform(_lurchT / TBGameMotion.lurch) *
            TBGameMotion.lurchCells;
      } else {
        final r = (_lurchT - TBGameMotion.lurch) / TBGameMotion.recoil;
        travel =
            (1 - Curves.elasticOut.transform(r.clamp(0.0, 1.0))) *
            TBGameMotion.lurchCells;
      }
      o += Offset(_dir.dx.toDouble(), _dir.dy.toDouble()) * (travel * _c);
    }
    if (_shakeT >= 0) {
      final k = 1 - _shakeT / TBGameMotion.shake;
      o += Offset(math.sin(_shakeT * 70) * 0.1 * _c * k, 0);
    }
    return o;
  }

  void _paintGlow(Canvas canvas) {
    if (_flashT >= 0) {
      // Two pulses over the flash time.
      final pulse = math
          .pow(
            math.sin(_flashT / TBGameMotion.flash * 2 * math.pi * 2).abs(),
            2,
          )
          .toDouble();
      canvas.drawPath(
        _bodyPath,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = _c * 0.5
          ..strokeCap = StrokeCap.round
          ..strokeJoin = StrokeJoin.round
          ..color = TBColors.berry.withValues(alpha: 0.75 * pulse),
      );
    }
    if (_hinted) {
      final wave = reduceMotion
          ? 1.0
          : 0.5 + 0.5 * math.sin(_hintT / TBGameMotion.hintPulse * math.pi * 2);
      canvas.drawPath(
        _bodyPath,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = _c * (0.56 + 0.08 * wave)
          ..strokeCap = StrokeCap.round
          ..strokeJoin = StrokeJoin.round
          ..color = TBColors.sky.withValues(alpha: 0.35 + 0.35 * wave),
      );
    }
  }

  @override
  void onRemove() {
    _baked.dispose();
    super.onRemove();
  }

  // --- the resting look ---------------------------------------------------

  /// The resting look: enamel tube plus the mechanic's marks.
  void paintStatic(Canvas canvas) {
    final tailDir = _points.length > 1
        ? _unit(_points[1] - _points.first)
        : Offset.zero;
    EnamelTube.paintPath(
      canvas,
      _bodyPath,
      tail: _points.first,
      head: _points.last,
      dir: Offset(_dir.dx.toDouble(), _dir.dy.toDouble()),
      c: _c,
      color: color,
    );
    switch (arrow.kind) {
      case ArrowKind.rotator:
        _paintRotatorRing(canvas, _points.last);
      case ArrowKind.key:
        _paintKey(canvas, _points.first, tailDir);
      case ArrowKind.normal:
      case ArrowKind.switcher:
      case ArrowKind.splitter:
        break;
    }
    if (_frozen > 0) _paintFrozen(canvas);
  }

  void _paintRotatorRing(Canvas canvas, Offset at) {
    final r = _c * 0.34;
    canvas
      ..drawCircle(
        at,
        r,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = _c * 0.11
          ..color = TBMaterials.brassDark,
      )
      ..drawCircle(
        at,
        r,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = _c * 0.07
          ..color = TBMaterials.brassFace,
      )
      ..drawCircle(
        at + Offset(-_c * 0.03, -_c * 0.04),
        r,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = _c * 0.025
          ..color = TBShade.white(0.6),
      );
    for (var i = 0; i < 4; i++) {
      final a = i * math.pi / 2 + math.pi / 4;
      final p = at + Offset(math.cos(a), math.sin(a)) * r;
      canvas.drawCircle(p, _c * 0.045, Paint()..color = TBMaterials.brassLight);
    }
  }

  void _paintKey(Canvas canvas, Offset tail, Offset awayFromTail) {
    final size = _c * 0.5;
    final origin = tail - Offset(size / 2, size / 2);
    final badge = Rect.fromCircle(center: tail, radius: size * 0.62);
    Brass.paint(
      canvas,
      RRect.fromRectAndRadius(badge, Radius.circular(size)),
      elevation: const [],
    );
    canvas
      ..save()
      ..translate(origin.dx, origin.dy);
    const TBIconPainter(TBIconId.key).paint(canvas, Size.square(size));
    canvas.restore();
    final sym = arrow.color;
    if (sym != null) {
      canvas.drawPath(
        ArrowVisuals.symbol(sym, tail + awayFromTail * (_c * 0.34), _c * 0.09),
        Paint()..color = TBColors.cream100,
      );
    }
  }

  void _paintFrozen(Canvas canvas) {
    final head = _points.last;
    final block = RRect.fromRectAndRadius(
      Rect.fromCenter(center: head, width: _c * 0.94, height: _c * 0.94),
      Radius.circular(_c * 0.2),
    );
    Crystal.paint(canvas, block);
    final label = TextPainter(
      text: TextSpan(
        text: '$_frozen',
        style: TBTypography.counter.style.copyWith(
          fontSize: _c * 0.46,
          color: TBColors.ink900,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    label.paint(canvas, head - Offset(label.width / 2, label.height / 2));
    label.dispose();
  }

  static Offset _unit(Offset v) {
    final d = v.distance;
    return d == 0 ? Offset.zero : v / d;
  }
}

/// The flying-off animation of one arrow.
class _Exit {
  new _({required this.duration, required this.runs, required this.fade});

  factory fade() =>
      _Exit._(duration: TBGameMotion.reducedFade, runs: const [], fade: true);

  factory fly(ArrowComponent a, List<List<Cell>> paths) {
    final c = a.geometry.cell;
    final dirVec = Offset(a._dir.dx.toDouble(), a._dir.dy.toDouble());
    final bodyLen = (a._points.length - 1) * c;
    final runs = <_Run>[];
    var cells = 0;
    for (var i = 0; i < math.max(paths.length, 1); i++) {
      final seg = i < paths.length ? paths[i] : const <Cell>[];
      cells += seg.length;
      final last = i >= paths.length - 1;
      final pts = <Offset>[
        if (i == 0) ...a._points else a.geometry.center(seg.first),
        for (final cell in i == 0 ? seg : seg.skip(1)) a.geometry.center(cell),
      ];
      final end = pts.last;
      // Run beyond the board (final segment) or into the portal (earlier).
      pts.add(end + dirVec * (c * (last ? (a._points.length + 1.2) : 0.6)));
      final path = EnamelTube.smoothPath(pts, c);
      final metric = path.computeMetrics().first;
      runs.add(
        _Run(metric: metric, bodyLen: bodyLen, emerge: i > 0, fadeAtEnd: !last),
      );
    }
    final seconds = (TBGameMotion.exitMin + TBGameMotion.exitPerCell * cells)
        .clamp(TBGameMotion.exitMin, TBGameMotion.exitMax);
    return _Exit._(duration: seconds, runs: runs, fade: false);
  }

  final double duration;
  final List<_Run> runs;
  final bool fade;
  double t = 0;

  void paint(Canvas canvas, ArrowComponent a) {
    final p = (t / duration).clamp(0.0, 1.0);
    if (fade) {
      canvas.saveLayer(null, Paint()..color = TBShade.white(1 - p));
      a._baked.paint(canvas, a.context);
      canvas.restore();
      return;
    }
    // Ease-in over the whole trip, split evenly between the runs.
    final eased = Curves.easeIn.transform(p) * runs.length;
    final index = math.min(eased.floor(), runs.length - 1);
    final local = (eased - index).clamp(0.0, 1.0);
    runs[index].paint(canvas, a, local);
  }
}

class _Run {
  new({
    required this.metric,
    required this.bodyLen,
    required this.emerge,
    required this.fadeAtEnd,
  });

  final PathMetric metric;
  final double bodyLen;
  final bool emerge;
  final bool fadeAtEnd;

  void paint(Canvas canvas, ArrowComponent a, double u) {
    final total = metric.length;
    final double from;
    final double to;
    if (emerge) {
      // Comes out of the portal head first.
      to = u * total;
      from = math.max(0, to - bodyLen);
    } else {
      from = u * (total - bodyLen);
      to = from + bodyLen;
    }
    if (to - from < 1) return;
    final body = metric.extractPath(from, to);
    final tail = metric.getTangentForOffset(from)!;
    final head = metric.getTangentForOffset(to)!;
    if (fadeAtEnd) {
      canvas.saveLayer(null, Paint()..color = TBShade.white(1 - u * u));
    }
    EnamelTube.paintPath(
      canvas,
      body,
      tail: tail.position,
      head: head.position,
      dir: head.vector,
      c: a.geometry.cell,
      color: a.color,
      blurShadow: false,
    );
    if (fadeAtEnd) canvas.restore();
  }
}
