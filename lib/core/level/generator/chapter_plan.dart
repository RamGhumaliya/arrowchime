import 'package:arrowchime/core/level/generator/gen_params.dart';
import 'package:arrowchime/core/level/generator/masks.dart';

/// Per-chapter generation band (`docs/04` §5 target-band table).
class ChapterBand {
  const new({
    required this.sizeMin,
    required this.sizeMax,
    required this.fillMin,
    required this.fillMax,
    required this.scoreMin,
    required this.scoreMax,
    required this.bossScore,
  });

  final int sizeMin;
  final int sizeMax;
  final double fillMin;
  final double fillMax;
  final double scoreMin;
  final double scoreMax;

  /// Absolute target of level 60.
  final double bossScore;
}

/// Chapter band table, sawtooth targets and level → [GenParams] mapping.
abstract final class ChapterPlan {
  static const int levelsPerChapter = 60;

  /// A level is accepted when its score is within this of its target.
  static const double checkTolerance = 6;

  static const Map<int, ChapterBand> bands = {
    1: ChapterBand(
      sizeMin: 6,
      sizeMax: 12,
      fillMin: 0.55,
      fillMax: 0.75,
      scoreMin: 10,
      scoreMax: 35,
      bossScore: 45,
    ),
    2: ChapterBand(
      sizeMin: 8,
      sizeMax: 14,
      fillMin: 0.65,
      fillMax: 0.80,
      scoreMin: 25,
      scoreMax: 45,
      bossScore: 55,
    ),
    3: ChapterBand(
      sizeMin: 10,
      sizeMax: 16,
      fillMin: 0.70,
      fillMax: 0.85,
      scoreMin: 30,
      scoreMax: 55,
      bossScore: 65,
    ),
    4: ChapterBand(
      sizeMin: 12,
      sizeMax: 18,
      fillMin: 0.75,
      fillMax: 0.88,
      scoreMin: 40,
      scoreMax: 65,
      bossScore: 75,
    ),
    5: ChapterBand(
      sizeMin: 14,
      sizeMax: 22,
      fillMin: 0.78,
      fillMax: 0.92,
      scoreMin: 50,
      scoreMax: 75,
      bossScore: 88,
    ),
  };

  /// Every 10th level is a Knot level (bigger board, special shape).
  static bool isKnot(int index) => index % 10 == 0 && index != levelsPerChapter;

  /// Level 60 is the Boss Knot.
  static bool isBoss(int index) => index == levelsPerChapter;

  /// Every 5th level (that is not a Knot) is a breather.
  static bool isBreather(int index) =>
      index % 5 == 0 && !isKnot(index) && !isBoss(index);

  /// `+0, +3, +6, +9`, then `-8` on every 5th level.
  static double saw(int index) {
    final k = (index - 1) % 5;
    return k < 4 ? 3.0 * k : -8;
  }

  /// Target difficulty score of level [index] (1–60) of [chapter]:
  /// `bandMin + (bandMax - bandMin) * (i / 60) + saw(i)`, Knot `+8`, Boss =
  /// the chapter's absolute boss score. Clamped to 0–100.
  static double targetScore(int chapter, int index) {
    final b = bands[chapter]!;
    if (isBoss(index)) return b.bossScore;
    var t =
        b.scoreMin +
        (b.scoreMax - b.scoreMin) * (index / levelsPerChapter) +
        saw(index);
    if (isKnot(index)) t += 8;
    return t.clamp(0.0, 100.0);
  }

  /// Mask name for this level, or `null` for the full rectangle.
  static String? maskKind(int chapter, int index) {
    if (isBoss(index)) return 'circle';
    if (isKnot(index)) {
      return Masks.kinds[(index ~/ 10 - 1) % Masks.kinds.length];
    }
    if (chapter == 1) {
      // Shaped boards are introduced at L12 and then recur.
      if (index >= 12 && index % 4 == 0) {
        return index % 8 == 0 ? 'ring' : 'diamond';
      }
      return null;
    }
    return index % 7 == 3
        ? Masks.kinds[(index ~/ 7) % Masks.kinds.length]
        : null;
  }

  /// Which mechanics a level carries (budget: ≤ 2 types in chapters 2–4,
  /// ≤ 3 in chapter 5; the Boss may use everything unlocked so far).
  static MechanicMix mixFor(int chapter, int index) {
    final boss = isBoss(index);
    final extra = isKnot(index) ? 1 : 0;
    switch (chapter) {
      case 2:
        return MechanicMix(
          rotators: 2 + (index * 4) ~/ levelsPerChapter + extra,
        );
      case 3:
        final second = index > 20 && index.isEven;
        return MechanicMix(
          gates: 1 + index ~/ 25 + extra,
          rotators: boss || second ? 2 + index ~/ 30 : 0,
        );
      case 4:
        final slot = index % 3;
        return MechanicMix(
          frozen: 2 + index ~/ 12 + extra,
          gates: boss || slot == 0 ? 1 + index ~/ 30 : 0,
          rotators: boss || slot == 1 ? 2 + index ~/ 30 : 0,
        );
      case 5:
        return MechanicMix(
          links: 1 + index ~/ 20 + extra,
          portalPairs: index >= 20 ? 1 + index ~/ 30 : 0,
          frozen: boss || index % 3 == 0 ? 2 : 0,
          gates: boss ? 2 : 0,
          rotators: boss ? 2 : 0,
        );
      default:
        return MechanicMix.none;
    }
  }

  /// Largest |adapt| accepted by [paramsFor].
  static const double maxAdapt = 3;

  /// Generator parameters for level [index] of [chapter].
  ///
  /// [adapt] ∈ [-3, 3] moves the level along an easy ↔ hard axis: it scales
  /// the fill, how winding the arrows are, their length and (beyond ±1.5) the
  /// board size. The pack builder bisects it to hit the target score.
  static GenParams paramsFor(int chapter, int index, {double adapt = 0}) {
    final b = bands[chapter]!;
    final a = adapt.clamp(-maxAdapt, maxAdapt);
    final t = (index - 1) / (levelsPerChapter - 1);
    var size = b.sizeMin + ((b.sizeMax - b.sizeMin) * t).round();
    var fill = b.fillMin + (b.fillMax - b.fillMin) * t;
    if (isKnot(index)) {
      size += 1;
      fill += 0.03;
    } else if (isBreather(index)) {
      size -= 1;
      fill -= 0.05;
    } else if (isBoss(index)) {
      size = b.sizeMax + 2;
      fill = b.fillMax;
    }
    size += (a / 1.5).truncate();
    if (size < b.sizeMin - 1) size = b.sizeMin - 1;
    if (size > 24) size = 24;
    if (size < 5) size = 5;

    final mix = mixFor(chapter, index);
    final lenMax = 3 + ((size * 0.5) + 1.5 * a).round();
    final mask = maskKind(chapter, index);
    return GenParams(
      width: size,
      height: size,
      mask: mask == null ? null : Masks.byName(mask, size, size),
      targetFill: (fill + 0.05 * a).clamp(0.3, 0.93),
      lenMax: lenMax < 3 ? 3 : lenMax,
      singleCellShare: mix.rotators > 0 ? 0.15 : 0,
      windiness: (0.3 + 0.3 * t + 0.1 * a).clamp(0.05, 0.95),
      maxFailures: 600 + size * 40,
      mix: mix,
    );
  }

  /// Melody id for a level (`ch1_m02`): 12 melodies per chapter, rotated.
  static String melodyFor(int chapter, int index) =>
      'ch${chapter}_m${((index - 1) % 12 + 1).toString().padLeft(2, '0')}';

  /// Level id (`ch1_l007`).
  static String idFor(int chapter, int index) =>
      'ch${chapter}_l${index.toString().padLeft(3, '0')}';
}
