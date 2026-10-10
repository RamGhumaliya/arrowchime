import 'package:arrowchime/app/theme/chapter_theme.dart';
import 'package:arrowchime/app/theme/tokens.dart';
import 'package:arrowchime/core/ui/components/tb_panel.dart';
import 'package:arrowchime/core/ui/components/tb_text.dart';
import 'package:flutter/widgets.dart';

/// The three surfaces every component is shown on (`docs/10` §11).
enum GallerySurfaceKind { cream, ink, chapter }

/// Debug-only helpers for the Design Gallery. Strings here are developer
/// labels, not player copy, so they are not in the ARB files.
class GallerySurface extends StatelessWidget {
  const new({required this.kind, required this.child, super.key});

  final GallerySurfaceKind kind;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    const pad = EdgeInsets.all(TBSpacing.s16);
    return switch (kind) {
      GallerySurfaceKind.cream => TBPanel(
        child: SizedBox(width: double.infinity, child: child),
      ),
      GallerySurfaceKind.ink => DecoratedBox(
        decoration: const BoxDecoration(
          color: TBColors.ink900,
          borderRadius: TBRadius.br32,
        ),
        child: Padding(
          padding: pad,
          child: SizedBox(width: double.infinity, child: child),
        ),
      ),
      GallerySurfaceKind.chapter => DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: TBRadius.br32,
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              ChapterTheme.mistyGarden.skyTop,
              ChapterTheme.mistyGarden.skyBottom,
            ],
          ),
        ),
        child: Padding(
          padding: pad,
          child: SizedBox(width: double.infinity, child: child),
        ),
      ),
    };
  }
}

/// A titled block showing [builder]'s content on all three surfaces.
class GalleryItem extends StatelessWidget {
  const new({required this.title, required this.builder, this.note, super.key});

  final String title;
  final String? note;

  /// Builds the states for the current surface.
  final Widget Function(BuildContext context, GallerySurfaceKind surface)
  builder;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: TBSpacing.s24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TBText.title(title),
          if (note != null)
            Padding(
              padding: const EdgeInsets.only(top: TBSpacing.s4),
              child: TBText.caption(note!, color: TBColors.cream300),
            ),
          const SizedBox(height: TBSpacing.s12),
          for (final kind in GallerySurfaceKind.values) ...[
            GallerySurface(kind: kind, child: builder(context, kind)),
            const SizedBox(height: TBSpacing.s12),
          ],
        ],
      ),
    );
  }
}

/// A labelled state ("pressed", "disabled", …) under or beside a component.
class StateLabel extends StatelessWidget {
  const new(this.label, {required this.child, this.surface, super.key});

  final String label;
  final Widget child;
  final GallerySurfaceKind? surface;

  @override
  Widget build(BuildContext context) {
    final dark = surface != GallerySurfaceKind.cream;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        child,
        const SizedBox(height: TBSpacing.s4),
        TBText.caption(
          label,
          color: dark ? TBColors.cream100 : TBColors.ink500,
        ),
      ],
    );
  }
}

/// Wraps states with spacing.
class StateWrap extends StatelessWidget {
  const new({required this.children, super.key});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) => Wrap(
    spacing: TBSpacing.s24,
    runSpacing: TBSpacing.s16,
    crossAxisAlignment: WrapCrossAlignment.end,
    children: children,
  );
}
