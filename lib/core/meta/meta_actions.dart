import 'package:arrowchime/core/meta/date_key.dart';
import 'package:arrowchime/core/meta/progression.dart';
import 'package:arrowchime/core/meta/quests.dart';
import 'package:arrowchime/core/meta/streak.dart';
import 'package:arrowchime/core/remote_config/app_config.dart';
import 'package:arrowchime/core/save/save_controller.dart';
import 'package:arrowchime/core/save/save_data.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'meta_actions.g.dart';

/// The things a player does outside a level that change the save: claim a
/// quest, open the chest, buy a streak freeze, pay for a missed Daily. Each is
/// one atomic update of the save.
class MetaActions {
  new(this._ref);

  final Ref _ref;

  SaveController get _save => _ref.read(saveControllerProvider.notifier);
  SaveData get _data => _ref.read(saveControllerProvider);
  String get today => DateKey.of(_ref.read(clockProvider)());

  /// Draws today's quests and this week's free freeze (call when Home opens).
  void refreshDay() {
    final day = today;
    _save.update(
      (d) => d.copyWith(
        quests: Quests.ensureToday(d.quests, day),
        streak: Streak.refreshFreezes(d.streak, day),
      ),
    );
  }

  /// Claims a finished quest; returns the coins (0 if it was not claimable).
  int claimQuest(String id) {
    final r = Quests.claim(_data.quests, id);
    if (r == null) return 0;
    _save.update((d) => d.copyWith(quests: r.$1, coins: d.coins + r.$2));
    return r.$2;
  }

  /// Opens the quest chest; returns the coins (0 if it is not ready).
  int openChest() {
    final r = Quests.openChest(_data.quests);
    if (r == null) return 0;
    _save.update((d) {
      final xp = d.xp;
      final next = d.copyWith(
        quests: r.$1,
        coins: d.coins + r.$2,
        flags: {...d.flags, 'questChestOpened': true},
      );
      return Progression.settle(next, xp, today).$1;
    });
    return r.$2;
  }

  /// Buys a streak freeze for the Remote Config freeze price coins; `false` if the stock
  /// is full or the coins are short.
  bool buyFreeze() {
    final d = _data;
    final price = _ref.read(appConfigProvider).streakFreezePrice;
    final streak = Streak.addFreeze(d.streak);
    if (streak == null || d.coins < price) return false;
    _save.update((x) => x.copyWith(streak: streak, coins: x.coins - price));
    return true;
  }

  /// Pays the Remote Config missed-Daily price to replay a missed Daily; `false` if
  /// the coins are short or the day was already played.
  bool payForMissedDaily(String dateKey) {
    final d = _data;
    final price = _ref.read(appConfigProvider).missedDailyPrice;
    if (d.daily.containsKey(dateKey) || d.coins < price) return false;
    _save.update((x) => x.copyWith(coins: x.coins - price));
    return true;
  }
}

@Riverpod(keepAlive: true)
MetaActions metaActions(Ref ref) => MetaActions(ref);
