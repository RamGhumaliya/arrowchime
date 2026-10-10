import 'package:arrowchime/core/level/models/level.dart';
import 'package:arrowchime/core/level/pack_loader.dart';
import 'package:arrowchime/features/game/state/level_ref.dart';
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

/// A single level of a chapter pack.
@Riverpod(keepAlive: true, retry: _noRetry)
Future<Level> level(Ref ref, LevelRef id) async {
  final pack = await ref.watch(levelPackProvider(id.chapter).future);
  return pack.levels[id.index - 1];
}
