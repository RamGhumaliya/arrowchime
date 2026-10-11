import 'dart:async';

import 'package:arrowchime/app/theme/tokens.dart';
import 'package:arrowchime/core/iap/iap_controller.dart';
import 'package:arrowchime/core/ui/components/tb_button.dart';
import 'package:arrowchime/core/ui/components/tb_sheet.dart';
import 'package:arrowchime/core/ui/components/tb_text.dart';
import 'package:arrowchime/core/ui/icons/tb_icon.dart';
import 'package:arrowchime/core/ui/icons/tb_icon_id.dart';
import 'package:arrowchime/l10n/gen/app_localizations.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// The Starter Bundle sheet (`docs/10` §7): shown once after level 15 while the
/// 48 h window is open, never on a win or fail sheet. One primary button (the
/// price) and "Not now".
Future<void> showStarterBundleSheet(BuildContext context) =>
    showTBSheet<void>(context, sheet: const StarterBundleSheet());

class StarterBundleSheet extends ConsumerWidget {
  const new({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final iap = ref.read(iapControllerProvider);
    final product = ref.read(productsProvider).starterBundle;
    return TBSheet(
      title: l10n.shopStarterTitle,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Wrap(
            alignment: WrapAlignment.center,
            spacing: TBSpacing.s12,
            runSpacing: TBSpacing.s8,
            children: [
              _Chip(TBIconId.shop, l10n.shopChipRemoveAds),
              _Chip(TBIconId.coin, l10n.shopChipCoins(product.coins)),
              _Chip(TBIconId.collection, l10n.shopChipSkin),
            ],
          ),
          const SizedBox(height: TBSpacing.s16),
          FutureBuilder<Map<String, String>>(
            future: iap.prices(),
            builder: (context, snapshot) {
              final price = snapshot.data?[product.id];
              return TBButton.primary(
                label: price ?? l10n.shopPriceLoading,
                expand: true,
                onPressed: price == null
                    ? null
                    : () {
                        unawaited(iap.buy(product));
                        Navigator.of(context).pop();
                      },
              );
            },
          ),
          const SizedBox(height: TBSpacing.s8),
          TBButton.tertiary(
            label: l10n.starterNotNow,
            expand: true,
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  const new(this.icon, this.text);

  final TBIconId icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        TBIcon(icon, size: TBSpacing.s24),
        const SizedBox(width: TBSpacing.s4),
        TBText.caption(text, color: TBColors.ink900),
      ],
    );
  }
}
