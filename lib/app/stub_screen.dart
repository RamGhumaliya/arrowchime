import 'package:arrowchime/app/theme/tokens.dart';
import 'package:arrowchime/app/theme/typography.dart';
import 'package:arrowchime/core/ui/components/tb_button.dart';
import 'package:flutter/widgets.dart';

/// Placeholder screen: a token-coloured background with a centred label.
///
/// Replaced by the real screens specified in `docs/10` §7 in later phases.
class StubScreen extends StatelessWidget {
  const new({required this.label, this.actionLabel, this.onAction, super.key});

  final String label;

  /// Optional button, used for debug shortcuts until the real screens exist.
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: TBColors.ink900,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Semantics(
              header: true,
              child: Text(
                label,
                textAlign: TextAlign.center,
                textDirection: TextDirection.ltr,
                style: TBTypography.title.style,
              ),
            ),
            if (actionLabel != null) ...[
              const SizedBox(height: TBSpacing.s24),
              TBButton.primary(label: actionLabel!, onPressed: onAction),
            ],
          ],
        ),
      ),
    );
  }
}
