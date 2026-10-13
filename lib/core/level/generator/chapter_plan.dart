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
    required this.arrowsMin,
    required this.arrowsMax,
  });

  final int sizeMin;
  final int sizeMax;
  final double fillMin;
  final double fillMax;
  final double scoreMin;
  final double scoreMax;

  /// Absolute target of level 60.
  final double bossScore;

  /// Fewest arrows a level may have, at level 1 and level 60 of the chapter:
  /// the game is about busy boards, so a level below this is rejected.
  final int arrowsMin;
  final int arrowsMax;
}

/// Chapter band table, sawtooth targets and level → [GenParams] mapping.
abstract final class ChapterPlan {
  static const int levelsPerChapter = 60;

  /// The endless track continues past the five authored stages: stage 6 and
  /// beyond reuse stage 5's band and mechanics with fresh seeds.
  static const int authoredChapters = 5;

  /// The chapter whose band/mechanics a stage uses (stages 6+ use 5).
  static int planOf(int chapter) => chapter < 1
      ? 1
      : (chapter > authoredChapters ? authoredChapters : chapter);

  /// A level is accepted when its score is within this of its target.
  static const double checkTolerance = 14;

  /// V2: dense boards from the start. Sizes are the board edge in cells; the
  /// first few levels of chapter 1 are the hand-built onboarding boards.
  static const Map<int, ChapterBand> bands = {
    1: ChapterBand(
      sizeMin: 10,
      sizeMax: 17,
      fillMin: 0.78,
      fillMax: 0.88,
      scoreMin: 26,
      scoreMax: 56,
      bossScore: 66,
      arrowsMin: 16,
      arrowsMax: 58,
    ),
    2: ChapterBand(
      sizeMin: 14,
      sizeMax: 22,
      fillMin: 0.84,
      fillMax: 0.91,
      scoreMin: 46,
      scoreMax: 70,
      bossScore: 78,
      arrowsMin: 40,
      arrowsMax: 90,
    ),
    3: ChapterBand(
      sizeMin: 18,
      sizeMax: 26,
      fillMin: 0.86,
      fillMax: 0.92,
      scoreMin: 56,
      scoreMax: 78,
      bossScore: 86,
      arrowsMin: 60,
      arrowsMax: 120,
    ),
    4: ChapterBand(
      sizeMin: 22,
      sizeMax: 30,
      fillMin: 0.88,
      fillMax: 0.93,
      scoreMin: 62,
      scoreMax: 80,
      bossScore: 88,
      arrowsMin: 80,
      arrowsMax: 150,
    ),
    5: ChapterBand(
      sizeMin: 26,
      sizeMax: 34,
      fillMin: 0.90,
      fillMax: 0.94,
      scoreMin: 68,
      scoreMax: 88,
      bossScore: 94,
      arrowsMin: 100,
      arrowsMax: 190,
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
    final b = bands[planOf(chapter)]!;
    if (isBoss(index)) return b.bossScore;
    var t =
        b.scoreMin +
        (b.scoreMax - b.scoreMin) * (index / levelsPerChapter) +
        saw(index);
    if (isKnot(index)) t += 8;
    return t.clamp(0.0, 100.0);
  }

  /// Fewest arrows level [index] of [chapter] may have.
  static int minArrows(int chapter, int index) {
    final b = bands[planOf(chapter)]!;
    final t = (index - 1) / (levelsPerChapter - 1);
    var n = b.arrowsMin + ((b.arrowsMax - b.arrowsMin) * t).round();
    if (isBreather(index)) n = (n * 0.8).round();
    if (isKnot(index)) n = (n * 1.15).round();
    return n;
  }

  /// Mask name for this level, or `null` for the full rectangle. Nearly every
  /// level is a silhouette (a heart, a cat, a tree, ...); one in four is a
  /// plain rectangle, and the first levels of the game always are.
  static String? maskKind(int chapter, int index) {
    if (chapter == 1 && index <= 5) return null;
    if (isBoss(index)) return 'circle';
    final slot = (chapter * 7 + index) % 4;
    if (slot == 3 && !isKnot(index)) return null;
    final n = Masks.kinds.length;
    return Masks.kinds[((chapter - 1) * 11 + index * 3 + index ~/ 7) % n];
  }

  /// Which mechanics a level carries (budget: ≤ 2 types in chapters 2–4,
  /// ≤ 3 in chapter 5; the Boss may use everything unlocked so far).
  static MechanicMix mixFor(int chapter, int index) {
    final boss = isBoss(index);
    final extra = isKnot(index) ? 1 : 0;
    switch (planOf(chapter)) {
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
    final b = bands[planOf(chapter)]!;
    final a = adapt.clamp(-maxAdapt, maxAdapt);
    final t = (index - 1) / (levelsPerChapter - 1);
    var size = b.sizeMin + ((b.sizeMax - b.sizeMin) * t).round();
    var fill = b.fillMin + (b.fillMax - b.fillMin) * t;
    if (isKnot(index)) {
      size += 2;
      fill += 0.02;
    } else if (isBreather(index)) {
      size -= 2;
      fill -= 0.04;
    } else if (isBoss(index)) {
      size = b.sizeMax + 3;
      fill = b.fillMax;
    }
    size += (a / 1.5).truncate();
    if (size < b.sizeMin) size = b.sizeMin;
    if (size > maxBoardSize) size = maxBoardSize;
    if (size < 6) size = 6;

    final mix = mixFor(chapter, index);
    // Short-ish bodies give many arrows; a few long ones add the tangles.
    final lenMax = (3 + size ~/ 6 + (1.2 * a).round()).clamp(3, 11);
    final kind = maskKind(chapter, index);
    List<String>? mask;
    if (kind != null) {
      // A thin silhouette (a bolt, an arrow) has few cells for its bounding
      // box: grow the board until it has about as many playable cells as a
      // 2/3-full square of the planned size.
      final wanted = (size * size * 0.66).round();
      mask = Masks.byName(kind, size, size);
      while (Masks.playable(mask, size, size) < wanted && size < maxBoardSize) {
        size++;
        mask = Masks.byName(kind, size, size);
      }
    }
    return GenParams(
      width: size,
      height: size,
      mask: mask,
      targetFill: (fill + 0.03 * a).clamp(0.5, 0.96),
      lenMax: lenMax,
      lenSkew: 2,
      singleCellShare: mix.rotators > 0 ? 0.12 : 0.02,
      windiness: (0.35 + 0.3 * t + 0.1 * a).clamp(0.1, 0.9),
      peelBias: 0.85,
      maxFailures: 1500 + size * 60,
      mix: mix,
    );
  }

  /// Largest board edge the generator and the game screen are built for.
  static const int maxBoardSize = 34;

  /// Melody id for a level (`ch1_m02`): 12 melodies per chapter, rotated.
  static String melodyFor(int chapter, int index) =>
      'ch${planOf(chapter)}_m${((index - 1) % 12 + 1).toString().padLeft(2, '0')}';

  /// Level id (`ch1_l007`).
  static String idFor(int chapter, int index) =>
      'ch${chapter}_l${index.toString().padLeft(3, '0')}';
}
