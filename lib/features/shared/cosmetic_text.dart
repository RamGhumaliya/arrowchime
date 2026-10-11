import 'package:arrowchime/core/cosmetics/cosmetics.dart';
import 'package:arrowchime/l10n/gen/app_localizations.dart';

/// Localised name of a cosmetic (`cos_<kind>_<id>` in the ARB files).
String cosmeticName(AppLocalizations l, Cosmetic c) =>
    switch ('${c.kind.name}_${c.id}') {
      'arrow_candy' => l.cos_arrow_candy,
      'arrow_bamboo' => l.cos_arrow_bamboo,
      'arrow_brass' => l.cos_arrow_brass,
      'arrow_silk' => l.cos_arrow_silk,
      'arrow_crystal' => l.cos_arrow_crystal,
      'arrow_galaxy' => l.cos_arrow_galaxy,
      'arrow_neon' => l.cos_arrow_neon,
      'arrow_paper' => l.cos_arrow_paper,
      'arrow_pixel' => l.cos_arrow_pixel,
      'trail_none' => l.cos_trail_none,
      'trail_sparkle' => l.cos_trail_sparkle,
      'trail_petals' => l.cos_trail_petals,
      'trail_snow' => l.cos_trail_snow,
      'trail_ribbons' => l.cos_trail_ribbons,
      'board_auto' => l.cos_board_auto,
      'board_night' => l.cos_board_night,
      'board_sunset' => l.cos_board_sunset,
      'board_constellation' => l.cos_board_constellation,
      'board_aurora' => l.cos_board_aurora,
      'instrument_auto' => l.cos_instrument_auto,
      'instrument_piano' => l.cos_instrument_piano,
      'instrument_marimba' => l.cos_instrument_marimba,
      'instrument_eightbit' => l.cos_instrument_eightbit,
      _ => l.cos_instrument_choir,
    };
