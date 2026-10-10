/// Every asset path the game references (`assets/ASSET_MANIFEST.md`).
///
/// Final art/audio is human-made and arrives later as WebP / OGG. Until then
/// `tool/gen_placeholder_assets.dart` writes **obvious placeholders** at these
/// paths using the extensions in [AssetFormats]. When the real files land,
/// change the two constants (or just the ones you need) and nothing else.
///
/// Pure Dart: shared by the app and the tool.
library;

/// File extensions of the current image / audio assets. The manifest's final
/// formats are `webp` and `ogg`; placeholders are `png` and `wav`.
abstract final class AssetFormats {
  /// Raster images (UI icons, chapter layers, cosmetics, branding).
  static const String image = 'png';

  /// Audio (music, notes, SFX).
  static const String audio = 'wav';
}

/// What kind of file an [AssetEntry] is, which decides how a placeholder is
/// drawn.
enum AssetKind {
  brandingImage,
  chapterLayer,
  chapterThumb,
  chapterFragments,
  uiIcon,
  mechanicSvg,
  mechanicImage,
  cosmeticPreview,
  shader,
  rive,
  lottie,
  music,
  sting,
  note,
  sfx,
  licence,
}

/// One manifest file.
class AssetEntry {
  const new(
    this.path,
    this.kind, {
    this.name = '',
    this.chapter = 0,
    this.width = 0,
    this.height = 0,
    this.alpha = false,
    this.scale = 1,
    this.extra = '',
  });

  /// Project-relative path, forward slashes.
  final String path;
  final AssetKind kind;

  /// Icon name, skin id, layer name, SFX id, note name…
  final String name;
  final int chapter;
  final int width;
  final int height;

  /// Image needs an alpha channel (transparent layers).
  final bool alpha;

  /// Density multiplier of UI icons (1, 2 or 3).
  final int scale;

  /// Instrument id for notes, layer name for chapter layers, etc.
  final String extra;
}

/// Pitched instruments and the scales their placeholder notes cover
/// (`docs/07` §1, `ASSET_MANIFEST.md` audio). Note names use `s` for sharp
/// (`Fs5`), never `#`.
abstract final class AudioCatalog {
  /// Instrument id → note names (two octaves of its scale).
  static const Map<String, List<String>> instrumentNotes = {
    // Chapter instruments.
    'kalimba': _cMajorPentatonic,
    'musicbox': _gMajor,
    'santoor': _dDorian,
    'celesta': _aMinorPentatonic,
    'harp': _eLydian,
    // Cosmetic instruments (swap the note voice).
    'piano': _cMajorPentatonic,
    'marimba': _cMajorPentatonic,
    'pixel': _cMajorPentatonic,
    'choir': _cMajorPentatonic,
  };

  /// Instrument of each chapter 1–5.
  static const Map<int, String> chapterInstrument = {
    1: 'kalimba',
    2: 'musicbox',
    3: 'santoor',
    4: 'celesta',
    5: 'harp',
  };

  static const List<String> _cMajorPentatonic = [
    'C4', 'D4', 'E4', 'G4', 'A4', //
    'C5', 'D5', 'E5', 'G5', 'A5', 'C6',
  ];
  static const List<String> _gMajor = [
    'G4', 'A4', 'B4', 'C5', 'D5', 'E5', 'Fs5', //
    'G5', 'A5', 'B5', 'C6', 'D6', 'E6', 'Fs6', 'G6',
  ];
  static const List<String> _dDorian = [
    'D4', 'E4', 'F4', 'G4', 'A4', 'B4', 'C5', //
    'D5', 'E5', 'F5', 'G5', 'A5', 'B5', 'C6', 'D6',
  ];
  static const List<String> _aMinorPentatonic = [
    'A4', 'C5', 'D5', 'E5', 'G5', //
    'A5', 'C6', 'D6', 'E6', 'G6', 'A6',
  ];
  static const List<String> _eLydian = [
    'E4', 'Fs4', 'Gs4', 'As4', 'B4', 'Cs5', 'Ds5', //
    'E5', 'Fs5', 'Gs5', 'As5', 'B5', 'Cs6', 'Ds6', 'E6',
  ];

  /// SFX ids of `docs/07` §2 (`star_1/2/3` expanded).
  static const List<String> sfxIds = [
    'ui_tap',
    'ui_back',
    'arrow_touch',
    'arrow_whoosh',
    'arrow_blocked',
    'heart_lost',
    'rotator_turn',
    'gate_open',
    'key_collect',
    'ice_tick',
    'ice_break',
    'portal_pass',
    'flow_up',
    'board_clear',
    'star_1',
    'star_2',
    'star_3',
    'coin',
    'level_fail',
    'fragment_restore',
    'chest_open',
    'daily_complete',
    'purchase',
  ];
}

/// The full list of manifest files, as [AssetEntry]s.
abstract final class AssetCatalog {
  static const int chapters = 5;

  /// Chapter scene layers, in back-to-front order.
  static const List<String> chapterLayers = [
    'bg_sky',
    'bg_far',
    'bg_mid',
    'bg_near',
    'fg',
  ];

  /// UI icon names (3D set by a human artist; placeholders until then).
  static const List<String> uiIcons = [
    'coin',
    'gem',
    'heart',
    'heart_broken',
    'star',
    'star_empty',
    'chest',
    'key',
    'ice',
    'hint',
    'undo',
    'grid',
    'fit',
    'pause',
    'settings',
    'shop',
    'trophy',
    'calendar',
    'flame',
    'share',
    'lock',
    'bell',
    'quests',
    'collection',
  ];

  static const List<String> mechanicSvgs = [
    'rotator_ring',
    'gate_amber',
    'gate_jade',
    'gate_rose',
    'gate_azure',
    'portal_ring',
    'chain_link',
  ];

  static const List<String> cosmeticSkins = [
    'candy',
    'bamboo',
    'brass',
    'silk',
    'crystal',
    'galaxy',
    'neon',
    'paper',
    'pixel',
  ];

  static const List<String> shaders = ['glow', 'desaturate'];

  static String get _img => AssetFormats.image;
  static String get _aud => AssetFormats.audio;

  static String chapterDir(int chapter) => 'assets/images/chapters/ch$chapter';

  /// `assets/images/chapters/chN/<layer>[_land].<ext>`.
  static String chapterLayerPath(
    int chapter,
    String layer, {
    bool land = false,
  }) => '${chapterDir(chapter)}/$layer${land ? '_land' : ''}.$_img';

  static String chapterThumbPath(int chapter) =>
      '${chapterDir(chapter)}/thumb.$_img';

  static String chapterFragmentsPath(int chapter) =>
      '${chapterDir(chapter)}/fragments.json';

  /// UI icon path for a density (`1`, `2`, `3`).
  static String uiIconPath(String name, {int scale = 1}) => scale == 1
      ? 'assets/images/ui/$name.$_img'
      : 'assets/images/ui/$scale.0x/$name.$_img';

  static String mechanicSvgPath(String name) =>
      'assets/images/mechanics/$name.svg';

  static String get iceBlockPath =>
      'assets/images/mechanics/ice_block_9slice.$_img';

  static String cosmeticPreviewPath(String skin) =>
      'assets/images/cosmetics/${skin}_preview.$_img';

  static String shaderPath(String name) => 'assets/shaders/$name.frag';

  static String notePath(String instrument, String note) =>
      'assets/audio/notes/$instrument/$note.$_aud';

  static String sfxPath(String id) => 'assets/audio/sfx/$id.$_aud';

  static String musicPath(int chapter) =>
      'assets/audio/music/ch${chapter}_loop.$_aud';

  static String stingPath(int chapter) =>
      'assets/audio/music/boss_sting_ch$chapter.$_aud';

  /// Every file of the manifest.
  static List<AssetEntry> all() => [
    // Branding exports.
    AssetEntry(
      'assets/images/app_icon_ios_1024.$_img',
      AssetKind.brandingImage,
      name: 'app_icon_ios',
      width: 1024,
      height: 1024,
    ),
    AssetEntry(
      'assets/images/app_icon_android_fg.$_img',
      AssetKind.brandingImage,
      name: 'app_icon_android_fg',
      width: 432,
      height: 432,
      alpha: true,
    ),
    AssetEntry(
      'assets/images/app_icon_android_bg.$_img',
      AssetKind.brandingImage,
      name: 'app_icon_android_bg',
      width: 432,
      height: 432,
    ),
    AssetEntry(
      'assets/images/logo_wordmark.$_img',
      AssetKind.brandingImage,
      name: 'logo_wordmark',
      width: 1200,
      height: 360,
      alpha: true,
    ),
    AssetEntry(
      'assets/images/splash_mark.$_img',
      AssetKind.brandingImage,
      name: 'splash_mark',
      width: 512,
      height: 512,
      alpha: true,
    ),
    // Chapter scenes.
    for (var c = 1; c <= chapters; c++) ...[
      for (final layer in chapterLayers) ...[
        AssetEntry(
          chapterLayerPath(c, layer),
          AssetKind.chapterLayer,
          name: layer,
          chapter: c,
          width: 2048,
          height: 2732,
          alpha: layer != 'bg_sky',
          extra: layer,
        ),
        AssetEntry(
          chapterLayerPath(c, layer, land: true),
          AssetKind.chapterLayer,
          name: '${layer}_land',
          chapter: c,
          width: 2732,
          height: 2048,
          alpha: layer != 'bg_sky',
          extra: layer,
        ),
      ],
      AssetEntry(
        chapterThumbPath(c),
        AssetKind.chapterThumb,
        name: 'thumb',
        chapter: c,
        width: 512,
        height: 512,
      ),
      AssetEntry(
        chapterFragmentsPath(c),
        AssetKind.chapterFragments,
        name: 'fragments',
        chapter: c,
      ),
    ],
    // UI icons @1x/2x/3x (256 px base).
    for (final name in uiIcons)
      for (final s in const [1, 2, 3])
        AssetEntry(
          uiIconPath(name, scale: s),
          AssetKind.uiIcon,
          name: name,
          width: 256 * s,
          height: 256 * s,
          alpha: true,
          scale: s,
        ),
    // Mechanic sprites.
    for (final name in mechanicSvgs)
      AssetEntry(mechanicSvgPath(name), AssetKind.mechanicSvg, name: name),
    AssetEntry(
      iceBlockPath,
      AssetKind.mechanicImage,
      name: 'ice_block_9slice',
      width: 96,
      height: 96,
      alpha: true,
    ),
    // Cosmetics.
    for (final skin in cosmeticSkins)
      AssetEntry(
        cosmeticPreviewPath(skin),
        AssetKind.cosmeticPreview,
        name: skin,
        width: 256,
        height: 256,
        alpha: true,
      ),
    // Shaders, Rive, Lottie.
    for (final s in shaders)
      AssetEntry(shaderPath(s), AssetKind.shader, name: s),
    const AssetEntry('assets/rive/mascot.riv', AssetKind.rive, name: 'mascot'),
    const AssetEntry(
      'assets/rive/buttons.riv',
      AssetKind.rive,
      name: 'buttons',
    ),
    const AssetEntry(
      'assets/lottie/confetti.json',
      AssetKind.lottie,
      name: 'confetti',
    ),
    // Audio.
    for (var c = 1; c <= chapters; c++) ...[
      AssetEntry(
        musicPath(c),
        AssetKind.music,
        name: 'ch${c}_loop',
        chapter: c,
      ),
      AssetEntry(
        stingPath(c),
        AssetKind.sting,
        name: 'boss_sting_ch$c',
        chapter: c,
      ),
    ],
    for (final e in AudioCatalog.instrumentNotes.entries)
      for (final note in e.value)
        AssetEntry(
          notePath(e.key, note),
          AssetKind.note,
          name: note,
          extra: e.key,
        ),
    for (final id in AudioCatalog.sfxIds)
      AssetEntry(sfxPath(id), AssetKind.sfx, name: id),
    // Licence ledgers.
    const AssetEntry(
      'assets/audio/LICENSES.md',
      AssetKind.licence,
      name: 'audio_licences',
    ),
    const AssetEntry(
      'assets/ART_LICENSES.md',
      AssetKind.licence,
      name: 'art_licences',
    ),
  ];

  /// Directories that need their own `pubspec.yaml` asset entry (Flutter does
  /// not recurse), ending in `/`.
  static List<String> assetDirectories() {
    final dirs = <String>{};
    for (final e in all()) {
      if (e.kind == AssetKind.licence) continue;
      final i = e.path.lastIndexOf('/');
      dirs.add('${e.path.substring(0, i)}/');
    }
    // Density folders are picked up through their base folder.
    dirs.removeWhere((d) => RegExp(r'/\d\.0x/$').hasMatch(d));
    return dirs.toList()..sort();
  }
}
