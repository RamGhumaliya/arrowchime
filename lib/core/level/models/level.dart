// Freezed redirecting factories keep the type name; the `new` shorthand the
// lint suggests is not supported by freezed 4.
// ignore_for_file: unnecessary_type_name_in_constructor
import 'package:arrowchime/core/level/models/arrow.dart';
import 'package:arrowchime/core/level/models/cell.dart';
import 'package:arrowchime/core/level/models/direction.dart';
import 'package:arrowchime/core/level/models/gate.dart';
import 'package:arrowchime/core/level/models/portal.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'level.freezed.dart';

/// Thrown when level / pack JSON does not follow schema v1.
class LevelFormatException implements Exception {
  const new(this.message);

  final String message;

  @override
  String toString() => 'LevelFormatException: $message';
}

/// Generator / tooling metadata stored with a level (`meta` in the JSON).
@Freezed(makeCollectionsUnmodifiable: false, fromJson: false, toJson: false)
abstract class LevelMeta with _$LevelMeta {
  const factory LevelMeta({
    int? seed,
    String? generatorVersion,

    /// 0–100, or `null` = "compute me".
    double? difficulty,
    int? depth,

    /// Arrow ids in a valid removal order (linked pairs: first id only).
    @Default(<int>[]) List<int> solution,
    String? melody,
    bool? approved,
  }) = _LevelMeta;

  const LevelMeta._();

  Map<String, Object?> toJson() => {
    if (seed != null) 'seed': seed,
    if (generatorVersion != null) 'generatorVersion': generatorVersion,
    'difficulty': difficulty,
    if (depth != null) 'depth': depth,
    'solution': solution,
    if (melody != null) 'melody': melody,
    if (approved != null) 'approved': approved,
  };
}

/// A parsed level (schema v1). Immutable authored data; runtime state lives in
/// `BoardState`.
@Freezed(makeCollectionsUnmodifiable: false, fromJson: false, toJson: false)
abstract class Level with _$Level {
  const factory Level({
    required String id,
    required int width,
    required int height,
    required List<Arrow> arrows,
    int? chapter,
    int? index,

    /// `null` = full rectangle; else `height` strings of length `width`
    /// (`'1'` cell, `'0'` void).
    List<String>? mask,
    @Default(3) int hearts,
    @Default(<Gate>[]) List<Gate> gates,
    @Default(<Portal>[]) List<Portal> portals,
    @Default(LevelMeta()) LevelMeta meta,
  }) = _Level;

  /// Parses and schema-checks one level object. Does **not** check game rules
  /// (adjacency, overlaps, ...): use `validateLevel` for that.
  factory Level.fromJson(Map<String, Object?> json) => _parseLevel(json);

  const Level._();

  /// Whether `(x, y)` is a playable cell (inside bounds and not masked out).
  bool isActive(int x, int y) {
    if (x < 0 || y < 0 || x >= width || y >= height) return false;
    final m = mask;
    return m == null || m[y][x] == '1';
  }

  Map<String, Object?> toJson() => {
    'schema': 1,
    'id': id,
    if (chapter != null) 'chapter': chapter,
    if (index != null) 'index': index,
    'width': width,
    'height': height,
    'mask': mask,
    'hearts': hearts,
    'arrows': [for (final a in arrows) _arrowToJson(a)],
    'gates': [
      for (final g in gates)
        {
          'cell': [g.cell.x, g.cell.y],
          'color': g.color.name,
        },
    ],
    'portals': [
      for (final p in portals)
        {
          'id': p.id,
          'a': [p.a.x, p.a.y],
          'b': [p.b.x, p.b.y],
        },
    ],
    'meta': meta.toJson(),
  };

  /// Returns a copy with a different [meta].
  Level withMeta(LevelMeta newMeta) => copyWith(meta: newMeta);
}

/// A chapter pack: `{ "schema": 1, "chapter": N, "levels": [...] }`.
@Freezed(makeCollectionsUnmodifiable: false, fromJson: false, toJson: false)
abstract class LevelPack with _$LevelPack {
  const factory LevelPack({required List<Level> levels, int? chapter}) =
      _LevelPack;

  factory LevelPack.fromJson(Map<String, Object?> json) => _parsePack(json);

  const LevelPack._();

  Map<String, Object?> toJson() => {
    'schema': 1,
    if (chapter != null) 'chapter': chapter,
    'levels': [for (final l in levels) l.toJson()],
  };
}

Level _parseLevel(Map<String, Object?> json) {
  _noExtraKeys(json, const {
    'schema',
    'id',
    'chapter',
    'index',
    'width',
    'height',
    'mask',
    'hearts',
    'arrows',
    'gates',
    'portals',
    'meta',
    r'$schema',
  }, 'level');
  final schema = _reqInt(json, 'schema', 'level');
  if (schema != 1) {
    throw LevelFormatException('level.schema must be 1, got $schema');
  }
  final id = _reqString(json, 'id', 'level');
  if (!RegExp(r'^[a-z0-9_]+$').hasMatch(id)) {
    throw LevelFormatException('level.id "$id" must match [a-z0-9_]+');
  }
  final width = _reqInt(json, 'width', 'level', min: 3, max: 40);
  final height = _reqInt(json, 'height', 'level', min: 3, max: 40);
  final hearts = _reqInt(json, 'hearts', 'level', min: 1, max: 9);
  final chapter = _optInt(json, 'chapter', 'level', min: 0);
  final index = _optInt(json, 'index', 'level', min: 1);

  List<String>? mask;
  final rawMask = json['mask'];
  if (rawMask != null) {
    if (rawMask is! List) {
      throw const LevelFormatException('level.mask must be null or a list');
    }
    mask = [
      for (final row in rawMask)
        if (row is String && RegExp(r'^[01]+$').hasMatch(row))
          row
        else
          throw const LevelFormatException(
            'level.mask rows must be strings of 0/1',
          ),
    ];
  }

  final rawArrows = json['arrows'];
  if (rawArrows is! List || rawArrows.isEmpty) {
    throw const LevelFormatException('level.arrows must be a non-empty list');
  }
  final arrows = [
    for (var i = 0; i < rawArrows.length; i++)
      _parseArrow(rawArrows[i], 'arrows[$i]'),
  ];

  final gates = <Gate>[];
  for (final (i, g) in _objList(json['gates'], 'level.gates').indexed) {
    _noExtraKeys(g, const {'cell', 'color'}, 'gates[$i]');
    gates.add(
      Gate(
        cell: _reqCell(g, 'cell', 'gates[$i]'),
        color: _reqColor(g, 'color', 'gates[$i]'),
      ),
    );
  }

  final portals = <Portal>[];
  for (final (i, p) in _objList(json['portals'], 'level.portals').indexed) {
    _noExtraKeys(p, const {'id', 'a', 'b'}, 'portals[$i]');
    portals.add(
      Portal(
        id: _reqString(p, 'id', 'portals[$i]'),
        a: _reqCell(p, 'a', 'portals[$i]'),
        b: _reqCell(p, 'b', 'portals[$i]'),
      ),
    );
  }

  return Level(
    id: id,
    chapter: chapter,
    index: index,
    width: width,
    height: height,
    mask: mask,
    hearts: hearts,
    arrows: arrows,
    gates: gates,
    portals: portals,
    meta: _parseMeta(json['meta']),
  );
}

LevelPack _parsePack(Map<String, Object?> json) {
  final schema = _reqInt(json, 'schema', 'pack');
  if (schema != 1) {
    throw LevelFormatException('pack.schema must be 1, got $schema');
  }
  final raw = json['levels'];
  if (raw is! List) {
    throw const LevelFormatException('pack.levels must be a list');
  }
  return LevelPack(
    chapter: _optInt(json, 'chapter', 'pack', min: 0),
    levels: [
      for (final (i, l) in raw.indexed)
        if (l is Map<String, Object?>)
          Level.fromJson(l)
        else
          throw LevelFormatException('pack.levels[$i] must be an object'),
    ],
  );
}

Map<String, Object?> _arrowToJson(Arrow a) => {
  'id': a.id,
  'body': [
    for (final c in a.body) [c.x, c.y],
  ],
  'dir': a.dir.code,
  'kind': a.kind.name,
  if (a.color != null) 'color': a.color!.name,
  if (a.frozen != null) 'frozen': a.frozen,
  if (a.link != null) 'link': a.link,
  if (a.skinHint != null) 'skinHint': a.skinHint,
};

Arrow _parseArrow(Object? raw, String path) {
  if (raw is! Map<String, Object?>) {
    throw LevelFormatException('$path must be an object');
  }
  _noExtraKeys(raw, const {
    'id',
    'body',
    'dir',
    'kind',
    'color',
    'frozen',
    'link',
    'skinHint',
  }, path);
  final id = _reqInt(raw, 'id', path, min: 0);
  final rawBody = raw['body'];
  if (rawBody is! List || rawBody.isEmpty || rawBody.length > 40) {
    throw LevelFormatException('$path.body must be a list of 1–40 cells');
  }
  final dirCode = _reqString(raw, 'dir', path);
  final dir = Direction.fromCode(dirCode);
  if (dir == null) {
    throw LevelFormatException('$path.dir "$dirCode" must be U, D, L or R');
  }
  final kindName = _reqString(raw, 'kind', path);
  final kind = ArrowKind.fromName(kindName);
  if (kind == null) {
    throw LevelFormatException('$path.kind "$kindName" is unknown');
  }
  final link = raw['link'];
  if (link != null &&
      (link is! String || !RegExp(r'^L[0-9]+$').hasMatch(link))) {
    throw LevelFormatException('$path.link must match L<number>');
  }
  return Arrow(
    id: id,
    body: [
      for (var i = 0; i < rawBody.length; i++)
        _cell(rawBody[i], '$path.body[$i]'),
    ],
    dir: dir,
    kind: kind,
    color: raw.containsKey('color') ? _reqColor(raw, 'color', path) : null,
    frozen: _optInt(raw, 'frozen', path, min: 1, max: 20),
    link: link as String?,
    skinHint: _optInt(raw, 'skinHint', path, min: 0, max: 5),
  );
}

LevelMeta _parseMeta(Object? raw) {
  if (raw == null) return const LevelMeta();
  if (raw is! Map<String, Object?>) {
    throw const LevelFormatException('level.meta must be an object');
  }
  final difficulty = raw['difficulty'];
  if (difficulty != null && difficulty is! num) {
    throw const LevelFormatException('meta.difficulty must be a number');
  }
  final rawSolution = raw['solution'];
  if (rawSolution != null &&
      (rawSolution is! List || rawSolution.any((e) => e is! int))) {
    throw const LevelFormatException('meta.solution must be a list of ints');
  }
  final approved = raw['approved'];
  if (approved != null && approved is! bool) {
    throw const LevelFormatException('meta.approved must be a bool');
  }
  final melody = raw['melody'];
  if (melody != null && melody is! String) {
    throw const LevelFormatException('meta.melody must be a string');
  }
  final generatorVersion = raw['generatorVersion'];
  if (generatorVersion != null && generatorVersion is! String) {
    throw const LevelFormatException('meta.generatorVersion must be a string');
  }
  return LevelMeta(
    seed: _optInt(raw, 'seed', 'meta'),
    generatorVersion: generatorVersion as String?,
    difficulty: (difficulty as num?)?.toDouble(),
    depth: _optInt(raw, 'depth', 'meta'),
    solution: [...?(rawSolution as List?)?.cast<int>()],
    melody: melody as String?,
    approved: approved as bool?,
  );
}

Cell _cell(Object? raw, String path) {
  if (raw is List &&
      raw.length == 2 &&
      raw[0] is int &&
      raw[1] is int &&
      (raw[0]! as int) >= 0 &&
      (raw[1]! as int) >= 0) {
    return Cell(raw[0]! as int, raw[1]! as int);
  }
  throw LevelFormatException('$path must be [x, y] with non-negative ints');
}

Cell _reqCell(Map<String, Object?> m, String key, String path) =>
    _cell(m[key], '$path.$key');

GateColor _reqColor(Map<String, Object?> m, String key, String path) {
  final name = _reqString(m, key, path);
  return GateColor.fromName(name) ??
      (throw LevelFormatException('$path.$key "$name" is not a colour'));
}

List<Map<String, Object?>> _objList(Object? raw, String path) {
  if (raw == null) return const [];
  if (raw is! List) throw LevelFormatException('$path must be a list');
  return [
    for (final e in raw)
      if (e is Map<String, Object?>)
        e
      else
        throw LevelFormatException('$path entries must be objects'),
  ];
}

void _noExtraKeys(Map<String, Object?> m, Set<String> allowed, String path) {
  for (final k in m.keys) {
    if (!allowed.contains(k)) {
      throw LevelFormatException('$path has unknown property "$k"');
    }
  }
}

String _reqString(Map<String, Object?> m, String key, String path) {
  final v = m[key];
  if (v is String) return v;
  throw LevelFormatException('$path.$key must be a string');
}

int _reqInt(
  Map<String, Object?> m,
  String key,
  String path, {
  int? min,
  int? max,
}) {
  final v = m[key];
  if (v is! int) throw LevelFormatException('$path.$key must be an integer');
  _range(v, key, path, min, max);
  return v;
}

int? _optInt(
  Map<String, Object?> m,
  String key,
  String path, {
  int? min,
  int? max,
}) {
  final v = m[key];
  if (v == null) return null;
  if (v is! int) throw LevelFormatException('$path.$key must be an integer');
  _range(v, key, path, min, max);
  return v;
}

void _range(int v, String key, String path, int? min, int? max) {
  if ((min != null && v < min) || (max != null && v > max)) {
    throw LevelFormatException('$path.$key=$v is out of range');
  }
}
