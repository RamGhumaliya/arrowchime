import 'dart:typed_data';

import 'package:arrowchime/core/level/difficulty.dart';
import 'package:arrowchime/core/level/generator/gen_params.dart';
import 'package:arrowchime/core/level/generator/mechanics_pass.dart';
import 'package:arrowchime/core/level/models/arrow.dart';
import 'package:arrowchime/core/level/models/cell.dart';
import 'package:arrowchime/core/level/models/direction.dart';
import 'package:arrowchime/core/level/models/level.dart';
import 'package:arrowchime/core/level/models/portal.dart';
import 'package:arrowchime/core/level/prng.dart';

/// Reverse-construction level generator (`docs/04` §3).
///
/// Arrows are placed one at a time so that each new arrow's exit ray avoids
/// every arrow already placed. Removing arrows in reverse placement order is
/// therefore always legal: **every base board is solvable by construction**.
/// Mechanics are then added by `MechanicsPass`, each verified by a solver.
///
/// Deterministic: all randomness comes from `Mulberry32(seed)`, so the same
/// `(params, seed)` yields identical JSON on every platform.
abstract final class LevelGenerator {
  /// Written to `meta.generatorVersion`. Bump when output changes.
  static const String version = '1.0.0';

  /// Generates one level.
  static Level generate(
    GenParams p,
    int seed, {
    String id = 'gen',
    int? chapter,
    int? index,
    String? melody,
  }) {
    final rng = Mulberry32(seed);

    // Portal levels retry the base layout until some ray actually uses a
    // portal (otherwise the mechanic would be decoration).
    final attempts = p.mix.portalPairs > 0 ? 8 : 1;
    late _Base base;
    for (var t = 0; t < attempts; t++) {
      base = _buildBase(p, Mulberry32(rng.nextUint32()));
      if (base.usesPortals || p.mix.portalPairs == 0) break;
    }
    if (base.placed.isEmpty) {
      throw StateError('generator placed no arrows (params too tight)');
    }

    final n = base.placed.length;
    final ids = rng.shuffle(List<int>.generate(n, (i) => i));
    final byId = <int, Arrow>{
      for (var k = 0; k < n; k++)
        ids[k]: Arrow(
          id: ids[k],
          body: [for (final c in base.placed[k].body) base.cell(c)],
          dir: base.placed[k].dir,
        ),
    };
    final arrows = [for (var i = 0; i < n; i++) byId[i]!];
    // Placed last = removed first.
    final solution = [for (var k = n - 1; k >= 0; k--) ids[k]];

    var level = Level(
      id: id,
      chapter: chapter,
      index: index,
      width: p.width,
      height: p.height,
      mask: p.mask,
      hearts: p.hearts,
      arrows: arrows,
      portals: base.portals,
    );

    final result = MechanicsPass.apply(level, solution, p, rng);
    level = result.level;

    final report = Difficulty.analyze(
      level,
      solution: result.solution,
      trapRatio: result.trapRatio,
    );
    return level.withMeta(
      LevelMeta(
        seed: seed,
        generatorVersion: version,
        difficulty: report.score,
        depth: report.depth,
        solution: result.solution,
        melody: melody,
      ),
    );
  }

  static _Base _buildBase(GenParams p, Mulberry32 rng) {
    final w = p.width;
    final h = p.height;
    final mask = p.mask;
    final active = Uint8List(w * h);
    var activeCount = 0;
    for (var y = 0; y < h; y++) {
      for (var x = 0; x < w; x++) {
        final on = mask == null || mask[y][x] == '1';
        if (on) {
          active[y * w + x] = 1;
          activeCount++;
        }
      }
    }
    final occ = Int16List(w * h)..fillRange(0, w * h, -1);
    final portalOther = Int16List(w * h)..fillRange(0, w * h, -1);
    final base = _Base(w, h);

    // Portal pairs go in first so every later ray is portal-aware.
    for (var k = 0; k < p.mix.portalPairs; k++) {
      final pair = _pickPortalPair(rng, w, h, active, portalOther);
      if (pair == null) break;
      portalOther[pair.$1] = pair.$2;
      portalOther[pair.$2] = pair.$1;
      base.portals.add(
        Portal(id: 'P${k + 1}', a: base.cell(pair.$1), b: base.cell(pair.$2)),
      );
    }

    List<int>? ray(int head, Direction d) {
      final out = <int>[];
      var x = head % w;
      var y = head ~/ w;
      Set<int>? entered;
      while (true) {
        x += d.dx;
        y += d.dy;
        if (x < 0 || y < 0 || x >= w || y >= h) return out;
        final c = y * w + x;
        final other = portalOther[c];
        if (other >= 0) {
          entered ??= <int>{};
          if (!entered.add(c)) return null;
          out
            ..add(c)
            ..add(other);
          x = other % w;
          y = other ~/ w;
          continue;
        }
        out.add(c);
      }
    }

    var occupied = 0;
    var failures = 0;
    final cap = p.maxArrows;
    while (occupied / activeCount < p.targetFill &&
        failures < p.maxFailures &&
        (cap == null || base.placed.length < cap)) {
      final head = _pickHead(rng, p, w, h, active, occ, portalOther);
      if (head < 0) break;

      Direction? dir;
      List<int>? exit;
      for (final d in rng.shuffle([...Direction.values])) {
        final r = ray(head, d);
        if (r != null && !r.contains(head) && r.every((c) => occ[c] < 0)) {
          dir = d;
          exit = r;
          break;
        }
      }
      if (dir == null || exit == null) {
        failures++;
        continue;
      }

      final length = _sampleLength(rng, p);
      final rayCells = exit.toSet();
      final body = <int>[head];
      final inBody = <int>{head};
      var cur = head;
      var last = dir.opposite;
      for (var i = 1; i < length; i++) {
        final opts = <Direction>[];
        for (final d in Direction.values) {
          final nx = cur % w + d.dx;
          final ny = cur ~/ w + d.dy;
          if (nx < 0 || ny < 0 || nx >= w || ny >= h) continue;
          final n = ny * w + nx;
          if (active[n] == 1 &&
              occ[n] < 0 &&
              portalOther[n] < 0 &&
              !inBody.contains(n) &&
              !rayCells.contains(n)) {
            opts.add(d);
          }
        }
        if (opts.isEmpty) break;
        final v = opts.contains(last) && rng.nextDouble() > p.windiness
            ? last
            : rng.pick(opts);
        cur = (cur ~/ w + v.dy) * w + (cur % w + v.dx);
        body.add(cur);
        inBody.add(cur);
        last = v;
      }
      if (body.length < (length == 1 ? 1 : p.lenMin)) {
        failures++;
        continue;
      }

      final ordinal = base.placed.length;
      for (final c in body) {
        occ[c] = ordinal;
      }
      occupied += body.length;
      base.placed.add(_Placed(body: body.reversed.toList(), dir: dir));
      if (exit.any((c) => portalOther[c] >= 0)) base.usesPortals = true;
    }
    return base;
  }

  static int _sampleLength(Mulberry32 rng, GenParams p) {
    if (p.singleCellShare > 0 && rng.nextBool(p.singleCellShare)) return 1;
    final span = p.lenMax - p.lenMin + 1;
    final draws = (p.lenSkew < 0 ? -p.lenSkew : p.lenSkew) + 1;
    var pick = rng.nextInt(span);
    for (var i = 1; i < draws; i++) {
      final other = rng.nextInt(span);
      pick = p.lenSkew < 0
          ? (other > pick ? other : pick)
          : (other < pick ? other : pick);
    }
    return p.lenMin + pick;
  }

  static int _pickHead(
    Mulberry32 rng,
    GenParams p,
    int w,
    int h,
    Uint8List active,
    Int16List occ,
    Int16List portalOther,
  ) {
    final empty = <int>[];
    for (var c = 0; c < w * h; c++) {
      if (active[c] == 1 && occ[c] < 0 && portalOther[c] < 0) empty.add(c);
    }
    if (empty.isEmpty) return -1;

    var pool = empty;
    if (rng.nextBool(p.clusterBias)) {
      final near = <int>[
        for (final c in empty)
          if (_touchesOccupied(c, w, h, occ)) c,
      ];
      if (near.isNotEmpty) pool = near;
    }
    var pick = rng.pick(pool);
    if (rng.nextBool(p.centerBias)) {
      final other = rng.pick(pool);
      if (_centerDist(other, w, h) < _centerDist(pick, w, h)) pick = other;
    }
    return pick;
  }

  static bool _touchesOccupied(int c, int w, int h, Int16List occ) {
    final x = c % w;
    final y = c ~/ w;
    for (final d in Direction.values) {
      final nx = x + d.dx;
      final ny = y + d.dy;
      if (nx >= 0 && ny >= 0 && nx < w && ny < h && occ[ny * w + nx] >= 0) {
        return true;
      }
    }
    return false;
  }

  /// Squared distance to the board centre, in half-cell units (integer).
  static int _centerDist(int c, int w, int h) {
    final dx = 2 * (c % w) - (w - 1);
    final dy = 2 * (c ~/ w) - (h - 1);
    return dx * dx + dy * dy;
  }

  static (int, int)? _pickPortalPair(
    Mulberry32 rng,
    int w,
    int h,
    Uint8List active,
    Int16List portalOther,
  ) {
    final free = <int>[
      for (var c = 0; c < w * h; c++)
        if (active[c] == 1 && portalOther[c] < 0) c,
    ];
    for (var attempt = 0; attempt < 50 && free.length >= 2; attempt++) {
      final a = rng.pick(free);
      final b = rng.pick(free);
      final dist = (a % w - b % w).abs() + (a ~/ w - b ~/ w).abs();
      if (a != b && dist >= 3) return (a, b);
    }
    return null;
  }
}

class _Placed {
  new({required this.body, required this.dir});

  /// Cell indices tail → head.
  final List<int> body;
  final Direction dir;
}

class _Base {
  new(this.width, this.height);

  final int width;
  final int height;
  final List<_Placed> placed = [];
  final List<Portal> portals = [];
  bool usesPortals = false;

  Cell cell(int c) => Cell(c % width, c ~/ width);
}
