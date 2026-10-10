/// Economy defaults (`docs/08` §1). The real values live in Remote Config
/// (`core/remote_config/defaults.dart`, Phase 9); these are its defaults.
abstract final class Pricing {
  /// Coins to buy a hint beyond the free allowance.
  static const int hint = 50;

  /// Coins for an undo after the free ones.
  static const int undo = 30;

  /// Free undos per level.
  static const int freeUndos = 2;

  /// Coins for +1 heart on the fail sheet.
  static const int heart = 100;

  /// Levels below this index have unlimited free hints; from here on a level
  /// gets [freeHintsPerLevel] free hint, then [hint] coins each.
  static const int hintsFreeBelowLevel = 20;
  static const int freeHintsPerLevel = 1;
}
