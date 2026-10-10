/// The 24 icons of the UI set (`assets/ASSET_MANIFEST.md`). Until the 3D
/// artist delivers the final art, `TBIcon` paints simple 3-tone placeholders.
enum TBIconId {
  coin,
  gem,
  heart,
  heartBroken,
  star,
  starEmpty,
  chest,
  key,
  ice,
  hint,
  undo,
  grid,
  fit,
  pause,
  settings,
  shop,
  trophy,
  calendar,
  flame,
  share,
  lock,
  bell,
  quests,
  collection,
  back;

  /// Manifest file name (`heart_broken`, `star_empty`, …).
  String get assetName => switch (this) {
    TBIconId.heartBroken => 'heart_broken',
    TBIconId.starEmpty => 'star_empty',
    _ => name,
  };

  /// Screen-reader label (placeholder wording; localise with the ARBs later).
  String get semanticLabel => switch (this) {
    TBIconId.heartBroken => 'Heart lost',
    TBIconId.starEmpty => 'Empty star',
    TBIconId.hint => 'Hint',
    TBIconId.fit => 'Fit board',
    TBIconId.back => 'Back',
    _ => '${name[0].toUpperCase()}${name.substring(1)}',
  };
}
