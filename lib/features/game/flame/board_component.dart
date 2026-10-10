import 'dart:math' as math;
import 'dart:ui';

import 'package:arrowchime/app/theme/chapter_theme.dart';
import 'package:arrowchime/app/theme/tokens.dart';
import 'package:arrowchime/core/level/models/arrow.dart';
import 'package:arrowchime/core/level/models/cell.dart';
import 'package:arrowchime/core/level/models/level.dart';
import 'package:arrowchime/core/ui/painters/brass_painter.dart';
import 'package:arrowchime/core/ui/painters/shade.dart';
import 'package:arrowchime/core/ui/painters/wood_painter.dart';
import 'package:arrowchime/features/game/flame/arrow_visuals.dart';
import 'package:arrowchime/features/game/flame/baked_picture.dart';
import 'package:arrowchime/features/game/model/board_geometry.dart';
import 'package:flame/components.dart';

/// The static scenery of a board: the felt tray with its wooden rim, blocked
/// (masked) cells, optional stitched grid lines, gates, portals, the chains of
/// linked arrows and the long-press path preview. Arrows are separate
/// components on top.
class BoardComponent extends Component {
  new({
    required this.level,
    required this.geometry,
    required this.theme,
    required this.reduceMotion,
    required this.isAlive,
    required this.context,
  });

  final Level level;
  final BoardGeometry geometry;
  final ChapterTheme theme;
  final bool reduceMotion;

  /// Shared per-frame facts (visible area, zoom bucket, bake budget).
  final BoardRenderContext context;

  /// Whether an arrow is still on the board (chains vanish with their arrow).
  final bool Function(int arrowId) isAlive;

  late final BakedPicture _tray = BakedPicture(
    bounds: geometry.trayRect.inflate(_c * 1.2),
    paintInto: _paintTray,
    maxDimension: 3072,
  );
  late final BakedPicture _grid = BakedPicture(
    bounds: geometry.gridRect,
    paintInto: _paintGrid,
    maxDimension: 3072,
  );
  bool gridVisible = false;

  /// Flow multiplier 1-5: from ×2 the felt's edge glows warmer.
  int flowTier = 1;
  double _time = 0;

  final Set<GateColor> _openGates = {};
  final Map<GateColor, double> _opening = {};
  List<(int, int)>? _links;

  // Peek preview.
  List<Cell> _peek = const [];
  bool _peekFree = true;
  double _peekAlpha = 0;
  bool _peeking = false;

  double get _c => geometry.cell;

  /// Opens every gate of [color] with a short animation.
  void openGates(GateColor color) {
    if (_openGates.add(color)) _opening[color] = 0;
  }

  /// Closes all gates (new attempt).
  void resetGates() {
    _openGates.clear();
    _opening.clear();
  }

  /// Shows the exit path of an arrow while the finger is held down.
  void showPeek(List<Cell> path, {required bool free}) {
    _peek = path;
    _peekFree = free;
    _peeking = true;
  }

  void hidePeek() => _peeking = false;

  @override
  void update(double dt) {
    _time += dt;
    for (final k in _opening.keys.toList()) {
      final t = _opening[k]! + dt;
      if (t >= TBGameMotion.reducedFade * 2) {
        _opening.remove(k);
      } else {
        _opening[k] = t;
      }
    }
    final target = _peeking ? 1.0 : 0.0;
    final step = dt / TBGameMotion.peekFade;
    if (_peekAlpha < target) {
      _peekAlpha = math.min(target, _peekAlpha + step);
    } else if (_peekAlpha > target) {
      _peekAlpha = math.max(target, _peekAlpha - step);
    }
  }

  @override
  void onRemove() {
    _tray.dispose();
    _grid.dispose();
    super.onRemove();
  }

  @override
  void render(Canvas canvas) {
    _tray.paint(canvas, context);
    _paintFlowGlow(canvas);
    if (gridVisible) _grid.paint(canvas, context);
    _paintLinks(canvas);
    _paintPortals(canvas);
    _paintGates(canvas);
    _paintPeek(canvas);
  }

  void _paintTray(Canvas canvas) {
    Felt.paintTray(
      canvas,
      geometry.worldSize,
      felt: theme.trayFelt,
      radius: _c * 0.5,
    );
    // Masked-out cells are wooden blocks standing in the tray.
    final mask = level.mask;
    if (mask != null) {
      for (var y = 0; y < level.height; y++) {
        for (var x = 0; x < level.width; x++) {
          if (mask[y][x] == '1') continue;
          final tl = geometry.topLeft(Cell(x, y));
          canvas
            ..save()
            ..translate(tl.dx, tl.dy);
          Wood.paint(
            canvas,
            Size.square(_c),
            radius: _c * 0.18,
            elevation: TBElevation.e1,
            grainSeed: x * 7 + y,
          );
          canvas.restore();
        }
      }
    }
  }

  void _paintGrid(Canvas canvas) {
    final paint = Paint()
      ..color = TBShade.white(theme.darkTray ? 0.12 : 0.10)
      ..strokeWidth = _c * 0.035
      ..strokeCap = StrokeCap.round;
    final g = geometry.gridRect;
    final dash = _c * 0.12;
    void line(Offset a, Offset b) {
      final total = (b - a).distance;
      final dir = (b - a) / total;
      for (var d = 0.0; d < total; d += dash * 2) {
        canvas.drawLine(
          a + dir * d,
          a + dir * math.min(d + dash, total),
          paint,
        );
      }
    }

    for (var x = 0; x <= level.width; x++) {
      line(Offset(g.left + x * _c, g.top), Offset(g.left + x * _c, g.bottom));
    }
    for (var y = 0; y <= level.height; y++) {
      line(Offset(g.left, g.top + y * _c), Offset(g.right, g.top + y * _c));
    }
  }

  void _paintFlowGlow(Canvas canvas) {
    if (flowTier < 2) return;
    final rim = RRect.fromRectAndRadius(
      geometry.trayRect.deflate(TBBevel.woodRim + _c * 0.1),
      Radius.circular(_c * 0.4),
    );
    canvas.drawRRect(
      rim,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = _c * 0.28
        ..color = TBColors.tangerine.withValues(alpha: 0.10 * (flowTier - 1)),
    );
  }

  void _paintLinks(Canvas canvas) {
    final links = _links ??= _computeLinks();
    final paint = Paint()..color = TBMaterials.brassFace;
    final shine = Paint()..color = TBMaterials.brassLight;
    for (final (a, b) in links) {
      if (!isAlive(a) || !isAlive(b)) continue;
      final pa = _mid(a);
      final pb = _mid(b);
      final dist = (pb - pa).distance;
      // Long chains get sparser dots so they stay a quiet detail.
      final step = dist > _c * 6 ? 0.6 : 0.22;
      final n = math.max(2, (dist / (_c * step)).floor());
      for (var i = 1; i < n; i++) {
        final p = Offset.lerp(pa, pb, i / n)!;
        canvas
          ..drawCircle(p, _c * 0.07, paint)
          ..drawCircle(p + Offset(-_c * 0.02, -_c * 0.02), _c * 0.03, shine);
      }
    }
  }

  List<(int, int)> _computeLinks() {
    final byLink = <String, List<int>>{};
    for (final a in level.arrows) {
      final l = a.link;
      if (l != null) byLink.putIfAbsent(l, () => []).add(a.id);
    }
    return [
      for (final ids in byLink.values)
        if (ids.length == 2) (ids[0], ids[1]),
    ];
  }

  Offset _mid(int arrowId) {
    final arrow = level.arrows.firstWhere((a) => a.id == arrowId);
    return geometry.center(arrow.body[arrow.body.length ~/ 2]);
  }

  void _paintPortals(Canvas canvas) {
    for (final portal in level.portals) {
      for (final cell in [portal.a, portal.b]) {
        final at = geometry.center(cell);
        final r = _c * 0.4;
        canvas
          ..drawCircle(at, r, Paint()..color = TBShade.ink(0.35))
          ..drawCircle(at, r * 0.78, Paint()..color = TBColors.ink700);
        final swirl = Paint()
          ..style = PaintingStyle.stroke
          ..strokeCap = StrokeCap.round
          ..strokeWidth = _c * 0.07
          ..color = TBColors.teal;
        final turn = reduceMotion ? 0.0 : _time * 2.4;
        for (var i = 0; i < 3; i++) {
          canvas.drawArc(
            Rect.fromCircle(center: at, radius: r * (0.3 + 0.16 * i)),
            turn + i * 1.7,
            math.pi * 1.1,
            false,
            swirl,
          );
        }
        canvas
          ..drawCircle(
            at,
            r,
            Paint()
              ..style = PaintingStyle.stroke
              ..strokeWidth = _c * 0.1
              ..color = TBColors.cream300,
          )
          ..drawCircle(
            at + Offset(-_c * 0.03, -_c * 0.03),
            r,
            Paint()
              ..style = PaintingStyle.stroke
              ..strokeWidth = _c * 0.03
              ..color = TBShade.white(0.7),
          );
      }
    }
  }

  void _paintGates(Canvas canvas) {
    for (final gate in level.gates) {
      var alpha = 1.0;
      final opening = _opening[gate.color];
      if (_openGates.contains(gate.color)) {
        if (opening == null) continue;
        alpha = 1 - opening / (TBGameMotion.reducedFade * 2);
      }
      final tl = geometry.topLeft(gate.cell);
      final rect = Rect.fromLTWH(tl.dx, tl.dy, _c, _c).deflate(_c * 0.06);
      final color = ArrowVisuals.gateColor(gate.color);
      canvas
        ..saveLayer(null, Paint()..color = TBShade.white(alpha))
        ..save()
        ..translate(rect.left, rect.top);
      Wood.paint(
        canvas,
        rect.size,
        radius: _c * 0.22,
        elevation: TBElevation.e1,
        grainSeed: gate.cell.x + gate.cell.y * 5,
      );
      canvas.restore();
      final door = RRect.fromRectAndRadius(
        rect.deflate(_c * 0.16),
        Radius.circular(_c * 0.14),
      );
      canvas
        ..drawRRect(door, Paint()..color = TBShade.bevelDark(color))
        ..drawRRect(door.deflate(_c * 0.04), Paint()..color = color);
      final badge = RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: rect.center,
          width: _c * 0.36,
          height: _c * 0.36,
        ),
        Radius.circular(_c * 0.18),
      );
      Brass.paint(canvas, badge, elevation: const []);
      canvas
        ..drawPath(
          ArrowVisuals.symbol(gate.color, rect.center, _c * 0.09),
          Paint()..color = TBColors.ink900,
        )
        ..restore();
    }
  }

  void _paintPeek(Canvas canvas) {
    if (_peekAlpha <= 0 || _peek.isEmpty) return;
    final color = _peekFree ? TBColors.sky : TBColors.berry;
    final paint = Paint()
      ..color = color.withValues(alpha: 0.85 * _peekAlpha)
      ..strokeWidth = _c * 0.09
      ..strokeCap = StrokeCap.round;
    for (var i = 0; i < _peek.length; i++) {
      final p = geometry.center(_peek[i]);
      canvas.drawCircle(p, _c * (i == _peek.length - 1 ? 0.12 : 0.07), paint);
    }
  }
}
