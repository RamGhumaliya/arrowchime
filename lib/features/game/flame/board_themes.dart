import 'package:arrowchime/app/theme/chapter_theme.dart';
import 'package:arrowchime/app/theme/tokens.dart';
import 'package:arrowchime/core/ui/painters/shade.dart';
import 'package:flutter/painting.dart';

/// Board themes (a cosmetic): the felt of the tray (`docs/10` §8). `auto`
/// keeps the chapter's own tray.
abstract final class BoardThemes {
  /// [base] with the tray of theme [id] (unknown ids and `auto` change
  /// nothing).
  static ChapterTheme apply(ChapterTheme base, String id) {
    final swap = switch (id) {
      'night' => (TBColors.ink700, true),
      'sunset' => (
        Color.lerp(TBColors.tangerine, TBColors.cream100, 0.55)!,
        false,
      ),
      'constellation' => (
        Color.lerp(TBColors.ink900, TBColors.berry, 0.28)!,
        true,
      ),
      'aurora' => (Color.lerp(TBColors.ink900, TBColors.teal, 0.35)!, true),
      _ => null,
    };
    if (swap == null) return base;
    return base.copyWith(
      trayFelt: TBShade.lighten(swap.$1, 0),
      darkTray: swap.$2,
    );
  }
}
