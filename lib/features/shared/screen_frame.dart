import 'package:arrowchime/app/theme/chapter_theme.dart';
import 'package:arrowchime/app/theme/tokens.dart';
import 'package:arrowchime/core/ui/components/tb_icon_button.dart';
import 'package:arrowchime/core/ui/components/tb_ribbon.dart';
import 'package:arrowchime/core/ui/icons/tb_icon_id.dart';
import 'package:arrowchime/core/ui/support/tb_layout.dart';
import 'package:arrowchime/l10n/gen/app_localizations.dart';
import 'package:flutter/widgets.dart';

/// The frame every secondary screen shares (`docs/10` §7): a back button, a
/// ribbon title, an optional trailing widget (usually the coins pill), then
/// the content, centred and capped at a readable width on tablets. The
/// background is a chapter scene when [theme] is given, else the ink page.
class ScreenFrame extends StatelessWidget {
  const new({
    required this.title,
    required this.onBack,
    required this.child,
    this.trailing,
    this.theme,
    this.scrollable = true,
    super.key,
  });

  final String title;
  final VoidCallback onBack;
  final Widget child;

  /// Right end of the header (the header keeps its height without it).
  final Widget? trailing;
  final ChapterTheme? theme;

  /// Whether the content scrolls (turn off for content that scrolls itself).
  final bool scrollable;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final margin = TBLayout.screenMargin(context);
    final header = Row(
      children: [
        TBIconButton(
          icon: TBIconId.back,
          semanticLabel: l10n.gameBack,
          onPressed: onBack,
        ),
        Expanded(child: Center(child: TBRibbon(title, compact: true))),
        trailing ?? const SizedBox(width: TBSizes.iconButton),
      ],
    );
    final body = scrollable
        ? SingleChildScrollView(
            padding: EdgeInsets.only(bottom: margin),
            child: child,
          )
        : child;
    return Stack(
      fit: StackFit.expand,
      children: [
        const ColoredBox(color: TBColors.page),
        SafeArea(
          child: Padding(
            padding: EdgeInsets.only(
              left: margin,
              top: TBSpacing.s8,
              right: margin,
            ),
            child: Column(
              children: [
                TBCentered(child: header),
                const SizedBox(height: TBSpacing.s16),
                Expanded(child: TBCentered(child: body)),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
