import 'package:arrowchime/app/theme/chapter_theme.dart';
import 'package:arrowchime/app/theme/tokens.dart';
import 'package:arrowchime/core/ui/components/tb_button.dart';
import 'package:arrowchime/core/ui/components/tb_chapter_card.dart';
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
import 'package:arrowchime/core/ui/painters/brass_painter.dart';
import 'package:arrowchime/core/ui/painters/crystal_painter.dart';
import 'package:arrowchime/core/ui/painters/enamel_tube_painter.dart';
import 'package:arrowchime/core/ui/painters/paper_painter.dart';
import 'package:arrowchime/core/ui/painters/wood_painter.dart';
import 'package:arrowchime/features/design_gallery/gallery_widgets.dart';
import 'package:flutter/widgets.dart';

/// The pages of the Design Gallery (`docs/10` §11). Each page is a column of
/// [GalleryItem]s: a component with all its states on cream, ink and one
/// chapter background.
enum GalleryGroup {
  foundations('Foundations'),
  buttons('Buttons'),
  surfaces('Panels'),
  hud('HUD'),
  controls('Controls'),
  chapters('Chapters'),
  icons('Icons'),
  materials('Materials');

  new(this.label);

  final String label;

  Widget get page => switch (this) {
    GalleryGroup.foundations => const _Foundations(),
    GalleryGroup.buttons => const _Buttons(),
    GalleryGroup.surfaces => const _Surfaces(),
    GalleryGroup.hud => const _Hud(),
    GalleryGroup.controls => const _Controls(),
    GalleryGroup.chapters => const _Chapters(),
    GalleryGroup.icons => const _Icons(),
    GalleryGroup.materials => const _Materials(),
  };
}

Widget _column(List<Widget> children) =>
    Column(crossAxisAlignment: CrossAxisAlignment.start, children: children);

bool _dark(GallerySurfaceKind k) => k != GallerySurfaceKind.cream;

// --- Foundations ----------------------------------------------------------

class _Foundations extends StatelessWidget {
  const new();

  static const _colours = <String, Color>{
    'ink900': TBColors.ink900,
    'ink700': TBColors.ink700,
    'ink500': TBColors.ink500,
    'cream100': TBColors.cream100,
    'cream300': TBColors.cream300,
    'tangerine': TBColors.tangerine,
    'tangerineLip': TBColors.tangerineLip,
    'teal': TBColors.teal,
    'tealLip': TBColors.tealLip,
    'berry': TBColors.berry,
    'butter': TBColors.butter,
    'butterLip': TBColors.butterLip,
    'sky': TBColors.sky,
  };

  @override
  Widget build(BuildContext context) {
    return _column([
      GalleryItem(
        title: 'Colour',
        note: 'Night Garden palette. Tangerine is the primary CTA only.',
        builder: (context, surface) => StateWrap(
          children: [
            for (final e in _colours.entries)
              StateLabel(
                e.key,
                surface: surface,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: e.value,
                    borderRadius: TBRadius.br12,
                    boxShadow: TBElevation.e1,
                  ),
                  child: const SizedBox.square(dimension: TBSizes.iconButton),
                ),
              ),
          ],
        ),
      ),
      GalleryItem(
        title: 'Type',
        note: 'Fredoka display/title/counter/button, Nunito body/caption.',
        builder: (context, surface) => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const TBText.display('Display 44'),
            const SizedBox(height: TBSpacing.s8),
            const TBText.title('Title 28'),
            const SizedBox(height: TBSpacing.s8),
            const TBText.counter('Counter 1,240'),
            const SizedBox(height: TBSpacing.s8),
            const TBText.button('Button 20', strokeColor: TBColors.tealLip),
            const SizedBox(height: TBSpacing.s8),
            TBText.body(
              'Body 16: short, warm, specific copy.',
              color: _dark(surface) ? TBColors.cream100 : TBColors.ink900,
            ),
            const SizedBox(height: TBSpacing.s8),
            TBText.caption(
              'Caption 13',
              color: _dark(surface) ? TBColors.cream300 : TBColors.ink500,
            ),
          ],
        ),
      ),
      GalleryItem(
        title: 'Radius and elevation',
        note: 'r12 / r20 / r32 / pill · e1 / e2 / e3 (the only three).',
        builder: (context, surface) => StateWrap(
          children: [
            for (final r in const [
              ('r12', TBRadius.br12),
              ('r20', TBRadius.br20),
              ('r32', TBRadius.br32),
              ('pill', TBRadius.brPill),
            ])
              StateLabel(
                r.$1,
                surface: surface,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: TBColors.teal,
                    borderRadius: r.$2,
                  ),
                  child: const SizedBox.square(dimension: TBSizes.iconButton),
                ),
              ),
            for (final e in const [
              ('e1', TBElevation.e1),
              ('e2', TBElevation.e2),
              ('e3', TBElevation.e3),
            ])
              StateLabel(
                e.$1,
                surface: surface,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: TBColors.cream100,
                    borderRadius: TBRadius.br12,
                    boxShadow: e.$2,
                  ),
                  child: const SizedBox.square(dimension: TBSizes.iconButton),
                ),
              ),
          ],
        ),
      ),
    ]);
  }
}

// --- Buttons ----------------------------------------------------------------

class _Buttons extends StatelessWidget {
  const new();

  Widget _states(
    GallerySurfaceKind surface,
    TBButton Function({
      required String label,
      required VoidCallback? onPressed,
      bool forcePressed,
      bool forceFocused,
    })
    make,
  ) {
    return StateWrap(
      children: [
        StateLabel(
          'idle',
          surface: surface,
          child: make(label: 'Play', onPressed: () {}),
        ),
        StateLabel(
          'pressed',
          surface: surface,
          child: make(label: 'Play', onPressed: () {}, forcePressed: true),
        ),
        StateLabel(
          'focus',
          surface: surface,
          child: make(label: 'Play', onPressed: () {}, forceFocused: true),
        ),
        StateLabel(
          'disabled',
          surface: surface,
          child: make(label: 'Play', onPressed: null),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return _column([
      GalleryItem(
        title: 'TBButton.primary',
        note: '64 dp · tangerine · ONE per screen.',
        builder: (context, surface) => _states(
          surface,
          ({
            required label,
            required onPressed,
            forcePressed = false,
            forceFocused = false,
          }) => TBButton.primary(
            label: label,
            onPressed: onPressed,
            forcePressed: forcePressed,
            forceFocused: forceFocused,
          ),
        ),
      ),
      GalleryItem(
        title: 'TBButton.secondary',
        note: '52 dp · teal.',
        builder: (context, surface) => _states(
          surface,
          ({
            required label,
            required onPressed,
            forcePressed = false,
            forceFocused = false,
          }) => TBButton.secondary(
            label: label,
            onPressed: onPressed,
            forcePressed: forcePressed,
            forceFocused: forceFocused,
          ),
        ),
      ),
      GalleryItem(
        title: 'TBButton.tertiary',
        note: '44 dp · cream.',
        builder: (context, surface) => _states(
          surface,
          ({
            required label,
            required onPressed,
            forcePressed = false,
            forceFocused = false,
          }) => TBButton.tertiary(
            label: label,
            onPressed: onPressed,
            forcePressed: forcePressed,
            forceFocused: forceFocused,
          ),
        ),
      ),
      GalleryItem(
        title: 'With icon, expanded',
        builder: (context, surface) => Column(
          children: [
            TBButton.primary(
              label: 'Next',
              onPressed: () {},
              icon: const TBIcon(TBIconId.star),
              expand: true,
            ),
            const SizedBox(height: TBSpacing.s12),
            TBButton.secondary(
              label: '+1',
              onPressed: () {},
              icon: const TBIcon(TBIconId.heart),
              expand: true,
            ),
          ],
        ),
      ),
    ]);
  }
}

// --- Panels, ribbons, sheet, toast ------------------------------------------

class _Surfaces extends StatelessWidget {
  const new();

  @override
  Widget build(BuildContext context) {
    return _column([
      GalleryItem(
        title: 'TBPanel',
        note: 'Raised and recessed lacquered paper.',
        builder: (context, surface) => const Column(
          children: [
            TBPanel(
              child: SizedBox(
                width: double.infinity,
                child: TBText.body('Raised panel: face, rim light, bevel.'),
              ),
            ),
            SizedBox(height: TBSpacing.s16),
            TBPanel.recessed(
              child: SizedBox(
                width: double.infinity,
                child: TBText.body('Recessed: lists and the board surround.'),
              ),
            ),
          ],
        ),
      ),
      GalleryItem(
        title: 'TBRibbon',
        builder: (context, surface) => const Column(
          children: [
            TBRibbon('Level 37'),
            SizedBox(height: TBSpacing.s12),
            TBRibbon('Daily Knot', kind: TBRibbonKind.teal),
            SizedBox(height: TBSpacing.s12),
            TBRibbon('Out of hearts', kind: TBRibbonKind.berry),
            SizedBox(height: TBSpacing.s12),
            TBRibbon('Level 37', compact: true),
          ],
        ),
      ),
      GalleryItem(
        title: 'TBSheet',
        note: 'Panel with a ribbon header; shown static here.',
        builder: (context, surface) => const Padding(
          padding: EdgeInsets.only(top: TBSpacing.s8),
          child: TBSheet(
            title: 'Level 37',
            child: Column(
              children: [
                TBStarRow(filled: 3, animate: false),
                SizedBox(height: TBSpacing.s16),
                TBText.body('Nice flow!'),
              ],
            ),
          ),
        ),
      ),
      GalleryItem(
        title: 'TBToast',
        builder: (context, surface) => const Column(
          children: [
            TBToast('Hold to peek the path.', icon: TBIconId.hint),
            SizedBox(height: TBSpacing.s12),
            TBToast('The garden is waking up.'),
          ],
        ),
      ),
      GalleryItem(
        title: 'Live overlays',
        note: 'Tap to try the real sheet and toast.',
        builder: (context, surface) => StateWrap(
          children: [
            TBButton.secondary(
              label: 'Open sheet',
              onPressed: () => showTBSheet<void>(
                context,
                sheet: TBSheet(
                  title: 'Out of hearts',
                  ribbon: TBRibbonKind.berry,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const TBText.body('So close — try again?'),
                      const SizedBox(height: TBSpacing.s16),
                      TBButton.primary(
                        label: 'Retry',
                        onPressed: () => Navigator.of(context).pop(),
                        expand: true,
                      ),
                    ],
                  ),
                ),
              ),
            ),
            TBButton.tertiary(
              label: 'Show toast',
              onPressed: () => showTBToast(context, 'Nice flow!'),
            ),
          ],
        ),
      ),
    ]);
  }
}

// --- HUD ----------------------------------------------------------------------

class _Hud extends StatelessWidget {
  const new();

  @override
  Widget build(BuildContext context) {
    const chapter = ChapterTheme.mistyGarden;
    return _column([
      GalleryItem(
        title: 'TBPill',
        builder: (context, surface) => StateWrap(
          children: [
            StateLabel(
              'hearts',
              surface: surface,
              child: const TBPill(icon: TBIconId.heart, value: '5/5'),
            ),
            StateLabel(
              'coins + add',
              surface: surface,
              child: TBPill(icon: TBIconId.coin, value: '1,240', onAdd: () {}),
            ),
            StateLabel(
              'add pressed',
              surface: surface,
              child: TBPill(
                icon: TBIconId.coin,
                value: '85',
                onAdd: () {},
                forcePressedAdd: true,
              ),
            ),
          ],
        ),
      ),
      GalleryItem(
        title: 'TBIconButton',
        builder: (context, surface) => StateWrap(
          children: [
            StateLabel(
              'idle',
              surface: surface,
              child: TBIconButton(
                icon: TBIconId.undo,
                onPressed: () {},
                semanticLabel: 'Undo',
              ),
            ),
            StateLabel(
              'badge',
              surface: surface,
              child: TBIconButton(
                icon: TBIconId.hint,
                onPressed: () {},
                semanticLabel: 'Hint',
                badge: '2',
              ),
            ),
            StateLabel(
              'price',
              surface: surface,
              child: TBIconButton(
                icon: TBIconId.undo,
                onPressed: () {},
                semanticLabel: 'Undo',
                badge: '30',
              ),
            ),
            StateLabel(
              'pressed',
              surface: surface,
              child: TBIconButton(
                icon: TBIconId.grid,
                onPressed: () {},
                semanticLabel: 'Grid',
                forcePressed: true,
              ),
            ),
            StateLabel(
              'selected',
              surface: surface,
              child: TBIconButton(
                icon: TBIconId.grid,
                onPressed: () {},
                semanticLabel: 'Grid',
                selected: true,
              ),
            ),
            StateLabel(
              'focus',
              surface: surface,
              child: TBIconButton(
                icon: TBIconId.fit,
                onPressed: () {},
                semanticLabel: 'Fit',
                forceFocused: true,
              ),
            ),
            const StateLabel(
              'disabled',
              child: TBIconButton(
                icon: TBIconId.fit,
                onPressed: null,
                semanticLabel: 'Fit',
              ),
            ),
          ],
        ),
      ),
      GalleryItem(
        title: 'TBFlowMeter',
        builder: (context, surface) => Column(
          children: [
            StateLabel(
              'empty',
              surface: surface,
              child: TBFlowMeter(fill: 0, color: chapter.arrowColors[0]),
            ),
            const SizedBox(height: TBSpacing.s12),
            StateLabel(
              'x3',
              surface: surface,
              child: TBFlowMeter(
                fill: 0.5,
                color: chapter.arrowColors[2],
                multiplier: 3,
              ),
            ),
            const SizedBox(height: TBSpacing.s12),
            StateLabel(
              'x5',
              surface: surface,
              child: TBFlowMeter(
                fill: 1,
                color: chapter.arrowColors[3],
                multiplier: 5,
              ),
            ),
          ],
        ),
      ),
      GalleryItem(
        title: 'TBProgressBar',
        builder: (context, surface) => const Column(
          children: [
            TBProgressBar(value: 0.08, shimmer: false),
            SizedBox(height: TBSpacing.s12),
            TBProgressBar(value: 0.55, shimmer: false),
            SizedBox(height: TBSpacing.s12),
            TBProgressBar(value: 1, shimmer: false),
          ],
        ),
      ),
      GalleryItem(
        title: 'TBStarRow',
        builder: (context, surface) => StateWrap(
          children: [
            for (final n in const [0, 1, 2, 3])
              StateLabel(
                '$n of 3',
                surface: surface,
                child: TBStarRow(
                  filled: n,
                  animate: false,
                  starSize: TBSizes.iconButton - TBSpacing.s12,
                ),
              ),
          ],
        ),
      ),
    ]);
  }
}

// --- Controls -----------------------------------------------------------------

class _Controls extends StatefulWidget {
  const new();

  @override
  State<_Controls> createState() => _ControlsState();
}

class _ControlsState extends State<_Controls> {
  bool _on = true;
  double _slider = 0.4;
  int _tab = 0;

  @override
  Widget build(BuildContext context) {
    return _column([
      GalleryItem(
        title: 'TBToggle',
        builder: (context, surface) => StateWrap(
          children: [
            StateLabel(
              'on (tap me)',
              surface: surface,
              child: TBToggle(
                value: _on,
                onChanged: (v) => setState(() => _on = v),
                semanticLabel: 'Haptics',
              ),
            ),
            StateLabel(
              'off',
              surface: surface,
              child: TBToggle(
                value: false,
                onChanged: (_) {},
                semanticLabel: 'Music',
              ),
            ),
            StateLabel(
              'focus',
              surface: surface,
              child: TBToggle(
                value: true,
                onChanged: (_) {},
                semanticLabel: 'Sound',
                forceFocused: true,
              ),
            ),
            const StateLabel(
              'disabled',
              child: TBToggle(
                value: true,
                onChanged: null,
                semanticLabel: 'Locked',
              ),
            ),
          ],
        ),
      ),
      GalleryItem(
        title: 'TBSlider',
        note: 'Ticks every 10% (haptic).',
        builder: (context, surface) => Column(
          children: [
            TBSlider(
              value: _slider,
              onChanged: (v) => setState(() => _slider = v),
              semanticLabel: 'Music volume',
            ),
            const SizedBox(height: TBSpacing.s8),
            const TBSlider(
              value: 1,
              onChanged: null,
              semanticLabel: 'Locked volume',
            ),
          ],
        ),
      ),
      GalleryItem(
        title: 'TBTabBar',
        builder: (context, surface) => TBTabBar(
          tabs: const [
            TBTabItem(icon: TBIconId.shop, label: 'Shop'),
            TBTabItem(icon: TBIconId.collection, label: 'Collection'),
            TBTabItem(icon: TBIconId.quests, label: 'Quests'),
          ],
          selectedIndex: _tab,
          onSelected: (i) => setState(() => _tab = i),
        ),
      ),
    ]);
  }
}

// --- Chapters -----------------------------------------------------------------

class _Chapters extends StatelessWidget {
  const new();

  @override
  Widget build(BuildContext context) {
    return _column([
      GalleryItem(
        title: 'TBChapterCard',
        note: 'Scenes are placeholders. Tilt 4° relaxes to 0 when focused.',
        builder: (context, surface) => SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              StateLabel(
                'tilted',
                surface: surface,
                child: const TBChapterCard(
                  chapter: ChapterTheme.mistyGarden,
                  restoration: 0.42,
                ),
              ),
              const SizedBox(width: TBSpacing.s24),
              StateLabel(
                'focused',
                surface: surface,
                child: const TBChapterCard(
                  chapter: ChapterTheme.clockworkTown,
                  restoration: 0.9,
                  focused: true,
                ),
              ),
              const SizedBox(width: TBSpacing.s24),
              StateLabel(
                'locked',
                surface: surface,
                child: const TBChapterCard(
                  chapter: ChapterTheme.lanternBazaar,
                  restoration: 0,
                  locked: true,
                ),
              ),
              const SizedBox(width: TBSpacing.s24),
              StateLabel(
                'dark chapter',
                surface: surface,
                child: const TBChapterCard(
                  chapter: ChapterTheme.starlightObservatory,
                  restoration: 0.15,
                ),
              ),
            ],
          ),
        ),
      ),
    ]);
  }
}

// --- Icons --------------------------------------------------------------------

class _Icons extends StatelessWidget {
  const new();

  @override
  Widget build(BuildContext context) {
    return _column([
      GalleryItem(
        title: 'Icons (placeholder)',
        note: "Code-painted 3-tone stand-ins for the 3D artist's set.",
        builder: (context, surface) => StateWrap(
          children: [
            for (final id in TBIconId.values)
              StateLabel(
                id.assetName,
                surface: surface,
                child: TBIcon(id, size: TBSizes.iconButton),
              ),
          ],
        ),
      ),
    ]);
  }
}

// --- Materials ----------------------------------------------------------------

class _Materials extends StatelessWidget {
  const new();

  static const _cells = [(0, 2), (1, 2), (2, 2), (2, 1), (3, 1), (4, 1)];
  static const _long = [
    (0, 0),
    (1, 0),
    (2, 0),
    (3, 0),
    (3, 1),
    (3, 2),
    (2, 2),
    (1, 2),
  ];

  Widget _swatch(String label, GallerySurfaceKind surface, CustomPainter p) =>
      StateLabel(
        label,
        surface: surface,
        child: SizedBox(
          width: TBSizes.chapterCardWidth / 2,
          height: TBSizes.iconButton + TBSpacing.s24,
          child: CustomPaint(painter: p),
        ),
      );

  @override
  Widget build(BuildContext context) {
    const chapter = ChapterTheme.mistyGarden;
    return _column([
      GalleryItem(
        title: 'Materials',
        note: 'Paper, wood, brass, crystal: one key light, top-left.',
        builder: (context, surface) => StateWrap(
          children: [
            _swatch('paper', surface, const PaperPainter()),
            _swatch(
              'paper recessed',
              surface,
              const PaperPainter(recessed: true),
            ),
            _swatch('brass', surface, const BrassPainter()),
            _swatch('crystal', surface, const CrystalPainter()),
          ],
        ),
      ),
      GalleryItem(
        title: 'Enamel tube (arrow)',
        note: '5 passes: shadow, rim, body, light band, specular. Head + nock.',
        builder: (context, surface) => TBTray(
          chapter: chapter,
          child: SizedBox(
            height: TBSizes.chapterCardWidth,
            child: Column(
              children: [
                for (var i = 0; i < 2; i++)
                  Expanded(
                    child: CustomPaint(
                      size: Size.infinite,
                      painter: EnamelTubePainter(
                        cells: i == 0 ? _cells : _long,
                        color: chapter.arrowColors[i * 2],
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
      GalleryItem(
        title: 'Board tray',
        note: 'Felt in the chapter tray colour, inner shadow, wooden rim.',
        builder: (context, surface) => StateWrap(
          children: [
            for (final c in const [
              ChapterTheme.mistyGarden,
              ChapterTheme.lanternBazaar,
            ])
              StateLabel(
                c.name,
                surface: surface,
                child: TBTray(
                  chapter: c,
                  child: const SizedBox.square(
                    dimension: TBSizes.iconButton * 1.5,
                  ),
                ),
              ),
          ],
        ),
      ),
      GalleryItem(
        title: 'Wood shelf',
        builder: (context, surface) => SizedBox(
          height: TBSizes.iconButton,
          width: double.infinity,
          child: CustomPaint(painter: _ShelfSample()),
        ),
      ),
    ]);
  }
}

class _ShelfSample extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) => Wood.paint(canvas, size);

  @override
  bool shouldRepaint(_ShelfSample old) => false;
}
