import 'package:arrowchime/app/theme/tokens.dart';
import 'package:arrowchime/app/theme/typography.dart';
import 'package:flutter/widgets.dart';

/// Placeholder screen: a token-coloured background with a centred label.
///
/// Replaced by the real screens specified in `docs/10` §7 in later phases.
class StubScreen extends StatelessWidget {
  const new({required this.label, super.key});

  final String label;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: TBColors.ink900,
      child: Center(
        child: Semantics(
          header: true,
          child: Text(
            label,
            textAlign: TextAlign.center,
            textDirection: TextDirection.ltr,
            style: TBTypography.title.style,
          ),
        ),
      ),
    );
  }
}
