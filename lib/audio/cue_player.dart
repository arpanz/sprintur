import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_soloud/flutter_soloud.dart';

import '../data/settings.dart';
import '../timer/session_engine.dart';

/// Plays the beep and haptic for each [Cue].
///
/// Tones are synthesised once at [open] and kept in memory, so playing one is
/// a single call into the native mixer with no file or decode work on the
/// timing path. The audio engine only runs between [open] and [close]: while
/// it runs it streams silence, which on iOS keeps the app alive in the
/// background, so it must not outlive a session.
class CuePlayer {
  final Map<Cue, AudioSource> _sources = {};
  bool muted = false;
  bool _open = false;
  Future<void> _previewing = Future.value();

  /// Applies from the next [open].
  BeepStyle style = BeepStyle.classic;

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

  Future<void> open() async {
    final soloud = SoLoud.instance;
    await _previewing;
    if (!soloud.isInitialized) await soloud.init();
    _open = true;
    _sources.clear();
    for (final entry in _tones.entries) {
      _sources[entry.key] = await soloud.loadMem(
        'cue-${style.name}-${entry.key.name}.wav',
        entry.value.toWav(style),
      );
    }
  }

  /// Plays the go beep in [preview] style outside a session, starting the
  /// engine just for it. Taps in quick succession play one after another.
  Future<void> preview(BeepStyle preview) {
    return _previewing = _previewing.then((_) async {
      if (_open) return;
      final soloud = SoLoud.instance;
      try {
        if (!soloud.isInitialized) await soloud.init();
        final tone = _tones[Cue.go]!;
        final source = await soloud.loadMem(
          'preview-${preview.name}.wav',
          tone.toWav(preview),
        );
        soloud.play(source);
        HapticFeedback.heavyImpact();
        await Future<void>.delayed(Duration(milliseconds: tone.ms + 80));
      } catch (e) {
        debugPrint('Beep preview failed: $e');
      } finally {
        if (!_open && soloud.isInitialized) soloud.deinit();
      }
    });
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

  Future<void> close() async {
    _open = false;
    _sources.clear();
    final soloud = SoLoud.instance;
    // deinit frees every loaded source along with the engine.
    if (soloud.isInitialized) soloud.deinit();
  }
}

class _Tone {
  const _Tone(this.hz, this.ms);

  final double hz;
  final int ms;

  static const _rate = 44100;

  /// 16-bit mono PCM WAV with a 4 ms attack and an exponential tail so it
  /// does not click. Classic is a sine with a little third harmonic so it
  /// cuts through wind and traffic; whistle is a higher pure tone with a
  /// slight warble; low is an octave down and rounder, easier on the ears.
  Uint8List toWav(BeepStyle style) {
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
      final wave = switch (style) {
        BeepStyle.classic =>
          (sin(2 * pi * hz * t) + 0.3 * sin(2 * pi * hz * 3 * t)) / 1.3,
        BeepStyle.whistle => sin(
          2 * pi * hz * 1.5 * t + 0.8 * sin(2 * pi * 7 * t),
        ),
        BeepStyle.low => (sin(pi * hz * t) + 0.5 * sin(2 * pi * hz * t)) / 1.5,
      };
      final env = i < attack ? i / attack : exp(-3.0 * (i - attack) / n);
      final sample = (wave * env * 0.9 * 32767).round();
      data.setInt16(44 + i * 2, sample, Endian.little);
    }
    return data.buffer.asUint8List();
  }
}
