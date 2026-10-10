import 'dart:math' as math;
import 'dart:typed_data';

import 'package:arrowchime/core/level/prng.dart';

/// Placeholder audio synthesis (`docs/07` §6): simple ADSR-shaped tones in
/// 16-bit mono WAV. Not music, not final: just audible stand-ins at every
/// manifest path.
abstract final class Wav {
  /// Low sample rate on purpose: placeholders stay tiny.
  static const int sampleRate = 11025;

  /// Encodes `-1..1` samples as a 16-bit PCM mono WAV file.
  static Uint8List encode(List<double> samples) {
    final dataLen = samples.length * 2;
    final b = ByteData(44 + dataLen)
      ..setUint32(0, 0x52494646) // "RIFF"
      ..setUint32(4, 36 + dataLen, Endian.little)
      ..setUint32(8, 0x57415645) // "WAVE"
      ..setUint32(12, 0x666d7420) // "fmt "
      ..setUint32(16, 16, Endian.little)
      ..setUint16(20, 1, Endian.little)
      ..setUint16(22, 1, Endian.little)
      ..setUint32(24, sampleRate, Endian.little)
      ..setUint32(28, sampleRate * 2, Endian.little)
      ..setUint16(32, 2, Endian.little)
      ..setUint16(34, 16, Endian.little)
      ..setUint32(36, 0x64617461) // "data"
      ..setUint32(40, dataLen, Endian.little);
    for (var i = 0; i < samples.length; i++) {
      final v = (samples[i].clamp(-1.0, 1.0) * 32000).round();
      b.setInt16(44 + i * 2, v, Endian.little);
    }
    return b.buffer.asUint8List();
  }

  /// Frequency in Hz of a note name like `C4`, `Fs5` (`s` = sharp).
  static double noteFrequency(String name) {
    const semis = {'C': 0, 'D': 2, 'E': 4, 'F': 5, 'G': 7, 'A': 9, 'B': 11};
    var i = 1;
    var s = semis[name[0]]!;
    if (name[i] == 's') {
      s += 1;
      i++;
    }
    final octave = int.parse(name.substring(i));
    final midi = 12 * (octave + 1) + s;
    return 440 * math.pow(2, (midi - 69) / 12).toDouble();
  }
}

/// Oscillator shapes of the placeholder voices.
enum Wave { sine, triangle, square, saw, noise }

/// One synthesized note / blip.
class Blip {
  const new({
    required this.start,
    required this.dur,
    required this.freq,
    this.freqEnd,
    this.wave = Wave.sine,
    this.amp = 0.5,
    this.decay = 4,
    this.attack = 0.004,
    this.harmonics = const [1],
  });

  /// Seconds from the start of the clip.
  final double start;
  final double dur;
  final double freq;

  /// If set, the frequency glides linearly to this over [dur].
  final double? freqEnd;
  final Wave wave;
  final double amp;

  /// Exponential decay rate (1/s).
  final double decay;
  final double attack;

  /// Relative amplitudes of harmonics 1, 2, 3, …
  final List<double> harmonics;
}

/// Renders [blips] into one clip of [seconds].
List<double> render(List<Blip> blips, double seconds, {int seed = 1}) {
  final n = (seconds * Wav.sampleRate).round();
  final out = List<double>.filled(n, 0);
  final rng = Mulberry32(seed);
  for (final b in blips) {
    final from = (b.start * Wav.sampleRate).round();
    final len = (b.dur * Wav.sampleRate).round();
    var phase = 0.0;
    for (var i = 0; i < len && from + i < n; i++) {
      final t = i / Wav.sampleRate;
      final f = b.freqEnd == null
          ? b.freq
          : b.freq + (b.freqEnd! - b.freq) * (i / len);
      phase += 2 * math.pi * f / Wav.sampleRate;
      var s = 0.0;
      if (b.wave == Wave.noise) {
        s = rng.nextDouble() * 2 - 1;
      } else {
        var hsum = 0.0;
        for (var h = 0; h < b.harmonics.length; h++) {
          final p = phase * (h + 1);
          final w = switch (b.wave) {
            Wave.sine => math.sin(p),
            Wave.triangle => 2 / math.pi * math.asin(math.sin(p)),
            Wave.square => math.sin(p) >= 0 ? 0.6 : -0.6,
            Wave.saw => 2 * ((p / (2 * math.pi)) % 1) - 1,
            Wave.noise => 0.0,
          };
          s += w * b.harmonics[h];
          hsum += b.harmonics[h];
        }
        s /= hsum;
      }
      final attack = t < b.attack ? t / b.attack : 1.0;
      final release = (len - i) < 220 ? (len - i) / 220 : 1.0;
      out[from + i] += s * b.amp * math.exp(-b.decay * t) * attack * release;
    }
  }
  return out;
}
