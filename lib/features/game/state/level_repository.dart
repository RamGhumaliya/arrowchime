import 'package:arrowchime/core/level/generator/daily.dart';
import 'package:arrowchime/core/level/models/level.dart';
import 'package:arrowchime/core/level/pack_loader.dart';
import 'package:arrowchime/core/meta/date_key.dart';
import 'package:arrowchime/features/game/state/level_ref.dart';
import 'package:flutter/foundation.dart' show compute;
import 'package:flutter/services.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'level_repository.g.dart';

/// A bundled asset that fails to load will not load on a second try either.
Duration? _noRetry(int retryCount, Object error) => null;

/// Where level packs are read from (swapped in tests).
@Riverpod(keepAlive: true)
AssetBundle levelBundle(Ref ref) => rootBundle;

/// One chapter pack (`assets/levels/ch{N}.json`), parsed once.
@Riverpod(keepAlive: true, retry: _noRetry)
Future<LevelPack> levelPack(Ref ref, int chapter) async {
  final text = await ref
      .watch(levelBundleProvider)
      .loadString('assets/levels/ch$chapter.json');
  return PackLoader.parsePack(text, validate: false);
}

/// The Daily Knot of a UTC date: from the pre-baked `daily_{year}.json` when
/// it has the day, else generated on the device with the same code (so the
/// level is identical either way, `docs/04` §6).
@Riverpod(keepAlive: true, retry: _noRetry)
Future<Level> dailyLevel(Ref ref, String dateKey) async {
  final year = dateKey.substring(0, 4);
  try {
    final text = await ref
        .watch(levelBundleProvider)
        .loadString('assets/levels/daily_$year.json');
    final pack = PackLoader.parseDailyPack(text, validate: false);
    final baked = pack.levels[dateKey];
    if (baked != null) return baked;
  } on Object {
    // No pack for this year: fall through to the generator.
  }
  return await compute(DailyKnot.levelFor, DateKey.parse(dateKey));
}

/// A single level of a chapter pack.
@Riverpod(keepAlive: true, retry: _noRetry)
Future<Level> level(Ref ref, LevelRef id) async {
  final daily = id.daily;
  if (daily != null) {
    return await ref.watch(dailyLevelProvider(daily).future);
  }
  final pack = await ref.watch(levelPackProvider(id.chapter).future);
  return pack.levels[id.index - 1];
}
