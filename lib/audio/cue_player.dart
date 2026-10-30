import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_soloud/flutter_soloud.dart';

import '../timer/session_engine.dart';

/// Plays the beep and haptic for each [Cue].
///
/// Tones are synthesised once at [init] and kept in memory, so playing one is
/// a single call into the native mixer with no file or decode work on the
/// timing path.
class CuePlayer {
  final Map<Cue, AudioSource> _sources = {};
  bool muted = false;

  static const _tones = <Cue, _Tone>{
    Cue.countdown: _Tone(660, 120),
    Cue.marks: _Tone(520, 180),
    Cue.set: _Tone(520, 180),
    Cue.go: _Tone(1320, 450),
    Cue.split: _Tone(880, 90),
    Cue.pace: _Tone(1100, 300),
    Cue.finish: _Tone(990, 120),
    Cue.restTick: _Tone(660, 110),
    Cue.falseStart: _Tone(220, 600),
    Cue.done: _Tone(990, 500),
  };

  Future<void> init() async {
    final soloud = SoLoud.instance;
    if (!soloud.isInitialized) await soloud.init();
    for (final entry in _tones.entries) {
      _sources[entry.key] = await soloud.loadMem(
        'cue-${entry.key.name}.wav',
        entry.value.toWav(),
      );
    }
  }

  void play(Cue cue) {
    _haptic(cue);
    final source = _sources[cue];
    if (muted || source == null) return;
    try {
      SoLoud.instance.play(source);
    } catch (e) {
      debugPrint('Cue $cue failed to play: $e');
    }
  }

  void _haptic(Cue cue) {
    switch (cue) {
      case Cue.go:
      case Cue.falseStart:
        HapticFeedback.heavyImpact();
      case Cue.pace:
      case Cue.done:
        HapticFeedback.mediumImpact();
      default:
        HapticFeedback.lightImpact();
    }
  }

  Future<void> dispose() async {
    final soloud = SoLoud.instance;
    for (final source in _sources.values) {
      await soloud.disposeSource(source);
    }
    _sources.clear();
  }
}

class _Tone {
  const _Tone(this.hz, this.ms);

  final double hz;
  final int ms;

  static const _rate = 44100;

  /// 16-bit mono PCM WAV: a sine with a little third harmonic so it cuts
  /// through wind and traffic, with a 4 ms attack and an exponential tail so
  /// it does not click.
  Uint8List toWav() {
    final n = _rate * ms ~/ 1000;
    final data = ByteData(44 + n * 2);
    void ascii(int offset, String s) {
      for (var i = 0; i < s.length; i++) {
        data.setUint8(offset + i, s.codeUnitAt(i));
      }
    }

    ascii(0, 'RIFF');
    data.setUint32(4, 36 + n * 2, Endian.little);
    ascii(8, 'WAVE');
    ascii(12, 'fmt ');
    data.setUint32(16, 16, Endian.little);
    data.setUint16(20, 1, Endian.little);
    data.setUint16(22, 1, Endian.little);
    data.setUint32(24, _rate, Endian.little);
    data.setUint32(28, _rate * 2, Endian.little);
    data.setUint16(32, 2, Endian.little);
    data.setUint16(34, 16, Endian.little);
    ascii(36, 'data');
    data.setUint32(40, n * 2, Endian.little);

    const attack = _rate * 4 ~/ 1000;
    for (var i = 0; i < n; i++) {
      final t = i / _rate;
      final wave = sin(2 * pi * hz * t) + 0.3 * sin(2 * pi * hz * 3 * t);
      final env = i < attack ? i / attack : exp(-3.0 * (i - attack) / n);
      final sample = (wave / 1.3 * env * 0.9 * 32767).round();
      data.setInt16(44 + i * 2, sample, Endian.little);
    }
    return data.buffer.asUint8List();
  }
}
