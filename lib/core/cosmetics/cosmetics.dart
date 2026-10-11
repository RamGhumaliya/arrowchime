import 'package:arrowchime/core/remote_config/app_config.dart';
import 'package:arrowchime/core/save/save_data.dart';

/// The four things that can be swapped (`docs/03` §7: cosmetic only, never
/// gameplay power).
enum CosmeticKind { arrow, trail, board, instrument }

enum CosmeticTier { common, rare, epic }

/// How an item is obtained.
sealed class CosmeticSource {
  const new();
}

/// Everybody has it.
class FreeSource extends CosmeticSource {
  const new();
}

/// Earned by restoring a whole chapter (all 60 levels cleared).
class ChapterSource extends CosmeticSource {
  const new(this.chapter);

  final int chapter;
}

/// Earned by collecting this many stars in one chapter ("Constellation").
class StarsSource extends CosmeticSource {
  const new(this.stars);

  final int stars;
}

/// Bought with coins at the price of its tier (`docs/08`).
class ShopSource extends CosmeticSource {
  const new(this.tier);

  final CosmeticTier tier;
}

/// Only comes from a real-money bundle.
class BundleSource extends CosmeticSource {
  const new();
}

/// One cosmetic item.
class Cosmetic {
  const new(this.id, this.kind, this.source);

  final String id;
  final CosmeticKind kind;
  final CosmeticSource source;

  /// The default of a kind ('candy', 'none', 'auto').
  bool get isDefault => source is FreeSource;
}

/// The catalogue (`docs/06` §6: nine arrow skins; trails sparkle / petals /
/// snow / ribbons; board themes; instruments piano / marimba / 8-bit /
/// choir).
abstract final class Cosmetics {
  static const List<Cosmetic> all = [
    // Arrow skins.
    Cosmetic('candy', CosmeticKind.arrow, FreeSource()),
    Cosmetic('bamboo', CosmeticKind.arrow, ChapterSource(1)),
    Cosmetic('brass', CosmeticKind.arrow, ChapterSource(2)),
    Cosmetic('silk', CosmeticKind.arrow, ChapterSource(3)),
    Cosmetic('crystal', CosmeticKind.arrow, ChapterSource(4)),
    Cosmetic('galaxy', CosmeticKind.arrow, ChapterSource(5)),
    Cosmetic('neon', CosmeticKind.arrow, BundleSource()),
    Cosmetic('paper', CosmeticKind.arrow, ShopSource(CosmeticTier.common)),
    Cosmetic('pixel', CosmeticKind.arrow, ShopSource(CosmeticTier.rare)),
    // Trails.
    Cosmetic('none', CosmeticKind.trail, FreeSource()),
    Cosmetic('sparkle', CosmeticKind.trail, ShopSource(CosmeticTier.common)),
    Cosmetic('petals', CosmeticKind.trail, ShopSource(CosmeticTier.common)),
    Cosmetic('snow', CosmeticKind.trail, ShopSource(CosmeticTier.rare)),
    Cosmetic('ribbons', CosmeticKind.trail, BundleSource()),
    // Board themes.
    Cosmetic('auto', CosmeticKind.board, FreeSource()),
    Cosmetic('night', CosmeticKind.board, ShopSource(CosmeticTier.rare)),
    Cosmetic('sunset', CosmeticKind.board, ShopSource(CosmeticTier.rare)),
    Cosmetic('constellation', CosmeticKind.board, StarsSource(120)),
    Cosmetic('aurora', CosmeticKind.board, StarsSource(180)),
    // Instruments (swap the note voice).
    Cosmetic('auto', CosmeticKind.instrument, FreeSource()),
    Cosmetic('piano', CosmeticKind.instrument, ShopSource(CosmeticTier.common)),
    Cosmetic('marimba', CosmeticKind.instrument, BundleSource()),
    Cosmetic(
      'eightbit',
      CosmeticKind.instrument,
      ShopSource(CosmeticTier.rare),
    ),
    Cosmetic('choir', CosmeticKind.instrument, ShopSource(CosmeticTier.epic)),
  ];

  static List<Cosmetic> of(CosmeticKind kind) => [
    for (final c in all)
      if (c.kind == kind) c,
  ];

  static Cosmetic? find(CosmeticKind kind, String id) {
    for (final c in all) {
      if (c.kind == kind && c.id == id) return c;
    }
    return null;
  }

  /// Inventory key of an item (`arrow:neon`).
  static String key(CosmeticKind kind, String id) => '${kind.name}:$id';

  /// Coins an item costs, or `null` if it cannot be bought.
  static int? price(Cosmetic c, AppConfig config) => switch (c.source) {
    ShopSource(:final tier) => switch (tier) {
      CosmeticTier.common => config.priceCommon,
      CosmeticTier.rare => config.priceRare,
      CosmeticTier.epic => config.priceEpic,
    },
    _ => null,
  };

  static bool _chapterRestored(SaveData d, int chapter) =>
      (d.currentLevel['$chapter'] ?? 1) > 60;

  static int _bestChapterStars(SaveData d) {
    var best = 0;
    for (var c = 1; c <= 5; c++) {
      final stars = d.stars.entries
          .where((e) => e.key.startsWith('ch${c}_l'))
          .fold(0, (a, e) => a + e.value);
      if (stars > best) best = stars;
    }
    return best;
  }

  /// Whether the player has [c]: free, bought / granted, or earned.
  static bool isOwned(SaveData d, Cosmetic c) {
    if (d.inventory.contains(key(c.kind, c.id))) return true;
    return switch (c.source) {
      FreeSource() => true,
      ChapterSource(:final chapter) => _chapterRestored(d, chapter),
      StarsSource(:final stars) => _bestChapterStars(d) >= stars,
      ShopSource() || BundleSource() => false,
    };
  }

  /// Short hint on how to get a locked item (resolved to text by the UI).
  static String requirement(Cosmetic c) => switch (c.source) {
    FreeSource() => 'free',
    ChapterSource(:final chapter) => 'chapter:$chapter',
    StarsSource(:final stars) => 'stars:$stars',
    ShopSource(:final tier) => 'shop:${tier.name}',
    BundleSource() => 'bundle',
  };

  /// What is equipped for [kind] (the default when nothing valid is).
  static String equipped(SaveData d, CosmeticKind kind) {
    final id = d.equipped[kind.name];
    final item = id == null ? null : find(kind, id);
    if (item != null && isOwned(d, item)) return item.id;
    return of(kind).firstWhere((c) => c.isDefault).id;
  }

  /// Buys [c] with coins: the new save, or `null` if it is not for sale, is
  /// owned already or the coins are short.
  static SaveData? buy(SaveData d, Cosmetic c, AppConfig config) {
    final cost = price(c, config);
    if (cost == null || isOwned(d, c) || d.coins < cost) return null;
    return d.copyWith(
      coins: d.coins - cost,
      inventory: [...d.inventory, key(c.kind, c.id)],
    );
  }

  /// Puts an owned item on; `null` if it is not owned.
  static SaveData? equip(SaveData d, Cosmetic c) {
    if (!isOwned(d, c)) return null;
    return d.copyWith(equipped: {...d.equipped, c.kind.name: c.id});
  }

  /// Adds items to the inventory (bundles, purchases); already owned ones are
  /// skipped.
  static SaveData grant(SaveData d, Iterable<String> keys) => d.copyWith(
    inventory: [
      ...d.inventory,
      for (final k in keys)
        if (!d.inventory.contains(k)) k,
    ],
  );
}
