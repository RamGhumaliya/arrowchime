import 'package:arrowchime/app/router.dart';
import 'package:arrowchime/app/theme/tokens.dart';
import 'package:arrowchime/core/audio/feedback_settings.dart';
import 'package:arrowchime/core/ui/components/tb_panel.dart';
import 'package:arrowchime/core/ui/components/tb_sheet.dart';
import 'package:arrowchime/core/ui/components/tb_slider.dart';
import 'package:arrowchime/core/ui/components/tb_tab_bar.dart';
import 'package:arrowchime/core/ui/components/tb_text.dart';
import 'package:arrowchime/core/ui/components/tb_toast.dart';
import 'package:arrowchime/core/ui/components/tb_toggle.dart';
import 'package:arrowchime/core/ui/icons/tb_icon_id.dart';
import 'package:arrowchime/core/ui/support/tb_pressable.dart';
import 'package:arrowchime/features/game/state/game_settings.dart';
import 'package:arrowchime/features/shared/screen_frame.dart';
import 'package:arrowchime/l10n/gen/app_localizations.dart';
import 'package:flutter/foundation.dart' show kReleaseMode;
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// Settings (`docs/10` §7): Sound (music, effects, haptics), Play (left-handed,
/// Relaxed mode, Reduce motion, colour-blind palette) and Account & info. No
/// primary button: every control acts at once.
class SettingsScreen extends ConsumerWidget {
  const new({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final fx = ref.watch(feedbackSettingsControllerProvider);
    final fxCtl = ref.read(feedbackSettingsControllerProvider.notifier);
    final play = ref.watch(gameSettingsControllerProvider);
    final playCtl = ref.read(gameSettingsControllerProvider.notifier);

    return ScreenFrame(
      title: l10n.settingsTitle,
      onBack: () =>
          context.canPop() ? context.pop() : context.go(AppRoutes.home),
      child: Column(
        children: [
          _Group(
            title: l10n.settingsSound,
            children: [
              _SliderRow(
                label: l10n.settingsMusic,
                on: fx.musicOn,
                value: fx.musicVolume,
                onToggle: (v) => fxCtl.setMusicOn(value: v),
                onSlide: fxCtl.setMusicVolume,
              ),
              _SliderRow(
                label: l10n.settingsSoundFx,
                on: fx.soundOn,
                value: fx.soundVolume,
                onToggle: (v) => fxCtl.setSoundOn(value: v),
                onSlide: fxCtl.setSoundVolume,
              ),
              _ToggleRow(
                label: l10n.settingsHaptics,
                value: fx.hapticsOn,
                onChanged: (v) => fxCtl.setHapticsOn(value: v),
              ),
            ],
          ),
          const SizedBox(height: TBSpacing.s16),
          _Group(
            title: l10n.settingsPlay,
            children: [
              _ToggleRow(
                label: l10n.settingsLeftHanded,
                value: play.leftHanded,
                onChanged: (v) => playCtl.setLeftHanded(value: v),
              ),
              _ToggleRow(
                label: l10n.settingsRelaxed,
                note: l10n.settingsRelaxedNote,
                value: play.relaxed,
                onChanged: (v) => playCtl.setRelaxed(value: v),
              ),
              _ToggleRow(
                label: l10n.settingsReduceMotion,
                note: play.reduceMotion == 'on'
                    ? l10n.settingsReduceOn
                    : l10n.settingsReduceSystem,
                value: play.reduceMotion == 'on',
                onChanged: (v) => playCtl.setReduceMotion(v ? 'on' : 'system'),
              ),
              _Segmented(
                label: l10n.settingsColorBlind,
                labels: [l10n.cbOff, l10n.cbDeutan, l10n.cbTritan],
                selected: const [
                  'off',
                  'deutan',
                  'tritan',
                ].indexOf(play.colorBlind),
                onSelected: (i) =>
                    playCtl.setColorBlind(const ['off', 'deutan', 'tritan'][i]),
              ),
            ],
          ),
          const SizedBox(height: TBSpacing.s16),
          _Group(
            title: l10n.settingsAccount,
            children: [
              _InfoRow(
                label: l10n.settingsLanguage,
                value: l10n.settingsLanguageValue,
              ),
              _ActionRow(
                label: l10n.settingsAccountRow,
                onTap: () => showTBToast(context, l10n.settingsComingSoon),
              ),
              _ActionRow(
                label: l10n.settingsPrivacy,
                onTap: () => showTBToast(context, l10n.settingsComingSoon),
              ),
              _ActionRow(
                label: l10n.settingsRestore,
                onTap: () => showTBToast(context, l10n.settingsComingSoon),
              ),
              _ActionRow(
                label: l10n.settingsCredits,
                onTap: () => showTBSheet<void>(
                  context,
                  sheet: TBSheet(
                    title: l10n.settingsCredits,
                    child: TBText.body(
                      l10n.settingsCreditsBody,
                      color: TBColors.ink900,
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ),
            ],
          ),
          if (!kReleaseMode) ...[
            const SizedBox(height: TBSpacing.s16),
            _Group(
              title: l10n.settingsDeveloper,
              children: [
                _ActionRow(
                  label: l10n.routeLevelLab,
                  onTap: () => context.push(AppRoutes.levelLab),
                ),
                _ActionRow(
                  label: l10n.routeDesignGallery,
                  onTap: () => context.push(AppRoutes.designGallery),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _Group extends StatelessWidget {
  const new({required this.title, required this.children});

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return TBPanel.recessed(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Semantics(header: true, child: TBText.title(title)),
          for (final c in children) ...[
            const SizedBox(height: TBSpacing.s12),
            c,
          ],
        ],
      ),
    );
  }
}

class _ToggleRow extends StatelessWidget {
  const new({
    required this.label,
    required this.value,
    required this.onChanged,
    this.note,
  });

  final String label;
  final String? note;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(minHeight: TBSizes.minTapTarget),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TBText.body(label, color: TBColors.ink900),
                if (note != null) TBText.caption(note!, color: TBColors.ink700),
              ],
            ),
          ),
          TBToggle(value: value, onChanged: onChanged, semanticLabel: label),
        ],
      ),
    );
  }
}

class _SliderRow extends StatelessWidget {
  const new({
    required this.label,
    required this.on,
    required this.value,
    required this.onToggle,
    required this.onSlide,
  });

  final String label;
  final bool on;
  final double value;
  final ValueChanged<bool> onToggle;
  final ValueChanged<double> onSlide;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _ToggleRow(label: label, value: on, onChanged: onToggle),
        TBSlider(
          value: value,
          onChanged: on ? onSlide : null,
          semanticLabel: label,
        ),
      ],
    );
  }
}

class _Segmented extends StatelessWidget {
  const new({
    required this.label,
    required this.labels,
    required this.selected,
    required this.onSelected,
  });

  final String label;
  final List<String> labels;
  final int selected;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TBText.body(label, color: TBColors.ink900),
        const SizedBox(height: TBSpacing.s8),
        TBTabBar(
          tabs: [
            for (final l in labels)
              TBTabItem(icon: TBIconId.collection, label: l),
          ],
          selectedIndex: selected < 0 ? 0 : selected,
          onSelected: onSelected,
        ),
      ],
    );
  }
}

class _InfoRow extends StatelessWidget {
  const new({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(minHeight: TBSizes.minTapTarget),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          TBText.body(label, color: TBColors.ink900),
          TBText.body(value, color: TBColors.ink700),
        ],
      ),
    );
  }
}

class _ActionRow extends StatelessWidget {
  const new({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return TBPressable(
      onPressed: onTap,
      semanticLabel: label,
      builder: (context, press) => ConstrainedBox(
        constraints: const BoxConstraints(minHeight: TBSizes.minTapTarget),
        child: Align(
          alignment: Alignment.centerLeft,
          child: TBText.body(
            label,
            color: press.press > 0 ? TBColors.tangerineLip : TBColors.ink900,
          ),
        ),
      ),
    );
  }
}
