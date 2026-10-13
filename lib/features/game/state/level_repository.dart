import 'package:arrowchime/core/level/generator/chapter_plan.dart';
import 'package:arrowchime/core/level/generator/daily.dart';
import 'package:arrowchime/core/level/generator/pack_builder.dart';
import 'package:arrowchime/core/level/models/level.dart';
import 'package:arrowchime/core/level/pack_loader.dart';
import 'package:arrowchime/core/meta/date_key.dart';
import 'package:arrowchime/features/game/state/level_ref.dart';
import 'package:flutter/foundation.dart' show compute;
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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

/// Levels that replace the shipped ones (Level Lab: regenerated or edited
/// levels played in the real game screen). Empty in normal play.
class LevelOverrides extends Notifier<Map<LevelRef, Level>> {
  @override
  Map<LevelRef, Level> build() => const {};

  // ignore: named for what it does
  void set(LevelRef id, Level level) => state = {...state, id: level};
}

final NotifierProvider<LevelOverrides, Map<LevelRef, Level>>
levelOverridesProvider = NotifierProvider<LevelOverrides, Map<LevelRef, Level>>(
  LevelOverrides.new,
);

Level _buildGenerated((int, int) at) =>
    PackBuilder.buildLevel(at.$1, at.$2, PackBuilder.defaultBaseSeed).level;

/// A single level of the endless track: bundled up to stage 5, generated
/// beyond.
@Riverpod(keepAlive: true, retry: _noRetry)
Future<Level> level(Ref ref, LevelRef id) async {
  final replaced = ref.watch(levelOverridesProvider.select((m) => m[id]));
  if (replaced != null) return replaced;
  final daily = id.daily;
  if (daily != null) {
    return await ref.watch(dailyLevelProvider(daily).future);
  }
  if (id.chapter > ChapterPlan.authoredChapters) {
    // Past the shipped packs the track is generated on the device from the
    // same deterministic seeds (identical on every device).
    return await compute(_buildGenerated, (id.chapter, id.index));
  }
  final pack = await ref.watch(levelPackProvider(id.chapter).future);
  return pack.levels[id.index - 1];
}
