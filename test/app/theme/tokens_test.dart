import 'package:arrowchime/app/theme/chapter_theme.dart';
import 'package:arrowchime/app/theme/tokens.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('brand colours match docs/10 §3.1', () {
    expect(TBColors.ink900.toARGB32(), 0xFF121A2B);
    expect(TBColors.tangerine.toARGB32(), 0xFFFF8A1F);
    expect(TBColors.butterLip.toARGB32(), 0xFFC9952A);
    expect(TBColors.sky.toARGB32(), 0xFF6EC6FF);
  });

  test('spacing is a 4 dp scale', () {
    const all = [
      TBSpacing.s4,
      TBSpacing.s8,
      TBSpacing.s12,
      TBSpacing.s16,
      TBSpacing.s24,
      TBSpacing.s32,
      TBSpacing.s48,
      TBSpacing.s64,
    ];
    for (final v in all) {
      expect(v % 4, 0);
    }
  });

  test('every elevation has a drop and a contact shadow', () {
    for (final e in [TBElevation.e1, TBElevation.e2, TBElevation.e3]) {
      expect(e, hasLength(2));
    }
    expect(TBElevation.e3.first.offset, const Offset(4, 18));
  });

  test('release curve overshoots then settles', () {
    expect(TBMotion.releaseCurve.transform(0), 0);
    expect(TBMotion.releaseCurve.transform(1), closeTo(1, 1e-9));
    expect(TBMotion.releaseCurve.transform(0.7), greaterThan(1));
  });

  test('five chapters with six arrow colours each', () {
    expect(ChapterTheme.all, hasLength(5));
    for (final c in ChapterTheme.all) {
      expect(c.arrowColors, hasLength(6));
    }
  });
}
