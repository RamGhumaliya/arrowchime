import 'package:arrowchime/l10n/gen/app_localizations.dart';

/// Localised chapter name (`docs/06` §4).
String chapterName(AppLocalizations l10n, int chapter) => switch (chapter) {
  1 => l10n.chapterName1,
  2 => l10n.chapterName2,
  3 => l10n.chapterName3,
  4 => l10n.chapterName4,
  _ => l10n.chapterName5,
};
