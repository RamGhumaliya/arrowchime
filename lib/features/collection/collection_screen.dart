import 'package:arrowchime/app/router.dart';
import 'package:arrowchime/app/theme/chapter_theme.dart';
import 'package:arrowchime/app/theme/tokens.dart';
import 'package:arrowchime/core/cosmetics/cosmetics.dart';
import 'package:arrowchime/core/remote_config/app_config.dart';
import 'package:arrowchime/core/save/save_controller.dart';
import 'package:arrowchime/core/ui/components/tb_button.dart';
import 'package:arrowchime/core/ui/components/tb_panel.dart';
import 'package:arrowchime/core/ui/components/tb_pill.dart';
import 'package:arrowchime/core/ui/components/tb_tab_bar.dart';
import 'package:arrowchime/core/ui/components/tb_text.dart';
import 'package:arrowchime/core/ui/components/tb_toast.dart';
import 'package:arrowchime/core/ui/icons/tb_icon.dart';
import 'package:arrowchime/core/ui/icons/tb_icon_id.dart';
import 'package:arrowchime/core/ui/painters/arrow_skin.dart';
import 'package:arrowchime/core/ui/painters/enamel_tube_painter.dart';
import 'package:arrowchime/core/ui/support/tb_pressable.dart';
import 'package:arrowchime/features/collection/collection_preview.dart';
import 'package:arrowchime/features/game/state/level_ref.dart';
import 'package:arrowchime/features/game/state/level_repository.dart';
import 'package:arrowchime/features/shared/chapter_names.dart';
import 'package:arrowchime/features/shared/cosmetic_text.dart';
import 'package:arrowchime/features/shared/screen_frame.dart';
import 'package:arrowchime/l10n/gen/app_localizations.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// The Collection (`docs/10` §7): a live preview board, four tabs (Arrows,
/// Trails, Boards, Instruments), tiles for every item and one primary button
/// (Equip, or Buy with coins).
class CollectionScreen extends ConsumerStatefulWidget {
  const new({super.key});

  @override
  ConsumerState<CollectionScreen> createState() => _CollectionScreenState();
}

class _CollectionScreenState extends ConsumerState<CollectionScreen> {
  static const double _previewHeight = 220;

  int _tab = 0;

  /// What the preview shows per kind (starts at what is equipped).
  final Map<CosmeticKind, String> _selected = {};

  CosmeticKind get _kind => CosmeticKind.values[_tab];

  String _pick(CosmeticKind kind) =>
      _selected[kind] ??
      Cosmetics.equipped(ref.read(saveControllerProvider), kind);

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final save = ref.watch(saveControllerProvider);
    final config = ref.watch(appConfigProvider);
    final level = ref.watch(levelProvider(const LevelRef(1, 7)));
    const theme = ChapterTheme.mistyGarden;
    final item = Cosmetics.find(_kind, _pick(_kind))!;
    final owned = Cosmetics.isOwned(save, item);
    final equipped = Cosmetics.equipped(save, _kind) == item.id;
    final price = Cosmetics.price(item, config);

    return ScreenFrame(
      title: l10n.collectionTitle,
      onBack: () =>
          context.canPop() ? context.pop() : context.go(AppRoutes.home),
      trailing: TBPill(
        icon: TBIconId.coin,
        value: '${save.coins}',
        semanticLabel: l10n.gameCoinsLabel(save.coins),
      ),
      child: Column(
        children: [
          TBPanel.recessed(
            padding: const EdgeInsets.all(TBSpacing.s8),
            child: SizedBox(
              height: _previewHeight,
              child: level.when(
                data: (l) => CollectionPreview(
                  level: l,
                  theme: theme,
                  skin: _pick(CosmeticKind.arrow),
                  trail: _pick(CosmeticKind.trail),
                  board: _pick(CosmeticKind.board),
                  instrument: _pick(CosmeticKind.instrument),
                ),
                loading: () => const SizedBox.shrink(),
                error: (_, _) => const SizedBox.shrink(),
              ),
            ),
          ),
          const SizedBox(height: TBSpacing.s4),
          TBText.caption(l10n.collPreviewHint, color: TBColors.cream300),
          const SizedBox(height: TBSpacing.s12),
          TBTabBar(
            tabs: [
              TBTabItem(icon: TBIconId.collection, label: l10n.collTabArrows),
              TBTabItem(icon: TBIconId.flame, label: l10n.collTabTrails),
              TBTabItem(icon: TBIconId.grid, label: l10n.collTabBoards),
              TBTabItem(icon: TBIconId.bell, label: l10n.collTabInstruments),
            ],
            selectedIndex: _tab,
            onSelected: (i) => setState(() => _tab = i),
          ),
          const SizedBox(height: TBSpacing.s12),
          LayoutBuilder(
            builder: (context, c) {
              const gap = TBSpacing.s12;
              final width = (c.maxWidth - gap) / 2;
              return Wrap(
                spacing: gap,
                runSpacing: gap,
                children: [
                  for (final it in Cosmetics.of(_kind))
                    SizedBox(
                      width: width,
                      child: _Tile(
                        item: it,
                        selected: it.id == item.id,
                        owned: Cosmetics.isOwned(save, it),
                        equipped: Cosmetics.equipped(save, _kind) == it.id,
                        price: Cosmetics.price(it, config),
                        onTap: () => setState(() => _selected[_kind] = it.id),
                      ),
                    ),
                ],
              );
            },
          ),
          const SizedBox(height: TBSpacing.s16),
          if (owned)
            TBButton.primary(
              label: equipped ? l10n.collEquipped : l10n.collEquip,
              expand: true,
              onPressed: equipped ? null : () => _equip(item),
            )
          else if (price != null)
            TBButton.primary(
              label: l10n.collBuy(price),
              expand: true,
              onPressed: () => _buy(item, price),
            )
          else
            TBText.body(
              lockText(l10n, item),
              color: TBColors.cream100,
              textAlign: TextAlign.center,
            ),
        ],
      ),
    );
  }

  void _equip(Cosmetic item) {
    ref
        .read(saveControllerProvider.notifier)
        .update((d) => Cosmetics.equip(d, item) ?? d);
  }

  void _buy(Cosmetic item, int price) {
    final l10n = AppLocalizations.of(context);
    final config = ref.read(appConfigProvider);
    final save = ref.read(saveControllerProvider.notifier);
    final bought = Cosmetics.buy(
      ref.read(saveControllerProvider),
      item,
      config,
    );
    if (bought == null) {
      showTBToast(context, l10n.gameNoCoins, icon: TBIconId.coin);
      return;
    }
    save.update((_) => Cosmetics.equip(bought, item) ?? bought);
  }
}

/// How an item is obtained, as text.
String lockText(AppLocalizations l10n, Cosmetic item) {
  final r = Cosmetics.requirement(item).split(':');
  return switch (r.first) {
    'chapter' => l10n.collLockChapter(chapterName(l10n, int.parse(r[1]))),
    'stars' => l10n.collLockStars(int.parse(r[1])),
    _ => l10n.collLockBundle,
  };
}

class _Tile extends StatelessWidget {
  const new({
    required this.item,
    required this.selected,
    required this.owned,
    required this.equipped,
    required this.price,
    required this.onTap,
  });

  final Cosmetic item;
  final bool selected;
  final bool owned;
  final bool equipped;
  final int? price;
  final VoidCallback onTap;

  static const double _swatch = 56;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final name = cosmeticName(l10n, item);
    final state = equipped
        ? l10n.collEquipped
        : owned
        ? l10n.collOwned
        : (price != null ? '$price' : lockText(l10n, item));
    return TBPressable(
      onPressed: onTap,
      semanticLabel: '$name, $state',
      builder: (context, press) => Transform.translate(
        offset: Offset(0, TBSizes.buttonPressDepth * press.press),
        child: DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: TBRadius.br20,
            border: Border.all(
              width: selected ? TBSizes.focusRing : 0,
              color: selected
                  ? TBColors.tangerine
                  : TBColors.ink900.withValues(alpha: 0),
            ),
          ),
          child: TBPanel(
            radius: TBRadius.r20,
            padding: const EdgeInsets.all(TBSpacing.s12),
            child: Column(
              children: [
                Opacity(
                  opacity: owned ? 1 : 0.55,
                  child: SizedBox.square(
                    dimension: _swatch,
                    child: _Swatch(item: item),
                  ),
                ),
                const SizedBox(height: TBSpacing.s8),
                TBText.body(
                  name,
                  color: TBColors.ink900,
                  textAlign: TextAlign.center,
                  maxLines: 1,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (!owned)
                      Padding(
                        padding: const EdgeInsets.only(right: TBSpacing.s4),
                        child: TBIcon(
                          price != null ? TBIconId.coin : TBIconId.lock,
                          size: TBSpacing.s16,
                        ),
                      ),
                    Flexible(
                      child: TBText.caption(
                        state,
                        color: TBColors.ink700,
                        textAlign: TextAlign.center,
                        maxLines: 2,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// A small picture of an item: the skin on a sample arrow, a trail's dots,
/// the felt colour, an instrument's icon.
class _Swatch extends StatelessWidget {
  const new({required this.item});

  final Cosmetic item;

  @override
  Widget build(BuildContext context) {
    switch (item.kind) {
      case CosmeticKind.arrow:
        return CustomPaint(
          painter: EnamelTubePainter(
            cells: const [(0, 1), (1, 1), (2, 1), (2, 0)],
            color: TBColors.berry,
            skin: ArrowSkin.fromId(item.id),
          ),
        );
      case CosmeticKind.trail:
        return const TBIcon(TBIconId.flame);
      case CosmeticKind.board:
        return DecoratedBox(
          decoration: BoxDecoration(
            color: _felt(item.id),
            borderRadius: TBRadius.br12,
          ),
        );
      case CosmeticKind.instrument:
        return const TBIcon(TBIconId.bell);
    }
  }

  static Color _felt(String id) => switch (id) {
    'night' => TBColors.ink700,
    'sunset' => TBColors.tangerine,
    'constellation' => TBColors.berry,
    'aurora' => TBColors.teal,
    _ => TBColors.cream300,
  };
}
