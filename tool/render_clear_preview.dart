// Renders what a level clear SOUNDS like to a WAV file, so you can listen
// without running the app (the Phase 5 acceptance needs human ears):
//
//   dart run tool/render_clear_preview.dart            # chapters 1-5, level 1
//   dart run tool/render_clear_preview.dart 3 7 14     # chapter 3, level 7, 14 arrows
//
// It plays the same notes the game plays: one melody note per freed arrow
// (350 ms apart, Flow harmony from the 4th tap on), then the cascade of the
// remaining notes 90 ms apart, the 2-bar flourish home and the chime.
// Output: build/audio_preview/ch<N>_l<M>.wav (placeholder samples, so the
// timbre is a sine; the notes and rhythm are the real ones).
import 'dart:io';
import 'dart:typed_data';

import 'package:arrowchime/core/audio/melody_player.dart';

// Mirror of TBFeedback in lib/app/theme/tokens.dart (that file needs Flutter).
const _cascadeMs = 90;
const _flourishGapMs = 150;
const _flourishMs = 110;
const _tapMs = 350;

void main(List<String> args) {
  final chapters = args.isNotEmpty ? [int.parse(args[0])] : [1, 2, 3, 4, 5];
  final level = args.length > 1 ? int.parse(args[1]) : 1;
  final arrows = args.length > 2 ? int.parse(args[2]) : 9;
  Directory('build/audio_preview').createSync(recursive: true);
  for (final chapter in chapters) {
    final out = render(chapter, level, arrows);
    final path = 'build/audio_preview/ch${chapter}_l$level.wav';
    File(path).writeAsBytesSync(out);
    stdout.writeln('wrote $path');
  }
}

Uint8List render(int chapter, int level, int arrows) {
  final player = MelodyPlayer.forLevel(chapter, level);
  final sound = player.sound;
  const rate = 11025;
  final cache = <String, List<double>>{};
  List<double> sample(int i) =>
      cache.putIfAbsent(sound.assetOf(i), () => _readWav(sound.assetOf(i)));

  final mix = List<double>.filled(rate * 30, 0);
  void play(int note, int atMs, double volume) {
    final s = sample(note);
    final start = atMs * rate ~/ 1000;
    for (var k = 0; k < s.length && start + k < mix.length; k++) {
      mix[start + k] += s[k] * volume;
    }
  }

  var t = 0;
  for (var n = 0; n < arrows; n++) {
    final flow = n >= 3 ? 2 + (n - 3) ~/ 2 : 1;
    final cue = player.next(flow: flow > 5 ? 5 : flow);
    play(cue.index, t, 0.8);
    for (final h in cue.harmony) {
      play(h, t, 0.35);
    }
    t += _tapMs;
  }
  for (final i in player.cascade()) {
    play(i, t, 0.8);
    t += _cascadeMs;
  }
  t += _flourishGapMs;
  for (final i in player.flourish()) {
    play(i, t, 0.8);
    t += _flourishMs;
  }
  // The chime: the high tonic, the way the game ends its clear.
  play(sound.tonics.last, t, 0.9);
  final length = (t + 1800) * rate ~/ 1000;
  return _writeWav(mix.sublist(0, length.clamp(0, mix.length)), rate);
}

List<double> _readWav(String path) {
  final bytes = File(path).readAsBytesSync();
  final data = ByteData.sublistView(bytes);
  var pos = 12;
  while (pos + 8 <= bytes.length) {
    final id = String.fromCharCodes(bytes.sublist(pos, pos + 4));
    final size = data.getUint32(pos + 4, Endian.little);
    if (id == 'data') {
      return [
        for (var i = 0; i < size ~/ 2; i++)
          data.getInt16(pos + 8 + i * 2, Endian.little) / 32768,
      ];
    }
    pos += 8 + size;
  }
  throw FormatException('no data chunk in $path');
}

Uint8List _writeWav(List<double> samples, int rate) {
  final dataLen = samples.length * 2;
  final b = ByteData(44 + dataLen)
    ..setUint32(0, 0x52494646)
    ..setUint32(4, 36 + dataLen, Endian.little)
    ..setUint32(8, 0x57415645)
    ..setUint32(12, 0x666d7420)
    ..setUint32(16, 16, Endian.little)
    ..setUint16(20, 1, Endian.little)
    ..setUint16(22, 1, Endian.little)
    ..setUint32(24, rate, Endian.little)
    ..setUint32(28, rate * 2, Endian.little)
    ..setUint16(32, 2, Endian.little)
    ..setUint16(34, 16, Endian.little)
    ..setUint32(36, 0x64617461)
    ..setUint32(40, dataLen, Endian.little);
  var peak = 0.0;
  for (final s in samples) {
    if (s.abs() > peak) peak = s.abs();
  }
  final gain = peak > 0.95 ? 0.95 / peak : 1.0;
  for (var i = 0; i < samples.length; i++) {
    b.setInt16(44 + i * 2, (samples[i] * gain * 32000).round(), Endian.little);
  }
  return b.buffer.asUint8List();
}
