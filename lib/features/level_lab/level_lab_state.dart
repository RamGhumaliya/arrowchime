import 'package:arrowchime/core/level/generator/chapter_plan.dart';
import 'package:arrowchime/core/level/generator/pack_builder.dart';
import 'package:arrowchime/core/level/level_checker.dart';
import 'package:arrowchime/core/level/models/level.dart';
import 'package:arrowchime/core/level/pack_loader.dart';
import 'package:arrowchime/features/game/state/level_repository.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// State of the Level Lab (debug tool, `docs/04` §7): the shipped chapter
/// packs plus the edits made in the lab (regenerated or approved levels).
/// Edits live in memory; **Export** gives the pack JSON to commit.
@immutable
class LabState {
  const new({
    this.chapter = 1,
    this.index = 1,
    this.edited = const {},
    this.baseSeed = PackBuilder.defaultBaseSeed,
    this.message,
  });

  final int chapter;

  /// Selected level, 1-60.
  final int index;

  /// Levels changed in the lab, by `chN_lXXX` id.
  final Map<String, Level> edited;

  /// Base seed for the next regeneration.
  final int baseSeed;

  /// Last status line (checker result, export size, ...).
  final String? message;

  LabState copyWith({
    int? chapter,
    int? index,
    Map<String, Level>? edited,
    int? baseSeed,
    String? message,
  }) => LabState(
    chapter: chapter ?? this.chapter,
    index: index ?? this.index,
    edited: edited ?? this.edited,
    baseSeed: baseSeed ?? this.baseSeed,
    message: message,
  );
}

class LevelLab extends Notifier<LabState> {
  @override
  LabState build() => const LabState();

  String _id(int chapter, int index) => ChapterPlan.idFor(chapter, index);

  /// The pack of [chapter] with this session's edits applied.
  Future<List<Level>> pack(int chapter) async {
    final shipped = await ref.read(levelPackProvider(chapter).future);
    return [for (final l in shipped.levels) state.edited[l.id] ?? l];
  }

  void select({int? chapter, int? index}) =>
      state = state.copyWith(chapter: chapter, index: index);

  /// Replaces the selected level with a fresh one (next seed); levels fixed by
  /// the plan (onboarding, mechanic tutorials) regenerate to themselves.
  Future<void> regenerate() async {
    final s = state;
    final seed = s.baseSeed + 1;
    final built = await compute(_build, (s.chapter, s.index, seed));
    state = s.copyWith(
      baseSeed: seed,
      edited: {...s.edited, _id(s.chapter, s.index): built},
      message:
          'Regenerated with base seed $seed: difficulty '
          '${built.meta.difficulty?.toStringAsFixed(1)}',
    );
  }

  static Level _build((int, int, int) args) =>
      PackBuilder.buildLevel(args.$1, args.$2, args.$3).level;

  /// Toggles `meta.approved` on the selected level.
  Future<void> toggleApproved() async {
    final s = state;
    final level = (await pack(s.chapter))[s.index - 1];
    final approved = level.meta.approved ?? false;
    final next = level.withMeta(
      LevelMeta(
        seed: level.meta.seed,
        generatorVersion: level.meta.generatorVersion,
        difficulty: level.meta.difficulty,
        depth: level.meta.depth,
        solution: level.meta.solution,
        melody: level.meta.melody,
        approved: !approved,
      ),
    );
    state = s.copyWith(
      edited: {...s.edited, level.id: next},
      message: approved ? 'Approval removed' : 'Marked approved',
    );
  }

  /// Runs the full checker on the selected level.
  Future<void> check() async {
    final s = state;
    final level = (await pack(s.chapter))[s.index - 1];
    final result = LevelChecker.checkLevel(level);
    state = s.copyWith(
      message: result.ok
          ? 'Checker: ok (score ${result.score?.toStringAsFixed(1)})'
          : 'Checker: ${result.errors.join('; ')}',
    );
  }

  /// The chapter's pack as JSON text, edits included.
  Future<String> export() async {
    final s = state;
    final levels = await pack(s.chapter);
    final text = PackLoader.encodePack(
      LevelPack(levels: levels, chapter: s.chapter),
    );
    state = s.copyWith(
      message: 'Exported ch${s.chapter}: ${text.length} characters',
    );
    return text;
  }
}

final levelLabProvider = NotifierProvider<LevelLab, LabState>(LevelLab.new);
