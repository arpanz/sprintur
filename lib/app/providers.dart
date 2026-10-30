import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../audio/cue_player.dart';
import '../timer/workout.dart';

/// Overridden in main with an initialised player, and in tests with a silent
/// one.
final cuePlayerProvider = Provider<CuePlayer>(
  (ref) => throw UnimplementedError('cuePlayerProvider must be overridden'),
);

/// The workout the home screen will start, edited live by the builder.
final workoutProvider = NotifierProvider<WorkoutNotifier, Workout>(
  WorkoutNotifier.new,
);

class WorkoutNotifier extends Notifier<Workout> {
  @override
  Workout build() => Workout.presets.first;

  void set(Workout workout) => state = workout;
}
