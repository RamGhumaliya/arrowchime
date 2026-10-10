/// Deterministic PRNG and hash used by level generation (`docs/04` §6).
///
/// Never use `dart:math` `Random` for levels: its algorithm may change between
/// SDK versions. All arithmetic is masked to 32 bits so Android, iOS and the
/// Dart VM produce identical sequences.
library;

const int _mask32 = 0xFFFFFFFF;

/// 32-bit integer multiply (JavaScript `Math.imul` semantics, unsigned result).
int _imul(int a, int b) =>
    ((a & 0xFFFF) * b + ((((a >>> 16) * b) & 0xFFFF) << 16)) & _mask32;

/// Mulberry32 pseudo-random generator.
class Mulberry32 {
  new(int seed) : _state = seed & _mask32;

  int _state;

  /// Next unsigned 32-bit integer.
  int nextUint32() {
    _state = (_state + 0x6D2B79F5) & _mask32;
    var t = _state;
    t = _imul(t ^ (t >>> 15), t | 1);
    t ^= (t + _imul(t ^ (t >>> 7), t | 61)) & _mask32;
    return (t ^ (t >>> 14)) & _mask32;
  }

  /// Uniform double in `[0, 1)`.
  double nextDouble() => nextUint32() / 4294967296;

  /// Uniform integer in `[0, max)`. [max] must be positive.
  int nextInt(int max) {
    if (max <= 0) throw ArgumentError.value(max, 'max', 'must be positive');
    return (nextDouble() * max).floor();
  }

  /// Uniform integer in `[min, max]` (inclusive).
  int nextRange(int min, int max) {
    if (max < min) throw ArgumentError('max must be >= min');
    return min + nextInt(max - min + 1);
  }

  /// `true` with probability [probability].
  bool nextBool([double probability = 0.5]) => nextDouble() < probability;

  /// Fisher–Yates shuffle, in place. Returns [list].
  List<T> shuffle<T>(List<T> list) {
    for (var i = list.length - 1; i > 0; i--) {
      final j = nextInt(i + 1);
      final tmp = list[i];
      list[i] = list[j];
      list[j] = tmp;
    }
    return list;
  }

  /// Uniformly picks one element of a non-empty [list].
  T pick<T>(List<T> list) => list[nextInt(list.length)];
}

/// FNV-1a 32-bit hash of the UTF-8 bytes of [input].
int fnv1a32(String input) {
  var hash = 0x811C9DC5;
  for (final byte in _utf8(input)) {
    hash ^= byte;
    hash = _imul(hash, 0x01000193);
  }
  return hash;
}

/// Seed of the Daily Knot for a UTC date (`docs/04` §6).
int dailySeed(DateTime date) {
  final d = date.toUtc();
  final mm = d.month.toString().padLeft(2, '0');
  final dd = d.day.toString().padLeft(2, '0');
  return fnv1a32('arrowchime-daily-v1-${d.year}-$mm-$dd');
}

List<int> _utf8(String s) {
  final out = <int>[];
  for (final r in s.runes) {
    if (r < 0x80) {
      out.add(r);
    } else if (r < 0x800) {
      out
        ..add(0xC0 | (r >> 6))
        ..add(0x80 | (r & 0x3F));
    } else if (r < 0x10000) {
      out
        ..add(0xE0 | (r >> 12))
        ..add(0x80 | ((r >> 6) & 0x3F))
        ..add(0x80 | (r & 0x3F));
    } else {
      out
        ..add(0xF0 | (r >> 18))
        ..add(0x80 | ((r >> 12) & 0x3F))
        ..add(0x80 | ((r >> 6) & 0x3F))
        ..add(0x80 | (r & 0x3F));
    }
  }
  return out;
}
