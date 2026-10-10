import 'package:arrowchime/core/level/generator/gen_params.dart';
import 'package:arrowchime/core/level/generator/generator.dart';
import 'package:arrowchime/core/level/models/daily_pack.dart';
import 'package:arrowchime/core/level/models/level.dart';
import 'package:arrowchime/core/level/prng.dart';

/// The Daily Knot: one seeded puzzle per UTC day, the same for everyone
/// (`docs/04` §6, `docs/03` §7).
///
/// The seed is `FNV-1a("arrowchime-daily-v1-yyyy-MM-dd")`. Pre-baked packs
/// (`daily_{yyyy}.json`) are built with exactly this code, so the on-device
/// fallback generates the identical level.
///
/// Difficulty follows the weekday (Monday gentlest, Sunday hardest). Daily
/// levels are not on the chapter difficulty curve, so they are not
/// band-checked; they are still validated and solver-verified.
abstract final class DailyKnot {
  /// `yyyy-mm-dd` key of [date] (UTC).
  static String keyFor(DateTime date) {
    final d = date.toUtc();
    return '${d.year}-${_two(d.month)}-${_two(d.day)}';
  }

  /// Level id (`daily_20261010`).
  static String idFor(DateTime date) {
    final d = date.toUtc();
    return 'daily_${d.year}${_two(d.month)}${_two(d.day)}';
  }

  /// Generator parameters for a UTC [date] (weekday-driven).
  static GenParams paramsFor(DateTime date) {
    final weekday = date.toUtc().weekday; // Monday = 1 … Sunday = 7
    final (size, fill, mix) = switch (weekday) {
      DateTime.monday => (9, 0.70, MechanicMix.none),
      DateTime.tuesday => (9, 0.74, const MechanicMix(frozen: 1)),
      DateTime.wednesday => (10, 0.74, const MechanicMix(links: 1)),
      DateTime.thursday => (10, 0.78, const MechanicMix(gates: 1)),
      DateTime.friday => (11, 0.78, const MechanicMix(gates: 1, frozen: 2)),
      DateTime.saturday => (11, 0.82, const MechanicMix(gates: 2, links: 1)),
      _ => (12, 0.84, const MechanicMix(gates: 2, frozen: 3, links: 1)),
    };
    return GenParams(
      width: size,
      height: size,
      targetFill: fill,
      lenMax: 3 + size ~/ 2,
      windiness: 0.45,
      maxFailures: 600 + size * 40,
      mix: mix,
    );
  }

  /// The Daily Knot of a UTC [date].
  static Level levelFor(DateTime date) {
    final d = DateTime.utc(
      date.toUtc().year,
      date.toUtc().month,
      date.toUtc().day,
    );
    final dayOfYear = d.difference(DateTime.utc(d.year)).inDays + 1;
    return LevelGenerator.generate(
      paramsFor(d),
      dailySeed(d),
      id: idFor(d),
      chapter: 0,
      index: dayOfYear,
    );
  }

  /// Pre-bakes every day from [from] to [to] inclusive (UTC dates, same
  /// calendar year) into one pack.
  static DailyPack buildRange(DateTime from, DateTime to) {
    final start = DateTime.utc(from.year, from.month, from.day);
    final end = DateTime.utc(to.year, to.month, to.day);
    if (start.year != end.year) {
      throw ArgumentError('a daily pack covers one calendar year');
    }
    final levels = <String, Level>{};
    for (var d = start; !d.isAfter(end); d = d.add(const Duration(days: 1))) {
      levels[keyFor(d)] = levelFor(d);
    }
    return DailyPack(year: start.year, levels: levels);
  }

  static String _two(int n) => n.toString().padLeft(2, '0');
}
