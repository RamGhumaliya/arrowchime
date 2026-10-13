import 'package:arrowchime/app/theme/chapter_theme.dart';
import 'package:arrowchime/app/theme/tokens.dart';
import 'package:arrowchime/core/ui/components/tb_button.dart';
import 'package:arrowchime/core/ui/components/tb_flow_meter.dart';
import 'package:arrowchime/core/ui/components/tb_icon_button.dart';
import 'package:arrowchime/core/ui/components/tb_panel.dart';
import 'package:arrowchime/core/ui/components/tb_pill.dart';
import 'package:arrowchime/core/ui/components/tb_progress_bar.dart';
import 'package:arrowchime/core/ui/components/tb_ribbon.dart';
import 'package:arrowchime/core/ui/components/tb_sheet.dart';
import 'package:arrowchime/core/ui/components/tb_slider.dart';
import 'package:arrowchime/core/ui/components/tb_star_row.dart';
import 'package:arrowchime/core/ui/components/tb_tab_bar.dart';
import 'package:arrowchime/core/ui/components/tb_text.dart';
import 'package:arrowchime/core/ui/components/tb_toast.dart';
import 'package:arrowchime/core/ui/components/tb_toggle.dart';
import 'package:arrowchime/core/ui/components/tb_tray.dart';
import 'package:arrowchime/core/ui/icons/tb_icon.dart';
import 'package:arrowchime/core/ui/icons/tb_icon_id.dart';
import 'package:arrowchime/core/ui/painters/enamel_tube_painter.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/ui_harness.dart';

/// Golden tests for every `TB*` component state at 1x and 3x (`docs/10` §5,
/// `docs/09` D6). Update only for an approved design change:
/// `flutter test --update-goldens test/core/ui`.
class _Case {
  const new(
    this.name,
    this.build, {
    this.size = const Size(240, 112),
    this.surface = TestSurface.cream,
  });

  final String name;
  final Widget Function() build;
  final Size size;
  final TestSurface surface;
}

Widget _tube() => SizedBox(
  width: 200,
  height: 80,
  child: CustomPaint(
    painter: EnamelTubePainter(
      cells: const [(0, 2), (1, 2), (2, 2), (2, 1), (3, 1), (4, 1), (4, 0)],
      color: ChapterTheme.mistyGarden.arrowColors[0],
    ),
  ),
);

final List<_Case> _cases = [
  // Text
  for (final v in TBTextVariant.values)
    _Case(
      'text_${v.name}',
      () => switch (v) {
        TBTextVariant.display => const TBText.display('Arrow 37'),
        TBTextVariant.title => const TBText.title('Level 37'),
        TBTextVariant.counter => const TBText.counter('1,240'),
        TBTextVariant.button => const TBText.button('Retry'),
        TBTextVariant.body => const TBText.body('Short, warm copy.'),
        TBTextVariant.caption => const TBText.caption('Caption'),
      },
      size: const Size(240, 96),
      surface: switch (v) {
        TBTextVariant.body || TBTextVariant.caption => TestSurface.cream,
        _ => TestSurface.ink,
      },
    ),
  // Buttons: every kind x every state.
  for (final k in TBButtonKind.values) ...[
    _Case(
      'button_${k.name}_idle',
      () => TBButton(label: 'Play', onPressed: () {}, kind: k),
    ),
    _Case(
      'button_${k.name}_pressed',
      () => TBButton(
        label: 'Play',
        onPressed: () {},
        kind: k,
        forcePressed: true,
      ),
    ),
    _Case(
      'button_${k.name}_focus',
      () => TBButton(
        label: 'Play',
        onPressed: () {},
        kind: k,
        forceFocused: true,
      ),
    ),
    _Case(
      'button_${k.name}_disabled',
      () => TBButton(label: 'Play', onPressed: null, kind: k),
    ),
  ],
  _Case(
    'button_primary_icon_expanded',
    () => TBButton.primary(
      label: 'Next',
      onPressed: () {},
      icon: const TBIcon(TBIconId.star),
      expand: true,
    ),
    size: const Size(320, 112),
    surface: TestSurface.chapter,
  ),
  // Icon buttons
  _Case(
    'icon_button_idle',
    () => TBIconButton(
      icon: TBIconId.undo,
      onPressed: () {},
      semanticLabel: 'Undo',
    ),
    size: const Size(140, 120),
  ),
  _Case(
    'icon_button_badge',
    () => TBIconButton(
      icon: TBIconId.hint,
      onPressed: () {},
      semanticLabel: 'Hint',
      badge: '2',
    ),
    size: const Size(140, 120),
  ),
  _Case(
    'icon_button_pressed',
    () => TBIconButton(
      icon: TBIconId.grid,
      onPressed: () {},
      semanticLabel: 'Grid',
      forcePressed: true,
    ),
    size: const Size(140, 120),
  ),
  _Case(
    'icon_button_selected',
    () => TBIconButton(
      icon: TBIconId.grid,
      onPressed: () {},
      semanticLabel: 'Grid',
      selected: true,
    ),
    size: const Size(140, 120),
    surface: TestSurface.ink,
  ),
  _Case(
    'icon_button_focus',
    () => TBIconButton(
      icon: TBIconId.fit,
      onPressed: () {},
      semanticLabel: 'Fit',
      forceFocused: true,
    ),
    size: const Size(140, 120),
  ),
  _Case(
    'icon_button_disabled',
    () => const TBIconButton(
      icon: TBIconId.fit,
      onPressed: null,
      semanticLabel: 'Fit',
    ),
    size: const Size(140, 120),
  ),
  // Pills
  _Case(
    'pill_hearts',
    () => const TBPill(icon: TBIconId.heart, value: '5/5'),
    size: const Size(220, 96),
    surface: TestSurface.chapter,
  ),
  _Case(
    'pill_coins_add',
    () => TBPill(icon: TBIconId.coin, value: '1,240', onAdd: () {}),
    size: const Size(260, 96),
    surface: TestSurface.chapter,
  ),
  _Case(
    'pill_add_pressed',
    () => TBPill(
      icon: TBIconId.coin,
      value: '85',
      onAdd: () {},
      forcePressedAdd: true,
    ),
    size: const Size(260, 96),
    surface: TestSurface.ink,
  ),
  // Panels, ribbons
  _Case(
    'panel_raised',
    () => const TBPanel(
      child: SizedBox(width: 160, height: 40, child: TBText.body('Raised')),
    ),
    size: const Size(260, 160),
  ),
  _Case(
    'panel_recessed',
    () => const TBPanel.recessed(
      child: SizedBox(width: 160, height: 40, child: TBText.body('Recessed')),
    ),
    size: const Size(260, 160),
    surface: TestSurface.chapter,
  ),
  for (final k in TBRibbonKind.values)
    _Case(
      'ribbon_${k.name}',
      () => TBRibbon('Level 37', kind: k),
      size: const Size(280, 112),
    ),
  _Case(
    'ribbon_compact',
    () => const TBRibbon('Level 37', compact: true),
    size: const Size(280, 96),
  ),
  _Case(
    'sheet',
    () => const TBSheet(
      title: 'Level 37',
      child: SizedBox(height: 60, child: TBText.body('Nice flow!')),
    ),
    size: const Size(375, 240),
    surface: TestSurface.ink,
  ),
  _Case(
    'toast',
    () => const TBToast('Hold to peek the path.', icon: TBIconId.hint),
    size: const Size(320, 96),
    surface: TestSurface.chapter,
  ),
  // Controls
  _Case(
    'toggle_on',
    () => TBToggle(value: true, onChanged: (_) {}, semanticLabel: 'On'),
    size: const Size(140, 96),
  ),
  _Case(
    'toggle_off',
    () => TBToggle(value: false, onChanged: (_) {}, semanticLabel: 'Off'),
    size: const Size(140, 96),
  ),
  _Case(
    'toggle_focus',
    () => TBToggle(
      value: true,
      onChanged: (_) {},
      semanticLabel: 'Focus',
      forceFocused: true,
    ),
    size: const Size(140, 96),
  ),
  _Case(
    'toggle_disabled',
    () =>
        const TBToggle(value: true, onChanged: null, semanticLabel: 'Disabled'),
    size: const Size(140, 96),
  ),
  for (final v in const [0.0, 0.4, 1.0])
    _Case(
      'slider_${(v * 100).round()}',
      () => SizedBox(
        width: 240,
        child: TBSlider(value: v, onChanged: (_) {}, semanticLabel: 'Volume'),
      ),
      size: const Size(300, 96),
    ),
  _Case(
    'slider_disabled',
    () => const SizedBox(
      width: 240,
      child: TBSlider(value: 0.6, onChanged: null, semanticLabel: 'Volume'),
    ),
    size: const Size(300, 96),
  ),
  for (var i = 0; i < 3; i++)
    _Case(
      'tab_bar_$i',
      () => TBTabBar(
        tabs: const [
          TBTabItem(icon: TBIconId.shop, label: 'Shop'),
          TBTabItem(icon: TBIconId.collection, label: 'Collection'),
          TBTabItem(icon: TBIconId.quests, label: 'Quests'),
        ],
        selectedIndex: i,
        onSelected: (_) {},
      ),
      size: const Size(375, 140),
      surface: TestSurface.ink,
    ),
  // HUD
  for (final n in const [0, 1, 2, 3])
    _Case(
      'star_row_$n',
      () => TBStarRow(filled: n, animate: false),
      size: const Size(280, 120),
    ),
  for (final v in const [0.0, 0.55, 1.0])
    _Case(
      'progress_${(v * 100).round()}',
      () =>
          SizedBox(width: 240, child: TBProgressBar(value: v, shimmer: false)),
      size: const Size(300, 80),
      surface: TestSurface.chapter,
    ),
  _Case(
    'flow_empty',
    () => SizedBox(
      width: 300,
      child: TBFlowMeter(
        fill: 0,
        color: ChapterTheme.mistyGarden.arrowColors[0],
      ),
    ),
    size: const Size(360, 80),
    surface: TestSurface.ink,
  ),
  _Case(
    'flow_x3',
    () => SizedBox(
      width: 300,
      child: TBFlowMeter(
        fill: 0.5,
        color: ChapterTheme.mistyGarden.arrowColors[2],
        multiplier: 3,
      ),
    ),
    size: const Size(360, 80),
    surface: TestSurface.ink,
  ),
  _Case(
    'flow_x5_full',
    () => SizedBox(
      width: 300,
      child: TBFlowMeter(
        fill: 1,
        color: ChapterTheme.mistyGarden.arrowColors[3],
        multiplier: 5,
      ),
    ),
    size: const Size(360, 80),
    surface: TestSurface.chapter,
  ),
  // Chapter cards, tray, tube
  _Case(
    'tray_light',
    () => TBTray(chapter: ChapterTheme.mistyGarden, child: _tube()),
    size: const Size(320, 200),
  ),
  _Case(
    'tray_dark',
    () => TBTray(chapter: ChapterTheme.starlightObservatory, child: _tube()),
    size: const Size(320, 200),
  ),
  // Icons: all 24 placeholders.
  for (final id in TBIconId.values)
    _Case(
      'icon_${id.assetName}',
      () => TBIcon(id, size: 64),
      size: const Size(104, 104),
    ),
];

void main() {
  for (final c in _cases) {
    for (final dpr in const [1.0, 3.0]) {
      final scale = '${dpr.round()}x';
      testWidgets('${c.name} @$scale', (tester) async {
        await pumpSurface(
          tester,
          c.build(),
          size: c.size,
          surface: c.surface,
          dpr: dpr,
          padding: EdgeInsets.zero,
        );
        await expectLater(
          find.byKey(surfaceKey),
          matchesGoldenFile('goldens/${c.name}@$scale.png'),
        );
      });
    }
  }

  test('every icon has a golden case', () {
    final icons = _cases.where((c) => c.name.startsWith('icon_')).toList();
    final plain = icons
        .where((c) => !c.name.startsWith('icon_button'))
        .toList();
    expect(plain, hasLength(TBIconId.values.length));
  });

  test('the gallery background tokens exist', () {
    expect(TBColors.ink700, isNotNull);
  });
}
