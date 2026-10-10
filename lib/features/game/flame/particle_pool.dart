import 'dart:math' as math;
import 'dart:ui';

import 'package:arrowchime/app/theme/tokens.dart';
import 'package:flame/components.dart';

/// A fixed pool of at most [TBGameMotion.maxParticles] confetti / spark dots.
/// Nothing is allocated while playing: slots are reused, oldest first.
///
/// Particle motion is cosmetic, so it uses a plain [math.Random] (the level
/// generator's deterministic PRNG is not involved here).
class ParticlePool extends Component {
  new({int? seed}) : _random = math.Random(seed);

  static const int capacity = TBGameMotion.maxParticles;

  final math.Random _random;
  final List<double> _x = List.filled(capacity, 0);
  final List<double> _y = List.filled(capacity, 0);
  final List<double> _vx = List.filled(capacity, 0);
  final List<double> _vy = List.filled(capacity, 0);
  final List<double> _life = List.filled(capacity, 0);
  final List<double> _maxLife = List.filled(capacity, 1);
  final List<double> _size = List.filled(capacity, 1);
  final List<Color> _color = List.filled(capacity, TBColors.ink900);
  final Paint _paint = Paint();
  int _next = 0;

  /// Gravity in world units per second squared.
  double gravity = 260;

  /// How many particles are alive.
  int get alive {
    var n = 0;
    for (final l in _life) {
      if (l > 0) n++;
    }
    return n;
  }

  /// Sprays [count] dots of [color] from ([x], [y]).
  void burst(
    double x,
    double y,
    Color color, {
    int count = 8,
    double speed = 90,
    double size = 3,
    double life = 0.5,
  }) {
    for (var i = 0; i < count; i++) {
      final angle = _random.nextDouble() * math.pi * 2;
      final v = speed * (0.4 + _random.nextDouble() * 0.6);
      _spawn(
        x,
        y,
        math.cos(angle) * v,
        math.sin(angle) * v,
        color,
        size * (0.6 + _random.nextDouble() * 0.8),
        life * (0.7 + _random.nextDouble() * 0.6),
      );
    }
  }

  /// Confetti raining from the top edge of a [width] wide area.
  void confetti(
    double width,
    double top,
    List<Color> colors, {
    int count = 60,
  }) {
    for (var i = 0; i < count; i++) {
      _spawn(
        _random.nextDouble() * width,
        top - _random.nextDouble() * 40,
        (_random.nextDouble() - 0.5) * 120,
        40 + _random.nextDouble() * 120,
        colors[_random.nextInt(colors.length)],
        3 + _random.nextDouble() * 3,
        1.2 + _random.nextDouble() * 0.8,
      );
    }
  }

  void _spawn(
    double x,
    double y,
    double vx,
    double vy,
    Color color,
    double size,
    double life,
  ) {
    final i = _next;
    _next = (_next + 1) % capacity;
    _x[i] = x;
    _y[i] = y;
    _vx[i] = vx;
    _vy[i] = vy;
    _color[i] = color;
    _size[i] = size;
    _life[i] = life;
    _maxLife[i] = life;
  }

  /// Removes every particle (new attempt).
  void clear() {
    for (var i = 0; i < capacity; i++) {
      _life[i] = 0;
    }
  }

  @override
  void update(double dt) {
    for (var i = 0; i < capacity; i++) {
      if (_life[i] <= 0) continue;
      _life[i] -= dt;
      _vy[i] += gravity * dt;
      _x[i] += _vx[i] * dt;
      _y[i] += _vy[i] * dt;
    }
  }

  @override
  void render(Canvas canvas) {
    for (var i = 0; i < capacity; i++) {
      final life = _life[i];
      if (life <= 0) continue;
      final fade = (life / _maxLife[i]).clamp(0.0, 1.0);
      _paint.color = _color[i].withValues(alpha: fade);
      canvas.drawCircle(Offset(_x[i], _y[i]), _size[i], _paint);
    }
  }
}
