import 'package:arrowchime/core/level/generator/chapter_plan.dart';

/// What a cleared level pays out.
class LevelReward {
  const new({required this.coins, required this.xp});

  final int coins;
  final int xp;
}

/// Reward rules (`docs/08` §1, `docs/03` §7):
/// * coins: `10 + 5 per star`, Knot ×1.5, Boss ×3, **+10** for reaching Flow ×5
/// * XP: `10 × stars + 5 per Flow tier reached`
abstract final class Rewards {
  static const int baseCoins = 10;
  static const int coinsPerStar = 5;
  static const int flowFiveBonus = 10;
  static const int xpPerStar = 10;
  static const int xpPerFlowTier = 5;

  /// Highest Flow multiplier (×5).
  static const int maxFlow = 5;

  /// Reward for clearing level [index] (1–60) with [stars] stars after
  /// reaching Flow multiplier [flowMultiplier] (1 = never).
  static LevelReward forWin({
    required int stars,
    required int index,
    int flowMultiplier = 1,
  }) {
    var coins = baseCoins + coinsPerStar * stars;
    if (ChapterPlan.isBoss(index)) {
      coins *= 3;
    } else if (ChapterPlan.isKnot(index)) {
      coins = (coins * 1.5).round();
    }
    if (flowMultiplier >= maxFlow) coins += flowFiveBonus;
    final tiers = (flowMultiplier - 1).clamp(0, maxFlow - 1);
    return LevelReward(
      coins: coins,
      xp: xpPerStar * stars + xpPerFlowTier * tiers,
    );
  }
}
