import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// Automatic design checks (`docs/10` §1 BANNED list, `docs/09` D1/D2): scans
/// the source of the design system and the player-facing features.
void main() {
  // The Level Lab is a debug-only developer tool: Material widgets are allowed
  // there (docs/10 B1 exception), so it is not scanned.
  bool notLab(File f) =>
      !f.path.replaceAll(String.fromCharCode(92), '/').contains('/level_lab/');

  List<File> dartFiles(String dir) =>
      Directory(dir)
          .listSync(recursive: true)
          .whereType<File>()
          .where((f) => f.path.endsWith('.dart'))
          .where(notLab)
          .where((f) => !f.path.endsWith('.freezed.dart'))
          .where((f) => !f.path.endsWith('.g.dart'))
          .toList();

  final uiFiles = [
    ...dartFiles('lib/core/ui'),
    ...dartFiles('lib/features'),
    ...dartFiles('lib/app'),
  ];
  // Components and features: tokens only (D2). Painters hold the recipes and
  // `lib/app/theme` defines the tokens, so they may use literals.
  final tokenOnly = [
    ...dartFiles('lib/core/ui/components'),
    ...dartFiles('lib/features'),
  ];

  String read(File f) => f.readAsStringSync();
  String rel(File f) => f.path.replaceAll(String.fromCharCode(92), '/');

  void expectNone(
    Iterable<File> files,
    RegExp pattern,
    String why, {
    bool Function(File)? skip,
  }) {
    final hits = [
      for (final f in files)
        if (!(skip?.call(f) ?? false) && pattern.hasMatch(read(f))) rel(f),
    ];
    expect(hits, isEmpty, reason: why);
  }

  test('sources exist', () {
    expect(uiFiles.length, greaterThan(35));
    expect(tokenOnly.length, greaterThan(15));
  });

  group('B1: no unstyled Material / Cupertino in player UI', () {
    test('no Material or Cupertino imports', () {
      expectNone(
        uiFiles,
        RegExp(r'package:flutter/(material|cupertino)\.dart'),
        'B1: player UI never imports Material or Cupertino',
      );
    });

    test('no stock Material widgets by name', () {
      expectNone(
        uiFiles,
        RegExp(
          r'\b(ElevatedButton|FilledButton|OutlinedButton|TextButton|'
          'FloatingActionButton|AppBar|BottomNavigationBar|NavigationBar|'
          'Card|Chip|ListTile|SnackBar|AlertDialog|Switch|Checkbox|Radio|'
          r'Slider|Scaffold|Material|InkWell|Divider)\(',
        ),
        'B1: use TBButton, TBPanel, TBToggle, TBSlider, ...',
      );
    });
  });

  group('B4: no Material icons and no emoji as UI icons', () {
    test('no Icons.* / CupertinoIcons / IconData', () {
      expectNone(
        uiFiles,
        RegExp(r'\bIcons\.|CupertinoIcons|\bIconData\b|\bIcon\('),
        'B4: use TBIcon',
      );
    });

    test('no emoji or pictographs in source strings', () {
      final emoji = RegExp(
        '[\u{1F300}-\u{1FAFF}\u{2600}-\u{27BF}\u{2B50}\u{2764}]',
        unicode: true,
      );
      expectNone(uiFiles, emoji, 'B4: emoji only inside the Daily share text');
    });
  });

  test('B5: only Fredoka and Nunito are named as fonts', () {
    expectNone(
      uiFiles,
      RegExp(r"fontFamily:\s*'(Roboto|Inter|Poppins|Montserrat|SF Pro|Arial)"),
      'B5: Fredoka (display) + Nunito (UI), bundled',
    );
    expectNone(
      tokenOnly,
      RegExp(r"fontFamily:\s*'"),
      'font families live in typography.dart only',
    );
  });

  group('D2: tokens only in components and features', () {
    test('no literal Color(0x...) or Colors.*', () {
      expectNone(
        tokenOnly,
        RegExp(r'Color\(\s*0x|\bColors\.'),
        'D2: use TBColors / ChapterTheme / TBShade',
      );
    });

    test('no literal Duration(...)', () {
      expectNone(
        tokenOnly,
        RegExp(r'\bDuration\('),
        'D2: use TBMotion durations',
        // `Duration(` in comments of this kind never appears; keep strict.
      );
    });

    test('no raw numeric EdgeInsets in features', () {
      expectNone(
        dartFiles('lib/features'),
        RegExp(r'EdgeInsets\.(all|symmetric|only|fromLTRB)\([^)]*\b\d'),
        'D2: use TBSpacing tokens',
      );
    });

    test('B8: no ad-hoc radii', () {
      expectNone(
        tokenOnly,
        RegExp(
          r'BorderRadius\.circular\(\s*\d|Radius\.circular\(\s*\d|'
          r'BorderRadius\.all\(',
        ),
        'B8: only r12, r20, r32, pill',
      );
    });

    test('B7: no ad-hoc shadows (the three elevations only)', () {
      expectNone(
        tokenOnly,
        RegExp(r'BoxShadow\(|Shadow\('),
        'B7: use TBElevation.e1/e2/e3',
      );
    });
  });

  group('B2 / B3: no AI-gradient or glass look', () {
    test('no BackdropFilter / ImageFilter blur (glassmorphism)', () {
      expectNone(
        uiFiles,
        RegExp(r'BackdropFilter|ImageFilter\.blur'),
        'B3: no frosted glass',
      );
    });

    test('no sweep / mesh gradients', () {
      expectNone(
        uiFiles,
        RegExp(r'SweepGradient|\.sweep\('),
        'B2: gradients must follow the light rule',
      );
    });
  });

  test('B10: no gradient text', () {
    expectNone(
      uiFiles,
      RegExp(r'foreground:\s*Paint\(\)\s*\.\.shader'),
      'B10: sticker text only',
    );
  });

  test('B16: no system dark mode in the app shell', () {
    expectNone(
      dartFiles('lib/app'),
      RegExp('darkTheme|ThemeMode|platformBrightness'),
      'B16: one designed theme per chapter',
    );
  });

  test('the light source is documented once in tokens', () {
    final tokens = File('lib/app/theme/tokens.dart').readAsStringSync();
    expect(tokens, contains('Alignment.topLeft'));
    expect(tokens, contains('elevationDegrees = 35'));
  });

  test('every TB component is exported from its own file', () {
    final names =
        Directory('lib/core/ui/components')
            .listSync()
            .whereType<File>()
            .map((f) => f.uri.pathSegments.last)
            .toList()
          ..sort();
    for (final expected in [
      'tb_button.dart',
      'tb_icon_button.dart',
      'tb_pill.dart',
      'tb_panel.dart',
      'tb_ribbon.dart',
      'tb_sheet.dart',
      'tb_toggle.dart',
      'tb_slider.dart',
      'tb_tab_bar.dart',
      'tb_star_row.dart',
      'tb_progress_bar.dart',
      'tb_toast.dart',
      'tb_chapter_card.dart',
      'tb_flow_meter.dart',
      'tb_text.dart',
      'tb_tray.dart',
    ]) {
      expect(names, contains(expected));
    }
  });
}
