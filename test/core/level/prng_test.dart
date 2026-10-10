import 'package:arrowchime/core/level/prng.dart';
import 'package:flutter_test/flutter_test.dart';

/// Golden values were produced by an independent Python port of Mulberry32
/// (JavaScript `Math.imul` semantics) and the standard FNV-1a test vectors.
void main() {
  group('Mulberry32 golden sequences', () {
    const cases = <int, List<int>>{
      0: [1144304738, 1416247, 958946056, 627933444, 2007157716, 2340967985],
      1: [2693262067, 11749833, 2265367787, 4213581821, 4159151403, 1207330352],
      12345: [
        4207900869,
        1317490944,
        2079646450,
        3513001552,
        2187978186,
        1492380277,
      ],
      0xFFFFFFFF: [
        3850105811,
        813802916,
        3073704848,
        4054706436,
        3630262831,
        2315588663,
      ],
    };
    cases.forEach((seed, expected) {
      test('seed $seed', () {
        final r = Mulberry32(seed);
        expect([
          for (var i = 0; i < expected.length; i++) r.nextUint32(),
        ], expected);
      });
    });

    test('seeds are masked to 32 bits', () {
      final a = Mulberry32(0x1FFFFFFFF);
      final b = Mulberry32(0xFFFFFFFF);
      expect(a.nextUint32(), b.nextUint32());
    });
  });

  group('helpers', () {
    test('nextDouble is in [0, 1)', () {
      final r = Mulberry32(3);
      expect(r.nextDouble(), closeTo(0.7202267837710679, 1e-15));
      for (var i = 0; i < 1000; i++) {
        final d = r.nextDouble();
        expect(d, inInclusiveRange(0, 0.9999999999));
      }
    });

    test('nextInt golden', () {
      final r = Mulberry32(42);
      expect(
        [for (var i = 0; i < 8; i++) r.nextInt(10)],
        [6, 4, 8, 6, 1, 5, 2, 6],
      );
    });

    test('nextInt rejects non-positive max', () {
      expect(() => Mulberry32(1).nextInt(0), throwsArgumentError);
    });

    test('nextRange golden and bounds', () {
      final r = Mulberry32(42);
      expect(
        [for (var i = 0; i < 8; i++) r.nextRange(5, 9)],
        [8, 7, 9, 8, 5, 7, 6, 8],
      );
      expect(() => r.nextRange(3, 2), throwsArgumentError);
    });

    test('nextBool golden', () {
      final r = Mulberry32(99);
      expect(
        [for (var i = 0; i < 8; i++) r.nextBool(0.3)],
        [true, false, false, false, true, false, true, true],
      );
    });

    test('shuffle golden', () {
      final list = Mulberry32(7).shuffle(List<int>.generate(10, (i) => i));
      expect(list, [6, 5, 8, 1, 2, 3, 4, 7, 9, 0]);
    });

    test('pick golden', () {
      final r = Mulberry32(5);
      const items = ['a', 'b', 'c', 'd'];
      expect(
        [for (var i = 0; i < 6; i++) r.pick(items)],
        ['c', 'd', 'a', 'c', 'a', 'c'],
      );
    });
  });

  group('FNV-1a 32', () {
    test('standard vectors', () {
      expect(fnv1a32(''), 0x811C9DC5);
      expect(fnv1a32('a'), 0xE40C292C);
      expect(fnv1a32('foobar'), 0xBF9CF968);
    });

    test('hashes UTF-8 bytes (2, 3 and 4 byte code points)', () {
      // Reference: independent Python FNV-1a over `s.encode('utf-8')`.
      expect(fnv1a32('é'), 0x1E9DE8C1);
      expect(fnv1a32('€'), 0x298F832B);
      expect(fnv1a32('\u{1F600}'), 0x33A29608);
    });

    test('daily seed golden (UTC)', () {
      expect(dailySeed(DateTime.utc(2026, 10, 9)), 0xF79170E7);
      expect(
        dailySeed(DateTime.utc(2026, 10, 9, 23, 59)),
        0xF79170E7,
        reason: 'time of day is ignored',
      );
    });
  });
}
