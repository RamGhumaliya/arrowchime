import 'dart:ui';

import 'package:arrowchime/app/theme/tokens.dart';
import 'package:arrowchime/core/ui/painters/shade.dart';
import 'package:arrowchime/features/game/flame/particle_pool.dart';

/// The look of the particles an arrow leaves behind (`docs/03` §7 trails):
/// [none] is the plain arrow-coloured puff of the base game.
enum TrailStyle {
  none,
  sparkle,
  petals,
  snow,
  ribbons;

  static TrailStyle fromId(String id) => TrailStyle.values.firstWhere(
    (t) => t.name == id,
    orElse: () => TrailStyle.none,
  );

  ParticleShape get shape => switch (this) {
    TrailStyle.none || TrailStyle.sparkle => ParticleShape.dot,
    TrailStyle.petals => ParticleShape.petal,
    TrailStyle.snow => ParticleShape.flake,
    TrailStyle.ribbons => ParticleShape.ribbon,
  };

  /// Particles in the burst when an arrow is freed.
  int get burst => switch (this) {
    TrailStyle.none => 6,
    TrailStyle.sparkle => 10,
    TrailStyle.petals => 8,
    TrailStyle.snow => 10,
    TrailStyle.ribbons => 8,
  };

  /// Particles dropped along the flight (per emission); 0 = none.
  int get perEmit => this == TrailStyle.none ? 0 : 1;

  /// How strongly gravity pulls: snow and petals drift down slowly.
  double get fall => switch (this) {
    TrailStyle.snow => 0.12,
    TrailStyle.petals => 0.2,
    _ => 1,
  };

  /// A colour for the next particle, from the arrow's own [base].
  Color color(Color base, int i) => switch (this) {
    TrailStyle.none => base,
    TrailStyle.sparkle => i.isEven ? TBColors.butter : TBShade.white(1),
    TrailStyle.petals =>
      i.isEven ? TBColors.berry : TBShade.lighten(TBColors.berry, 0.25),
    TrailStyle.snow => TBShade.white(0.95),
    TrailStyle.ribbons => i.isEven ? base : TBShade.lighten(base, 0.2),
  };
}
