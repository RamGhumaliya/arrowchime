import 'dart:convert';

import 'package:arrowchime/core/level/generator/daily.dart';
import 'package:arrowchime/core/level/generator/gen_params.dart';
import 'package:arrowchime/core/level/generator/generator.dart';
import 'package:arrowchime/core/level/generator/masks.dart';
import 'package:arrowchime/core/level/generator/onboarding.dart';
import 'package:arrowchime/core/level/generator/pack_builder.dart';
import 'package:arrowchime/core/level/models/level.dart';
import 'package:arrowchime/core/level/prng.dart';

/// Golden determinism fixtures (`docs/04` §6, `docs/09` §3): the same seed must
/// give identical level JSON on the Dart VM, Android and iOS.
///
/// Each case builds a level from fixed inputs; its canonical JSON is hashed
/// with FNV-1a 32. Used by `test/core/level/generator/golden_test.dart` and
/// `integration_test/determinism_test.dart`. Regenerate the hashes only for a
/// deliberate generator change (bump `LevelGenerator.version`) with
/// `dart run tool/print_golden_hashes.dart`.
final Map<String, Level Function()> goldenCases = {
  'base_8x8_seed42': () => LevelGenerator.generate(
    const GenParams(width: 8, height: 8, targetFill: 0.8, lenMax: 7),
    42,
  ),
  'heart_10x10_seed7': () => LevelGenerator.generate(
    GenParams(width: 10, height: 10, mask: Masks.heart(10, 10)),
    7,
  ),
  'gates_frozen_links_10x10_seed99': () => LevelGenerator.generate(
    const GenParams(
      width: 10,
      height: 10,
      targetFill: 0.8,
      lenMax: 7,
      mix: MechanicMix(gates: 2, frozen: 2, links: 1),
    ),
    99,
  ),
  'portals_9x9_seed5': () => LevelGenerator.generate(
    const GenParams(
      width: 9,
      height: 9,
      targetFill: 0.75,
      mix: MechanicMix(portalPairs: 1),
    ),
    5,
  ),
  'rotators_8x8_seed13': () => LevelGenerator.generate(
    const GenParams(
      width: 8,
      height: 8,
      targetFill: 0.75,
      singleCellShare: 0.2,
      mix: MechanicMix(rotators: 3),
    ),
    13,
  ),
  'pack_ch1_l25': () => PackBuilder.buildLevel(1, 25, 1001).level,
  'pack_ch3_l22': () => PackBuilder.buildLevel(3, 22, 1001).level,
  'onboarding_l7': () => OnboardingLevels.build(7),
  'daily_2026_10_10': () => DailyKnot.levelFor(DateTime.utc(2026, 10, 10)),
};

/// Canonical JSON of [level] hashed with FNV-1a 32.
int levelHash(Level level) => fnv1a32(jsonEncode(level.toJson()));

/// Expected hashes (from `tool/print_golden_hashes.dart`).
const Map<String, int> goldenHashes = {
  'base_8x8_seed42': 0x4748D093,
  'heart_10x10_seed7': 0xCDFD17D9,
  'gates_frozen_links_10x10_seed99': 0xBC66DD01,
  'portals_9x9_seed5': 0x45A2199E,
  'rotators_8x8_seed13': 0x41FA23B1,
  'pack_ch1_l25': 0x3EEAAB24,
  'pack_ch3_l22': 0xC9370D9A,
  'onboarding_l7': 0xB2BB014D,
  'daily_2026_10_10': 0x3D82768A,
};
