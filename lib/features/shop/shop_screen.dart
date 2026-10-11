import 'dart:async';

import 'package:arrowchime/app/router.dart';
import 'package:arrowchime/app/theme/tokens.dart';
import 'package:arrowchime/core/iap/iap_controller.dart';
import 'package:arrowchime/core/iap/products.dart';
import 'package:arrowchime/core/iap/starter_offer.dart';
import 'package:arrowchime/core/meta/date_key.dart';
import 'package:arrowchime/core/remote_config/app_config.dart';
import 'package:arrowchime/core/save/save_controller.dart';
import 'package:arrowchime/core/ui/components/tb_button.dart';
import 'package:arrowchime/core/ui/components/tb_panel.dart';
import 'package:arrowchime/core/ui/components/tb_pill.dart';
import 'package:arrowchime/core/ui/components/tb_text.dart';
import 'package:arrowchime/core/ui/components/tb_toast.dart';
import 'package:arrowchime/core/ui/icons/tb_icon.dart';
import 'package:arrowchime/core/ui/icons/tb_icon_id.dart';
import 'package:arrowchime/core/ui/painters/brass_painter.dart';
import 'package:arrowchime/features/shared/screen_frame.dart';
import 'package:arrowchime/l10n/gen/app_localizations.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// The Shop (`docs/10` §7 SHOP): the Starter Bundle while its 48 h window is
/// open (the screen's one primary button), Remove Ads, three coin packs, the
/// Chapter Art Pack and Restore purchases. No fake timers, no pre-ticked
/// upsells.
class ShopScreen extends ConsumerStatefulWidget {
  const new({super.key});

  @override
  ConsumerState<ShopScreen> createState() => _ShopScreenState();
}

class _ShopScreenState extends ConsumerState<ShopScreen> {
  Map<String, String>? _prices;
  StreamSubscription<PurchaseOutcome>? _outcomes;

  @override
  void initState() {
    super.initState();
    final iap = ref.read(iapControllerProvider);
    unawaited(
      iap.prices().then((p) {
        if (mounted) setState(() => _prices = p);
      }),
    );
    _outcomes = iap.outcomes.listen((o) {
      if (!mounted) return;
      final l10n = AppLocalizations.of(context);
      showTBToast(context, switch (o) {
        PurchaseOutcome.thankYou => l10n.shopThanks,
        PurchaseOutcome.restored => l10n.shopRestored,
        PurchaseOutcome.failed => l10n.shopFailed,
      });
    });
  }

  @override
  void dispose() {
    unawaited(_outcomes?.cancel());
    super.dispose();
  }

  String _price(String id) =>
      _prices?[id] ?? AppLocalizations.of(context).shopPriceLoading;

  bool _canBuy(String id) => _prices?.containsKey(id) ?? false;

  void _buy(IapProduct product) {
    unawaited(ref.read(iapControllerProvider).buy(product));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final save = ref.watch(saveControllerProvider);
    final products = ref.watch(productsProvider);
    final now = ref.watch(clockProvider)();
    final offer = StarterOffer.of(
      save,
      ref.watch(appConfigProvider),
      nowMs: now.millisecondsSinceEpoch,
      today: DateKey.of(now),
    );
    final adsRemoved = save.flags['adsRemoved'] ?? false;
    final storeDown = _prices != null && _prices!.isEmpty;

    return ScreenFrame(
      title: l10n.shopTitle,
      onBack: () =>
          context.canPop() ? context.pop() : context.go(AppRoutes.home),
      trailing: TBPill(
        icon: TBIconId.coin,
        value: '${save.coins}',
        semanticLabel: l10n.gameCoinsLabel(save.coins),
      ),
      child: Column(
        children: [
          if (storeDown) ...[
            TBText.body(l10n.shopUnavailable, color: TBColors.cream100),
            const SizedBox(height: TBSpacing.s12),
          ],
          if (offer.open) ...[
            _StarterPanel(
              left: _format(l10n, offer.remaining),
              price: _price(products.starterBundle.id),
              coins: products.starterBundle.coins,
              onBuy: _canBuy(products.starterBundle.id)
                  ? () => _buy(products.starterBundle)
                  : null,
            ),
            const SizedBox(height: TBSpacing.s16),
          ],
          _RemoveAdsPanel(
            owned: adsRemoved,
            coins: products.removeAds.coins,
            price: _price(products.removeAds.id),
            onBuy: _canBuy(products.removeAds.id)
                ? () => _buy(products.removeAds)
                : null,
          ),
          const SizedBox(height: TBSpacing.s16),
          TBText.title(l10n.shopCoinsSection, color: TBColors.cream100),
          const SizedBox(height: TBSpacing.s8),
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                for (final p in [
                  products.coinPouch,
                  products.coinChest,
                  products.coinVault,
                ])
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: TBSpacing.s4,
                      ),
                      child: _CoinTile(
                        coins: p.coins,
                        price: _price(p.id),
                        best: p == products.coinChest,
                        onBuy: _canBuy(p.id) ? () => _buy(p) : null,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: TBSpacing.s16),
          _ArtPackPanel(
            owned: save.purchases.contains('product:${products.artPack.id}'),
            price: _price(products.artPack.id),
            onBuy: _canBuy(products.artPack.id)
                ? () => _buy(products.artPack)
                : null,
          ),
          const SizedBox(height: TBSpacing.s16),
          TBButton.tertiary(
            label: l10n.shopRestore,
            onPressed: () =>
                unawaited(ref.read(iapControllerProvider).restore()),
          ),
        ],
      ),
    );
  }

  /// `1d 20h` or `5h 12m`.
  static String _format(AppLocalizations l10n, Duration d) {
    final days = d.inDays;
    final hours = d.inHours % 24;
    final minutes = d.inMinutes % 60;
    return days > 0 ? '${days}d ${hours}h' : '${d.inHours}h ${minutes}m';
  }
}

class _StarterPanel extends StatelessWidget {
  const new({
    required this.left,
    required this.price,
    required this.coins,
    required this.onBuy,
  });

  final String left;
  final String price;
  final int coins;
  final VoidCallback? onBuy;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return TBPanel(
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(child: TBText.title(l10n.shopStarterTitle)),
              TBText.caption(
                l10n.shopStarterLeft(left),
                color: TBColors.ink700,
              ),
            ],
          ),
          const SizedBox(height: TBSpacing.s8),
          Wrap(
            alignment: WrapAlignment.center,
            spacing: TBSpacing.s8,
            runSpacing: TBSpacing.s8,
            children: [
              _Chip(TBIconId.shop, l10n.shopChipRemoveAds),
              _Chip(TBIconId.coin, l10n.shopChipCoins(coins)),
              _Chip(TBIconId.collection, l10n.shopChipSkin),
            ],
          ),
          const SizedBox(height: TBSpacing.s12),
          TBButton.primary(label: price, expand: true, onPressed: onBuy),
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

class _RemoveAdsPanel extends StatelessWidget {
  const new({
    required this.owned,
    required this.coins,
    required this.price,
    required this.onBuy,
  });

  final bool owned;
  final int coins;
  final String price;
  final VoidCallback? onBuy;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return TBPanel(
      child: Row(
        children: [
          const TBIcon(TBIconId.shop),
          const SizedBox(width: TBSpacing.s12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TBText.title(l10n.shopRemoveAdsTitle),
                TBText.caption(
                  l10n.shopRemoveAdsNote(coins),
                  color: TBColors.ink700,
                ),
              ],
            ),
          ),
          const SizedBox(width: TBSpacing.s8),
          if (owned)
            Semantics(label: l10n.shopOwned, child: const TBIcon(TBIconId.star))
          else
            TBButton.secondary(label: price, onPressed: onBuy),
        ],
      ),
    );
  }
}

class _CoinTile extends StatelessWidget {
  const new({
    required this.coins,
    required this.price,
    required this.best,
    required this.onBuy,
  });

  final int coins;
  final String price;
  final bool best;
  final VoidCallback? onBuy;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Stack(
      clipBehavior: Clip.none,
      children: [
        TBPanel(
          padding: const EdgeInsets.all(TBSpacing.s8),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const TBIcon(TBIconId.coin),
              FittedBox(
                fit: BoxFit.scaleDown,
                child: TBText.title(
                  l10n.shopCoinsAmount(coins),
                  color: TBColors.ink900,
                ),
              ),
              FittedBox(
                fit: BoxFit.scaleDown,
                child: TBText.caption(price, color: TBColors.ink700),
              ),
              const SizedBox(height: TBSpacing.s8),
              TBButton.secondary(
                label: l10n.shopBuyShort,
                expand: true,
                semanticLabel: l10n.shopBuy(price),
                onPressed: onBuy,
              ),
            ],
          ),
        ),
        if (best)
          Positioned(
            top: -TBSpacing.s8,
            left: 0,
            right: 0,
            child: Center(
              child: CustomPaint(
                painter: const BrassPainter(radius: TBRadius.pill),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: TBSpacing.s8,
                    vertical: TBSpacing.s4,
                  ),
                  child: TBText.caption(
                    l10n.shopBestValue,
                    color: TBColors.ink900,
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class _ArtPackPanel extends StatelessWidget {
  const new({required this.owned, required this.price, required this.onBuy});

  final bool owned;
  final String price;
  final VoidCallback? onBuy;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return TBPanel(
      child: Row(
        children: [
          const TBIcon(TBIconId.collection),
          const SizedBox(width: TBSpacing.s12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TBText.title(l10n.shopArtPack),
                TBText.caption(l10n.shopArtPackNote, color: TBColors.ink700),
              ],
            ),
          ),
          const SizedBox(width: TBSpacing.s8),
          if (owned)
            Semantics(label: l10n.shopOwned, child: const TBIcon(TBIconId.star))
          else
            TBButton.secondary(label: price, onPressed: onBuy),
        ],
      ),
    );
  }
}
