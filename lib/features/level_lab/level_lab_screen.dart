// The Level Lab is a developer tool (docs/10 B1 exception): Material widgets
// and plain English are fine here. It is only reachable in debug builds.
import 'dart:async';

import 'package:arrowchime/app/router.dart';
import 'package:arrowchime/app/theme/chapter_theme.dart';
import 'package:arrowchime/core/level/generator/chapter_plan.dart';
import 'package:arrowchime/core/level/generator/mechanic_tutorials.dart';
import 'package:arrowchime/core/level/models/level.dart';
import 'package:arrowchime/features/game/model/board_geometry.dart';
import 'package:arrowchime/features/game/model/view_transform.dart';
import 'package:arrowchime/features/game/preview/board_preview.dart';
import 'package:arrowchime/features/game/state/level_ref.dart';
import 'package:arrowchime/features/game/state/level_repository.dart';
import 'package:arrowchime/features/level_lab/level_lab_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// Browse the chapter packs, look at any level with its solution order,
/// difficulty and depth, play it, regenerate it, mark it approved, run the
/// checker and export the pack (`docs/04` §7, Phase 7).
class LevelLabScreen extends ConsumerStatefulWidget {
  const new({super.key});

  @override
  ConsumerState<LevelLabScreen> createState() => _LevelLabScreenState();
}

class _LevelLabScreenState extends ConsumerState<LevelLabScreen> {
  bool _showSolution = true;
  bool _showFps = false;

  @override
  Widget build(BuildContext context) {
    final lab = ref.watch(levelLabProvider);
    final ctl = ref.read(levelLabProvider.notifier);
    return Theme(
      data: ThemeData.dark(useMaterial3: true),
      child: ScaffoldMessenger(
        child: Scaffold(
          appBar: AppBar(
            title: const Text('Level Lab'),
            leading: BackButton(
              onPressed: () =>
                  context.canPop() ? context.pop() : context.go('/'),
            ),
            actions: [
              DropdownButton<int>(
                value: lab.chapter,
                items: [
                  for (var c = 1; c <= 5; c++)
                    DropdownMenuItem(value: c, child: Text('Chapter $c')),
                ],
                onChanged: (c) => ctl.select(chapter: c, index: 1),
              ),
              const SizedBox(width: 12),
            ],
          ),
          body: FutureBuilder<List<Level>>(
            key: ValueKey((lab.chapter, lab.edited.length, lab.message)),
            future: ctl.pack(lab.chapter),
            builder: (context, snapshot) {
              final levels = snapshot.data;
              if (levels == null) {
                return const Center(child: CircularProgressIndicator());
              }
              return LayoutBuilder(
                builder: (context, c) {
                  final wide = c.maxWidth > 760;
                  final list = _LevelList(levels: levels, lab: lab);
                  final detail = _Detail(
                    level: levels[lab.index - 1],
                    lab: lab,
                    showSolution: _showSolution,
                    showFps: _showFps,
                    onSolution: (v) => setState(() => _showSolution = v),
                    onFps: (v) => setState(() => _showFps = v),
                  );
                  return wide
                      ? Row(
                          children: [
                            SizedBox(width: 300, child: list),
                            const VerticalDivider(width: 1),
                            Expanded(child: detail),
                          ],
                        )
                      : Column(
                          children: [
                            SizedBox(height: 180, child: list),
                            const Divider(height: 1),
                            Expanded(child: detail),
                          ],
                        );
                },
              );
            },
          ),
        ),
      ),
    );
  }
}

class _LevelList extends ConsumerWidget {
  const new({required this.levels, required this.lab});

  final List<Level> levels;
  final LabState lab;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListView.builder(
      itemCount: levels.length,
      itemBuilder: (context, i) {
        final l = levels[i];
        final target = ChapterPlan.targetScore(lab.chapter, i + 1);
        final score = l.meta.difficulty ?? 0;
        final approved = l.meta.approved ?? false;
        final edited = lab.edited.containsKey(l.id);
        return ListTile(
          dense: true,
          selected: lab.index == i + 1,
          title: Text(
            '${i + 1}  ${l.width}×${l.height}  ${l.arrows.length} arrows'
            '${edited ? '  •edited' : ''}',
          ),
          subtitle: Text(
            'score ${score.toStringAsFixed(1)} / target '
            '${target.toStringAsFixed(1)}  ·  ${_mechanics(l)}',
          ),
          trailing: approved
              ? const Icon(Icons.check_circle, color: Colors.greenAccent)
              : null,
          onTap: () => ref.read(levelLabProvider.notifier).select(index: i + 1),
        );
      },
    );
  }

  static String _mechanics(Level l) {
    final m = MechanicTutorials.mechanicsOf(l);
    return m.isEmpty ? 'plain' : m.map((e) => e.name).join('+');
  }
}

class _Detail extends ConsumerWidget {
  const new({
    required this.level,
    required this.lab,
    required this.showSolution,
    required this.showFps,
    required this.onSolution,
    required this.onFps,
  });

  final Level level;
  final LabState lab;
  final bool showSolution;
  final bool showFps;
  final ValueChanged<bool> onSolution;
  final ValueChanged<bool> onFps;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ctl = ref.read(levelLabProvider.notifier);
    final theme = ChapterTheme.byId(lab.chapter);
    final target = ChapterPlan.targetScore(lab.chapter, lab.index);
    return ListView(
      padding: const EdgeInsets.all(12),
      children: [
        Text(
          '${level.id}  ·  seed ${level.meta.seed}  ·  '
          '${level.meta.generatorVersion}',
        ),
        Text(
          'difficulty ${level.meta.difficulty?.toStringAsFixed(1)} '
          '(target ${target.toStringAsFixed(1)})  ·  depth ${level.meta.depth}'
          '  ·  melody ${level.meta.melody}',
        ),
        const SizedBox(height: 8),
        Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 440),
            child: AspectRatio(
              aspectRatio: 1,
              child: Stack(
                children: [
                  BoardPreview(
                    key: ValueKey('${level.id}${level.meta.seed}$showFps'),
                    level: level,
                    theme: theme,
                    showFps: showFps,
                  ),
                  if (showSolution)
                    Positioned.fill(
                      child: IgnorePointer(
                        child: CustomPaint(painter: _SolutionPainter(level)),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 4,
          children: [
            FilledButton(
              onPressed: () => unawaited(_play(context)),
              child: const Text('Play'),
            ),
            OutlinedButton(
              onPressed: () => unawaited(ctl.regenerate()),
              child: const Text('Regenerate'),
            ),
            OutlinedButton(
              onPressed: () => unawaited(ctl.toggleApproved()),
              child: Text(
                (level.meta.approved ?? false) ? 'Unapprove' : 'Approve',
              ),
            ),
            OutlinedButton(
              onPressed: () => unawaited(ctl.check()),
              child: const Text('Check'),
            ),
            OutlinedButton(
              onPressed: () => unawaited(_export(context, ctl)),
              child: const Text('Export pack'),
            ),
          ],
        ),
        SwitchListTile(
          dense: true,
          title: const Text('Solution order'),
          value: showSolution,
          onChanged: onSolution,
        ),
        SwitchListTile(
          dense: true,
          title: const Text('FPS overlay'),
          value: showFps,
          onChanged: onFps,
        ),
        if (lab.message != null) Text(lab.message!),
        const SizedBox(height: 8),
        Text('solution: ${level.meta.solution.join(' ')}'),
      ],
    );
  }

  /// Plays the level in the real game screen (counts as a real play in the
  /// debug save). Edited levels are played from the lab's copy.
  Future<void> _play(BuildContext context) async {
    final id = LevelRef(lab.chapter, lab.index);
    ProviderScope.containerOf(context)
        .read(levelOverridesProvider.notifier)
        .set(id, level);
    await context.push<void>(AppRoutes.levelPath(id.chapterSlug, id.index));
  }

  Future<void> _export(BuildContext context, LevelLab ctl) async {
    final text = await ctl.export();
    await Clipboard.setData(ClipboardData(text: text));
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Pack JSON (${text.length} chars) copied')),
      );
    }
  }
}

/// Numbers the head of each arrow with its place in the stored solution.
class _SolutionPainter extends CustomPainter {
  const new(this.level);

  final Level level;

  @override
  void paint(Canvas canvas, Size size) {
    final geometry = BoardGeometry(level);
    final view = ViewTransform(worldSize: geometry.worldSize, viewport: size);
    final order = {
      for (var i = 0; i < level.meta.solution.length; i++)
        level.meta.solution[i]: i + 1,
    };
    for (final a in level.arrows) {
      final n = order[a.id];
      if (n == null) continue;
      final at = view.toScreen(geometry.center(a.head));
      final tp = TextPainter(
        text: TextSpan(
          text: '$n',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 11,
            fontWeight: FontWeight.bold,
            backgroundColor: Color(0xAA000000),
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(canvas, at - Offset(tp.width / 2, tp.height / 2));
    }
  }

  @override
  bool shouldRepaint(_SolutionPainter old) => old.level != level;
}
