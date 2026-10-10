import 'package:arrowchime/core/level/prng.dart';
import 'package:arrowchime/core/save/save_data.dart';

/// What can advance a quest.
enum QuestMetric { levelsCleared, flowThree, arrowsFreed, perfectClears, daily }

/// One kind of daily quest (`docs/03` §7, `docs/08`: 30–80 coins each).
class QuestDef {
  const new(this.id, this.metric, this.target, this.coins);

  final String id;
  final QuestMetric metric;
  final int target;
  final int coins;
}

/// Three quests a day from a pool, plus a chest once all three are claimed.
abstract final class Quests {
  static const List<QuestDef> pool = [
    QuestDef('clear5', QuestMetric.levelsCleared, 5, 40),
    QuestDef('clear10', QuestMetric.levelsCleared, 10, 80),
    QuestDef('flow3', QuestMetric.flowThree, 1, 30),
    QuestDef('free100', QuestMetric.arrowsFreed, 100, 50),
    QuestDef('perfect3', QuestMetric.perfectClears, 3, 80),
    QuestDef('daily1', QuestMetric.daily, 1, 40),
  ];

  static const int perDay = 3;
  static const int chestCoins = 100;

  static QuestDef def(String id) => pool.firstWhere((q) => q.id == id);

  /// Today's quests: kept if already drawn for [today], else a fresh draw
  /// seeded by the date (the same three on every device that day).
  static QuestState ensureToday(QuestState s, String today) {
    if (s.date == today && s.items.length == perDay) return s;
    final rng = Mulberry32(_seed(today));
    final bag = List<QuestDef>.of(pool);
    final picked = <QuestDef>[];
    // Never two quests on the same metric: they would be the same chore.
    while (picked.length < perDay && bag.isNotEmpty) {
      final q = bag.removeAt(rng.nextInt(bag.length));
      if (picked.every((p) => p.metric != q.metric)) picked.add(q);
    }
    return QuestState(
      date: today,
      items: [for (final q in picked) QuestProgress(id: q.id)],
    );
  }

  static int _seed(String date) {
    var h = 0x811c9dc5;
    for (final c in 'arrowchime-quests-$date'.codeUnits) {
      h = ((h ^ c) * 0x01000193) & 0xFFFFFFFF;
    }
    return h;
  }

  /// Adds [amount] to every unclaimed quest of [metric].
  static QuestState advance(QuestState s, QuestMetric metric, int amount) {
    if (amount <= 0) return s;
    return s.copyWith(
      items: [
        for (final it in s.items)
          if (def(it.id).metric == metric && !it.claimed)
            it.copyWith(
              progress: (it.progress + amount).clamp(0, def(it.id).target),
            )
          else
            it,
      ],
    );
  }

  static bool isDone(QuestProgress it) => it.progress >= def(it.id).target;

  /// Claims quest [id]; returns the new state and the coins, or `null` if it
  /// is not finished or already claimed.
  static (QuestState, int)? claim(QuestState s, String id) {
    final it = s.items.where((i) => i.id == id).firstOrNull;
    if (it == null || it.claimed || !isDone(it)) return null;
    return (
      s.copyWith(
        items: [
          for (final i in s.items)
            if (i.id == id) i.copyWith(claimed: true) else i,
        ],
      ),
      def(id).coins,
    );
  }

  /// The chest is ready once all quests are claimed.
  static bool chestReady(QuestState s) =>
      s.items.isNotEmpty && s.items.every((i) => i.claimed) && !s.chestOpened;

  /// Opens the chest: the new state and its coins, or `null` if not ready.
  static (QuestState, int)? openChest(QuestState s) {
    if (!chestReady(s)) return null;
    return (s.copyWith(chestOpened: true), chestCoins);
  }
}
